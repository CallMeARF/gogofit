import 'dart:async';
import 'package:flutter/material.dart';
import 'package:gogofit_frontend/models/food.dart';
// Import MealEntry tidak lagi diperlukan di file ini
// import 'package:gogofit_frontend/models/meal_data.dart';
import 'package:gogofit_frontend/services/api_service.dart';
import 'package:gogofit_frontend/screens/add_meal_manual_screen.dart';
import 'package:gogofit_frontend/screens/food_scanner_screen.dart';

// Mengubah widget menjadi StatefulWidget untuk mengelola state
class SelectMealScreen extends StatefulWidget {
  const SelectMealScreen({super.key});

  // Definisi warna tetap di sini agar konsisten dengan gaya asli
  static final Color headerBackgroundColor = const Color(0xFF014a74);
  static final Color accentBlueColor = const Color(0xFF015c91);
  static final Color darkerBlue = const Color(0xFF002033);

  @override
  State<SelectMealScreen> createState() => _SelectMealScreenState();
}

class _SelectMealScreenState extends State<SelectMealScreen> {
  final ApiService _apiService = ApiService();
  final TextEditingController _searchController = TextEditingController();
  final ScrollController _scrollController = ScrollController();
  Timer? _debounce;

  final List<Food> _foods = [];
  bool _isLoading = false;
  bool _isFirstLoad = true;
  String? _errorMessage;
  int _currentPage = 1;
  int? _lastPage;
  bool _isLoadingMore = false;

  // Variabel warna dari kode asli, dipindahkan ke sini dari build method
  final Color whiteWithOpacity70 = const Color.fromARGB(179, 255, 255, 255);
  final Color blackWithOpacity10 = const Color.fromARGB(25, 0, 0, 0);
  final Color blackWithOpacity20 = const Color.fromARGB(51, 0, 0, 0);
  final Color saranDividerActualColor = const Color.fromARGB(76, 0, 32, 51);

  @override
  void initState() {
    super.initState();
    _searchController.addListener(_onSearchChanged);
    _scrollController.addListener(_onScroll);
    _fetchFoods(); // Memuat data saran awal
  }

  @override
  void dispose() {
    _searchController.removeListener(_onSearchChanged);
    _searchController.dispose();
    _scrollController.dispose();
    _debounce?.cancel();
    super.dispose();
  }

