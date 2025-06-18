import 'package:flutter/material.dart';
import 'package:gogofit_frontend/screens/add_meal_manual_screen.dart'; // Import halaman AddMealManualScreen
import 'package:gogofit_frontend/screens/food_scanner_screen.dart'; // Import FoodScannerScreen
import 'package:gogofit_frontend/screens/food_info_screen.dart'; // Import FoodInfoScreen
import 'package:gogofit_frontend/models/meal_data.dart'; // Import MealEntry

class SelectMealScreen extends StatelessWidget {
  const SelectMealScreen({super.key});

  // Definisi warna yang digunakan (diubah menjadi final tanpa const Color(...))
  static final Color headerBackgroundColor = const Color(
    0xFF014a74,
  ); // Normal :active (biru lebih gelap)
  static final Color accentBlueColor = const Color(
    0xFF015c91,
  ); // Normal Blue (biru yang sebelumnya untuk header)

  static final Color darkerBlue = const Color(
    0xFF002033,
  ); // Darker Blue, tidak digunakan langsung di screen ini

  final Color whiteWithOpacity70 = const Color.fromARGB(
    179,
    255,
    255,
    255,
  ); // (255 * 0.7).round() = 179
  final Color blackWithOpacity10 = const Color.fromARGB(
    25,
    0,
    0,
    0,
  ); // (255 * 0.1).round() = 25
  final Color blackWithOpacity20 = const Color.fromARGB(
    51,
    0,
    0,
    0,
  ); // (255 * 0.2).round() = 51

  // Mengubah ini menjadi final dan menghitung value alpha secara langsung
  final Color saranDividerActualColor = const Color.fromARGB(
    76,
    0,
    32,
    51,
  ); // 30% opacity dari darkerBlue (0, 32, 51)

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white, // Background putih untuk keseluruhan layar
      appBar: AppBar(
        backgroundColor:
            headerBackgroundColor, // Warna app bar menjadi biru yang lebih gelap
        elevation: 0,
        leading: IconButton(
          icon: const Icon(
            Icons.close,
            color: Colors.white,
            size: 28,
          ), // Ikon silang putih
          onPressed: () {
            Navigator.pop(context); // Kembali ke halaman sebelumnya
          },
        ),
        title: const Text(
          // Menghilangkan Row dan Icon drop down
          'Pilih Santapan',
          style: TextStyle(
            color: Colors.white,
            fontSize: 20,
            fontWeight: FontWeight.bold,
            fontFamily: 'Poppins',
          ),
        ),
        centerTitle: true, // Pusatkan judul
        actions: const [
          SizedBox(width: 48), // Spacer to balance leading icon
        ],
      ),
      body: Column(
        children: [
          // Bagian atas dengan search bar
          Container(
            padding: const EdgeInsets.all(16.0),
            decoration: BoxDecoration(
              color:
                  headerBackgroundColor, // Warna latar belakang menjadi biru yang lebih gelap
              borderRadius: const BorderRadius.vertical(
                bottom: Radius.circular(30), // Rounded bottom
              ),
              boxShadow: [
                BoxShadow(
                  color: blackWithOpacity20,
                  blurRadius: 10,
                  offset: const Offset(0, 5),
                ),
              ],
            ),
            child: Column(
              children: [
                // Search Bar
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(30),
                    boxShadow: [
                      BoxShadow(
                        color: blackWithOpacity10,
                        blurRadius: 5,
                        offset: const Offset(0, 3),
                      ),
                    ],
                  ),
                  child: TextField(
                    decoration: InputDecoration(
                      hintText: 'Cari Makanan',
                      hintStyle: TextStyle(
                        color: Colors.grey.shade600,
                        fontFamily: 'Poppins',
                        fontSize: 16,
                      ),
                      prefixIcon: Icon(
                        Icons.search,
                        color:
                            headerBackgroundColor, // Icon search juga mengikuti warna header baru
                      ), // Icon search juga mengikuti warna header baru
                      border: InputBorder.none,
                      contentPadding: const EdgeInsets.symmetric(vertical: 14),
                      isDense: true,
                    ),
                    style: TextStyle(
                      fontFamily: 'Poppins',
                      fontSize: 16,
                      color: darkerBlue,
                    ),
                  ),
                ),
              ],
            ),
          ),

