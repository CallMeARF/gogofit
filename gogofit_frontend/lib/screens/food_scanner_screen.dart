// lib/screens/food_scanner_screen.dart
import 'package:flutter/material.dart';
import 'package:gogofit_frontend/models/meal_data.dart';
import 'package:gogofit_frontend/screens/food_info_screen.dart';

class FoodScannerScreen extends StatefulWidget {
  const FoodScannerScreen({super.key});

  @override
  State<FoodScannerScreen> createState() => _FoodScannerScreenState();
}

class _FoodScannerScreenState extends State<FoodScannerScreen> {
  // Warna yang konsisten dengan desain Gogofit
  final Color primaryBlueNormal = const Color(0xFF015c91);
  final Color darkerBlue = const Color(0xFF002033);
  final Color white70Opacity = const Color.fromARGB(179, 255, 255, 255);

  // Dummy data untuk hasil scan/ML. Nanti akan diganti dengan hasil sebenarnya.
  final MealEntry dummyScannedFood = MealEntry(
    name: 'Ayam Geprek', // Ini akan menjadi makanan utama yang 'terpindai'
    calories: 320,
    fat: 25.0,
    saturatedFat: 8.0,
    carbs: 10.0,
    protein: 20.0,
    sugar: 0.5,
    timestamp: DateTime.now(),
    mealType: 'Makan Siang',
  );

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      extendBodyBehindAppBar: true,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.close, color: Colors.white, size: 28),
          onPressed: () {
            Navigator.pop(context);
          },
        ),
        title: const Text(
          'Pindai Makanan',
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
      body: Stack(
        children: [
          // Placeholder untuk Preview Kamera
          Positioned.fill(
            child: Image.asset(
              'assets/images/mock_food_scanner_bg.png', // Background gambar Anda
              fit: BoxFit.cover,
            ),
          ),
          // Overlay Pemindaian (bingkai putih persegi)
          Center(
            child: Container(
              width: MediaQuery.of(context).size.width * 0.7,
              height: MediaQuery.of(context).size.width * 0.7,
              decoration: BoxDecoration(
                border: Border.all(color: Colors.white, width: 3),
                borderRadius: BorderRadius.circular(15),
              ),
            ),
          ),
          // Navigasi Bawah
          Align(
            alignment: Alignment.bottomCenter,
            child: Container(
              height: 120,
              decoration: BoxDecoration(
                color: primaryBlueNormal,
                borderRadius: const BorderRadius.vertical(
                  top: Radius.circular(30),
                ),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withAlpha((255 * 0.3).round()),
                    blurRadius: 10,
                    offset: const Offset(0, -5),
                  ),
                ],
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceAround,
                children: [
                  _buildBottomNavItem(
                    icon: Icons.camera_alt,
                    label: 'Scan',
                    onTap: () {
                      debugPrint(
                        'Scan button tapped, navigating to FoodInfoScreen for results.',
                      );
                      // NAVIGASI KE FOOD INFO SCREEN, TAPI MULAI DARI TAHAP 1 (HASIL PEMINDAIAN/LIST)
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder:
                              (context) => FoodInfoScreen(
                                scannedFood: dummyScannedFood,
                                initialShowDetail:
                                    false, // DIUBAH: Mengatur untuk menampilkan daftar terkait duluan
                              ),
                        ),
                      );
                    },
                    isActive: true,
                  ),
                  _buildBottomNavItem(
                    icon: Icons.history,
                    label: 'History',
                    onTap: () {
                      debugPrint('History button tapped');
                    },
                  ),
                ],
              ),
            ),
          ),
          // Tombol Kamera di tengah bawah
          Positioned(
            bottom: 70,
            left: MediaQuery.of(context).size.width / 2 - 40,
            child: GestureDetector(
              onTap: () {
                debugPrint(
                  'Camera button tapped! Navigating to FoodInfoScreen for results.',
                );
                // NAVIGASI KE FOOD INFO SCREEN, TAPI MULAI DARI TAHAP 1 (HASIL PEMINDAIAN/LIST)
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder:
                        (context) => FoodInfoScreen(
                          scannedFood: dummyScannedFood,
                          initialShowDetail:
                              false, // DIUBAH: Mengatur untuk menampilkan daftar terkait duluan
                        ),
                  ),
                );
              },
              child: Container(
                width: 80,
                height: 80,
                decoration: BoxDecoration(
                  color: Colors.white,
                  shape: BoxShape.circle,
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withAlpha((255 * 0.4).round()),
                      blurRadius: 15,
                      offset: const Offset(0, 5),
                    ),
                  ],
                ),
                child: Icon(
                  Icons.camera_alt,
                  color: primaryBlueNormal,
                  size: 40,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildBottomNavItem({
    required IconData icon,
    required String label,
    required VoidCallback onTap,
    bool isActive = false,
  }) {
    return InkWell(
      onTap: onTap,
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(icon, color: isActive ? Colors.white : white70Opacity, size: 30),
          const SizedBox(height: 4),
          Text(
            label,
            style: TextStyle(
              color: isActive ? Colors.white : white70Opacity,
              fontSize: 14,
              fontFamily: 'Poppins',
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }
}
