// lib/screens/edit_meal_list_screen.dart
import 'package:flutter/material.dart';
import 'package:gogofit_frontend/models/meal_data.dart'; // Import meal_data.dart
import 'package:gogofit_frontend/screens/add_meal_manual_screen.dart'; // Import AddMealManualScreen
import 'package:gogofit_frontend/models/notification_data.dart'; // Import notification_data.dart
// import 'package:gogofit_frontend/services/notification_service.dart'; // Import NotificationService
import 'package:gogofit_frontend/services/api_service.dart'; // BARU: Import ApiService

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
  final Color alertRedColor = const Color(0xFFEF5350);

  // FIX: Menggunakan final Color untuk konsistensi dan performa
  final Color white70Opacity = const Color.fromARGB(179, 255, 255, 255);
  final Color darkerBlue60Opacity = const Color.fromARGB(153, 0, 32, 51);

  List<MealEntry> _mealsToEdit = [];
  bool _isLoading = false; // State untuk loading
  final ApiService _apiService = ApiService(); // Inisialisasi ApiService

  // Target Kalori dan Gula (sesuai dengan yang ada di Dashboard/AddMealManual)
  final double _targetDailyCalories = 1340.0;
  final double _burnedCaloriesFromExercise = 190.0;
  final double _targetDailySugar = 30.0;

  final double _calorieTolerance = 50.0;
  final double _sugarTolerance = 0.0;

  @override
  void initState() {
    super.initState();
    // Panggil metode baru untuk ambil data dari API saat inisialisasi
    _fetchMealsToEdit();
    // userMeals global tidak lagi digunakan di sini untuk loading data,
    // sehingga listener tidak diperlukan.
  }

  @override
  void dispose() {
    // FIX: Hapus listener saat dispose

    super.dispose();
  }

  // BARU: Metode untuk mengambil data MealEntry dari API
  Future<void> _fetchMealsToEdit() async {
    if (!mounted) return; // Pastikan widget masih mounted sebelum setState
    setState(() {
      _isLoading = true; // Tampilkan indikator loading
    });
    try {
      // Panggil API untuk mendapatkan semua food logs untuk tanggal yang dipilih
      final List<MealEntry> allFoodLogsForDate = await _apiService.getFoodLogs(
        date: widget.selectedDate,
      );

      // Kemudian filter daftar tersebut berdasarkan mealType di sisi client
      if (!mounted) return;
      setState(() {
        _mealsToEdit =
            allFoodLogsForDate
                .where((meal) => meal.mealType == widget.mealType)
                .toList();
      });
      // PENTING: Panggil _checkAndManageNotifications di sini setelah data dimuat
      // agar logika notifikasi bekerja dengan data terbaru dari backend (dari _mealsToEdit).
      _checkAndManageNotifications();
    } catch (e) {
      debugPrint("Error fetching meals for edit: $e");
      if (!mounted) return;
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('Gagal memuat santapan: $e')));
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false; // Sembunyikan indikator loading
        });
      }
    }
  }

  // Logika notifikasi yang disalin dan disesuaikan dari AddMealManualScreen
  void _checkAndManageNotifications() async {
    // Pastikan perhitungan ini menggunakan _mealsToEdit yang sudah di-fetch dari API
    final double totalCalories = _mealsToEdit.fold(
      0.0,
      (sum, meal) => sum + meal.calories,
    );
    final double totalSugar = _mealsToEdit.fold(
      0.0,
      (sum, meal) => sum + meal.sugar,
    );

    double netCaloriesForNotifications =
        totalCalories - _burnedCaloriesFromExercise;

    debugPrint(
      'DEBUG Notif Check (EditMealList): Total Kalori Harian (Net): $netCaloriesForNotifications, Target: $_targetDailyCalories',
    );
    debugPrint(
      'DEBUG Notif Check (EditMealList): Total Gula Harian: $totalSugar, Target: $_targetDailySugar',
    );

    // --- LOGIKA PENGHAPUSAN NOTIFIKASI YANG TIDAK RELEVAN ---
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
        // FIX: Komen out pemanggilan notifikasi lokal
        /*
        await notificationService.showLocalNotification(
          id: 100,
          title: 'Target Kalori Tercapai!',
          body: 'Selamat! Anda berhasil mencapai target kalori harian Anda.',
          channelId: 'gogofit_achievement_calorie_channel',
          channelName: 'Pencapaian Kalori',
          channelDescription: 'Notifikasi untuk pencapaian target kalori',
          payload: 'calorie_achievement_payload',
        );
        */
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
        // FIX: Komen out pemanggilan notifikasi lokal
        /*
        await notificationService.showLocalNotification(
          id: 0,
          title: 'Peringatan Kalori Berlebih!',
          body: 'Anda telah melewati batas konsumsi kalori harian.',
          channelId: 'gogofit_calorie_channel',
          channelName: 'Peringatan Kalori',
          channelDescription: 'Notifikasi untuk peringatan kalori berlebih',
          payload: 'calorie_warning_payload',
        );
        */
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
        // FIX: Komen out pemanggilan notifikasi lokal
        /*
        await notificationService.showLocalNotification(
          id: 101,
          title: 'Target Gula Tercapai!',
          body: 'Selamat! Anda berhasil mencapai target gula harian Anda.',
          channelId: 'gogofit_achievement_sugar_channel',
          channelName: 'Pencapaian Gula',
          channelDescription: 'Notifikasi untuk pencapaian target gula',
          payload: 'sugar_achievement_payload',
        );
        */
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
        // FIX: Komen out pemanggilan notifikasi lokal
        /*
        await notificationService.showLocalNotification(
          id: 1,
          title: 'Peringatan Gula Berlebih!',
          body: 'Anda telah melewati batas konsumsi gula harian.',
          channelId: 'gogofit_sugar_channel',
          channelName: 'Peringatan Gula',
          channelDescription: 'Notifikasi untuk peringatan gula berlebih',
          payload: 'sugar_warning_payload',
        );
        */
        debugPrint(
          'Notifikasi: Kelebihan Gula ditambahkan (from EditMealList)!',
        );
      }
    }
  }

  // Fungsi untuk mengkonfirmasi dan menghapus MealEntry
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
              onPressed: () async {
                Navigator.of(dialogContext).pop(); // Tutup dialog
                setState(() {
                  _isLoading = true;
                }); // Tampilkan loading
                try {
                  // Panggil API deleteFoodLog menggunakan ID unik dari meal
                  final response = await _apiService.deleteFoodLog(meal.id!);

                  if (!mounted) return;
                  if (response['success']) {
                    // Setelah berhasil dihapus dari BE, muat ulang data dari API
                    _fetchMealsToEdit(); // Ini akan memicu refresh UI
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(content: Text('${meal.name} berhasil dihapus.')),
                    );
                  } else {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: Text(
                          response['message'] ?? 'Gagal menghapus santapan.',
                        ),
                      ),
                    );
                  }
                } catch (e) {
                  debugPrint('Delete Meal Error: $e');
                  if (!mounted) return;
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text(
                        'Terjadi kesalahan saat menghapus santapan: $e',
                      ),
                    ),
                  );
                } finally {
                  if (mounted) {
                    setState(() {
                      _isLoading = false;
                    }); // Sembunyikan loading
                  }
                }
              },
            ),
          ],
        );
      },
    );
  }

  // MODIFIKASI: Metode untuk mengedit MealEntry spesifik
  void _editSpecificMeal(MealEntry meal) async {
    // Kirim objek meal yang akan diedit langsung ke AddMealManualScreen
    final result = await Navigator.push(
      context,
      MaterialPageRoute(
        builder:
            (context) => AddMealManualScreen(
              initialMealType:
                  meal.mealType, // Teruskan mealType untuk konsistensi
              mealToEdit: meal, // Kirim objek MealEntry lengkap untuk diedit
              // Gunakan 'timestamp' yang ada di model MealEntry Anda
              // dan teruskan sebagai 'selectedDate' ke AddMealManualScreen
              selectedDate: meal.timestamp,
            ),
      ),
    );
    // Setelah kembali dari AddMealManualScreen (setelah add/edit), muat ulang data dari API
    if (result == true) {
      // Asumsi AddMealManualScreen mengembalikan true jika ada perubahan
      _fetchMealsToEdit(); // Panggil ulang untuk merefresh data dari API
    }
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
            Navigator.pop(context, true);
          },
        ),
      ),
      body:
          _isLoading
              ? const Center(
                child: CircularProgressIndicator(color: Colors.blueAccent),
              )
              : _mealsToEdit.isEmpty
              ? Center(
                child: Text(
                  'Tidak ada makanan di sesi ${widget.mealType} untuk tanggal ini.',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: 16,
                    color:
                        darkerBlue60Opacity, // FIX: Gunakan properti langsung
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
                                    color:
                                        white70Opacity, // FIX: Gunakan properti langsung
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
