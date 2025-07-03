// lib/screens/daily_log_screen.dart
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:gogofit_frontend/models/exercise_log.dart';
import 'package:gogofit_frontend/models/meal_data.dart';
import 'package:gogofit_frontend/models/notification_data.dart';
import 'package:gogofit_frontend/models/user_profile_data.dart';
import 'package:gogofit_frontend/screens/add_exercise_screen.dart';
import 'package:gogofit_frontend/screens/add_meal_manual_screen.dart';
import 'package:gogofit_frontend/screens/dashboard_screen.dart';
import 'package:gogofit_frontend/screens/edit_exercise_screen.dart'; // PERBAIKAN: Import halaman edit
import 'package:gogofit_frontend/screens/edit_meal_list_screen.dart';
import 'package:gogofit_frontend/screens/more_options_screen.dart';
import 'package:gogofit_frontend/screens/notifications_screen.dart';
import 'package:gogofit_frontend/screens/profile_detail_screen.dart';
import 'package:gogofit_frontend/screens/select_meal_screen.dart';
import 'package:gogofit_frontend/screens/food_scanner_screen.dart';
import 'package:gogofit_frontend/services/api_service.dart';
import 'package:intl/intl.dart';

class DailyLogScreen extends StatefulWidget {
  const DailyLogScreen({super.key});

  @override
  State<DailyLogScreen> createState() => _DailyLogScreenState();
}

class _DailyLogScreenState extends State<DailyLogScreen> {
  final Color primaryBlueNormal = const Color(0xFF015c91);
  final Color darkerBlue = const Color(0xFF002033);
  final Color lightBlueCardBackground = const Color(0xFFD9E7EF);
  final Color searchBarIconColor = const Color(0xFF6DCFF6);
  final Color white70Opacity = const Color.fromARGB(179, 255, 255, 255);
  final Color black25Opacity = const Color.fromARGB(25, 0, 0, 0);
  final Color black51Opacity = const Color.fromARGB(51, 0, 0, 0);
  final Color darkerBlue70Opacity = const Color.fromARGB(179, 0, 32, 51);
  final Color darkerBlue60Opacity = const Color.fromARGB(153, 0, 32, 51);
  final Color alertRedColor = const Color(0xFFEF5350);

  DateTime _selectedDate = DateTime.now();
  List<MealEntry> _foodLogs = [];
  List<ExerciseLog> _exerciseLogs = [];
  bool _isLoading = false;
  final ApiService _apiService = ApiService();

  @override
  void initState() {
    super.initState();
    _fetchDataForSelectedDate();
    currentUserProfile.addListener(_updateTargetValuesAndFetchData);
  }

  @override
  void dispose() {
    currentUserProfile.removeListener(_updateTargetValuesAndFetchData);
    super.dispose();
  }

  void _updateTargetValuesAndFetchData() {
    if (mounted) {
      setState(() {});
    }
    _fetchDataForSelectedDate();
  }

