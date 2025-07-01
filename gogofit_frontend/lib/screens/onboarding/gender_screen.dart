// lib/screens/onboarding/gender_screen.dart

import 'package:flutter/material.dart';
import 'package:gogofit_frontend/screens/onboarding/birth_date_screen.dart';
// PERBAIKAN 1: Import model untuk mengakses currentUserProfile
import 'package:gogofit_frontend/models/user_profile_data.dart';

class GenderScreen extends StatefulWidget {
  final Map<String, dynamic> registrationData;

  const GenderScreen({super.key, required this.registrationData});

  @override
  State<GenderScreen> createState() => _GenderScreenState();
}

class _GenderScreenState extends State<GenderScreen> {
  String? _selectedGender;

  @override
  void initState() {
    super.initState();

    // PERBAIKAN 2: Inisialisasi currentUserProfile dengan data dari RegisterScreen
    // Ini adalah langkah kunci untuk mengisi nama dan email di awal.
    currentUserProfile.value = currentUserProfile.value.copyWith(
      name: widget.registrationData['name'] as String?,
      email: widget.registrationData['email'] as String?,
    );
    debugPrint(
      'GenderScreen initState: currentUserProfile initialized with name and email.',
    );

    // Logika yang sudah ada untuk mempertahankan pilihan jika pengguna kembali
    if (widget.registrationData.containsKey('gender') &&
        widget.registrationData['gender'] != null) {
      _selectedGender = widget.registrationData['gender'];
    } else {
      // Jika gender belum ada, kita juga bisa set dari state global jika ada
      _selectedGender = currentUserProfile.value.gender;
    }
  }

  void _navigateToNextScreen() {
    if (_selectedGender == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Mohon pilih jenis kelamin Anda.')),
      );
      return;
    }

    // PERBAIKAN 3: Update currentUserProfile dengan gender yang dipilih
    currentUserProfile.value = currentUserProfile.value.copyWith(
      gender: _selectedGender,
    );

    // Akumulasikan data ke map lokal untuk diteruskan
    final updatedRegistrationData = Map<String, dynamic>.from(
      widget.registrationData,
    );
    updatedRegistrationData['gender'] = _selectedGender;

    // Cetak kedua state untuk verifikasi
    debugPrint(
      'Jenis Kelamin terpilih: $_selectedGender, melanjutkan ke BirthDateScreen.',
    );
    debugPrint('  - RegistrationData: $updatedRegistrationData');
    debugPrint(
      '  - CurrentProfile State: ${currentUserProfile.value.toJson()}',
    );

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('Jenis Kelamin dipilih: $_selectedGender')),
    );

    Navigator.of(context).push(
      MaterialPageRoute(
        builder:
            (context) =>
                BirthDateScreen(registrationData: updatedRegistrationData),
      ),
    );
  }

  void _skipOnboarding() {
    // Saat skip, kita tetap set gender ke default di state global
    currentUserProfile.value = currentUserProfile.value.copyWith(
      gender: 'Laki-laki', // Atau default lain yang sesuai
    );

    final updatedRegistrationData = Map<String, dynamic>.from(
      widget.registrationData,
    );
    updatedRegistrationData['gender'] = null; // Map bisa null untuk API

    debugPrint('Skip Onboarding dari Gender Screen menuju BirthDateScreen.');
    debugPrint('  - RegistrationData: $updatedRegistrationData');
    debugPrint(
      '  - CurrentProfile State: ${currentUserProfile.value.toJson()}',
    );

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text(
          'Melewati pengisian jenis kelamin, melanjutkan ke tanggal lahir',
        ),
      ),
    );

    Navigator.of(context).push(
      MaterialPageRoute(
        builder:
            (context) =>
                BirthDateScreen(registrationData: updatedRegistrationData),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    // Tidak ada perubahan pada UI, jadi kode build tetap sama
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: Padding(
          padding: const EdgeInsets.only(left: 10.0, top: 5.0, bottom: 5.0),
          child: Container(
            decoration: BoxDecoration(
              color: Colors.grey.shade200,
              borderRadius: BorderRadius.circular(10),
            ),
            child: IconButton(
              icon: const Icon(Icons.arrow_back_ios, color: Colors.black),
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
                color: Colors.grey.shade200,
                borderRadius: BorderRadius.circular(10),
              ),
              child: TextButton(
                onPressed: _skipOnboarding,
                child: const Text(
                  'Skip',
                  style: TextStyle(
                    color: Colors.black,
                    fontSize: 16,
                    fontFamily: 'Poppins',
                    fontWeight: FontWeight.w500,
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
                style: const TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                  color: Color(0xFF002033),
                  fontFamily: 'Poppins',
                ),
                children: <TextSpan>[
                  const TextSpan(text: 'Apa '),
                  TextSpan(
                    text: 'Jenis Kelamin',
                    style: TextStyle(color: Theme.of(context).primaryColor),
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
                color: Colors.grey.shade600,
                fontFamily: 'Poppins',
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
                        _selectedGender = 'Laki-laki';
                      });
                    },
                    child: Container(
                      height: 180,
                      decoration: BoxDecoration(
                        color: const Color(0xFFE6EFF4),
                        borderRadius: BorderRadius.circular(15),
                        border: Border.all(
                          color:
                              _selectedGender == 'Laki-laki'
                                  ? const Color(0xFF015C91)
                                  : Colors.transparent,
                          width: _selectedGender == 'Laki-laki' ? 2 : 0,
                        ),
                      ),
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Image.asset(
                            'assets/images/male_icon.png',
                            height: 100,
                            width: 100,
                          ),
                          const SizedBox(height: 10),
                          const Text(
                            'Laki-laki',
                            style: TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                              color: Color(0xFF002033),
                              fontFamily: 'Poppins',
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
                        _selectedGender = 'Perempuan';
                      });
                    },
                    child: Container(
                      height: 180,
                      decoration: BoxDecoration(
                        color: const Color(0xFFE6EFF4),
                        borderRadius: BorderRadius.circular(15),
                        border: Border.all(
                          color:
                              _selectedGender == 'Perempuan'
                                  ? const Color(0xFF015C91)
                                  : Colors.transparent,
                          width: _selectedGender == 'Perempuan' ? 2 : 0,
                        ),
                      ),
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Image.asset(
                            'assets/images/female_icon.png',
                            height: 100,
                            width: 100,
                          ),
                          const SizedBox(height: 10),
                          const Text(
                            'Perempuan',
                            style: TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                              color: Color(0xFF002033),
                              fontFamily: 'Poppins',
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ],
            ),
            const Spacer(),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed:
                    _selectedGender != null ? _navigateToNextScreen : null,
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF01456D),
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(vertical: 18),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                  elevation: 5,
                  textStyle: const TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    fontFamily: 'Poppins',
                  ),
                ),
                child: const Text('Next'),
              ),
            ),
            const SizedBox(
              height: 40, // Padding bawah
            ),
          ],
        ),
      ),
    );
  }
}