          const SizedBox(
            height: 16,
          ), // Jarak antara search bar group dan tombol aksi
          // Tombol Pindai Makanan & Tambah Cepat (di luar container atas)
          Padding(
            padding: const EdgeInsets.symmetric(
              horizontal: 16.0,
            ), // Padding horizontal agar tidak terlalu lebar
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                _buildActionButton(
                  context,
                  icon: Icons.camera_alt,
                  label: 'Pindai makanan',
                  color:
                      accentBlueColor, // Warna tombol menjadi biru yang lebih terang
                  onTap: () {
                    debugPrint(
                      'Pindai makanan clicked, navigating to FoodScannerScreen',
                    );
                    // NAVIGASI KE FOOD SCANNER SCREEN
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => const FoodScannerScreen(),
                      ),
                    );
                  },
                ),
                _buildActionButton(
                  context,
                  icon: Icons.local_fire_department, // Ikon api
                  label: 'Tambah Cepat',
                  color:
                      accentBlueColor, // Warna tombol menjadi biru yang lebih terang
                  onTap: () {
                    debugPrint('Tambah Cepat clicked');
                    // Navigasi ke AddMealManualScreen
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => const AddMealManualScreen(),
                      ),
                    );
                  },
                ),
              ],
            ),
          ),

          // Bagian Saran Makanan
          Expanded(
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    // Menggunakan Row untuk menambahkan aksen dekoratif
                    children: [
                      Expanded(
                        child: Container(
                          // Mengganti Divider dengan Container
                          height: 1.5, // Ketebalan garis
                          color:
                              saranDividerActualColor, // Menggunakan static final warna garis Saran
                          margin: const EdgeInsets.only(
                            right: 10,
                          ), // Jarak ke teks
                        ),
                      ),
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 10.0),
                        child: Text(
                          'Saran',
                          style: TextStyle(
                            color: darkerBlue,
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                            fontFamily: 'Poppins',
                          ),
                        ),
                      ),
                      Expanded(
                        child: Container(
                          // Mengganti Divider dengan Container
                          height: 1.5, // Ketebalan garis
                          color:
                              saranDividerActualColor, // Menggunakan static final warna garis Saran
                          margin: const EdgeInsets.only(
                            left: 10,
                          ), // Jarak ke teks
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 10),
                  Expanded(
                    child: ListView(
                      children: [
                        // MODIFIKASI: Menambahkan onTap untuk menavigasi ke FoodInfoScreen
                        _buildMealSuggestionCard(
                          context, // Pass context
                          MealEntry(
                            name: 'Tahu',
                            calories: 78.0,
                            fat: 4.8,
                            saturatedFat: 0.7, // Dummy
                            carbs: 1.9,
                            protein: 8.1,
                            sugar: 0.5, // Dummy
                            timestamp: DateTime.now(),
                            mealType: 'Camilan',
                          ),
                          icon: Icons.grain,
                          // DIUBAH: isComingFromScan = false karena bukan dari scan
                          isComingFromScan: false,
                        ),
                        _buildMealSuggestionCard(
                          context, // Pass context
                          MealEntry(
                            name: 'Ayam Goreng Dada',
                            calories: 216.0,
                            fat: 12.0,
                            saturatedFat: 3.5, // Dummy
                            carbs: 0.0,
                            protein: 25.0,
                            sugar: 0.0, // Dummy
                            timestamp: DateTime.now(),
                            mealType: 'Makan Siang',
                          ),
                          icon: Icons.fastfood,
                          // DIUBAH: isComingFromScan = false karena bukan dari scan
                          isComingFromScan: false,
                        ),
                        _buildMealSuggestionCard(
                          context, // Pass context
                          MealEntry(
                            name: 'Telur Dadar',
                            calories: 154.0,
                            fat: 11.0,
                            saturatedFat: 3.0, // Dummy
                            carbs: 1.0,
                            protein: 13.0,
                            sugar: 0.0, // Dummy
                            timestamp: DateTime.now(),
                            mealType: 'Sarapan',
                          ),
                          icon: Icons.egg,
                          // DIUBAH: isComingFromScan = false karena bukan dari scan
                          isComingFromScan: false,
                        ),
                        // Tambahkan lebih banyak saran makanan di sini
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildActionButton(
    BuildContext context, {
    required IconData icon,
    required String label,
    required Color color,
    required VoidCallback onTap,
  }) {
    return Expanded(
      child: GestureDetector(
        onTap: onTap,
        child: Container(
          height: 100, // Tinggi tombol
          margin: const EdgeInsets.symmetric(horizontal: 8),
          decoration: BoxDecoration(
            color: color,
            borderRadius: BorderRadius.circular(15),
            boxShadow: [
              BoxShadow(
                color: blackWithOpacity20,
                blurRadius: 8,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(icon, color: Colors.white, size: 40), // Ikon lebih besar
              const SizedBox(height: 8),
              Text(
                label,
                textAlign: TextAlign.center,
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                  fontFamily: 'Poppins',
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  // MODIFIKASI: Menerima BuildContext dan MealEntry, serta memiliki onTap
  // Tambahkan parameter isComingFromScan
  Widget _buildMealSuggestionCard(
    BuildContext context,
    MealEntry food, {
    IconData? icon,
    bool isComingFromScan = false, // Parameter BARU: isComingFromScan
  }) {
    return Card(
      margin: const EdgeInsets.symmetric(vertical: 8.0),
      elevation: 4,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      color:
          accentBlueColor, // Latar belakang card saran makanan menjadi biru yang lebih terang
      child: InkWell(
        onTap: () {
          debugPrint('Tapped on suggestion: ${food.name}');
          Navigator.push(
            context,
            MaterialPageRoute(
              builder:
                  (context) => FoodInfoScreen(
                    scannedFood: food,
                    initialShowDetail:
                        true, // Saran makanan selalu langsung ke detail
                    isComingFromScan:
                        isComingFromScan, // Gunakan parameter yang diterima
                  ),
            ),
          );
        },
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Row(
            children: [
              if (icon != null) ...[
                Icon(icon, color: Colors.white, size: 24),
                const SizedBox(width: 12),
              ],
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      food.name, // Gunakan nama dari MealEntry
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        fontFamily: 'Poppins',
                      ),
                    ),
                    Text(
                      '${food.calories.toStringAsFixed(1)} kkal, ${food.carbs.toStringAsFixed(1)} gr Karbohidrat', // Ringkasan dari MealEntry
                      style: TextStyle(
                        color: whiteWithOpacity70,
                        fontSize: 14,
                        fontFamily: 'Poppins',
                      ),
                    ),
                  ],
                ),
              ),
              IconButton(
                icon: Icon(
                  Icons.add_circle,
                  color: Colors.white,
                  size: 30,
                ), // Ikon tambah dengan warna putih
                onPressed: () {
                  debugPrint('Add ${food.name} to meal');
                  // UBAH: Meneruskan data melalui initialMealData (mode tambah baru dengan pre-fill)
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder:
                          (context) => AddMealManualScreen(
                            initialMealData: food, // Gunakan initialMealData
                          ),
                    ),
                  );
                },
              ),
            ],
          ),
        ),
      ),
    );
  }
}
