import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:gogofit_frontend/screens/select_meal_screen.dart';
import 'package:gogofit_frontend/models/meal_data.dart';
import 'package:gogofit_frontend/screens/add_meal_manual_screen.dart';
import 'package:gogofit_frontend/screens/dashboard_screen.dart';
import 'package:gogofit_frontend/screens/edit_meal_list_screen.dart';
import 'package:gogofit_frontend/screens/more_options_screen.dart';
import 'package:gogofit_frontend/models/notification_data.dart'; // Import notification_data.dart
import 'package:gogofit_frontend/screens/notifications_screen.dart'; // Import NotificationsScreen

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

  @override
  void initState() {
    super.initState();
    userMeals.addListener(_updateScreen);
    // addDummyNotifications(); // Pastikan sudah dipanggil di main.dart
  }

  @override
  void dispose() {
    userMeals.removeListener(_updateScreen);
    super.dispose();
  }

  void _updateScreen() {
    setState(() {
      // Rebuild UI saat data userMeals berubah
    });
  }

  Future<void> _selectDate(BuildContext context) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: _selectedDate,
      firstDate: DateTime(2020),
      lastDate: DateTime(2030),
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
    }
  }

  void _goToPreviousDay() {
    setState(() {
      _selectedDate = _selectedDate.subtract(const Duration(days: 1));
    });
  }

  void _goToNextDay() {
    setState(() {
      _selectedDate = _selectedDate.add(const Duration(days: 1));
    });
  }

  String _formatDate(DateTime date) {
    if (date.day == DateTime.now().day &&
        date.month == DateTime.now().month &&
        date.year == DateTime.now().year) {
      return 'Hari ini';
    } else if (date.day ==
            DateTime.now().subtract(const Duration(days: 1)).day &&
        date.month == DateTime.now().month &&
        date.year == DateTime.now().year) {
      return 'Kemarin';
    } else {
      return '${date.day}/${date.month}/${date.year}';
    }
  }

  @override
  Widget build(BuildContext context) {
    return ValueListenableBuilder<List<MealEntry>>(
      valueListenable: userMeals,
      builder: (context, allMeals, child) {
        final List<MealEntry> mealsForSelectedDate =
            allMeals
                .where(
                  (meal) =>
                      meal.timestamp.year == _selectedDate.year &&
                      meal.timestamp.month == _selectedDate.month &&
                      meal.timestamp.day == _selectedDate.day,
                )
                .toList();

        final double totalCaloriesConsumed = mealsForSelectedDate.fold(
          // UBAH: dari int menjadi double
          0.0, // UBAH: dari 0 menjadi 0.0
          (sum, meal) => sum + meal.calories,
        );
        final double totalSugarConsumed = mealsForSelectedDate.fold(
          0.0,
          (sum, meal) => sum + meal.sugar,
        );

        const double targetCalories = 1340.0; // UBAH: dari int menjadi double
        const double exerciseCalories = 190.0; // UBAH: dari int menjadi double
        const double targetSugar = 30.0;

        double remainingCalories = // UBAH: dari int menjadi double
            targetCalories - totalCaloriesConsumed + exerciseCalories;
        double remainingSugar = targetSugar - totalSugarConsumed;

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
                debugPrint('Navigasi ke halaman Profil');
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
              // Stack untuk ikon lonceng dan badge notifikasi
              ValueListenableBuilder<List<AppNotification>>(
                // <<<--- DIUBAH: Menggunakan ValueListenableBuilder di sini
                valueListenable: appNotifications,
                builder: (context, notifications, child) {
                  final int unreadCount =
                      getUnreadNotificationCount(); // Ambil jumlah belum dibaca
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
                      if (unreadCount >
                          0) // Tampilkan badge jika ada notifikasi belum dibaca
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
          body: SingleChildScrollView(
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Bagian Navigasi Tanggal
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

                  // Kartu Sisa Kalori
                  _buildSummaryCard(
                    title: 'Sisa Kalori',
                    data: [
                      {
                        'label': 'Sasaran',
                        'value': targetCalories.toStringAsFixed(0),
                      }, // UBAH: Format desimal
                      {
                        'label': 'Makanan',
                        'value': totalCaloriesConsumed.toStringAsFixed(
                          0,
                        ), // UBAH: Format desimal
                      },
                      {
                        'label': 'Latihan',
                        'value': exerciseCalories.toStringAsFixed(
                          0,
                        ), // UBAH: Format desimal
                      },
                      {
                        'label': 'Sisa',
                        'value': remainingCalories.toStringAsFixed(
                          0,
                        ), // UBAH: Format desimal
                        'isResult': true,
                      },
                    ],
                    mainColor: lightBlueCardBackground,
                    darkerTextColor: darkerBlue,
                    valueColorForSummary:
                        calorieValueColor, // Mengirim warna nilai sisa/kelebihan
                    unitForSummary: calorieUnit, // Mengirim unit sisa/kelebihan
                  ),
                  const SizedBox(height: 16),

                  // Kartu Sisa Gula
                  _buildSummaryCard(
                    title: 'Sisa Gula',
                    data: [
                      {
                        'label': 'Sasaran',
                        'value':
                            '${targetSugar.toStringAsFixed(1)} gram', // UBAH: Format desimal
                      },
                      {
                        'label': 'Makanan',
                        'value': totalSugarConsumed.toStringAsFixed(
                          1,
                        ), // UBAH: Format desimal
                      },
                      {
                        'label': 'Sisa',
                        'value': remainingSugar.toStringAsFixed(
                          1,
                        ), // UBAH: Format desimal
                        'isResult': true,
                      },
                    ],
                    mainColor: lightBlueCardBackground,
                    darkerTextColor: darkerBlue,
                    valueColorForSummary:
                        sugarValueColor, // Mengirim warna nilai sisa/kelebihan
                    unitForSummary: sugarUnit, // Mengirim unit sisa/kelebihan
                  ),
                  const SizedBox(height: 24),

                  // Bagian Daftar Makanan per Santapan
                  _buildMealSection(
                    context,
                    'Sarapan',
                    mealsForSelectedDate
                        .where((meal) => meal.mealType == 'Sarapan')
                        .toList(),
                  ),
                  const SizedBox(height: 16),
                  _buildMealSection(
                    context,
                    'Makan Siang',
                    mealsForSelectedDate
                        .where((meal) => meal.mealType == 'Makan Siang')
                        .toList(),
                  ),
                  const SizedBox(height: 16),
                  _buildMealSection(
                    context,
                    'Makan Malam',
                    mealsForSelectedDate
                        .where((meal) => meal.mealType == 'Makan Malam')
                        .toList(),
                  ),
                  const SizedBox(height: 16),
                  _buildMealSection(
                    context,
                    'Camilan',
                    mealsForSelectedDate
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
                // Wave background using SVG asset
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
                // Bottom Navigation Bar
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
                    currentIndex:
                        1, // Atur currentIndex ke 1 untuk DailyLogScreen
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
                // Search bar (diposisikan sama dengan Dashboard)
                Positioned(
                  bottom: 95,
                  left: 40,
                  right: 40,
                  child: GestureDetector(
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => const SelectMealScreen(),
                        ),
                      );
                    },
                    child: Container(
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
                          Icon(
                            Icons.search,
                            color: searchBarIconColor,
                            size: 20,
                          ),
                          const SizedBox(width: 8),
                          Expanded(
                            child: TextField(
                              readOnly: true,
                              onTap: () {
                                Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder:
                                        (context) => const SelectMealScreen(),
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
                            icon: Icon(
                              Icons.camera_alt,
                              color: searchBarIconColor,
                              size: 30,
                            ),
                            onPressed: () {
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder:
                                      (context) => const SelectMealScreen(),
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
                ),
              ],
            ),
          ),
        );
      },
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
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder:
                          (context) => EditMealListScreen(
                            mealType: mealType,
                            selectedDate: _selectedDate,
                          ),
                    ),
                  );
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
                            '${meal.calories.toStringAsFixed(1)} kkal', // UBAH: Format desimal
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
              onPressed: () {
                debugPrint('Tambah Makanan untuk $mealType');
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder:
                        (context) =>
                            AddMealManualScreen(initialMealType: mealType),
                  ),
                );
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
                  side: BorderSide(
                    color: Color.fromARGB((255 * 0.5).round(), 1, 92, 145),
                  ),
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
