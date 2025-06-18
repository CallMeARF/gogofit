// lib/screens/add_meal_manual_screen.dart
import 'package:flutter/material.dart';
import 'package:flutter/services.dart'; // Import ini untuk FilteringTextInputFormatter
import '../models/meal_data.dart';
import '../models/notification_data.dart';
import 'package:gogofit_frontend/services/notification_service.dart';
import 'package:gogofit_frontend/screens/dashboard_screen.dart'; // Import DashboardScreen

class AddMealManualScreen extends StatefulWidget {
  final String? initialMealType;
  final MealEntry?
  mealToEdit; // Digunakan jika benar-benar mengedit entri yang ada
  final MealEntry?
  initialMealData; // Digunakan untuk pre-fill data makanan baru (misal dari scanner)

  const AddMealManualScreen({
    super.key,
    this.initialMealType,
    this.mealToEdit,
    this.initialMealData,
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

  @override
  void initState() {
    super.initState();
    _isEditing = widget.mealToEdit != null;

    MealEntry? dataToFill = widget.mealToEdit ?? widget.initialMealData;

    if (dataToFill != null) {
      _mealNameController.text = dataToFill.name;
      _caloriesController.text = dataToFill.calories.toStringAsFixed(1);
      _fatController.text = dataToFill.fat.toStringAsFixed(1);
      _saturatedFatController.text = dataToFill.saturatedFat.toStringAsFixed(1);
      _carbsController.text = dataToFill.carbs.toStringAsFixed(1);
      _proteinController.text = dataToFill.protein.toStringAsFixed(1);
      _sugarController.text = dataToFill.sugar.toStringAsFixed(1);
      _selectedMealType = dataToFill.mealType;
    } else {
      _selectedMealType = widget.initialMealType ?? 'Sarapan';
    }
  }

  void _saveMeal() {
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

    if (_isEditing) {
      final updatedMeal = widget.mealToEdit!.copyWith(
        name: name,
        calories: calories,
        fat: fat,
        saturatedFat: saturatedFat,
        carbs: carbs,
        protein: protein,
        sugar: sugar,
        mealType: _selectedMealType,
      );
      updateMealEntry(updatedMeal);
      debugPrint('Updated Meal: ${updatedMeal.toJson()}');
      _checkAndAddNotifications(updatedMeal);
      _showAlertDialog('Sukses', 'Santapan berhasil diperbarui!', () {
        Navigator.pop(context);
      });
    } else {
      final newMeal = MealEntry(
        name: name,
        calories: calories,
        fat: fat,
        saturatedFat: saturatedFat,
        carbs: carbs,
        protein: protein,
        sugar: sugar,
        timestamp: DateTime.now(),
        mealType: _selectedMealType,
      );
      userMeals.value = [...userMeals.value, newMeal];
      debugPrint('Added Meal: ${newMeal.toJson()}');
      _checkAndAddNotifications(newMeal);
      _showAlertDialog('Sukses', 'Santapan berhasil ditambahkan!', () {
        Navigator.pushAndRemoveUntil(
          context,
          MaterialPageRoute(builder: (context) => const DashboardScreen()),
          (Route<dynamic> route) => false,
        );
      });
    }
  }

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
        await notificationService.showLocalNotification(
          id: 100,
          title: 'Target Kalori Tercapai!',
          body: 'Selamat! Anda berhasil mencapai target kalori harian Anda.',
          channelId: 'gogofit_achievement_calorie_channel',
          channelName: 'Pencapaian Kalori',
          channelDescription: 'Notifikasi untuk pencapaian target kalori',
          payload: 'calorie_achievement_payload',
        );
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
        await notificationService.showLocalNotification(
          id: 0,
          title: 'Peringatan Kalori Berlebih!',
          body: 'Anda telah melewati batas konsumsi kalori harian.',
          channelId: 'gogofit_calorie_channel',
          channelName: 'Peringatan Kalori',
          channelDescription: 'Notifikasi untuk peringatan kalori berlebih',
          payload: 'calorie_warning_payload',
        );
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
        await notificationService.showLocalNotification(
          id: 101,
          title: 'Target Gula Tercapai!',
          body: 'Selamat! Anda berhasil mencapai target gula harian Anda.',
          channelId: 'gogofit_achievement_sugar_channel',
          channelName: 'Pencapaian Gula',
          channelDescription: 'Notifikasi untuk pencapaian target gula',
          payload: 'sugar_achievement_payload',
        );
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
        await notificationService.showLocalNotification(
          id: 1,
          title: 'Peringatan Gula Berlebih!',
          body: 'Anda telah melewati batas konsumsi gula harian.',
          channelId: 'gogofit_sugar_channel',
          channelName: 'Peringatan Gula',
          channelDescription: 'Notifikasi untuk peringatan gula berlebih',
          payload: 'sugar_warning_payload',
        );
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
            Navigator.pop(context);
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
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
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
                  icon: Icon(Icons.keyboard_arrow_down, color: darkerBlue),
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
              'Contoh: Nasi Goreng', // Hint lebih pendek
              _mealNameController,
              keyboardType: TextInputType.text,
            ),
            _buildInputField(
              'Kalori (kkal)', // Label lebih jelas
              'Ex: 320.5', // Hint lebih pendek dan contoh
              _caloriesController,
              keyboardType: TextInputType.numberWithOptions(decimal: true),
              inputFormatters: [
                FilteringTextInputFormatter.allow(RegExp(r'^\d*\.?\d*')),
              ],
            ),
            _buildInputField(
              'Lemak total (gr)', // Label lebih jelas
              'Ex: 25.0', // Hint lebih pendek dan contoh
              _fatController,
              keyboardType: TextInputType.numberWithOptions(decimal: true),
              inputFormatters: [
                FilteringTextInputFormatter.allow(RegExp(r'^\d*\.?\d*')),
              ],
            ),
            _buildInputField(
              'Lemak jenuh (gr)', // Label lebih jelas
              'Ex: 8.0 (opsional)', // Hint lebih pendek, contoh, dan opsional
              _saturatedFatController,
              keyboardType: TextInputType.numberWithOptions(decimal: true),
              inputFormatters: [
                FilteringTextInputFormatter.allow(RegExp(r'^\d*\.?\d*')),
              ],
            ),
            _buildInputField(
              'Karbohidrat (gr)', // Label lebih jelas
              'Ex: 10.0', // Hint lebih pendek dan contoh
              _carbsController,
              keyboardType: TextInputType.numberWithOptions(decimal: true),
              inputFormatters: [
                FilteringTextInputFormatter.allow(RegExp(r'^\d*\.?\d*')),
              ],
            ),
            _buildInputField(
              'Protein (gr)', // Label lebih jelas
              'Ex: 20.0', // Hint lebih pendek dan contoh
              _proteinController,
              keyboardType: TextInputType.numberWithOptions(decimal: true),
              inputFormatters: [
                FilteringTextInputFormatter.allow(RegExp(r'^\d*\.?\d*')),
              ],
            ),
            _buildInputField(
              'Gula (gr)', // Label lebih jelas
              'Ex: 0.5', // Hint lebih pendek dan contoh
              _sugarController,
              keyboardType: TextInputType.numberWithOptions(decimal: true),
              inputFormatters: [
                FilteringTextInputFormatter.allow(RegExp(r'^\d*\.?\d*')),
              ],
            ),

            const SizedBox(height: 30), // Padding atas tombol
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
                  _isEditing ? 'Perbarui Santapan' : 'Tambahkan Santapan',
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    fontFamily: 'Poppins',
                  ),
                ),
              ),
            ),
            const SizedBox(height: 30), // Padding bawah tombol
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
