import 'package:flutter/material.dart';
import 'dart:math' as math;
import 'package:flutter_svg/flutter_svg.dart';
import 'package:gogofit_frontend/models/exercise_log.dart'; // BARU
import 'package:gogofit_frontend/screens/add_exercise_screen.dart'; // BARU
import 'package:gogofit_frontend/screens/select_meal_screen.dart';
import 'package:gogofit_frontend/models/meal_data.dart';
import 'package:gogofit_frontend/screens/daily_log_screen.dart';
import 'package:gogofit_frontend/screens/more_options_screen.dart';
import 'package:gogofit_frontend/models/notification_data.dart';
import 'package:gogofit_frontend/screens/notifications_screen.dart';
import 'package:gogofit_frontend/models/user_profile_data.dart';
import 'package:gogofit_frontend/services/api_service.dart'; // BARU

class DashboardScreen extends StatefulWidget {
  const DashboardScreen({super.key});

  @override
  State<DashboardScreen> createState() => _DashboardScreenState();
}

class _DashboardScreenState extends State<DashboardScreen> {
  final Color primaryBlueNormal = const Color(0xFF015c91);
  final Color darkerBlue = const Color(0xFF002033);
  final Color orangeColor = const Color(0xFFF2A900);
  final Color sugarArcNewColor = const Color(0xFF4CAF50); // Hijau terang
  final Color searchBarIconColor = const Color(0xFF6DCFF6);
  final Color white70Opacity = const Color.fromARGB(179, 255, 255, 255);
  final Color white20Opacity = const Color.fromARGB(51, 255, 255, 255);
  final Color black25Opacity = const Color.fromARGB(25, 0, 0, 0);
  final Color black51Opacity = const Color.fromARGB(51, 0, 0, 0);
  final Color alertRedColor = const Color(0xFFEF5350);
  final Color successGreenColor = const Color(0xFF4CAF50);

  // BARU: State untuk data dinamis
  final ApiService _apiService = ApiService();
  List<MealEntry> _foodLogs = [];
  List<ExerciseLog> _exerciseLogs = [];
  bool _isLoading = true;

  final double _calorieTolerance = 50.0;
  final double _sugarTolerance = 0.0;

  @override
  void initState() {
    super.initState();
    _fetchDataForToday();
    currentUserProfile.addListener(_handleProfileChange);
  }

  @override
  void dispose() {
    currentUserProfile.removeListener(_handleProfileChange);
    super.dispose();
  }

  void _handleProfileChange() {
    if (mounted) {
      setState(() {});
    }
  }

