// lib/screens/food_scanner_screen.dart
import 'dart:io'; // Untuk File
import 'dart:typed_data'; // Untuk Float32List
import 'package:flutter/material.dart';
import 'package:gogofit_frontend/models/food.dart'; // Import model Food
import 'package:gogofit_frontend/services/api_service.dart'; // Import ApiService
import 'package:gogofit_frontend/screens/add_meal_manual_screen.dart';
import 'package:image_picker/image_picker.dart'; // Import ImagePicker
import 'package:tflite_flutter/tflite_flutter.dart'; // Import TFLite
import 'package:image/image.dart' as img; // Import package image dengan alias

import 'package:gogofit_frontend/screens/food_info_screen.dart';
import 'package:gogofit_frontend/screens/daily_log_screen.dart';

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

  // State untuk mengelola UI dan ML
  File? _image; // File gambar yang dipilih
  final ImagePicker _picker = ImagePicker(); // Instance ImagePicker
  bool _isLoading = false; // Status loading
  String _message =
      'Pilih gambar atau ambil foto makanan Anda.'; // Pesan status
  Interpreter? _interpreter; // Interpreter TFLite
  List<String>? _labels; // Daftar label makanan
  final ApiService _apiService = ApiService(); // Instance ApiService

  @override
  void initState() {
    super.initState();
    // Panggil _loadModel di sini untuk memuat model saat layar diinisialisasi
    _loadModel();
  }

  @override
  void dispose() {
    // Pastikan interpreter ditutup saat widget dibuang untuk menghindari kebocoran memori
    _interpreter?.close();
    super.dispose();
  }

  // Metode untuk memuat model TFLite dan label
  Future<void> _loadModel() async {
    setState(() {
      _isLoading = true;
      _message = 'Memuat model ML...';
    });
    try {
      _interpreter = await Interpreter.fromAsset(
        'assets/ml_models/model_unquant.tflite',
      );
      debugPrint('[_loadModel] Interpreter dimuat.');

      // Pastikan widget masih mounted sebelum menggunakan context
      if (!mounted) {
        debugPrint(
          '[_loadModel] Widget tidak lagi mounted, membatalkan pemuatan label.',
        );
        return;
      }
      // Menggunakan DefaultAssetBundle.of(context) untuk mengakses aset
      String labelsData = await DefaultAssetBundle.of(
        context,
      ).loadString('assets/ml_models/labels.txt');
      _labels =
          labelsData
              .split('\n')
              .map((e) => e.trim())
              .where((e) => e.isNotEmpty)
              .toList();
      debugPrint('[_loadModel] Label dimuat. Jumlah label: ${_labels?.length}');

      // Pastikan widget masih mounted sebelum setState terakhir
      if (!mounted) {
        debugPrint(
          '[_loadModel] Widget tidak lagi mounted, membatalkan update UI.',
        );
        return;
      }
      setState(() {
        _isLoading = false;
        _message = 'Model ML siap! Pilih gambar.';
      });
      debugPrint('Model ML dan label berhasil dimuat.');
    } catch (e) {
      // Pastikan widget masih mounted sebelum setState di catch
      if (!mounted) {
        debugPrint(
          '[_loadModel] Widget tidak lagi mounted saat error, membatalkan update UI.',
        );
        return;
      }
      setState(() {
        _isLoading = false;
        _message = 'Gagal memuat model ML: ${e.toString()}';
      });
      debugPrint('Error loading ML model: $e');
    }
  }

  // Metode untuk memilih gambar dari kamera atau galeri
  Future<void> _pickImage(ImageSource source) async {
    debugPrint('[_pickImage] Memulai pemilihan gambar dari $source');
    if (_isLoading) {
      debugPrint('[_pickImage] Sedang loading, mengabaikan permintaan.');
      return;
    }

    setState(() {
      _isLoading = true;
      _message = 'Mengambil gambar...';
      _image = null; // Reset gambar sebelumnya
    });

    try {
      final pickedFile = await _picker.pickImage(source: source);
      if (pickedFile != null) {
        debugPrint('[_pickImage] Gambar berhasil dipilih: ${pickedFile.path}');
        setState(() {
          _image = File(pickedFile.path);
          _message = 'Gambar berhasil diambil. Menganalisis...';
        });
        await _runInference(
          _image!,
        ); // Jalankan inferensi pada gambar yang dipilih
      } else {
        debugPrint('[_pickImage] Pengambilan gambar dibatalkan.');
        setState(() {
          _isLoading = false;
          _message = 'Pengambilan gambar dibatalkan.';
        });
      }
    } catch (e) {
      debugPrint('[_pickImage] Error saat mengambil gambar: $e');
      setState(() {
        _isLoading = false;
        _message = 'Gagal mengambil gambar: ${e.toString()}';
      });
    }
  }

  // Metode untuk menjalankan inferensi ML dan memproses hasilnya
  Future<void> _runInference(File imageFile) async {
    debugPrint(
      '[_runInference] Memulai inferensi untuk gambar: ${imageFile.path}',
    );
    if (_interpreter == null || _labels == null) {
      debugPrint(
        '[_runInference] Interpreter atau label belum dimuat. Interpreter: ${_interpreter != null}, Labels: ${_labels != null}',
      );
      setState(() {
        _message = 'Model ML belum dimuat sepenuhnya. Mohon tunggu.';
        _isLoading = false;
      });
      return;
    }

    setState(() {
      _message = 'Menganalisis gambar dengan model ML...';
    });

    try {
      debugPrint('[_runInference] Membaca bytes gambar...');
      final bytes = await imageFile.readAsBytes();
      debugPrint('[_runInference] Bytes gambar dibaca. Decoding gambar...');
      img.Image? originalImage = img.decodeImage(bytes);

      if (originalImage == null) {
        debugPrint('[_runInference] Gagal mendekode gambar.');
        setState(() {
          _message = 'Gagal memproses gambar.';
          _isLoading = false;
        });
        return;
      }

      debugPrint('[_runInference] Gambar didekode. Mengubah ukuran gambar...');
      // Periksa dokumentasi model TFLite Anda untuk ukuran input yang tepat
      final inputSize =
          224; // Ganti sesuai ukuran input model Anda (misal: 224x224)
      img.Image resizedImage = img.copyResize(
        originalImage,
        width: inputSize,
        height: inputSize,
      );
      debugPrint(
        '[_runInference] Gambar diubah ukurannya. Mengonversi piksel...',
      );

      // Konversi gambar ke format input yang diharapkan oleh model (misal: Float32List)
      // Ini adalah contoh untuk model yang mengharapkan input [1, inputSize, inputSize, 3] Float32
      // Normalisasi (0-1 atau -1 ke 1) mungkin diperlukan tergantung model Anda
      // Jika model Anda mengharapkan nilai piksel 0-255, hapus `/ 255.0`
      var input = Float32List(1 * inputSize * inputSize * 3);
      var buffer = Float32List.view(input.buffer);
      int pixelIndex = 0;
      for (int i = 0; i < inputSize; i++) {
        for (int j = 0; j < inputSize; j++) {
          var pixel = resizedImage.getPixel(j, i);
          // Menggunakan properti r, g, b dari objek Pixel
          buffer[pixelIndex++] = pixel.r / 255.0; // Normalisasi 0-1
          buffer[pixelIndex++] = pixel.g / 255.0;
          buffer[pixelIndex++] = pixel.b / 255.0;
        }
      }
      debugPrint('[_runInference] Piksel dikonversi. Menyiapkan output...');

      // Siapkan output model. Ukuran output bergantung pada jumlah kelas (label) Anda
      var output = List.filled(
        1 * _labels!.length,
        0,
      ).reshape([1, _labels!.length]);
      debugPrint(
        '[_runInference] Output disiapkan. Menjalankan interpreter...',
      );

      _interpreter!.run(input.buffer, output);
      debugPrint('[_runInference] Inferensi selesai. Memproses hasil...');

      // Proses hasil inferensi
      var outputProbabilities = output[0] as List<double>;
      var maxProb = 0.0;
      var recognizedIndex = -1;

      for (int i = 0; i < outputProbabilities.length; i++) {
        if (outputProbabilities[i] > maxProb) {
          maxProb = outputProbabilities[i];
          recognizedIndex = i;
        }
      }

      String recognizedFoodName = 'Tidak Dikenali';
      Food? identifiedFood;

      if (recognizedIndex != -1 && maxProb > 0.5) {
        // Threshold kepercayaan
        String fullLabel = _labels![recognizedIndex];

        int splitIndex = -1;
        splitIndex = fullLabel.indexOf(' Kalori:');
        if (splitIndex == -1) {
          splitIndex = fullLabel.indexOf(' :');
        }

        if (splitIndex != -1) {
          recognizedFoodName = fullLabel.substring(0, splitIndex).trim();
        } else {
          recognizedFoodName = fullLabel.trim();
        }

        if (recognizedFoodName.isEmpty) {
          recognizedFoodName = 'Tidak Dikenali';
        }

        // Normalisasi nama makanan
        // Ganti non-breaking hyphen (\u2011) dengan hyphen standar (-)
        recognizedFoodName = recognizedFoodName.replaceAll('\u2011', '-');

        // Ganti satu atau lebih spasi dengan satu spasi tunggal
        recognizedFoodName = recognizedFoodName.replaceAll(RegExp(r'\s+'), ' ');

        // BARU: Hapus spasi yang muncul tepat sebelum tanda baca tertentu
        // Contoh: "Sate (5 tusuk )" -> "Sate (5 tusuk)"
        // Contoh: "French Fries: " -> "French Fries:" (lalu colon dihapus di langkah berikutnya)
        recognizedFoodName = recognizedFoodName.replaceAllMapped(
          RegExp(r'\s([:.,;?!)])'), // Cari spasi diikuti oleh tanda baca
          (match) => match.group(1)!, // Ganti dengan tanda baca saja
        );

        // Pembersihan tambahan untuk menghapus ":" dan spasi di akhir
        if (recognizedFoodName.endsWith(':')) {
          recognizedFoodName = recognizedFoodName.substring(
            0,
            recognizedFoodName.length - 1,
          );
        }
        // Pastikan tidak ada spasi di awal atau akhir setelah pembersihan akhir
        recognizedFoodName = recognizedFoodName.trim();

        // Sangat penting untuk debugging: Cetak nama makanan final yang dikirim ke BE
        debugPrint(
          '[_runInference] Nama makanan final yang dikirim ke BE: "$recognizedFoodName"',
        );

        setState(() {
          _message =
              'Makanan teridentifikasi: $recognizedFoodName. Mencocokkan dengan database...';
        });

        final foods = await _apiService.getFoods(query: recognizedFoodName);
        if (foods.isNotEmpty) {
          identifiedFood = foods[0]; // Ambil makanan pertama yang cocok
          setState(() {
            _message = 'Detail makanan berhasil ditemukan!';
          });
          // Navigasi ke FoodInfoScreen dengan data yang teridentifikasi
          if (mounted) {
            // PERBAIKAN: Menunggu hasil dari FoodInfoScreen
            final bool? foodAdded = await Navigator.push(
              context,
              MaterialPageRoute(
                builder:
                    (context) => FoodInfoScreen(
                      scannedFood: identifiedFood!,
                      scannedImagePath: _image?.path,
                    ),
              ),
            );
            // Jika makanan tidak ditambahkan (pengguna menekan 'X'), reset UI
            if (foodAdded == false && mounted) {
              setState(() {
                _image = null; // Hapus gambar yang dipindai
                _message =
                    'Ketuk tombol kamera atau galeri\nuntuk memindai makanan.'; // Reset pesan
              });
            }
          }
        } else {
          // BARU: Jika makanan dikenali oleh ML tapi tidak ada di backend
          // Langsung arahkan ke AddMealManualScreen dengan nama yang dikenali
          debugPrint(
            '[_runInference] Makanan $recognizedFoodName dikenali ML tapi tidak ditemukan di backend. Mengarahkan ke input manual.',
          );
          if (mounted) {
            Navigator.pushReplacement(
              // Menggunakan pushReplacement agar tidak bisa kembali ke FoodScannerScreen dengan tombol back
              context,
              MaterialPageRoute(
                builder:
                    (context) => AddMealManualScreen(
                      initialFoodData: Food(
                        id: 0, // ID dummy
                        name: recognizedFoodName, // Nama yang dikenali ML
                        calories: 0.0,
                        protein: 0.0,
                        carbohydrates: 0.0,
                        fat: 0.0,
                        saturatedFat: 0.0,
                        sugar: 0.0,
                        imageUrl: null,
                      ),
                      message:
                          'Makanan "$recognizedFoodName" tidak ditemukan di database kami. Silakan isi detailnya secara manual.',
                    ),
              ),
            );
          }
        }
      } else {
        // BARU: Jika makanan TIDAK dikenali oleh ML sama sekali
        debugPrint(
          '[_runInference] Makanan tidak dapat dikenali oleh ML. Mengarahkan ke input manual.',
        );
        if (mounted) {
          Navigator.pushReplacement(
            // Menggunakan pushReplacement
            context,
            MaterialPageRoute(
              builder:
                  (context) => AddMealManualScreen(
                    initialFoodData: Food(
                      id: 0,
                      name: '', // Kosongkan nama agar pengguna mengisi sendiri
                      calories: 0.0,
                      protein: 0.0,
                      carbohydrates: 0.0,
                      fat: 0.0,
                      saturatedFat: 0.0,
                      sugar: 0.0,
                      imageUrl: null,
                    ),
                    message:
                        'Maaf, makanan tidak dapat dikenali. Silakan masukkan detailnya secara manual.',
                  ),
            ),
          );
        }
      }
    } catch (e) {
      debugPrint('[_runInference] Error saat menjalankan inferensi ML: $e');
      if (!mounted) {
        debugPrint(
          '[_runInference] Widget tidak lagi mounted saat error, membatalkan update UI.',
        );
        return;
      }
      setState(() {
        _message = 'Terjadi kesalahan saat menganalisis: ${e.toString()}';
      });
      // BARU: Jika terjadi error fatal, arahkan ke input manual
      if (mounted) {
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(
            builder:
                (context) => AddMealManualScreen(
                  initialFoodData: Food(
                    id: 0,
                    name: '',
                    calories: 0.0,
                    protein: 0.0,
                    carbohydrates: 0.0,
                    fat: 0.0,
                    saturatedFat: 0.0,
                    sugar: 0.0,
                    imageUrl: null,
                  ),
                  message:
                      'Terjadi kesalahan saat pemindaian. Silakan masukkan detailnya secara manual.',
                ),
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

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
          // Latar belakang polos (selalu ada)
          Positioned.fill(
            child: Container(
              color: darkerBlue, // Warna latar belakang gelap
            ),
          ),
          // BARU: Tampilkan gambar yang dipilih di tengah dengan ukuran terkontrol
          if (_image != null) // Hanya tampilkan gambar jika sudah ada
            Center(
              child: ClipRRect(
                // Tambahkan ClipRRect untuk sudut membulat
                borderRadius: BorderRadius.circular(
                  15,
                ), // Sesuaikan dengan bingkai
                child: Image.file(
                  _image!,
                  width:
                      MediaQuery.of(context).size.width *
                      0.7, // Sesuaikan dengan lebar bingkai
                  height:
                      MediaQuery.of(context).size.width *
                      0.7, // Sesuaikan dengan tinggi bingkai
                  fit: BoxFit.cover, // Tetap cover agar gambar mengisi area
                ),
              ),
            ),
          // Bingkai Pemindaian hanya muncul saat gambar dipilih dan sedang loading
          if (_image != null && _isLoading)
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
          // Teks instruksi di awal (saat _image null dan tidak loading)
          if (_image == null &&
              !_isLoading) // Hanya tampilkan instruksi jika belum ada gambar dan tidak loading
            Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.camera_alt, size: 80, color: white70Opacity),
                  const SizedBox(height: 20),
                  Text(
                    'Ketuk tombol kamera atau galeri\nuntuk memindai makanan.',
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      color: white70Opacity,
                      fontSize: 18,
                      fontFamily: 'Poppins',
                    ),
                  ),
                ],
              ),
            ),
          // Indikator Loading dan Pesan Status
          if (_isLoading)
            Positioned.fill(
              child: Container(
                color: Colors.black54, // Overlay gelap
                child: Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const CircularProgressIndicator(color: Colors.white),
                      const SizedBox(height: 20),
                      Text(
                        _message,
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 16,
                          fontFamily: 'Poppins',
                        ),
                        textAlign: TextAlign.center,
                      ),
                    ],
                  ),
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
                    icon: Icons.photo_library, // Ganti ikon untuk Galeri
                    label: 'Galeri',
                    onTap:
                        () => _pickImage(
                          ImageSource.gallery,
                        ), // Panggil _pickImage
                    isActive: false, // Tidak ada item aktif default
                  ),
                  _buildBottomNavItem(
                    icon: Icons.history,
                    label: 'History',
                    onTap: () {
                      debugPrint(
                        'History button tapped, navigating to DailyLogScreen.',
                      );
                      // PERBAIKAN: Navigasi ke DailyLogScreen
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder:
                              (context) =>
                                  const DailyLogScreen(), // Ganti dengan DailyLogScreen Anda
                        ),
                      );
                    },
                  ),
                ],
              ),
            ),
          ),
          // Tombol Kamera di tengah bawah (di atas bottom nav)
          Positioned(
            bottom: 70, // Sesuaikan posisi agar di atas bottom nav
            left: MediaQuery.of(context).size.width / 2 - 40,
            child: GestureDetector(
              onTap: () => _pickImage(ImageSource.camera), // Panggil _pickImage
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
