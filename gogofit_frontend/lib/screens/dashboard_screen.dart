import 'package:flutter/material.dart';
import 'dart:math' as math;
import 'package:flutter_svg/flutter_svg.dart';
import 'package:gogofit_frontend/screens/select_meal_screen.dart';
import 'package:gogofit_frontend/models/meal_data.dart';
import 'package:gogofit_frontend/screens/daily_log_screen.dart';
import 'package:gogofit_frontend/screens/more_options_screen.dart';
import 'package:gogofit_frontend/models/notification_data.dart';
import 'package:gogofit_frontend/screens/notifications_screen.dart';

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
  final Color white70Opacity = Color.fromARGB(
    (255 * 0.7).round(),
    255,
    255,
    255,
  );
  final Color white20Opacity = Color.fromARGB(
    (255 * 0.2).round(),
    255,
    255,
    255,
  );
  final Color black25Opacity = Color.fromARGB(25, 0, 0, 0);
  final Color black51Opacity = Color.fromARGB(51, 0, 0, 0);
  final Color alertRedColor = const Color(0xFFEF5350);
  final Color successGreenColor = const Color(
    0xFF4CAF50,
  ); // Hijau untuk status "Tercapai"

  double _currentCaloriesConsumed = 0.0; // UBAH: Dari int menjadi double
  double _currentSugarConsumed = 0.0;

  final double _targetDailyCalories = 1340.0; // UBAH: Dari int menjadi double
  final double _burnedCaloriesFromExercise =
      190.0; // UBAH: Dari int menjadi double
  final double _targetDailySugar = 30.0;

  final double _calorieTolerance = 50.0; // UBAH: Dari int menjadi double
  final double _sugarTolerance = 0.0; // Toleransi gula tetap 0.0

  @override
  void initState() {
    super.initState();
    _updateTotals();
    userMeals.addListener(_updateTotals);
  }

  @override
  void dispose() {
    userMeals.removeListener(_updateTotals);
    super.dispose();
  }

  void _updateTotals() {
    setState(() {
      _currentCaloriesConsumed =
          calculateTotalCalories(); // Ini adalah kalori makanan
      _currentSugarConsumed = calculateTotalSugar();
      debugPrint(
        'DEBUG Dashboard: Kalori Makanan Konsumsi Saat Ini: $_currentCaloriesConsumed kkal',
      );
      debugPrint(
        'DEBUG Dashboard: Gula Konsumsi Saat Ini: $_currentSugarConsumed gram',
      );
    });
  }

  @override
  Widget build(BuildContext context) {
    // Definisi Kalori Bersih: Kalori dari Makanan dikurangi Kalori Latihan
    // Ini adalah nilai yang akan dibandingkan dengan target
    double netCalories =
        _currentCaloriesConsumed -
        _burnedCaloriesFromExercise; // UBAH: Dari int menjadi double

    // Persentase untuk arc didasarkan pada netCalories dibandingkan target
    double caloriePercentage = 0.0;
    if (_targetDailyCalories > 0) {
      // Pastikan netCalories tidak negatif sebelum perhitungan persentase
      caloriePercentage = (netCalories.clamp(0.0, double.infinity) /
              _targetDailyCalories)
          .clamp(0.0, 1.0);
    }

    double sugarPercentage = 0.0;
    if (_targetDailySugar > 0) {
      sugarPercentage = (_currentSugarConsumed / _targetDailySugar).clamp(
        0.0,
        1.0,
      );
    }

    // --- Logika Penentuan Unit dan Warna untuk Kalori ---
    String calorieUnit;
    String calorieValue;
    Color calorieValueColor;

    if (netCalories >= _targetDailyCalories - _calorieTolerance &&
        netCalories <= _targetDailyCalories + _calorieTolerance) {
      // Tercapai dalam toleransi
      calorieUnit = 'Tercapai!';
      calorieValue = '0'; // Tampilkan 0 karena sudah tercapai
      calorieValueColor = successGreenColor;
    } else if (netCalories > _targetDailyCalories + _calorieTolerance) {
      // Kelebihan (Kalori bersih melebihi target)
      calorieUnit = 'Kelebihan';
      calorieValue = (netCalories - _targetDailyCalories).toStringAsFixed(
        0,
      ); // UBAH: Format desimal
      calorieValueColor = alertRedColor;
    } else {
      // Sisa (Kalori bersih di bawah target)
      calorieUnit = 'Sisa';
      calorieValue = (_targetDailyCalories - netCalories).toStringAsFixed(
        0,
      ); // UBAH: Format desimal
      calorieValueColor = Colors.white;
    }

    // --- Logika Penentuan Unit dan Warna untuk Gula ---
    String sugarUnit;
    String sugarValue;
    Color sugarValueColor;

    double remainingSugarCalc = _targetDailySugar - _currentSugarConsumed;

    // Gula Tercapai jika persis sama dengan target
    if ((_currentSugarConsumed - _targetDailySugar).abs() < 0.001) {
      // UBAH: Gunakan toleransi kecil untuk perbandingan double
      sugarUnit = 'Tercapai!';
      sugarValue = '0'; // Tampilkan 0 karena sudah tercapai
      sugarValueColor = successGreenColor;
    } else if (_currentSugarConsumed > _targetDailySugar + _sugarTolerance) {
      // Total gula > 30.0 (karena toleransi 0.0)
      // Kelebihan
      sugarUnit = 'Kelebihan';
      sugarValue = (_currentSugarConsumed - _targetDailySugar).toStringAsFixed(
        1, // UBAH: Menampilkan satu angka desimal
      );
      sugarValueColor = alertRedColor;
    } else {
      // Sisa
      sugarUnit = 'Sisa';
      sugarValue = remainingSugarCalc.toStringAsFixed(
        1,
      ); // UBAH: Menampilkan satu angka desimal
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
      body: SingleChildScrollView(
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

              // Calorie Card
              _buildMetricCard(
                context,
                title: 'Kalori',
                currentValue:
                    calorieValue, // Sisa/Tercapai/Kelebihan dari netCalories
                unit: calorieUnit, // Unit: Sisa/Tercapai/Kelebihan
                valueColor: calorieValueColor, // Warna dinamis
                target: _targetDailyCalories.toStringAsFixed(
                  0,
                ), // UBAH: Format desimal
                consumed: _currentCaloriesConsumed.toStringAsFixed(
                  0,
                ), // UBAH: Format desimal
                exercise: _burnedCaloriesFromExercise.toStringAsFixed(
                  0,
                ), // UBAH: Format desimal
                arcColor: orangeColor,
                consumedIcon: Icons.restaurant_menu,
                exerciseIcon: Icons.local_fire_department,
                percentage:
                    caloriePercentage, // Persentase berdasarkan netCalories
              ),
              const SizedBox(height: 16),

              // Sugar Card
              _buildMetricCard(
                context,
                title: 'Gula',
                currentValue:
                    sugarValue, // Gunakan nilai yang sudah disesuaikan
                unit: sugarUnit, // Gunakan unit yang sudah disesuaikan
                valueColor: sugarValueColor, // Gunakan warna dinamis
                target: _targetDailySugar.toStringAsFixed(
                  1,
                ), // UBAH: Format desimal
                consumed: _currentSugarConsumed.toStringAsFixed(
                  1,
                ), // UBAH: Format desimal
                arcColor: sugarArcNewColor,
                consumedIcon: Icons.restaurant_menu,
                percentage: sugarPercentage,
              ),
              const SizedBox(height: 16),

              const SizedBox(height: 190),
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
                currentIndex: 0,
                onTap: (index) {
                  if (index == 0) {
                    debugPrint('Already on Dashboard');
                  } else if (index == 1) {
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

  // Widget helper to create metric cards (Calories, Sugar)
  Widget _buildMetricCard(
    BuildContext context, {
    required String title,
    required String currentValue,
    required String unit,
    Color? valueColor,
    String? target,
    required String consumed, // Ini adalah kalori makanan yang murni
    String? exercise,
    required Color arcColor,
    required IconData consumedIcon,
    IconData? exerciseIcon,
    double percentage = 0.0,
  }) {
    String targetDisplay = target ?? '';
    String consumedDisplay = consumed; // Sudah positif
    String exerciseDisplay = exercise ?? '';

    if (title == 'Kalori') {
      targetDisplay = '$target kkal';
      consumedDisplay = '$consumed kkal'; // Pastikan ini kkal
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
              // Donut Chart / Arc Section
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
                            fontSize: 28, // Ukuran font diperkecil
                            fontWeight: FontWeight.bold,
                            color: valueColor ?? Colors.white,
                            fontFamily: 'Poppins',
                          ),
                        ),
                        Text(
                          unit,
                          style: TextStyle(
                            fontSize: 14, // Ukuran font diperkecil
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
              // Target, Food, Exercise Details Section
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
                    // Menampilkan Kalori Makanan yang murni (_currentCaloriesConsumed)
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

  // Widget helper to create detail rows in metric cards with a vertical separator line
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

// CustomPainter for drawing arc/donut chart
class _ArcPainter extends CustomPainter {
  final Color arcColor;
  final Color backgroundColor;
  final double percentage; // 0.0 to 1.0

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

    // Draw full background arc
    canvas.drawCircle(center, radius, backgroundPaint);

    // Draw arc based on percentage
    double sweepAngle = 2 * math.pi * percentage;
    canvas.drawArc(
      Rect.fromCircle(center: center, radius: radius),
      -math.pi / 2, // Start from top
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
