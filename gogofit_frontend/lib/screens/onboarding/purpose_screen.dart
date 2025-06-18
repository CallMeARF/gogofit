import 'package:flutter/material.dart';
import 'package:gogofit_frontend/screens/dashboard_screen.dart'; // Import DashboardScreen
import 'package:gogofit_frontend/services/api_service.dart'; // Import ApiService
import 'package:gogofit_frontend/models/user_profile_data.dart'; // BARU: Import UserProfile model (Diperlukan!)

class PurposeScreen extends StatefulWidget {
  final Map<String, dynamic> registrationData;

  const PurposeScreen({super.key, required this.registrationData});

  @override
  State<PurposeScreen> createState() => _PurposeScreenState();
}

class _PurposeScreenState extends State<PurposeScreen> {
  String? _selectedPurpose; // Menyimpan tujuan yang dipilih
  final ApiService _apiService = ApiService(); // Inisialisasi ApiService
  bool _isRegistering = false; // Untuk mengelola state loading

  @override
  void initState() {
    super.initState();
    // Inisialisasi tujuan jika sudah ada di data (misal dari edit profil atau skip)
    if (widget.registrationData.containsKey('purpose') &&
        widget.registrationData['purpose'] != null) {
      _selectedPurpose = widget.registrationData['purpose'];
    }
  }