  Future<void> _fetchDataForToday() async {
    if (!mounted) return;
    // Tidak set _isLoading jika ini adalah refresh, agar tidak ada lompatan UI
    if (_foodLogs.isEmpty && _exerciseLogs.isEmpty) {
      setState(() => _isLoading = true);
    }

    try {
      final today = DateTime.now();
      final futureFoodLogs = _apiService.getFoodLogs(date: today);
      final futureExerciseLogs = _apiService.getExerciseLogs(date: today);

      final results = await Future.wait([futureFoodLogs, futureExerciseLogs]);

      if (!mounted) return;
      setState(() {
        _foodLogs = results[0] as List<MealEntry>;
        _exerciseLogs = results[1] as List<ExerciseLog>;
      });
    } catch (e) {
      debugPrint("Error fetching dashboard data: $e");
      if (!mounted) return;
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('Gagal memuat data dasbor: $e')));
    } finally {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final double targetDailyCalories =
        currentUserProfile.value.calculatedTargetCalories;
    final double targetDailySugar =
        currentUserProfile.value.calculatedTargetSugar;

    final double currentCaloriesConsumed = _foodLogs.fold(
      0.0,
      (sum, meal) => sum + meal.calories,
    );
    final double currentSugarConsumed = _foodLogs.fold(
      0.0,
      (sum, meal) => sum + meal.sugar,
    );
    final double burnedCaloriesFromExercise = _exerciseLogs.fold(
      0.0,
      (sum, log) => sum + log.caloriesBurned,
    );

    double netCalories = currentCaloriesConsumed - burnedCaloriesFromExercise;

    double caloriePercentage = 0.0;
    if (targetDailyCalories > 0) {
      caloriePercentage = (netCalories.clamp(0.0, double.infinity) /
              targetDailyCalories)
          .clamp(0.0, 1.0);
    }

    double sugarPercentage = 0.0;
    if (targetDailySugar > 0) {
      sugarPercentage = (currentSugarConsumed / targetDailySugar).clamp(
        0.0,
        1.0,
      );
    }

    String calorieUnit;
    String calorieValue;
    Color calorieValueColor;
    if (netCalories >= targetDailyCalories - _calorieTolerance &&
        netCalories <= targetDailyCalories + _calorieTolerance) {
      calorieUnit = 'Tercapai!';
      calorieValue = '0';
      calorieValueColor = successGreenColor;
    } else if (netCalories > targetDailyCalories + _calorieTolerance) {
      calorieUnit = 'Kelebihan';
      calorieValue = (netCalories - targetDailyCalories).toStringAsFixed(0);
      calorieValueColor = alertRedColor;
    } else {
      calorieUnit = 'Sisa';
      calorieValue = (targetDailyCalories - netCalories).toStringAsFixed(0);
      calorieValueColor = Colors.white;
    }

    String sugarUnit;
    String sugarValue;
    Color sugarValueColor;
    double remainingSugarCalc = targetDailySugar - currentSugarConsumed;
    if ((currentSugarConsumed - targetDailySugar).abs() < 0.001) {
      sugarUnit = 'Tercapai!';
      sugarValue = '0';
      sugarValueColor = successGreenColor;
    } else if (currentSugarConsumed > targetDailySugar + _sugarTolerance) {
      sugarUnit = 'Kelebihan';
      sugarValue = (currentSugarConsumed - targetDailySugar).toStringAsFixed(1);
      sugarValueColor = alertRedColor;
    } else {
      sugarUnit = 'Sisa';
      sugarValue = remainingSugarCalc.toStringAsFixed(1);
      sugarValueColor = Colors.white;
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
                builder: (context) => const MoreOptionsScreen(),
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
              ? const Center(child: CircularProgressIndicator())
              : RefreshIndicator(
                onRefresh: _fetchDataForToday,
                child: SingleChildScrollView(
                  physics:
                      const AlwaysScrollableScrollPhysics(), // Agar bisa refresh walaupun konten sedikit
                  child: Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Hari ini',
                          style: TextStyle(
                            fontSize: 22,
                            fontWeight: FontWeight.bold,
                            color: darkerBlue,
                            fontFamily: 'Poppins',
                          ),
                        ),
                        const SizedBox(height: 16),
                        _buildMetricCard(
                          context,
                          title: 'Kalori',
                          currentValue: calorieValue,
                          unit: calorieUnit,
                          valueColor: calorieValueColor,
                          target: targetDailyCalories.toStringAsFixed(0),
                          consumed: currentCaloriesConsumed.toStringAsFixed(0),
                          exercise: burnedCaloriesFromExercise.toStringAsFixed(
                            0,
                          ), // PERBAIKAN: Gunakan nilai dinamis
                          arcColor: orangeColor,
                          consumedIcon: Icons.restaurant_menu,
                          exerciseIcon: Icons.local_fire_department,
                          percentage: caloriePercentage,
                        ),
                        const SizedBox(height: 16),
                        _buildMetricCard(
                          context,
                          title: 'Gula',
                          currentValue: sugarValue,
                          unit: sugarUnit,
                          valueColor: sugarValueColor,
                          target: targetDailySugar.toStringAsFixed(1),
                          consumed: currentSugarConsumed.toStringAsFixed(1),
                          arcColor: sugarArcNewColor,
                          consumedIcon: Icons.restaurant_menu,
                          percentage: sugarPercentage,
                        ),
                        const SizedBox(height: 24),
                        // BARU: Tombol aksi
                        _buildActionButtons(context),
                        const SizedBox(height: 190),
                      ],
                    ),
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
                currentIndex: 0,
                onTap: (index) {
                  if (index == 1) {
                    Navigator.pushReplacement(
                      context,
                      MaterialPageRoute(
                        builder: (context) => const DailyLogScreen(),
                      ),
                    );
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
                      Icon(Icons.search, color: searchBarIconColor, size: 20),
                      const SizedBox(width: 8),
                      Expanded(
                        child: TextField(
                          readOnly: true,
                          onTap: () {
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
                        icon: Icon(
                          Icons.camera_alt,
                          color: searchBarIconColor,
                          size: 30,
                        ),
                        onPressed: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => const SelectMealScreen(),
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
  }

  // BARU: Widget untuk tombol aksi
  Widget _buildActionButtons(BuildContext context) {
    return Row(
      children: [
        Expanded(
          child: ElevatedButton.icon(
            icon: const Icon(Icons.restaurant_menu, color: Colors.white),
            label: const Text('MAKANAN'),
            onPressed: () async {
              await Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => const SelectMealScreen(),
                ),
              );
              _fetchDataForToday(); // Refresh data setelah kembali
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: primaryBlueNormal,
              foregroundColor: Colors.white,
              padding: const EdgeInsets.symmetric(vertical: 15),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
              textStyle: const TextStyle(
                fontFamily: 'Poppins',
                fontWeight: FontWeight.bold,
                fontSize: 16,
              ),
            ),
          ),
        ),
        const SizedBox(width: 16),
        Expanded(
          child: ElevatedButton.icon(
            icon: const Icon(Icons.fitness_center, color: Colors.white),
            label: const Text('LATIHAN'),
            onPressed: () async {
              final result = await Navigator.push(
                context,
                MaterialPageRoute(
                  builder:
                      (context) =>
                          AddExerciseScreen(selectedDate: DateTime.now()),
                ),
              );
              if (result == true) {
                _fetchDataForToday();
              }
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: orangeColor,
              foregroundColor: Colors.white,
              padding: const EdgeInsets.symmetric(vertical: 15),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
              textStyle: const TextStyle(
                fontFamily: 'Poppins',
                fontWeight: FontWeight.bold,
                fontSize: 16,
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildMetricCard(
    BuildContext context, {
    required String title,
    required String currentValue,
    required String unit,
    Color? valueColor,
    String? target,
    required String consumed,
    String? exercise,
    required Color arcColor,
    required IconData consumedIcon,
    IconData? exerciseIcon,
    double percentage = 0.0,
  }) {
    String targetDisplay = target ?? '';
    String consumedDisplay = consumed;
    String exerciseDisplay = exercise ?? '';
    if (title == 'Kalori') {
      targetDisplay = '$target kkal';
      consumedDisplay = '$consumed kkal';
      exerciseDisplay = '$exercise kkal';
    } else if (title == 'Gula') {
      targetDisplay = '$target gram';
      consumedDisplay = '$consumed gram';
    }
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16.0),
      decoration: BoxDecoration(
        color: primaryBlueNormal,
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
            style: const TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
              color: Colors.white,
              fontFamily: 'Poppins',
            ),
          ),
          const SizedBox(height: 16),
          Row(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              SizedBox(
                width: 120,
                height: 120,
                child: CustomPaint(
                  painter: _ArcPainter(
                    arcColor: arcColor,
                    backgroundColor: white20Opacity,
                    percentage: percentage,
                  ),
                  child: Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text(
                          currentValue,
                          style: TextStyle(
                            fontSize: 28,
                            fontWeight: FontWeight.bold,
                            color: valueColor ?? Colors.white,
                            fontFamily: 'Poppins',
                          ),
                        ),
                        Text(
                          unit,
                          style: TextStyle(
                            fontSize: 14,
                            color: white70Opacity,
                            fontFamily: 'Poppins',
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 24),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    if (target != null)
                      _buildDetailRow(
                        icon: Icons.flag,
                        label: 'Sasaran Dasar',
                        value: targetDisplay,
                        iconColor: Colors.white,
                        textColor: Colors.white,
                      ),
                    _buildDetailRow(
                      icon: consumedIcon,
                      label: 'Makanan',
                      value: consumedDisplay,
                      iconColor: Colors.white,
                      textColor: Colors.white,
                    ),
                    if (exercise != null && exerciseIcon != null)
                      _buildDetailRow(
                        icon: exerciseIcon,
                        label: 'Latihan',
                        value: exerciseDisplay,
                        iconColor: Colors.white,
                        textColor: Colors.white,
                      ),
                  ],
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildDetailRow({
    required IconData icon,
    required String label,
    required String value,
    required Color iconColor,
    required Color textColor,
  }) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4.0),
      child: Row(
        children: [
          Icon(icon, color: iconColor, size: 20),
          const SizedBox(width: 8),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  label,
                  style: TextStyle(
                    fontSize: 16,
                    color: textColor,
                    fontFamily: 'Poppins',
                  ),
                ),
                Text(
                  value,
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                    fontFamily: 'Poppins',
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _ArcPainter extends CustomPainter {
  final Color arcColor;
  final Color backgroundColor;
  final double percentage;

  _ArcPainter({
    required this.arcColor,
    required this.backgroundColor,
    required this.percentage,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final Paint backgroundPaint =
        Paint()
          ..color = backgroundColor
          ..strokeWidth = 10
          ..style = PaintingStyle.stroke
          ..strokeCap = StrokeCap.round;
    final Paint arcPaint =
        Paint()
          ..color = arcColor
          ..strokeWidth = 10
          ..style = PaintingStyle.stroke
          ..strokeCap = StrokeCap.round;
    final Offset center = Offset(size.width / 2, size.height / 2);
    final double radius = math.min(size.width / 2, size.height / 2) - 5;
    canvas.drawCircle(center, radius, backgroundPaint);
    double sweepAngle = 2 * math.pi * percentage;
    canvas.drawArc(
      Rect.fromCircle(center: center, radius: radius),
      -math.pi / 2,
      sweepAngle,
      false,
      arcPaint,
    );
  }

  @override
  bool shouldRepaint(covariant _ArcPainter oldDelegate) {
    return oldDelegate.arcColor != arcColor ||
        oldDelegate.backgroundColor != backgroundColor ||
        oldDelegate.percentage != percentage;
  }
}
