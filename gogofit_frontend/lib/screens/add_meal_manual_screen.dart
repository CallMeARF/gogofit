// lib/screens/add_meal_manual_screen.dart
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../models/meal_data.dart';
import '../models/notification_data.dart';
import '../models/food.dart'; // <-- BARU: Import model Food
import 'package:gogofit_frontend/screens/dashboard_screen.dart';
import 'package:gogofit_frontend/services/api_service.dart';

class AddMealManualScreen extends StatefulWidget {
  final String? initialMealType;
  final MealEntry? mealToEdit; // Untuk mode edit
  final Food? initialFoodData; // Untuk pre-fill dari master food
  final DateTime? selectedDate; // <-- BARU: Tambahkan parameter ini
  final String? message;

  const AddMealManualScreen({
    super.key,
    this.initialMealType,
    this.mealToEdit,
    this.initialFoodData,
    this.selectedDate, // <-- BARU: Inisialisasi parameter ini
    this.message,
  });

  @override
  State<AddMealManualScreen> createState() => _AddMealManualScreenState();
}

class _AddMealManualScreenState extends State<AddMealManualScreen> {
  final TextEditingController _mealNameController = TextEditingController();
  final TextEditingController _caloriesController = TextEditingController();
  final TextEditingController _fatController = TextEditingController();
  final TextEditingController _saturatedFatController =
      TextEditingController(); // Controller untuk Lemak Jenuh
  final TextEditingController _carbsController = TextEditingController();
  final TextEditingController _proteinController = TextEditingController();
  final TextEditingController _sugarController = TextEditingController();

  late String _selectedMealType;
  late bool _isEditing;
  late String _displayMessage;

  final Color headerBackgroundColor = const Color(0xFF014a74);
  final Color accentBlueColor = const Color(0xFF015c91);
  final Color darkerBlue = const Color(0xFF002033);
  final Color whiteWithOpacity70 = const Color.fromARGB(179, 255, 255, 255);
  final Color blackWithOpacity10 = const Color.fromARGB(25, 0, 0, 0);
  final Color blackWithOpacity20 = const Color.fromARGB(51, 0, 0, 0);
  final Color accentBlueWithOpacity20 = Color.fromARGB(
    (255 * 0.2).round(),
    1,
    92,
    145,
  );

  final double _targetDailyCalories = 1340.0;
  final double _targetDailySugar = 30.0;

  final double _calorieTolerance = 50.0;
  final double _sugarTolerance = 0.0;

  final ApiService _apiService = ApiService(); // Inisialisasi ApiService
  bool _isSaving = false; // State untuk loading saat menyimpan

  @override
  void initState() {
    super.initState();
    _isEditing = widget.mealToEdit != null;

    // Inisialisasi _displayMessage
    _displayMessage =
        widget.message ?? ''; // Gunakan pesan dari widget atau string kosong

    // Prioritas 1: Isi form dari data Food (dari SelectMealScreen)
    if (widget.initialFoodData != null) {
      final food = widget.initialFoodData!;
      _mealNameController.text = food.name;
      _caloriesController.text = food.calories.toStringAsFixed(1);
      _fatController.text = food.fat.toStringAsFixed(1);
      _saturatedFatController.text = food.saturatedFat.toStringAsFixed(1);
      _carbsController.text = food.carbohydrates.toStringAsFixed(
        1,
      ); // Gunakan 'carbohydrates' dari model Food
      _proteinController.text = food.protein.toStringAsFixed(1);
      _sugarController.text = food.sugar.toStringAsFixed(1);
    }
    // Prioritas 2: Isi form dari data MealEntry (untuk mode edit)
    else if (widget.mealToEdit != null) {
      final meal = widget.mealToEdit!;
      _mealNameController.text = meal.name;
      _caloriesController.text = meal.calories.toStringAsFixed(1);
      _fatController.text = meal.fat.toStringAsFixed(1);
      _saturatedFatController.text = meal.saturatedFat.toStringAsFixed(1);
      _carbsController.text = meal.carbs.toStringAsFixed(
        1,
      ); // Gunakan 'carbs' dari model MealEntry
      _proteinController.text = meal.protein.toStringAsFixed(1);
      _sugarController.text = meal.sugar.toStringAsFixed(1);
    }

    // Atur tipe santapan default
    _selectedMealType =
        widget.initialMealType ?? // Dari argumen
        widget.mealToEdit?.mealType ?? // Dari mode edit
        'Sarapan'; // Default jika tidak ada
  }

