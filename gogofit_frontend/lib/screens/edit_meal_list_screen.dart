// lib/screens/edit_meal_list_screen.dart
import 'package:flutter/material.dart';
import 'package:gogofit_frontend/models/meal_data.dart'; // Import meal_data.dart
import 'package:gogofit_frontend/screens/add_meal_manual_screen.dart'; // Import AddMealManualScreen
import 'package:gogofit_frontend/models/notification_data.dart'; // Import notification_data.dart
import 'package:gogofit_frontend/services/notification_service.dart'; // Import NotificationService

class EditMealListScreen extends StatefulWidget {
  final String mealType;
  final DateTime selectedDate;

  const EditMealListScreen({
    super.key,
    required this.mealType,
    required this.selectedDate,
  });

  @override
  State<EditMealListScreen> createState() => _EditMealListScreenState();
}

class _EditMealListScreenState extends State<EditMealListScreen> {
  // Definisi warna yang konsisten
  final Color primaryBlueNormal = const Color(0xFF015c91);
  final Color darkerBlue = const Color(0xFF002033);
  final Color accentBlueColor = const Color(0xFF015c91);
  final Color alertRedColor = const Color(0xFFEF5350); // Tambahkan warna ini

  // Menggunakan getter untuk warna opacity
  Color white70Opacity() => const Color.fromARGB(179, 255, 255, 255);
  Color darkerBlue60Opacity() => const Color.fromARGB(153, 0, 32, 51);

  List<MealEntry> _mealsToEdit = [];

  // Target Kalori dan Gula (sesuai dengan yang ada di Dashboard/AddMealManual)
  final double _targetDailyCalories = 1340.0;
  final double _burnedCaloriesFromExercise = 190.0;
  final double _targetDailySugar = 30.0;

  final double _calorieTolerance = 50.0;
  final double _sugarTolerance = 0.0;

  @override
  void initState() {
    super.initState();
    _filterMeals();
    userMeals.addListener(_onMealsChanged); // Gunakan listener baru
  }

  @override
  void dispose() {
    userMeals.removeListener(_onMealsChanged); // Hapus listener baru
    super.dispose();
  }

  // Listener yang akan dipanggil saat userMeals berubah
  void _onMealsChanged() {
    _filterMeals(); // Perbarui daftar makanan yang ditampilkan
    _checkAndManageNotifications(); // Panggil logika notifikasi setelah perubahan
  }

  void _filterMeals() {
    setState(() {
      // Filter berdasarkan mealType dan tanggal yang dipilih
      _mealsToEdit =
          userMeals.value
              .where(
                (meal) =>
                    meal.mealType == widget.mealType &&
                    meal.timestamp.year == widget.selectedDate.year &&
                    meal.timestamp.month == widget.selectedDate.month &&
                    meal.timestamp.day == widget.selectedDate.day,
              )
              .toList();
    });
  }