  Future<void> _completeRegistration({bool skipPurpose = false}) async {
    if (!skipPurpose && _selectedPurpose == null) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('Mohon pilih tujuan Anda.')));
      return;
    }

    setState(() {
      _isRegistering = true; // Set loading state
    });

    final Map<String, dynamic> finalRegistrationData =
        Map<String, dynamic>.from(widget.registrationData);
    if (skipPurpose) {
      finalRegistrationData['purpose'] = null; // Set null jika diskip
    } else {
      finalRegistrationData['purpose'] =
          _selectedPurpose; // Simpan tujuan yang dipilih
    }

    debugPrint('Final Registration Data: $finalRegistrationData');

    try {
      String? bePurpose;
      if (finalRegistrationData['purpose'] != null) {
        if (finalRegistrationData['purpose'] == 'Menurunkan Berat Badan') {
          bePurpose = 'lose_weight';
        } else if (finalRegistrationData['purpose'] ==
            'Menaikkan Berat Badan') {
          bePurpose = 'gain_weight';
        } else if (finalRegistrationData['purpose'] == 'Menjaga Kesehatan') {
          bePurpose = 'stay_healthy';
        }
      }

      String? beGender;
      if (finalRegistrationData['gender'] != null) {
        if (finalRegistrationData['gender'] == 'Laki-laki') {
          beGender = 'male';
        } else if (finalRegistrationData['gender'] == 'Perempuan') {
          beGender = 'female';
        }
      }

      final response = await _apiService.register(
        name: finalRegistrationData['name']!,
        email: finalRegistrationData['email']!,
        password: finalRegistrationData['password']!,
        passwordConfirmation: finalRegistrationData['passwordConfirmation']!,
        gender: beGender, // Gunakan gender yang sudah dipetakan
        birthDate: finalRegistrationData['birthDate'],
        heightCm: finalRegistrationData['heightCm'],
        currentWeightKg: finalRegistrationData['currentWeightKg'],
        targetWeightKg: finalRegistrationData['targetWeightKg'],
        purpose: bePurpose, // Gunakan purpose yang sudah dipetakan
      );

      // Pastikan context masih mounted sebelum melakukan navigasi atau show dialog
      if (!mounted) return;

      setState(() {
        _isRegistering = false; // Selesai loading
      });

      if (response['success']) {
        // BARU: Setelah registrasi berhasil, ambil data profil terbaru
        // Pastikan UserProfile dan currentUserProfile didefinisikan atau diimpor dengan benar
        // Jika belum ada, Anda mungkin perlu dummy atau implementasi yang sebenarnya.
        // Contoh dummy jika belum ada:
        // final currentUserProfile = ValueNotifier<UserProfile>(UserProfile(name: '', email: '', gender: '', birthDate: DateTime.now(), heightCm: 0, currentWeightKg: 0, targetWeightKg: 0));
        // UserProfile getDietPurposeEnum(String purpose) => UserProfile(name: '', email: '', gender: '', birthDate: DateTime.now(), heightCm: 0, currentWeightKg: 0, targetWeightKg: 0);

        final UserProfile? fetchedProfile = await _apiService.getUserProfile();

        // FIX: Cek mounted lagi setelah fetching profil
        if (!mounted) return;

        if (fetchedProfile != null) {
          currentUserProfile.value =
              fetchedProfile; // Perbarui ValueNotifier global
          debugPrint(
            'User profile updated after successful registration: ${fetchedProfile.name}',
          );
        } else {
          debugPrint(
            'Failed to fetch user profile immediately after registration.',
          );
        }

        _showAlertDialog(
          'Sukses',
          response['message'] ?? 'Registrasi berhasil!',
          () {
            if (!mounted) return;
            // Registrasi sukses, langsung ke Dashboard
            Navigator.of(context).pushAndRemoveUntil(
              MaterialPageRoute(builder: (context) => const DashboardScreen()),
              (Route<dynamic> route) => false,
            );
          },
        );
      } else {
        _showAlertDialog(
          'Error',
          response['message'] ?? 'Registrasi gagal. Mohon coba lagi.',
        );
      }
    } catch (e) {
      if (!mounted) return; // Check mounted before setState in catch block too
      setState(() {
        _isRegistering = false; // Selesai loading
      });
      debugPrint('Registration Error: $e');
      _showAlertDialog('Error', 'Terjadi kesalahan saat registrasi: $e');
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
              child: const Text(
                'OK',
                style: TextStyle(
                  fontFamily: 'Poppins',
                  color: Color(0xFF015C91),
                ),
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
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: Padding(
          padding: const EdgeInsets.only(left: 10.0, top: 5.0, bottom: 5.0),
          child: Container(
            decoration: BoxDecoration(
              color: Colors.grey.shade200, // Warna abu-abu background icon back
              borderRadius: BorderRadius.circular(10),
            ),
            child: IconButton(
              icon: const Icon(
                Icons.arrow_back_ios,
                color: Colors.black,
              ), // Warna ikon back hitam
              onPressed: () {
                Navigator.of(context).pop();
              },
            ),
          ),
        ),
        actions: [
          Padding(
            padding: const EdgeInsets.only(right: 10.0, top: 5.0, bottom: 5.0),
            child: Container(
              decoration: BoxDecoration(
                color:
                    Colors
                        .grey
                        .shade200, // Warna abu-abu background tombol Skip
                borderRadius: BorderRadius.circular(10),
              ),
              child: TextButton(
                onPressed:
                    () => _completeRegistration(
                      skipPurpose: true,
                    ), // Panggil completeRegistration dengan skip
                child: const Text(
                  'Skip',
                  style: TextStyle(
                    color: Colors.black, // Warna teks Skip hitam
                    fontSize: 16,
                    fontFamily: 'Poppins', // Font Poppins
                    fontWeight: FontWeight.w500, // SemiBold atau Medium
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
      body:
          _isRegistering // Tampilkan loading indicator jika sedang memproses registrasi
              ? const Center(
                child: CircularProgressIndicator(color: Colors.blue),
              )
              : Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    const SizedBox(height: 20),
                    RichText(
                      textAlign: TextAlign.center,
                      text: TextSpan(
                        style: TextStyle(
                          fontSize: 24,
                          fontWeight: FontWeight.bold,
                          color: const Color(0xFF002033), // Darker Blue
                          fontFamily: 'Poppins', // Font Poppins
                        ),
                        children: <TextSpan>[
                          const TextSpan(text: 'Apa '),
                          TextSpan(
                            text: 'tujuan',
                            style: TextStyle(
                              color: Theme.of(context).primaryColor,
                            ), // Normal Blue
                          ),
                          const TextSpan(text: ' anda?'),
                        ],
                      ),
                    ),
                    const SizedBox(height: 10),
                    Text(
                      'Kami akan menggunakan data ini untuk memberi anda jenis diet yang lebih baik untuk anda',
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        fontSize: 14,
                        color:
                            Colors
                                .grey
                                .shade600, // Warna abu-abu yang lebih sesuai
                        fontFamily: 'Poppins', // Font Poppins
                      ),
                    ),
                    const SizedBox(height: 50),
                    // Pilihan "Menurunkan Berat Badan"
                    _buildPurposeOption(
                      context,
                      'Menurunkan Berat Badan',
                      'assets/images/purpose_lose_weight.png', // Nama file gambar untuk menurunkan berat badan
                      const Color(
                        0xFF01456D,
                      ), // Dark Blue untuk border terpilih
                      const Color(
                        0xFFE6EFF4,
                      ), // Light Blue untuk background tidak terpilih
                    ),
                    const SizedBox(height: 20),
                    // Pilihan "Menaikkan Berat Badan"
                    _buildPurposeOption(
                      context,
                      'Menaikkan Berat Badan',
                      'assets/images/purpose_gain_weight.png', // Nama file gambar untuk menaikkan berat badan
                      const Color(
                        0xFF01456D,
                      ), // Dark Blue untuk border terpilih
                      const Color(
                        0xFFE6EFF4,
                      ), // Light Blue untuk background tidak terpilih
                    ),
                    const SizedBox(height: 20),
                    // Pilihan "Menjaga Kesehatan" (perubahan dari "Stay healthy")
                    _buildPurposeOption(
                      context,
                      'Menjaga Kesehatan', // Mengubah teks
                      'assets/images/purpose_stay_healthy.png', // Nama file gambar untuk stay healthy
                      const Color(
                        0xFF01456D,
                      ), // Dark Blue untuk border terpilih
                      const Color(
                        0xFFE6EFF4,
                      ), // Light Blue untuk background tidak terpilih
                    ),
                    const Spacer(), // Mendorong semua konten di atas ke atas layar
                    const SizedBox(
                      height: 40,
                    ), // Jarak antara konten atas dan tombol Next
                    SizedBox(
                      width: double.infinity,
                      child: ElevatedButton(
                        // Tombol 'Selesai' akan memicu registrasi
                        onPressed:
                            _selectedPurpose != null
                                ? () => _completeRegistration()
                                : null, // Tombol dinonaktifkan jika belum ada tujuan terpilih
                        style: ElevatedButton.styleFrom(
                          backgroundColor: const Color(0xFF01456D), // Dark Blue
                          foregroundColor: Colors.white,
                          padding: const EdgeInsets.symmetric(vertical: 18),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(
                              8,
                            ), // Sudut tombol 8px
                          ),
                          elevation: 5,
                          textStyle: const TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                            fontFamily: 'Poppins', // Font Poppins
                          ),
                        ),
                        child: const Text(
                          'Selesai',
                        ), // Mengubah teks tombol dari 'Next' menjadi 'Selesai'
                      ),
                    ),
                    const SizedBox(
                      height: 40,
                    ), // Memberi sedikit padding dari bawah layar, disesuaikan agar tidak terlalu banyak
                  ],
                ),
              ),
      // HAPUS BARIS INI (Ln 328 di gambar Anda) -> ],
      // HAPUS BARIS INI (Ln 329 di gambar Anda) -> ),
      // HAPUS BARIS INI (Ln 330 di gambar Anda) -> );
    );
  }

  // Widget helper untuk membangun setiap opsi tujuan
  Widget _buildPurposeOption(
    BuildContext context,
    String title,
    String imagePath,
    Color selectedBorderColor, // Parameter baru
    Color defaultBackgroundColor, // Parameter baru
  ) {
    bool isSelected = _selectedPurpose == title;
    return GestureDetector(
      onTap: () {
        setState(() {
          _selectedPurpose = title;
        });
      },
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 15),
        decoration: BoxDecoration(
          color:
              isSelected
                  ? const Color(0xFFB0CCDD) // Light :active Blue saat terpilih
                  : defaultBackgroundColor, // Light Blue untuk default
          borderRadius: BorderRadius.circular(8), // Mengubah ke 8px
          border: Border.all(
            color:
                isSelected
                    ? selectedBorderColor // Dark Blue untuk border terpilih
                    : Colors.transparent, // Transparan
            width: isSelected ? 2 : 0,
          ),
          boxShadow: const [
            BoxShadow(
              color: Color(0x1A9E9E9E), // Colors.grey.withOpacity(0.1)
              spreadRadius: 1,
              blurRadius: 5,
              offset: Offset(0, 3),
            ),
          ],
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              title,
              style: const TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
                color: Color(0xFF002033), // Darker Blue
                fontFamily: 'Poppins', // Font Poppins
              ),
            ),
            Image.asset(
              imagePath,
              height: 100, // Ukuran gambar diperbesar
              width: 100, // Ukuran gambar diperbesar
            ),
          ],
        ),
      ),
    );
  }
}