  /// Fungsi untuk memanggil API foods
  Future<void> _fetchFoods({bool isNewSearch = false}) async {
    if (_isLoading) return;

    setState(() {
      _isLoading = true;
      if (isNewSearch) {
        _foods.clear();
        _currentPage = 1;
        _lastPage = null;
        _isFirstLoad = false;
      }
      _errorMessage = null;
    });

    try {
      final response = await _apiService.fetchMasterFoods(
        query: _searchController.text,
        page: _currentPage,
      );

      if (!mounted) return;

      setState(() {
        _foods.addAll(response['foods']);
        _lastPage = response['meta']['last_page'];
      });
    } catch (e) {
      if (!mounted) return;
      setState(() {
        _errorMessage = e.toString();
      });
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
          _isLoadingMore = false;
        });
      }
    }
  }

  /// Fungsi debouncing untuk menunda pencarian
  void _onSearchChanged() {
    if (_debounce?.isActive ?? false) _debounce!.cancel();
    _debounce = Timer(const Duration(milliseconds: 500), () {
      // Perbarui judul secara manual saat teks berubah
      setState(() {});
      _fetchFoods(isNewSearch: true);
    });
  }

  /// Fungsi untuk infinite scrolling
  void _onScroll() {
    if (_scrollController.position.pixels >=
            _scrollController.position.maxScrollExtent - 200 &&
        !_isLoadingMore) {
      if (_lastPage != null && _currentPage < _lastPage!) {
        setState(() {
          _isLoadingMore = true;
          _currentPage++;
        });
        _fetchFoods();
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    // Judul dinamis berdasarkan input pencarian
    final String listTitle =
        _searchController.text.isEmpty ? 'Saran' : 'Hasil Pencarian';

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: SelectMealScreen.headerBackgroundColor,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.close, color: Colors.white, size: 28),
          onPressed: () {
            Navigator.pop(context);
          },
        ),
        title: const Text(
          'Pilih Santapan',
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
      body: Column(
        children: [
          // Bagian header dengan search bar (Struktur asli dipertahankan)
          Container(
            padding: const EdgeInsets.all(16.0),
            decoration: BoxDecoration(
              color: SelectMealScreen.headerBackgroundColor,
              borderRadius: const BorderRadius.vertical(
                bottom: Radius.circular(30),
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
                    controller: _searchController, // Menggunakan controller
                    decoration: InputDecoration(
                      hintText: 'Cari Nasi Goreng, Ayam Bakar...',
                      hintStyle: TextStyle(
                        color: Colors.grey.shade600,
                        fontFamily: 'Poppins',
                        fontSize: 16,
                      ),
                      prefixIcon: Icon(
                        Icons.search,
                        color: SelectMealScreen.headerBackgroundColor,
                      ),
                      border: InputBorder.none,
                      contentPadding: const EdgeInsets.symmetric(vertical: 14),
                      isDense: true,
                    ),
                    style: TextStyle(
                      fontFamily: 'Poppins',
                      fontSize: 16,
                      color: SelectMealScreen.darkerBlue,
                    ),
                  ),
                ),
              ],
            ),
          ),

          const SizedBox(height: 16),

          // Tombol Aksi (Struktur asli dipertahankan)
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16.0),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                _buildActionButton(
                  context,
                  icon: Icons.camera_alt,
                  label: 'Pindai makanan',
                  color: SelectMealScreen.accentBlueColor,
                  onTap: () {
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
                  icon: Icons.local_fire_department,
                  label: 'Tambah Cepat',
                  color: SelectMealScreen.accentBlueColor,
                  onTap: () {
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

          const SizedBox(height: 10),

          Padding(
            padding: const EdgeInsets.fromLTRB(16.0, 16.0, 16.0, 8.0),
            child: Row(
              children: [
                Expanded(
                  child: Container(
                    height: 1.5,
                    color: saranDividerActualColor,
                    margin: const EdgeInsets.only(right: 10),
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 10.0),
                  child: Text(
                    listTitle, // Menggunakan judul dinamis
                    style: TextStyle(
                      color: SelectMealScreen.darkerBlue,
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      fontFamily: 'Poppins',
                    ),
                  ),
                ),
                Expanded(
                  child: Container(
                    height: 1.5,
                    color: saranDividerActualColor,
                    margin: const EdgeInsets.only(left: 10),
                  ),
                ),
              ],
            ),
          ),

          Expanded(child: _buildResultsList()),
        ],
      ),
    );
  }

  /// Widget untuk membangun daftar hasil pencarian/saran secara dinamis.
  Widget _buildResultsList() {
    if (_isLoading && _foods.isEmpty) {
      return const Center(child: CircularProgressIndicator());
    }

    if (_errorMessage != null) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Text(
            'Gagal memuat data: $_errorMessage',
            textAlign: TextAlign.center,
          ),
        ),
      );
    }

    if (_foods.isEmpty && !_isFirstLoad) {
      return const Center(
        child: Text(
          'Makanan tidak ditemukan.',
          style: TextStyle(fontSize: 16, color: Colors.grey),
        ),
      );
    }

    return ListView.builder(
      controller: _scrollController,
      padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
      itemCount: _foods.length + (_isLoadingMore ? 1 : 0),
      itemBuilder: (context, index) {
        if (index == _foods.length) {
          return const Center(
            child: Padding(
              padding: EdgeInsets.all(8.0),
              child: CircularProgressIndicator(),
            ),
          );
        }
        final food = _foods[index];
        // Menggunakan widget card baru untuk data dari API
        return _buildFoodItemCard(food);
      },
    );
  }

  /// Widget card untuk setiap item makanan dari API.
  Widget _buildFoodItemCard(Food food) {
    return Card(
      margin: const EdgeInsets.symmetric(vertical: 6.0),
      elevation: 3,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      color: Colors.white,
      child: Padding(
        padding: const EdgeInsets.all(12.0),
        child: Row(
          children: [
            // --- KODE BARU DITERAPKAN DI SINI ---
            ClipRRect(
              borderRadius: BorderRadius.circular(8.0),
              child:
                  (food.imageUrl != null)
                      // Jika URL gambar ada, tampilkan dari internet.
                      ? Image.network(
                        food.imageUrl!,
                        width: 70,
                        height: 70,
                        fit: BoxFit.cover,
                        errorBuilder: (context, error, stackTrace) {
                          // Fallback jika URL dari API error
                          return Container(
                            width: 70,
                            height: 70,
                            color: Colors.grey[200],
                            child: Icon(
                              Icons.restaurant,
                              color: Colors.grey[400],
                            ),
                          );
                        },
                      )
                      // Jika URL gambar tidak ada, langsung tampilkan placeholder lokal.
                      : Container(
                        width: 70,
                        height: 70,
                        color: Colors.grey[200],
                        child: Icon(Icons.restaurant, color: Colors.grey[400]),
                      ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    food.name,
                    style: TextStyle(
                      fontSize: 17,
                      fontWeight: FontWeight.bold,
                      fontFamily: 'Poppins',
                      color: SelectMealScreen.darkerBlue,
                    ),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 4),
                  Text(
                    '${food.calories.toStringAsFixed(0)} kkal • 1 Porsi',
                    style: TextStyle(
                      fontSize: 14,
                      color: Colors.grey.shade600,
                      fontFamily: 'Poppins',
                    ),
                  ),
                ],
              ),
            ),
            IconButton(
              icon: Icon(
                Icons.add_circle,
                color: SelectMealScreen.headerBackgroundColor,
                size: 32,
              ),
              onPressed: () {
                // LANGSUNG KIRIM OBJEK 'Food' UTUH.
                // Ini akan memastikan semua data nutrisi (termasuk karbohidrat, gula, dll.)
                // ikut terbawa ke layar berikutnya tanpa ada yang hilang.
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder:
                        (context) => AddMealManualScreen(
                          // PENTING: Nama parameter diubah menjadi `initialFoodData`
                          initialFoodData: food,
                        ),
                  ),
                );
              },
            ),
          ],
        ),
      ),
    );
  }

  // Widget _buildActionButton dipertahankan seperti aslinya
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
          height: 100,
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
              Icon(icon, color: Colors.white, size: 40),
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
}