  // Logika notifikasi yang disalin dan disesuaikan dari AddMealManualScreen
  void _checkAndManageNotifications() async {
    // Pastikan ini menghitung total kalori dan gula untuk HARI INI
    // karena notifikasi harian berlaku untuk hari ini
    final double totalCalories = calculateTotalCalories();
    final double totalSugar = calculateTotalSugar();

    // Hitung kalori bersih yang relevan untuk notifikasi kalori
    double netCaloriesForNotifications =
        totalCalories - _burnedCaloriesFromExercise;

    debugPrint(
      'DEBUG Notif Check (EditMealList): Total Kalori Harian (Net): $netCaloriesForNotifications, Target: $_targetDailyCalories',
    );
    debugPrint(
      'DEBUG Notif Check (EditMealList): Total Gula Harian: $totalSugar, Target: $_targetDailySugar',
    );

    // --- LOGIKA PENGHAPUSAN NOTIFIKASI YANG TIDAK RELEVAN ---
    // Hapus notifikasi "berlebih" kalori jika sudah tidak berlebih lagi
    if (netCaloriesForNotifications <=
            _targetDailyCalories + _calorieTolerance &&
        hasSpecificNotificationForToday(
          'Peringatan Kalori Berlebih!',
          NotificationType.warning,
        )) {
      removeSpecificNotificationForToday(
        'Peringatan Kalori Berlebih!',
        NotificationType.warning,
      );
      debugPrint(
        'Notifikasi: Peringatan Kalori Berlebih dihapus karena sudah tidak berlebih (dari EditMealList).',
      );
    }
    // Hapus notifikasi "tercapai" kalori jika sudah tidak dalam rentang tercapai
    if (!(netCaloriesForNotifications >=
                _targetDailyCalories - _calorieTolerance &&
            netCaloriesForNotifications <=
                _targetDailyCalories + _calorieTolerance) &&
        hasSpecificNotificationForToday(
          'Target Kalori Tercapai!',
          NotificationType.achievement,
        )) {
      removeSpecificNotificationForToday(
        'Target Kalori Tercapai!',
        NotificationType.achievement,
      );
      debugPrint(
        'Notifikasi: Target Kalori Tercapai dihapus karena sudah tidak tercapai (dari EditMealList).',
      );
    }

    // Hapus notifikasi "berlebih" gula jika sudah tidak berlebih lagi
    if (totalSugar <= _targetDailySugar + _sugarTolerance &&
        hasSpecificNotificationForToday(
          'Peringatan Gula Berlebih!',
          NotificationType.warning,
        )) {
      removeSpecificNotificationForToday(
        'Peringatan Gula Berlebih!',
        NotificationType.warning,
      );
      debugPrint(
        'Notifikasi: Peringatan Gula Berlebih dihapus karena sudah tidak berlebih (from EditMealList).',
      );
    }
    // Hapus notifikasi "tercapai" gula jika sudah tidak dalam rentang tercapai
    if (!((totalSugar - _targetDailySugar).abs() < 0.001) &&
        hasSpecificNotificationForToday(
          'Target Gula Tercapai!',
          NotificationType.achievement,
        )) {
      removeSpecificNotificationForToday(
        'Target Gula Tercapai!',
        NotificationType.achievement,
      );
      debugPrint(
        'Notifikasi: Target Gula Tercapai dihapus karena sudah tidak tercapai (from EditMealList).',
      );
    }

    // --- LOGIKA PENAMBAHAN NOTIFIKASI BERDASARKAN KONDISI TERKINI ---

    // Notifikasi Kalori Tercapai
    if (netCaloriesForNotifications >=
            _targetDailyCalories - _calorieTolerance &&
        netCaloriesForNotifications <=
            _targetDailyCalories + _calorieTolerance) {
      if (!hasSpecificNotificationForToday(
        'Target Kalori Tercapai!',
        NotificationType.achievement,
      )) {
        addNotification(
          AppNotification(
            title: 'Target Kalori Tercapai!',
            message:
                'Selamat! Anda berhasil mencapai target kalori harian Anda.',
            timestamp: DateTime.now(),
            type: NotificationType.achievement,
          ),
        );
        await notificationService.showLocalNotification(
          id: 100,
          title: 'Target Kalori Tercapai!',
          body: 'Selamat! Anda berhasil mencapai target kalori harian Anda.',
          channelId: 'gogofit_achievement_calorie_channel',
          channelName: 'Pencapaian Kalori',
          channelDescription: 'Notifikasi untuk pencapaian target kalori',
          payload: 'calorie_achievement_payload',
        );
        debugPrint(
          'Notifikasi: Target Kalori Tercapai ditambahkan (from EditMealList)!',
        );
      }
    }
    // Notifikasi Kalori Berlebih
    else if (netCaloriesForNotifications >
        _targetDailyCalories + _calorieTolerance) {
      if (!hasSpecificNotificationForToday(
        'Peringatan Kalori Berlebih!',
        NotificationType.warning,
      )) {
        addNotification(
          AppNotification(
            title: 'Peringatan Kalori Berlebih!',
            message:
                'Anda telah melewati batas konsumsi kalori harian (${_targetDailyCalories.toStringAsFixed(0)} kkal).',
            timestamp: DateTime.now(),
            type: NotificationType.warning,
          ),
        );
        await notificationService.showLocalNotification(
          id: 0,
          title: 'Peringatan Kalori Berlebih!',
          body: 'Anda telah melewati batas konsumsi kalori harian.',
          channelId: 'gogofit_calorie_channel',
          channelName: 'Peringatan Kalori',
          channelDescription: 'Notifikasi untuk peringatan kalori berlebih',
          payload: 'calorie_warning_payload',
        );
        debugPrint(
          'Notifikasi: Kelebihan Kalori ditambahkan (from EditMealList)!',
        );
      }
    }

    // Notifikasi Gula Tercapai
    if ((totalSugar - _targetDailySugar).abs() < 0.001) {
      if (!hasSpecificNotificationForToday(
        'Target Gula Tercapai!',
        NotificationType.achievement,
      )) {
        addNotification(
          AppNotification(
            title: 'Target Gula Tercapai!',
            message: 'Selamat! Anda berhasil mencapai target gula harian Anda.',
            timestamp: DateTime.now(),
            type: NotificationType.achievement,
          ),
        );
        await notificationService.showLocalNotification(
          id: 101,
          title: 'Target Gula Tercapai!',
          body: 'Selamat! Anda berhasil mencapai target gula harian Anda.',
          channelId: 'gogofit_achievement_sugar_channel',
          channelName: 'Pencapaian Gula',
          channelDescription: 'Notifikasi untuk pencapaian target gula',
          payload: 'sugar_achievement_payload',
        );
        debugPrint(
          'Notifikasi: Target Gula Tercapai ditambahkan (from EditMealList)!',
        );
      }
    }
    // Notifikasi Gula Berlebih
    else if (totalSugar > _targetDailySugar + _sugarTolerance) {
      if (!hasSpecificNotificationForToday(
        'Peringatan Gula Berlebih!',
        NotificationType.warning,
      )) {
        addNotification(
          AppNotification(
            title: 'Peringatan Gula Berlebih!',
            message:
                'Anda telah melewati batas konsumsi gula harian (${_targetDailySugar.toStringAsFixed(1)} gram).',
            timestamp: DateTime.now(),
            type: NotificationType.warning,
          ),
        );
        await notificationService.showLocalNotification(
          id: 1,
          title: 'Peringatan Gula Berlebih!',
          body: 'Anda telah melewati batas konsumsi gula harian.',
          channelId: 'gogofit_sugar_channel',
          channelName: 'Peringatan Gula',
          channelDescription: 'Notifikasi untuk peringatan gula berlebih',
          payload: 'sugar_warning_payload',
        );
        debugPrint(
          'Notifikasi: Kelebihan Gula ditambahkan (from EditMealList)!',
        );
      }
    }
  }