  @override
  void dispose() {
    _mealNameController.dispose();
    _caloriesController.dispose();
    _fatController.dispose();
    _saturatedFatController.dispose(); // Dispose controller lemak jenuh
    _carbsController.dispose();
    _proteinController.dispose();
    _sugarController.dispose();
    super.dispose();
  }

  void _saveMeal() async {
    if (_mealNameController.text.isEmpty || _caloriesController.text.isEmpty) {
      _showAlertDialog('Error', 'Nama Makanan dan Kalori harus diisi.');
      return;
    }

    double calories = double.tryParse(_caloriesController.text) ?? 0.0;
    if (calories < 0) {
      _showAlertDialog('Error', 'Jumlah kalori tidak boleh negatif.');
      return;
    }

    double fat = double.tryParse(_fatController.text) ?? 0.0;
    if (fat < 0) fat = 0.0;
    double saturatedFat = double.tryParse(_saturatedFatController.text) ?? 0.0;
    if (saturatedFat < 0) saturatedFat = 0.0;

    double carbs = double.tryParse(_carbsController.text) ?? 0.0;
    if (carbs < 0) carbs = 0.0;
    double protein = double.tryParse(_proteinController.text) ?? 0.0;
    if (protein < 0) protein = 0.0;
    double sugar = double.tryParse(_sugarController.text) ?? 0.0;
    if (sugar < 0) sugar = 0.0;

    final String name = _mealNameController.text;

    setState(() {
      _isSaving = true; // Set isSaving true
    });

    try {
      if (_isEditing) {
        // Karena mealToEdit adalah MealEntry?, tambahkan ! untuk akses yang tidak bisa null
        final updatedMealPayload = MealEntry(
          id: widget.mealToEdit!.id,
          name: name,
          calories: calories,
          fat: fat,
          saturatedFat: saturatedFat,
          carbs: carbs,
          protein: protein,
          sugar: sugar,
          timestamp: widget.mealToEdit!.timestamp,
          mealType: _selectedMealType,
        );

        final response = await _apiService.updateFoodLog(updatedMealPayload);

        if (!mounted) return;
        if (response['success']) {
          updateMealEntry(updatedMealPayload);

          debugPrint('Updated Meal: ${updatedMealPayload.toJson()}');
          _checkAndAddNotifications(updatedMealPayload);
          _showAlertDialog('Sukses', 'Santapan berhasil diperbarui!', () {
            if (!mounted) return;
            Navigator.pop(context, true);
          });
        } else {
          _showAlertDialog(
            'Error',
            response['message'] ?? 'Gagal memperbarui santapan.',
          );
        }
      } else {
        final newMealPayload = MealEntry(
          name: name,
          calories: calories,
          fat: fat,
          saturatedFat: saturatedFat,
          carbs: carbs,
          protein: protein,
          sugar: sugar,
          timestamp:
              widget.selectedDate ?? DateTime.now(), // <-- UBAH MENJADI INI
          mealType: _selectedMealType,
        );

        final response = await _apiService.addFoodLog(newMealPayload);

        if (!mounted) return;
        if (response['success']) {
          final MealEntry newMealFromBE = MealEntry.fromJson(response['log']);

          userMeals.value = [...userMeals.value, newMealFromBE];

          debugPrint('Added Meal (from BE): ${newMealFromBE.toJson()}');
          _checkAndAddNotifications(newMealFromBE);
          _showAlertDialog('Sukses', 'Santapan berhasil ditambahkan!', () {
            if (!mounted) return;
            Navigator.pushAndRemoveUntil(
              context,
              MaterialPageRoute(builder: (context) => const DashboardScreen()),
              (Route<dynamic> route) => false,
            );
          });
        } else {
          _showAlertDialog(
            'Error',
            response['message'] ?? 'Gagal menambahkan santapan.',
          );
        }
      }
    } catch (e) {
      if (!mounted) return;
      debugPrint('Save Meal Error: $e');
      _showAlertDialog(
        'Error',
        'Terjadi kesalahan saat menyimpan santapan: $e',
      );
    } finally {
      setState(() {
        _isSaving = false; // Set isSaving false di finally
      });
    }
  }

