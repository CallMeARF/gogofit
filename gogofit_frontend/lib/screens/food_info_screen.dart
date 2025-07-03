// lib/screens/food_info_screen.dart
import 'package:flutter/material.dart';
import 'package:gogofit_frontend/models/meal_data.dart'; // Import MealEntry
import 'package:gogofit_frontend/models/food.dart'; // <-- BARU: Import model Food untuk konversi
import 'package:gogofit_frontend/screens/add_meal_manual_screen.dart'; // Import AddMealManualScreen

class FoodInfoScreen extends StatefulWidget {
  final MealEntry scannedFood;
  final bool initialShowDetail;
  final bool isComingFromScan;

  const FoodInfoScreen({
    super.key,
    required this.scannedFood,
    this.initialShowDetail = true,
    this.isComingFromScan = false,
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

  // Dummy data untuk makanan terkait
  final List<MealEntry> relatedFoods = [
    MealEntry(
      name: 'Ayam Geprek',
      calories: 320.0,
      fat: 25.0,
      saturatedFat: 8.0, // Dummy
      carbs: 10.0,
      protein: 20.0,
      sugar: 0.5,
      timestamp: DateTime.now(),
      mealType: 'Makan Siang', // Set default mealType untuk dummy data
    ),
    MealEntry(
      name: 'Timun',
      calories: 15.0,
      fat: 0.1,
      saturatedFat: 0.0, // Dummy
      carbs: 3.6,
      protein: 0.7,
      sugar: 1.7,
      timestamp: DateTime.now(),
      mealType: 'Camilan', // Set default mealType untuk dummy data
    ),
    MealEntry(
      name: 'Nasi Putih',
      calories: 209.0,
      fat: 0.4,
      saturatedFat: 0.1, // Dummy
      carbs: 45.0,
      protein: 4.3,
      sugar: 0.1,
      timestamp: DateTime.now(),
      mealType: 'Makan Siang', // Set default mealType untuk dummy data
    ),
  ];

  bool _showDetail = false;
  MealEntry? _currentFoodDetail;

  @override
  void initState() {
    super.initState();
    _currentFoodDetail = widget.scannedFood;
    _showDetail = widget.initialShowDetail;
  }

  void _showRelatedFoodDetail(MealEntry food) {
    setState(() {
      _currentFoodDetail = food;
      _showDetail = true;
    });
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
            if (widget.isComingFromScan && _showDetail) {
              setState(() {
                _showDetail =
                    false; // Kembali ke daftar terkait (hasil pemindaian)
                _currentFoodDetail =
                    null; // Reset detail saat kembali ke daftar
              });
            } else {
              Navigator.pop(context); // Keluar dari halaman
            }
          },
        ),
        title: Text(
          _showDetail ? 'Informasi Makanan' : 'Hasil Pemindaian',
          style: const TextStyle(
            color: Colors.white,
            fontSize: 20,
            fontWeight: FontWeight.bold,
            fontFamily: 'Poppins',
          ),
        ),
        centerTitle: true,
        actions: const [SizedBox(width: 48)],
      ),
      body:
          _showDetail
              ? _buildFoodDetailView(_currentFoodDetail!)
              : _buildRelatedFoodListView(),
    );
  }

  Widget _buildRelatedFoodListView() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        if (widget
            .scannedFood
            .name
            .isNotEmpty) // Cek ini agar gambar hanya muncul jika ada makanan
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                ClipRRect(
                  borderRadius: BorderRadius.circular(15),
                  child: Image.asset(
                    'assets/images/mock_scanned_food.png', // Background gambar Anda
                    width: double.infinity,
                    height: 200,
                    fit: BoxFit.cover,
                  ),
                ),
                const SizedBox(height: 16),
                Text(
                  'Makanan Terkait:',
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                    color: darkerBlue,
                    fontFamily: 'Poppins',
                  ),
                ),
              ],
            ),
          ),
        Expanded(
          child: ListView.builder(
            padding: const EdgeInsets.symmetric(horizontal: 16.0),
            itemCount: relatedFoods.length,
            itemBuilder: (context, index) {
              final food = relatedFoods[index];
              return _buildRelatedFoodCard(food);
            },
          ),
        ),
        // Tombol "Lihat Lebih Lengkap" telah dihapus sepenuhnya.
      ],
    );
  }

  Widget _buildRelatedFoodCard(MealEntry food) {
    return Card(
      margin: const EdgeInsets.symmetric(vertical: 8.0),
      elevation: 4,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      color: accentBlueColor,
      child: InkWell(
        onTap: () => _showRelatedFoodDetail(food),
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Row(
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      food.name,
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        fontFamily: 'Poppins',
                      ),
                    ),
                    Text(
                      '${food.calories.toStringAsFixed(1)} kkal, ${food.carbs.toStringAsFixed(1)} gr Karbohidrat',
                      style: TextStyle(
                        color: white70Opacity,
                        fontSize: 14,
                        fontFamily: 'Poppins',
                      ),
                    ),
                  ],
                ),
              ),
              Icon(Icons.arrow_forward_ios, color: Colors.white, size: 20),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildFoodDetailView(MealEntry food) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          ClipRRect(
            borderRadius: BorderRadius.circular(15),
            child: Image.asset(
              'assets/images/mock_scanned_food.png',
              width: double.infinity,
              height: 200,
              fit: BoxFit.cover,
            ),
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
                  '${food.saturatedFat.toStringAsFixed(1)} gram',
                ),
                _buildNutritionRow(
                  'Karbohidrat',
                  '${food.carbs.toStringAsFixed(1)} gram',
                ),
                _buildNutritionRow(
                  'Gula',
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

                // BARU: Konversi objek MealEntry ke Food sebelum navigasi
                final foodForNextScreen = Food(
                  // --- FIX: Melakukan casting eksplisit dari Object? ke int ---
                  id: (food.id as int?) ?? 0,
                  name: food.name,
                  calories: food.calories,
                  protein: food.protein,
                  carbohydrates:
                      food.carbs, // Mapping dari 'carbs' ke 'carbohydrates'
                  fat: food.fat,
                  saturatedFat: food.saturatedFat,
                  sugar: food.sugar,
                  imageUrl:
                      null, // imageUrl tidak tersedia di MealEntry, jadi kita set null
                );

                Navigator.pushReplacement(
                  context,
                  MaterialPageRoute(
                    builder:
                        (context) => AddMealManualScreen(
                          initialFoodData: foodForNextScreen,
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
