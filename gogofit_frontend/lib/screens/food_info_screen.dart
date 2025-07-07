// lib/screens/food_info_screen.dart
import 'package:flutter/material.dart';
import 'dart:io';
import 'package:gogofit_frontend/models/food.dart'; // Import model Food
import 'package:gogofit_frontend/screens/add_meal_manual_screen.dart'; // Import AddMealManualScreen

class FoodInfoScreen extends StatefulWidget {
  final Food scannedFood;
  final String? scannedImagePath;

  const FoodInfoScreen({
    super.key,
    required this.scannedFood,
    this.scannedImagePath,
  });

  @override
  State<FoodInfoScreen> createState() => _FoodInfoScreenState();
}

class _FoodInfoScreenState extends State<FoodInfoScreen> {
  final Color headerBackgroundColor = const Color(0xFF014a74);
  final Color accentBlueColor = const Color(0xFF015c91);
  final Color darkerBlue = const Color(0xFF002033);
  final Color white70Opacity = const Color.fromARGB(179, 255, 255, 255);
  final Color primaryBlueNormal = const Color(0xFF015c91);

  @override
  void initState() {
    super.initState();
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
            Navigator.pop(context, false); // Mengembalikan false
          },
        ),
        title: const Text(
          // Ubah menjadi const Text karena judul selalu "Informasi Makanan"
          'Informasi Makanan', // Selalu tampilkan ini
          style: TextStyle(
            color: Colors.white,
            fontSize: 20,
            fontWeight: FontWeight.bold,
            fontFamily: 'Poppins',
          ),
        ),
        centerTitle: true,
        actions: const [SizedBox(width: 48)],
      ),
      // PERBAIKAN: Langsung panggil _buildFoodDetailView
      body: _buildFoodDetailView(widget.scannedFood),
    );
  }

  // PERBAIKAN: Ubah tipe parameter food menjadi Food
  Widget _buildFoodDetailView(Food food) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          ClipRRect(
            borderRadius: BorderRadius.circular(15),
            child:
                widget.scannedImagePath != null &&
                        widget.scannedImagePath!.isNotEmpty
                    ? Image.file(
                      // BARU: Tampilkan gambar dari path yang dipindai
                      File(widget.scannedImagePath!),
                      width: double.infinity,
                      height: 200,
                      fit: BoxFit.cover,
                      errorBuilder:
                          (context, error, stackTrace) => Image.asset(
                            'assets/images/mock_scanned_food.png', // Fallback jika file tidak dapat dimuat
                            width: double.infinity,
                            height: 200,
                            fit: BoxFit.cover,
                          ),
                    )
                    : (food.imageUrl != null && food.imageUrl!.isNotEmpty
                        ? Image.network(
                          // Fallback ke gambar dari backend
                          food.imageUrl!,
                          width: double.infinity,
                          height: 200,
                          fit: BoxFit.cover,
                          errorBuilder:
                              (context, error, stackTrace) => Image.asset(
                                'assets/images/mock_scanned_food.png', // Fallback jika URL gambar error
                                width: double.infinity,
                                height: 200,
                                fit: BoxFit.cover,
                              ),
                        )
                        : Image.asset(
                          // Fallback ke placeholder default
                          'assets/images/mock_scanned_food.png',
                          width: double.infinity,
                          height: 200,
                          fit: BoxFit.cover,
                        )),
          ),
          const SizedBox(height: 16),
          Text(
            food.name,
            style: TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.bold,
              color: darkerBlue,
              fontFamily: 'Poppins',
            ),
          ),
          const SizedBox(height: 16),
          Container(
            padding: const EdgeInsets.all(16.0),
            decoration: BoxDecoration(
              color: accentBlueColor,
              borderRadius: BorderRadius.circular(15),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withAlpha((255 * 0.2).round()),
                  blurRadius: 10,
                  offset: const Offset(0, 5),
                ),
              ],
            ),
            child: Column(
              children: [
                _buildNutritionRow(
                  'Kalori',
                  '${food.calories.toStringAsFixed(1)} kkal',
                ),
                _buildNutritionRow(
                  'Protein',
                  '${food.protein.toStringAsFixed(1)} gram',
                ),
                _buildNutritionRow(
                  'Lemak total',
                  '${food.fat.toStringAsFixed(1)} gram',
                ),
                _buildNutritionRow(
                  'Lemak jenuh',
                  // PERBAIKAN: Gunakan food.saturatedFat
                  '${food.saturatedFat.toStringAsFixed(1)} gram',
                ),
                _buildNutritionRow(
                  'Karbohidrat',
                  // PERBAIKAN: Gunakan food.carbohydrates
                  '${food.carbohydrates.toStringAsFixed(1)} gram',
                ),
                _buildNutritionRow(
                  'Gula',
                  // PERBAIKAN: Gunakan food.sugar
                  '${food.sugar.toStringAsFixed(1)} gram',
                ),
              ],
            ),
          ),
          const SizedBox(height: 20),
          SizedBox(
            width: double.infinity,
            height: 55,
            child: ElevatedButton(
              onPressed: () {
                debugPrint(
                  'Tambahkan ${food.name} ke Log Makanan. Mengarahkan ke AddMealManualScreen.',
                );

                // Data `food` sudah bertipe `Food`, jadi tidak perlu konversi lagi.
                // Cukup teruskan `food` langsung ke `AddMealManualScreen`.
                Navigator.pushReplacement(
                  context,
                  MaterialPageRoute(
                    builder:
                        (context) => AddMealManualScreen(
                          initialFoodData: food, // Langsung gunakan objek food
                        ),
                  ),
                );
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: primaryBlueNormal,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                elevation: 5,
                shadowColor: Colors.black.withAlpha((255 * 0.2).round()),
              ),
              child: const Text(
                'Tambahkan ke Log',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  fontFamily: 'Poppins',
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildNutritionRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            label,
            style: const TextStyle(
              color: Colors.white,
              fontSize: 16,
              fontFamily: 'Poppins',
            ),
          ),
          Text(
            value,
            style: const TextStyle(
              color: Colors.white,
              fontSize: 16,
              fontWeight: FontWeight.bold,
              fontFamily: 'Poppins',
            ),
          ),
        ],
      ),
    );
  }
}