  double calculateTotalCalories() {
    return userMeals.value
        .where(
          (meal) =>
              meal.timestamp.year == DateTime.now().year &&
              meal.timestamp.month == DateTime.now().month &&
              meal.timestamp.day == DateTime.now().day,
        )
        .fold(0.0, (sum, meal) => sum + meal.calories);
  }

  double calculateTotalSugar() {
    return userMeals.value
        .where(
          (meal) =>
              meal.timestamp.year == DateTime.now().year &&
              meal.timestamp.month == DateTime.now().month &&
              meal.timestamp.day == DateTime.now().day,
        )
        .fold(0.0, (sum, meal) => sum + meal.sugar);
  }

  bool hasSpecificNotificationForToday(String title, NotificationType type) =>
      false;
  void addNotification(AppNotification notification) {}
  // FIX: Menggunakan instance global notificationService
  // Hapus deklarasi lokal ini karena sudah ada yang global di file notification_service.dart
  // final NotificationService notificationService = NotificationService();
  void removeSpecificNotificationForToday(
    String title,
    NotificationType type,
  ) {}

  void _checkAndAddNotifications(MealEntry currentMeal) async {
    final double totalCalories = calculateTotalCalories();
    final double totalSugar = calculateTotalSugar();

    debugPrint(
      'DEBUG Notif Check: Total Kalori Harian: $totalCalories, Target: $_targetDailyCalories, Toleransi Kalori: $_calorieTolerance',
    );
    debugPrint(
      'DEBUG Notif Check: Total Gula Harian: $totalSugar, Target: $_targetDailySugar, Toleransi Gula: $_sugarTolerance',
    );

    // --- LOGIKA PENGHAPUSAN NOTIFIKASI YANG TIDAK RELEVAN ---
    if (totalCalories <= _targetDailyCalories + _calorieTolerance &&
        hasSpecificNotificationForToday(
          'Peringatan Kalori Berlebih!',
          NotificationType.warning,
        )) {
      removeSpecificNotificationForToday(
        'Peringatan Kalori Berlebih!',
        NotificationType.warning,
      );
      debugPrint(
        'Notifikasi: Peringatan Kalori Berlebih dihapus karena sudah tidak berlebih.',
      );
    }
    if (!(totalCalories >= _targetDailyCalories - _calorieTolerance &&
            totalCalories <= _targetDailyCalories + _calorieTolerance) &&
        hasSpecificNotificationForToday(
          'Target Kalori Tercapai!',
          NotificationType.achievement,
        )) {
      removeSpecificNotificationForToday(
        'Target Kalori Tercapai!',
        NotificationType.achievement,
      );
      debugPrint(
        'Notifikasi: Target Kalori Tercapai dihapus karena sudah tidak tercapai.',
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
        'Notifikasi: Peringatan Gula Berlebih dihapus karena sudah tidak berlebih.',
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
        'Notifikasi: Target Gula Tercapai dihapus karena sudah tidak tercapai.',
      );
    }

    // --- LOGIKA PENAMBAHAN NOTIFIKASI BERDASARKAN KONDISI TERKINI ---
    if (totalCalories >= _targetDailyCalories - _calorieTolerance &&
        totalCalories <= _targetDailyCalories + _calorieTolerance) {
      debugPrint('DEBUG Notif Check: Kondisi Kalori Tercapai terpenuhi.');
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
        debugPrint('Notifikasi: Target Kalori Tercapai ditambahkan!');
      } else {
        debugPrint(
          'DEBUG Notif Check: Notif Target Kalori Tercapai sudah ada untuk hari ini. Tidak ditambahkan duplikat.',
        );
      }
    } else if (totalCalories > _targetDailyCalories + _calorieTolerance) {
      debugPrint('DEBUG Notif Check: Kondisi Kalori Berlebih terpenuhi.');
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
        debugPrint('Notifikasi: Kelebihan Kalori ditambahkan!');
      } else {
        debugPrint(
          'DEBUG Notif Check: Notif Peringatan Kalori Berlebih sudah ada untuk hari ini. Tidak ditambahkan duplikat.',
        );
      }
    } else {
      debugPrint('DEBUG Notif Check: Kalori di bawah target atau toleransi.');
    }

    if ((totalSugar - _targetDailySugar).abs() < 0.001) {
      debugPrint('DEBUG Notif Check: Kondisi Gula Tercapai terpenuhi.');
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
        debugPrint('Notifikasi: Target Gula Tercapai ditambahkan!');
      } else {
        debugPrint(
          'DEBUG Notif Check: Notif Target Gula Tercapai sudah ada untuk hari ini. Tidak ditambahkan duplikat.',
        );
      }
    } else if (totalSugar > _targetDailySugar + _sugarTolerance) {
      debugPrint('DEBUG Notif Check: Kondisi Gula Berlebih terpenuhi.');
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
        debugPrint('Notifikasi: Kelebihan Gula ditambahkan!');
      } else {
        debugPrint(
          'DEBUG Notif Check: Notif Peringatan Gula Berlebih sudah ada untuk hari ini. Tidak ditambahkan duplikat.',
        );
      }
    } else {
      debugPrint('DEBUG Notif Check: Gula di bawah target atau toleransi.');
    }
  }

  void _showAlertDialog(String title, String message, [VoidCallback? onOk]) {
    showDialog(
      context: context,
      builder: (BuildContext dialogContext) {
        return AlertDialog(
          title: Text(
            title,
            style: const TextStyle(
              fontFamily: 'Poppins',
              fontWeight: FontWeight.bold,
            ),
          ),
          content: Text(message, style: const TextStyle(fontFamily: 'Poppins')),
          actions: <Widget>[
            TextButton(
              child: Text(
                'OK',
                style: TextStyle(fontFamily: 'Poppins', color: accentBlueColor),
              ),
              onPressed: () {
                Navigator.of(dialogContext).pop();
                onOk?.call();
              },
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: headerBackgroundColor,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.close, color: Colors.white, size: 28),
          onPressed: () {
            Navigator.pop(context, true);
          },
        ),
        title: Text(
          _isEditing ? 'Edit Santapan' : 'Tambah Santapan',
          style: const TextStyle(
            color: Colors.white,
            fontSize: 20,
            fontWeight: FontWeight.bold,
            fontFamily: 'Poppins',
          ),
        ),
        centerTitle: true,
      ),
      body:
          _isSaving // BARU: Tampilkan CircularProgressIndicator saat _isSaving true
              ? const Center(
                child: CircularProgressIndicator(color: Colors.blueAccent),
              )
              : SingleChildScrollView(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // BARU: Tampilkan pesan jika ada
                    if (_displayMessage.isNotEmpty)
                      Padding(
                        padding: const EdgeInsets.only(bottom: 20.0),
                        child: Container(
                          padding: const EdgeInsets.all(12.0),
                          decoration: BoxDecoration(
                            color: Colors.orange.shade100,
                            borderRadius: BorderRadius.circular(12),
                            border: Border.all(color: Colors.orange.shade400),
                          ),
                          child: Row(
                            children: [
                              Icon(
                                Icons.info_outline,
                                color: Colors.orange.shade700,
                              ),
                              const SizedBox(width: 10),
                              Expanded(
                                child: Text(
                                  _displayMessage,
                                  style: TextStyle(
                                    color: Colors.orange.shade800,
                                    fontSize: 14,
                                    fontFamily: 'Poppins',
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    // Dropdown Santapan
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 16),
                      margin: const EdgeInsets.only(bottom: 20),
                      decoration: BoxDecoration(
                        color: accentBlueWithOpacity20,
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(color: accentBlueColor),
                      ),
                      child: DropdownButtonHideUnderline(
                        child: DropdownButton<String>(
                          isExpanded: true,
                          value: _selectedMealType,
                          icon: Icon(
                            Icons.keyboard_arrow_down,
                            color: darkerBlue,
                          ),
                          style: TextStyle(
                            color: darkerBlue,
                            fontSize: 16,
                            fontFamily: 'Poppins',
                            fontWeight: FontWeight.w500,
                          ),
                          onChanged: (String? newValue) {
                            setState(() {
                              _selectedMealType = newValue!;
                            });
                            debugPrint('Santapan selected: $newValue');
                          },
                          items:
                              <String>[
                                'Sarapan',
                                'Makan Siang',
                                'Makan Malam',
                                'Camilan',
                              ].map<DropdownMenuItem<String>>((String value) {
                                return DropdownMenuItem<String>(
                                  value: value,
                                  child: Text(value),
                                );
                              }).toList(),
                        ),
                      ),
                    ),

                    // Form Input Makanan
                    _buildInputField(
                      'Nama Makanan',
                      'Contoh: Nasi Goreng',
                      _mealNameController,
                      keyboardType: TextInputType.text,
                    ),
                    _buildInputField(
                      'Kalori (kkal)',
                      'Ex: 320.5',
                      _caloriesController,
                      keyboardType: TextInputType.numberWithOptions(
                        decimal: true,
                      ),
                      inputFormatters: [
                        FilteringTextInputFormatter.allow(
                          RegExp(r'^\d*\.?\d*'),
                        ),
                      ],
                    ),
                    _buildInputField(
                      'Lemak total (gr)',
                      'Ex: 25.0',
                      _fatController,
                      keyboardType: TextInputType.numberWithOptions(
                        decimal: true,
                      ),
                      inputFormatters: [
                        FilteringTextInputFormatter.allow(
                          RegExp(r'^\d*\.?\d*'),
                        ),
                      ],
                    ),
                    _buildInputField(
                      'Lemak jenuh (gr)',
                      'Ex: 8.0 (opsional)',
                      _saturatedFatController,
                      keyboardType: TextInputType.numberWithOptions(
                        decimal: true,
                      ),
                      inputFormatters: [
                        FilteringTextInputFormatter.allow(
                          RegExp(r'^\d*\.?\d*'),
                        ),
                      ],
                    ),
                    _buildInputField(
                      'Karbohidrat (gr)',
                      'Ex: 10.0',
                      _carbsController,
                      keyboardType: TextInputType.numberWithOptions(
                        decimal: true,
                      ),
                      inputFormatters: [
                        FilteringTextInputFormatter.allow(
                          RegExp(r'^\d*\.?\d*'),
                        ),
                      ],
                    ),
                    _buildInputField(
                      'Protein (gr)',
                      'Ex: 20.0',
                      _proteinController,
                      keyboardType: TextInputType.numberWithOptions(
                        decimal: true,
                      ),
                      inputFormatters: [
                        FilteringTextInputFormatter.allow(
                          RegExp(r'^\d*\.?\d*'),
                        ),
                      ],
                    ),
                    _buildInputField(
                      'Gula (gr)',
                      'Ex: 0.5',
                      _sugarController,
                      keyboardType: TextInputType.numberWithOptions(
                        decimal: true,
                      ),
                      inputFormatters: [
                        FilteringTextInputFormatter.allow(
                          RegExp(r'^\d*\.?\d*'),
                        ),
                      ],
                    ),

                    const SizedBox(height: 30),
                    // Tombol Simpan/Perbarui Santapan
                    SizedBox(
                      width: double.infinity,
                      height: 55,
                      child: ElevatedButton(
                        onPressed: _saveMeal,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: accentBlueColor,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                          elevation: 5,
                          shadowColor: blackWithOpacity20,
                        ),
                        child: Text(
                          _isEditing
                              ? 'Perbarui Santapan'
                              : 'Tambahkan Santapan',
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                            fontFamily: 'Poppins',
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(height: 30),
                  ],
                ),
              ),
    );
  }

  // Helper untuk membuat input field
  Widget _buildInputField(
    String label,
    String hint,
    TextEditingController controller, {
    TextInputType keyboardType = TextInputType.text,
    List<TextInputFormatter>? inputFormatters,
  }) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            label,
            style: TextStyle(
              color: darkerBlue,
              fontSize: 16,
              fontWeight: FontWeight.bold,
              fontFamily: 'Poppins',
            ),
          ),
          const SizedBox(height: 8),
          TextField(
            controller: controller,
            keyboardType: keyboardType,
            inputFormatters: inputFormatters,
            decoration: InputDecoration(
              hintText: hint,
              hintStyle: TextStyle(
                color: Colors.grey.shade500,
                fontFamily: 'Poppins',
                fontSize: 14,
              ),
              enabledBorder: UnderlineInputBorder(
                borderSide: BorderSide(color: Colors.grey.shade400, width: 1.5),
              ),
              focusedBorder: UnderlineInputBorder(
                borderSide: BorderSide(color: accentBlueColor, width: 2.0),
              ),
              contentPadding: const EdgeInsets.symmetric(vertical: 12),
              isDense: true,
            ),
            style: TextStyle(
              color: darkerBlue,
              fontSize: 16,
              fontFamily: 'Poppins',
            ),
          ),
        ],
      ),
    );
  }
}