  Future<void> _fetchDataForSelectedDate() async {
    if (!mounted) return;
    setState(() {
      _isLoading = true;
    });
    try {
      final futureFoodLogs = _apiService.getFoodLogs(date: _selectedDate);
      final futureExerciseLogs = _apiService.getExerciseLogs(
        date: _selectedDate,
      );

      final results = await Future.wait([futureFoodLogs, futureExerciseLogs]);

      if (!mounted) return;
      setState(() {
        _foodLogs = results[0] as List<MealEntry>;
        _exerciseLogs = results[1] as List<ExerciseLog>;
      });
    } catch (e) {
      debugPrint("Error fetching daily logs: $e");
      if (!mounted) return;
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('Gagal memuat data harian: $e')));
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  Future<void> _selectDate(BuildContext context) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: _selectedDate,
      firstDate: DateTime(2020),
      lastDate: DateTime.now().add(const Duration(days: 365)),
      builder: (BuildContext context, Widget? child) {
        return Theme(
          data: ThemeData.light().copyWith(
            colorScheme: ColorScheme.light(
              primary: primaryBlueNormal,
              onPrimary: Colors.white,
              surface: Colors.white,
              onSurface: darkerBlue,
            ),
            textButtonTheme: TextButtonThemeData(
              style: TextButton.styleFrom(
                foregroundColor: primaryBlueNormal,
                textStyle: const TextStyle(fontFamily: 'Poppins'),
              ),
            ),
          ),
          child: child!,
        );
      },
    );
    if (picked != null && picked != _selectedDate) {
      setState(() {
        _selectedDate = picked;
      });
      await _fetchDataForSelectedDate();
    }
  }

  void _goToPreviousDay() async {
    setState(() {
      _selectedDate = _selectedDate.subtract(const Duration(days: 1));
    });
    await _fetchDataForSelectedDate();
  }

  void _goToNextDay() async {
    setState(() {
      _selectedDate = _selectedDate.add(const Duration(days: 1));
    });
    await _fetchDataForSelectedDate();
  }

  String _formatDate(DateTime date) {
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final yesterday = today.subtract(const Duration(days: 1));
    final dateOnly = DateTime(date.year, date.month, date.day);

    if (dateOnly == today) {
      return 'Hari ini';
    } else if (dateOnly == yesterday) {
      return 'Kemarin';
    } else {
      return DateFormat('dd MMMM yyyy', 'id').format(date);
    }
  }

  Future<void> _deleteExerciseLog(int logId) async {
    final bool? confirmDelete = await showDialog<bool>(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Hapus Latihan'),
          content: const Text('Anda yakin ingin menghapus log latihan ini?'),
          actions: <Widget>[
            TextButton(
              child: const Text('Batal'),
              onPressed: () => Navigator.of(context).pop(false),
            ),
            TextButton(
              child: const Text('Hapus', style: TextStyle(color: Colors.red)),
              onPressed: () => Navigator.of(context).pop(true),
            ),
          ],
        );
      },
    );

    if (confirmDelete == true) {
      try {
        final response = await _apiService.deleteExerciseLog(logId);
        if (!mounted) return;

        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(response['message'] ?? 'Proses selesai.'),
            backgroundColor: response['success'] ? Colors.green : Colors.red,
          ),
        );

        if (response['success']) {
          _fetchDataForSelectedDate();
        }
      } catch (e) {
        if (!mounted) return;
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Terjadi kesalahan: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  Future<void> _navigateToEditExerciseScreen(ExerciseLog exerciseLog) async {
    final result = await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => EditExerciseScreen(exerciseLog: exerciseLog),
      ),
    );
    if (result == true) {
      _fetchDataForSelectedDate();
    }
  }

  @override
  Widget build(BuildContext context) {
    final double targetDailyCalories =
        currentUserProfile.value.calculatedTargetCalories;
    final double targetDailySugar =
        currentUserProfile.value.calculatedTargetSugar;
    final double totalCaloriesConsumed = _foodLogs.fold(
      0.0,
      (sum, meal) => sum + meal.calories,
    );
    final double totalSugarConsumed = _foodLogs.fold(
      0.0,
      (sum, meal) => sum + meal.sugar,
    );
    final double totalExerciseCalories = _exerciseLogs.fold(
      0.0,
      (sum, log) => sum + log.caloriesBurned,
    );

    double remainingCalories =
        targetDailyCalories - totalCaloriesConsumed + totalExerciseCalories;
    double remainingSugar = targetDailySugar - totalSugarConsumed;

    String calorieUnit = 'Sisa';
    Color calorieValueColor = darkerBlue;
    if (remainingCalories < 0) {
      calorieUnit = 'Kelebihan';
      remainingCalories = remainingCalories.abs();
      calorieValueColor = alertRedColor;
    }

    String sugarUnit = 'Sisa';
    Color sugarValueColor = darkerBlue;
    if (remainingSugar < 0) {
      sugarUnit = 'Kelebihan';
      remainingSugar = remainingSugar.abs();
      sugarValueColor = alertRedColor;
    }

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        scrolledUnderElevation: 0.0,
        shadowColor: Colors.transparent,
        leading: IconButton(
          icon: Icon(Icons.person, color: primaryBlueNormal, size: 28),
          onPressed: () {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => const ProfileDetailScreen(),
              ),
            );
          },
        ),
        title: Text(
          'GOGOFIT',
          style: TextStyle(
            color: darkerBlue,
            fontSize: 24,
            fontWeight: FontWeight.bold,
            fontFamily: 'Poppins',
          ),
        ),
        centerTitle: true,
        actions: [
          ValueListenableBuilder<List<AppNotification>>(
            valueListenable: appNotifications,
            builder: (context, notifications, child) {
              final int unreadCount = getUnreadNotificationCount();
              return Stack(
                children: [
                  IconButton(
                    icon: Icon(
                      Icons.notifications,
                      color: primaryBlueNormal,
                      size: 28,
                    ),
                    onPressed: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => const NotificationsScreen(),
                        ),
                      );
                    },
                  ),
                  if (unreadCount > 0)
                    Positioned(
                      right: 8,
                      top: 8,
                      child: Container(
                        padding: const EdgeInsets.all(2),
                        decoration: BoxDecoration(
                          color: alertRedColor,
                          borderRadius: BorderRadius.circular(6),
                        ),
                        constraints: const BoxConstraints(
                          minWidth: 12,
                          minHeight: 12,
                        ),
                        child: Text(
                          unreadCount.toString(),
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 8,
                            fontFamily: 'Poppins',
                          ),
                          textAlign: TextAlign.center,
                        ),
                      ),
                    ),
                ],
              );
            },
          ),
        ],
      ),
      body:
          _isLoading
              ? const Center(
                child: CircularProgressIndicator(color: Colors.blueAccent),
              )
              : SingleChildScrollView(
                child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          IconButton(
                            icon: Icon(
                              Icons.arrow_back_ios,
                              color: darkerBlue,
                              size: 20,
                            ),
                            onPressed: _goToPreviousDay,
                          ),
                          GestureDetector(
                            onTap: () => _selectDate(context),
                            child: Row(
                              children: [
                                Text(
                                  _formatDate(_selectedDate),
                                  style: TextStyle(
                                    fontSize: 22,
                                    fontWeight: FontWeight.bold,
                                    color: darkerBlue,
                                    fontFamily: 'Poppins',
                                  ),
                                ),
                                const SizedBox(width: 8),
                                Icon(
                                  Icons.calendar_today,
                                  color: darkerBlue,
                                  size: 20,
                                ),
                              ],
                            ),
                          ),
                          IconButton(
                            icon: Icon(
                              Icons.arrow_forward_ios,
                              color: darkerBlue,
                              size: 20,
                            ),
                            onPressed: _goToNextDay,
                          ),
                        ],
                      ),
                      const SizedBox(height: 16),
                      _buildSummaryCard(
                        title: 'Sisa Kalori',
                        data: [
                          {
                            'label': 'Sasaran',
                            'value': targetDailyCalories.toStringAsFixed(0),
                          },
                          {
                            'label': 'Makanan',
                            'value': totalCaloriesConsumed.toStringAsFixed(0),
                          },
                          {
                            'label': 'Latihan',
                            'value': totalExerciseCalories.toStringAsFixed(0),
                          },
                          {
                            'label': 'Sisa',
                            'value': remainingCalories.toStringAsFixed(0),
                            'isResult': true,
                          },
                        ],
                        mainColor: lightBlueCardBackground,
                        darkerTextColor: darkerBlue,
                        valueColorForSummary: calorieValueColor,
                        unitForSummary: calorieUnit,
                      ),
                      const SizedBox(height: 16),
                      _buildSummaryCard(
                        title: 'Sisa Gula',
                        data: [
                          {
                            'label': 'Sasaran',
                            'value':
                                '${targetDailySugar.toStringAsFixed(1)} gram',
                          },
                          {
                            'label': 'Makanan',
                            'value': totalSugarConsumed.toStringAsFixed(1),
                          },
                          {
                            'label': 'Sisa',
                            'value': remainingSugar.toStringAsFixed(1),
                            'isResult': true,
                          },
                        ],
                        mainColor: lightBlueCardBackground,
                        darkerTextColor: darkerBlue,
                        valueColorForSummary: sugarValueColor,
                        unitForSummary: sugarUnit,
                      ),
                      const SizedBox(height: 24),
                      _buildExerciseSection(context, _exerciseLogs),
                      const SizedBox(height: 24),
                      _buildMealSection(
                        context,
                        'Sarapan',
                        _foodLogs
                            .where((meal) => meal.mealType == 'Sarapan')
                            .toList(),
                      ),
                      const SizedBox(height: 16),
                      _buildMealSection(
                        context,
                        'Makan Siang',
                        _foodLogs
                            .where((meal) => meal.mealType == 'Makan Siang')
                            .toList(),
                      ),
                      const SizedBox(height: 16),
                      _buildMealSection(
                        context,
                        'Makan Malam',
                        _foodLogs
                            .where((meal) => meal.mealType == 'Makan Malam')
                            .toList(),
                      ),
                      const SizedBox(height: 16),
                      _buildMealSection(
                        context,
                        'Camilan',
                        _foodLogs
                            .where((meal) => meal.mealType == 'Camilan')
                            .toList(),
                      ),
                      const SizedBox(height: 100),
                    ],
                  ),
                ),
              ),
      bottomNavigationBar: Container(
        height: 170,
        color: Colors.transparent,
        child: Stack(
          alignment: Alignment.bottomCenter,
          children: [
            Positioned(
              bottom: 0,
              left: 0,
              right: 0,
              child: SvgPicture.asset(
                'assets/images/bottom_wave_nav.svg',
                fit: BoxFit.fill,
                colorFilter: ColorFilter.mode(
                  primaryBlueNormal,
                  BlendMode.srcIn,
                ),
                height: 170,
              ),
            ),
            Positioned(
              bottom: 0,
              left: 0,
              right: 0,
              child: BottomNavigationBar(
                backgroundColor: Colors.transparent,
                elevation: 0,
                selectedItemColor: Colors.white,
                unselectedItemColor: white70Opacity,
                selectedLabelStyle: const TextStyle(
                  fontFamily: 'Poppins',
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                ),
                unselectedLabelStyle: TextStyle(
                  fontFamily: 'Poppins',
                  color: white70Opacity,
                ),
                showUnselectedLabels: true,
                items: const [
                  BottomNavigationBarItem(
                    icon: Icon(Icons.dashboard),
                    label: 'Dasbor',
                  ),
                  BottomNavigationBarItem(
                    icon: Icon(Icons.menu_book),
                    label: 'Buku Harian',
                  ),
                  BottomNavigationBarItem(
                    icon: Icon(Icons.more_horiz),
                    label: 'Lainnya',
                  ),
                ],
                currentIndex: 1,
                onTap: (index) {
                  if (index == 0) {
                    Navigator.pushReplacement(
                      context,
                      MaterialPageRoute(
                        builder: (context) => const DashboardScreen(),
                      ),
                    );
                  } else if (index == 1) {
                    debugPrint('Already on DailyLogScreen');
                  } else if (index == 2) {
                    Navigator.pushReplacement(
                      context,
                      MaterialPageRoute(
                        builder: (context) => const MoreOptionsScreen(),
                      ),
                    );
                  }
                },
              ),
            ),
            Positioned(
              bottom: 95,
              left: 40,
              right: 40,
              child: Container(
                // <-- UBAH DARI GestureDetector MENJADI Container
                height: 40.0,
                padding: const EdgeInsets.symmetric(horizontal: 16.0),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(30.0),
                  boxShadow: [
                    BoxShadow(
                      color: black25Opacity,
                      blurRadius: 10,
                      offset: const Offset(0, 5),
                    ),
                  ],
                ),
                child: Row(
                  children: [
                    Icon(Icons.search, color: searchBarIconColor, size: 20),
                    const SizedBox(width: 8),
                    Expanded(
                      child: TextField(
                        readOnly: true,
                        onTap: () {
                          // <-- NAVIGASI KE SELECT_MEAL_SCREEN
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => const SelectMealScreen(),
                            ),
                          );
                        },
                        decoration: InputDecoration(
                          hintText: 'Cari Makanan',
                          hintStyle: TextStyle(
                            color: Colors.grey.shade600,
                            fontFamily: 'Poppins',
                            fontSize: 14,
                          ),
                          border: InputBorder.none,
                          isDense: true,
                          contentPadding: EdgeInsets.zero,
                        ),
                        style: const TextStyle(
                          fontFamily: 'Poppins',
                          fontSize: 14,
                        ),
                        textAlignVertical: TextAlignVertical.center,
                      ),
                    ),
                    IconButton(
                      // <-- NAVIGASI KE FOOD_SCANNER_SCREEN
                      icon: Icon(
                        Icons.camera_alt,
                        color: searchBarIconColor,
                        size: 30,
                      ),
                      onPressed: () {
                        // Pergi ke FoodScannerScreen saat ikon kamera ditekan
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => const FoodScannerScreen(),
                          ),
                        );
                      },
                      padding: EdgeInsets.zero,
                      constraints: const BoxConstraints(),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSummaryCard({
    required String title,
    required List<Map<String, dynamic>> data,
    required Color mainColor,
    required Color darkerTextColor,
    Color? valueColorForSummary,
    String? unitForSummary,
  }) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16.0),
      decoration: BoxDecoration(
        color: mainColor,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: black51Opacity,
            blurRadius: 10,
            offset: const Offset(0, 5),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
              color: darkerTextColor,
              fontFamily: 'Poppins',
            ),
          ),
          const SizedBox(height: 16),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children:
                data.map((item) {
                  bool isResult = item['isResult'] ?? false;
                  return Column(
                    children: [
                      Text(
                        item['value'].toString(),
                        style: TextStyle(
                          fontSize: isResult ? 28 : 18,
                          fontWeight:
                              isResult ? FontWeight.bold : FontWeight.normal,
                          color:
                              isResult
                                  ? (valueColorForSummary ?? darkerTextColor)
                                  : darkerBlue70Opacity,
                          fontFamily: 'Poppins',
                        ),
                      ),
                      Text(
                        isResult
                            ? (unitForSummary ?? item['label'].toString())
                            : item['label'].toString(),
                        style: TextStyle(
                          fontSize: 14,
                          color:
                              isResult
                                  ? (valueColorForSummary ?? darkerTextColor)
                                  : darkerBlue60Opacity,
                          fontFamily: 'Poppins',
                        ),
                      ),
                    ],
                  );
                }).toList(),
          ),
        ],
      ),
    );
  }

  Widget _buildMealSection(
    BuildContext context,
    String mealType,
    List<MealEntry> meals,
  ) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16.0),
      decoration: BoxDecoration(
        color: lightBlueCardBackground,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: black51Opacity,
            blurRadius: 10,
            offset: const Offset(0, 5),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                mealType,
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                  color: darkerBlue,
                  fontFamily: 'Poppins',
                ),
              ),
              IconButton(
                icon: Icon(Icons.edit, color: darkerBlue70Opacity, size: 20),
                onPressed: () async {
                  // Tangkap hasil dari Navigator.pop
                  final bool? result = await Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder:
                          (context) => EditMealListScreen(
                            mealType: mealType,
                            selectedDate: _selectedDate,
                          ),
                    ),
                  );
                  if (result == true) {
                    _fetchDataForSelectedDate();
                  }
                },
              ),
            ],
          ),
          const SizedBox(height: 10),
          if (meals.isEmpty)
            Text(
              'Belum ada makanan dicatat untuk $mealType.',
              style: TextStyle(
                fontSize: 14,
                color: darkerBlue60Opacity,
                fontFamily: 'Poppins',
              ),
            )
          else
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children:
                  meals.map((meal) {
                    return Padding(
                      padding: const EdgeInsets.symmetric(vertical: 4.0),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            meal.name,
                            style: TextStyle(
                              fontSize: 16,
                              color: darkerBlue,
                              fontFamily: 'Poppins',
                            ),
                          ),
                          Text(
                            '${meal.calories.toStringAsFixed(1)} kkal',
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                              color: darkerBlue,
                              fontFamily: 'Poppins',
                            ),
                          ),
                        ],
                      ),
                    );
                  }).toList(),
            ),
          const SizedBox(height: 10),
          SizedBox(
            width: double.infinity,
            child: TextButton.icon(
              onPressed: () async {
                debugPrint('Tambah Makanan untuk $mealType');
                // Tangkap hasil dari Navigator.pop
                final bool? result = await Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder:
                        (context) => AddMealManualScreen(
                          initialMealType: mealType,
                          selectedDate:
                              _selectedDate, // Pastikan meneruskan tanggal saat ini
                        ),
                  ),
                );
                // Jika result adalah true, berarti ada perubahan, maka refresh data
                if (result == true) {
                  _fetchDataForSelectedDate();
                }
              },
              icon: Icon(
                Icons.add_circle_outline,
                color: primaryBlueNormal,
                size: 24,
              ),
              label: Text(
                'TAMBAH MAKANAN',
                style: TextStyle(
                  color: primaryBlueNormal,
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  fontFamily: 'Poppins',
                ),
              ),
              style: TextButton.styleFrom(
                padding: const EdgeInsets.symmetric(vertical: 12),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8),
                  side: BorderSide(color: primaryBlueNormal.withAlpha(128)),
                ),
                backgroundColor: Colors.white,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildExerciseSection(
    BuildContext context,
    List<ExerciseLog> exercises,
  ) {
    final double totalCalories = exercises.fold(
      0.0,
      (sum, ex) => sum + ex.caloriesBurned,
    );

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16.0),
      decoration: BoxDecoration(
        color: lightBlueCardBackground,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: black51Opacity,
            blurRadius: 10,
            offset: const Offset(0, 5),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Latihan',
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                  color: darkerBlue,
                  fontFamily: 'Poppins',
                ),
              ),
              Text(
                '${totalCalories.toStringAsFixed(0)} kkal',
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                  color: darkerBlue,
                  fontFamily: 'Poppins',
                ),
              ),
            ],
          ),
          const SizedBox(height: 10),
          if (exercises.isEmpty)
            Text(
              'Belum ada latihan dicatat.',
              style: TextStyle(
                fontSize: 14,
                color: darkerBlue60Opacity,
                fontFamily: 'Poppins',
              ),
            )
          else
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children:
                  exercises.map((ex) {
                    return Padding(
                      padding: const EdgeInsets.symmetric(vertical: 2.0),
                      child: Row(
                        children: [
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  ex.activityName,
                                  style: TextStyle(
                                    fontSize: 16,
                                    color: darkerBlue,
                                    fontFamily: 'Poppins',
                                  ),
                                  overflow: TextOverflow.ellipsis,
                                ),
                                Text(
                                  '${ex.durationMinutes} menit',
                                  style: TextStyle(
                                    fontSize: 12,
                                    color: darkerBlue60Opacity,
                                    fontFamily: 'Poppins',
                                  ),
                                ),
                              ],
                            ),
                          ),
                          Text(
                            '${ex.caloriesBurned} kkal',
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                              color: darkerBlue,
                              fontFamily: 'Poppins',
                            ),
                          ),
                          IconButton(
                            icon: Icon(
                              Icons.edit_note,
                              color: darkerBlue70Opacity,
                            ),
                            onPressed: () => _navigateToEditExerciseScreen(ex),
                            visualDensity: VisualDensity.compact,
                            padding: const EdgeInsets.all(4),
                          ),
                          IconButton(
                            icon: Icon(
                              Icons.delete_outline,
                              color: alertRedColor,
                            ),
                            onPressed: () => _deleteExerciseLog(ex.id),
                            visualDensity: VisualDensity.compact,
                            padding: const EdgeInsets.all(4),
                          ),
                        ],
                      ),
                    );
                  }).toList(),
            ),
          const SizedBox(height: 10),
          SizedBox(
            width: double.infinity,
            child: TextButton.icon(
              onPressed: () async {
                final result = await Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder:
                        (context) =>
                            AddExerciseScreen(selectedDate: _selectedDate),
                  ),
                );
                if (result == true) {
                  _fetchDataForSelectedDate();
                }
              },
              icon: Icon(
                Icons.add_circle_outline,
                color: primaryBlueNormal,
                size: 24,
              ),
              label: Text(
                'TAMBAH LATIHAN',
                style: TextStyle(
                  color: primaryBlueNormal,
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  fontFamily: 'Poppins',
                ),
              ),
              style: TextButton.styleFrom(
                padding: const EdgeInsets.symmetric(vertical: 12),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8),
                  side: BorderSide(color: primaryBlueNormal.withAlpha(128)),
                ),
                backgroundColor: Colors.white,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