  void _confirmDeleteMeal(MealEntry meal) {
    showDialog(
      context: context,
      builder: (BuildContext dialogContext) {
        return AlertDialog(
          title: const Text(
            'Hapus Santapan?',
            style: TextStyle(
              fontFamily: 'Poppins',
              fontWeight: FontWeight.bold,
            ),
          ),
          content: Text(
            'Anda yakin ingin menghapus "${meal.name}"?',
            style: const TextStyle(fontFamily: 'Poppins'),
          ),
          actions: <Widget>[
            TextButton(
              child: const Text(
                'Batal',
                style: TextStyle(fontFamily: 'Poppins', color: Colors.grey),
              ),
              onPressed: () {
                Navigator.of(dialogContext).pop();
              },
            ),
            TextButton(
              child: const Text(
                'Hapus',
                style: TextStyle(fontFamily: 'Poppins', color: Colors.red),
              ),
              onPressed: () {
                deleteMealEntry(
                  meal.id,
                ); // Panggil fungsi delete dari meal_data.dart
                Navigator.of(dialogContext).pop(); // Tutup dialog
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(content: Text('${meal.name} berhasil dihapus.')),
                );
                // NOTIFIKASI: _onMealsChanged akan dipanggil via listener,
                // yang kemudian akan memanggil _checkAndManageNotifications()
              },
            ),
          ],
        );
      },
    );
  }

  void _editSpecificMeal(MealEntry meal) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder:
            (context) => AddMealManualScreen(
              mealToEdit: meal,
            ), // Kirim objek meal untuk diedit
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: primaryBlueNormal,
        elevation: 0,
        title: Text(
          'Edit ${widget.mealType}',
          style: const TextStyle(
            color: Colors.white,
            fontSize: 20,
            fontWeight: FontWeight.bold,
            fontFamily: 'Poppins',
          ),
        ),
        centerTitle: true,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.white, size: 28),
          onPressed: () {
            Navigator.pop(context);
          },
        ),
      ),
      body:
          _mealsToEdit.isEmpty
              ? Center(
                child: Text(
                  'Tidak ada makanan di sesi ${widget.mealType} untuk tanggal ini.',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: 16,
                    color: darkerBlue60Opacity(),
                    fontFamily: 'Poppins',
                  ),
                ),
              )
              : ListView.builder(
                padding: const EdgeInsets.all(16.0),
                itemCount: _mealsToEdit.length,
                itemBuilder: (context, index) {
                  final meal = _mealsToEdit[index];
                  return Card(
                    margin: const EdgeInsets.symmetric(vertical: 8.0),
                    elevation: 4,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    color: accentBlueColor,
                    child: Padding(
                      padding: const EdgeInsets.all(16.0),
                      child: Row(
                        children: [
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  meal.name,
                                  style: const TextStyle(
                                    color: Colors.white,
                                    fontSize: 18,
                                    fontWeight: FontWeight.bold,
                                    fontFamily: 'Poppins',
                                  ),
                                ),
                                Text(
                                  // Menggunakan toStringAsFixed(1) untuk kalori dan gula
                                  '${meal.calories.toStringAsFixed(1)} kkal, ${meal.sugar.toStringAsFixed(1)} gr gula',
                                  style: TextStyle(
                                    color: white70Opacity(),
                                    fontSize: 14,
                                    fontFamily: 'Poppins',
                                  ),
                                ),
                              ],
                            ),
                          ),
                          // Tombol Edit
                          IconButton(
                            icon: const Icon(
                              Icons.edit,
                              color: Colors.white,
                              size: 24,
                            ),
                            onPressed: () => _editSpecificMeal(meal),
                          ),
                          // Tombol Hapus
                          IconButton(
                            icon: const Icon(
                              Icons.delete,
                              color: Colors.redAccent,
                              size: 24,
                            ),
                            onPressed: () => _confirmDeleteMeal(meal),
                          ),
                        ],
                      ),
                    ),
                  );
                },
              ),
    );
  }
}
