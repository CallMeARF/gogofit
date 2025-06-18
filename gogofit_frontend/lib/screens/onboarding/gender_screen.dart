// lib/screens/onboarding/gender_screen.dart

import 'package:flutter/material.dart';
import 'package:gogofit_frontend/screens/onboarding/birth_date_screen.dart'; // Import halaman tanggal lahir

class GenderScreen extends StatefulWidget {
  // BARU: Menerima data registrasi awal dari RegisterScreen
  final Map<String, dynamic> registrationData;

  // FIX: Konstruktor yang benar untuk menerima registrationData
  const GenderScreen({super.key, required this.registrationData});

  @override
  State<GenderScreen> createState() => _GenderScreenState();
}

class _GenderScreenState extends State<GenderScreen> {
  String? _selectedGender;

  @override
  void initState() {
    super.initState();
    // Inisialisasi gender yang dipilih jika sudah ada di data (misal dari edit profil atau skip)
    // Pastikan nilai 'gender' ada dan bukan null sebelum inisialisasi _selectedGender
    if (widget.registrationData.containsKey('gender') &&
        widget.registrationData['gender'] != null) {
      _selectedGender = widget.registrationData['gender'];
    }
  }

  void _navigateToNextScreen() {
    if (_selectedGender == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Mohon pilih jenis kelamin Anda.')),
      );
      return;
    }

    // Akumulasikan data yang sudah ada dan tambahkan data baru dari layar ini
    final updatedRegistrationData = Map<String, dynamic>.from(
      widget.registrationData,
    );
    updatedRegistrationData['gender'] =
        _selectedGender; // Simpan gender yang dipilih

    debugPrint(
      'Jenis Kelamin terpilih: $_selectedGender, melanjutkan ke BirthDateScreen dengan data: $updatedRegistrationData',
    );
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('Jenis Kelamin dipilih: $_selectedGender')),
    );

    // Navigasi ke halaman BirthDateScreen dengan meneruskan data yang sudah terakumulasi
    Navigator.of(context).push(
      MaterialPageRoute(
        builder:
            (context) => BirthDateScreen(
              registrationData: updatedRegistrationData, // Teruskan data
            ),
      ),
    );
  }

  // Fungsi untuk 'Skip'
  void _skipOnboarding() {
    final updatedRegistrationData = Map<String, dynamic>.from(
      widget.registrationData,
    );
    // Jika diskip, pastikan gender menjadi null di data (atau sesuai kebutuhan backend)
    updatedRegistrationData['gender'] = null;

    debugPrint(
      'Skip Onboarding dari Gender Screen menuju BirthDateScreen dengan data: $updatedRegistrationData',
    );
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text(
          'Melewati pengisian jenis kelamin, melanjutkan ke tanggal lahir',
        ),
      ),
    );
    // Navigasi ke halaman BirthDateScreen saat tombol 'Skip' ditekan
    Navigator.of(context).push(
      MaterialPageRoute(
        builder:
            (context) => BirthDateScreen(
              registrationData:
                  updatedRegistrationData, // Teruskan data yang sudah terakumulasi
            ),
      ),
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
                onPressed: _skipOnboarding, // Panggil fungsi skip
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
      body: Padding(
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
                    text: 'Jenis Kelamin',
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
                color: Colors.grey.shade600, // Warna abu-abu yang lebih sesuai
                fontFamily: 'Poppins', // Font Poppins
              ),
            ),
            const SizedBox(height: 50),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                Expanded(
                  child: GestureDetector(
                    onTap: () {
                      setState(() {
                        _selectedGender =
                            'Laki-laki'; // Ubah ke Bahasa Indonesia
                      });
                    },
                    child: Container(
                      height: 180,
                      decoration: BoxDecoration(
                        color:
                            _selectedGender == 'Laki-laki'
                                ? const Color(
                                  0xFFE6EFF4,
                                ) // Light Blue saat terpilih
                                : const Color(
                                  0xFFE6EFF4,
                                ), // Light Blue default (sesuai mockup)
                        borderRadius: BorderRadius.circular(15),
                        border: Border.all(
                          color:
                              _selectedGender == 'Laki-laki'
                                  ? const Color(
                                    0xFF015C91,
                                  ) // Normal Blue saat terpilih
                                  : Colors
                                      .transparent, // Transparan jika tidak terpilih
                          width: _selectedGender == 'Laki-laki' ? 2 : 0,
                        ),
                      ),
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Image.asset(
                            'assets/images/male_icon.png', // Pastikan path asset ini benar
                            height: 100,
                            width: 100,
                          ),
                          const SizedBox(height: 10),
                          Text(
                            'Laki-laki', // Ubah ke Bahasa Indonesia
                            style: TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                              color: const Color(0xFF002033), // Darker Blue
                              fontFamily: 'Poppins', // Font Poppins
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 20),
                Expanded(
                  child: GestureDetector(
                    onTap: () {
                      setState(() {
                        _selectedGender =
                            'Perempuan'; // Ubah ke Bahasa Indonesia
                      });
                    },
                    child: Container(
                      height: 180,
                      decoration: BoxDecoration(
                        color:
                            _selectedGender == 'Perempuan'
                                ? const Color(
                                  0xFFE6EFF4,
                                ) // Light Blue saat terpilih
                                : const Color(
                                  0xFFE6EFF4,
                                ), // Light Blue default (sesuai mockup)
                        borderRadius: BorderRadius.circular(15),
                        border: Border.all(
                          color:
                              _selectedGender == 'Perempuan'
                                  ? const Color(
                                    0xFF015C91,
                                  ) // Normal Blue saat terpilih
                                  : Colors
                                      .transparent, // Transparan jika tidak terpilih
                          width: _selectedGender == 'Perempuan' ? 2 : 0,
                        ),
                      ),
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Image.asset(
                            'assets/images/female_icon.png', // Pastikan path asset ini benar
                            height: 100,
                            width: 100,
                          ),
                          const SizedBox(height: 10),
                          Text(
                            'Perempuan', // Ubah ke Bahasa Indonesia
                            style: TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                              color: const Color(0xFF002033), // Darker Blue
                              fontFamily: 'Poppins', // Font Poppins
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ],
            ),
            const Spacer(), // Mendorong semua konten di atas ke atas layar
            // Tombol "Next"
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed:
                    _selectedGender != null
                        ? _navigateToNextScreen // Panggil fungsi navigasi
                        : null, // Tombol dinonaktifkan jika belum ada pilihan gender
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF01456D), // Dark Blue
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(vertical: 18),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8), // Sudut tombol 8px
                  ),
                  elevation: 5,
                  textStyle: const TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    fontFamily: 'Poppins', // Font Poppins
                  ),
                ),
                child: const Text('Next'),
              ),
            ),
            const SizedBox(
              height: 200, // Memberi sedikit padding dari bawah layar
            ),
          ],
        ),
      ),
    );
  }
}
