// lib/screens/onboarding/birth_date_screen.dart

import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:gogofit_frontend/screens/onboarding/height_screen.dart';
// PERBAIKAN 1: Import model untuk mengakses currentUserProfile
import 'package:gogofit_frontend/models/user_profile_data.dart';

class BirthDateScreen extends StatefulWidget {
  final Map<String, dynamic> registrationData;

  const BirthDateScreen({super.key, required this.registrationData});

  @override
  State<BirthDateScreen> createState() => _BirthDateScreenState();
}

class _BirthDateScreenState extends State<BirthDateScreen> {
  DateTime? _selectedDate;

  @override
  void initState() {
    super.initState();
    Intl.defaultLocale = 'id';

    DateTime initialDate;
    if (widget.registrationData.containsKey('birthDate') &&
        widget.registrationData['birthDate'] != null) {
      initialDate = widget.registrationData['birthDate'];
    } else {
      initialDate = DateTime(1999, 2, 20); // Default sesuai mockup
    }

    _selectedDate = initialDate;

    // PERBAIKAN 2: Langsung update state global agar sinkron dengan UI
    currentUserProfile.value = currentUserProfile.value.copyWith(
      birthDate: _selectedDate,
    );
    debugPrint(
      'BirthDateScreen initState: currentUserProfile updated with date: $_selectedDate',
    );
  }

  void _navigateToNextScreen() {
    if (_selectedDate == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Mohon pilih tanggal lahir Anda.')),
      );
      return;
    }

    // PERBAIKAN 3: Pastikan state global di-update sebelum navigasi
    currentUserProfile.value = currentUserProfile.value.copyWith(
      birthDate: _selectedDate,
    );

    final updatedRegistrationData = Map<String, dynamic>.from(
      widget.registrationData,
    );
    updatedRegistrationData['birthDate'] = _selectedDate;

    // Cetak kedua state untuk verifikasi
    debugPrint(
      'Tanggal lahir dipilih: $_selectedDate, melanjutkan ke Height Screen.',
    );
    debugPrint('  - RegistrationData: $updatedRegistrationData');
    debugPrint(
      '  - CurrentProfile State: ${currentUserProfile.value.toJson()}',
    );

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          'Tanggal lahir dipilih: ${DateFormat('dd MMMM yyyy', 'id').format(_selectedDate!)}',
        ),
      ),
    );

    Navigator.of(context).push(
      MaterialPageRoute(
        builder:
            (context) =>
                HeightScreen(registrationData: updatedRegistrationData),
      ),
    );
  }

  void _skipOnboarding() {
    // Saat skip, kita set tanggal lahir default di state global
    // agar perhitungan umur tidak error.
    currentUserProfile.value = currentUserProfile.value.copyWith(
      birthDate: DateTime(2000, 1, 1), // Default aman
    );

    final updatedRegistrationData = Map<String, dynamic>.from(
      widget.registrationData,
    );
    updatedRegistrationData['birthDate'] = null;

    debugPrint('Skip Onboarding dari Birth Date Screen menuju Height Screen.');
    debugPrint('  - RegistrationData: $updatedRegistrationData');
    debugPrint(
      '  - CurrentProfile State: ${currentUserProfile.value.toJson()}',
    );

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text(
          'Melewati pengisian tanggal lahir, melanjutkan ke tinggi badan',
        ),
      ),
    );

    Navigator.of(context).push(
      MaterialPageRoute(
        builder:
            (context) =>
                HeightScreen(registrationData: updatedRegistrationData),
      ),
    );
  }

  Future<void> _selectDate(BuildContext context) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: _selectedDate ?? DateTime(2000, 1, 1),
      firstDate: DateTime(1900),
      lastDate: DateTime.now(),
      builder: (BuildContext context, Widget? child) {
        return Theme(
          data: ThemeData.light().copyWith(
            primaryColor: const Color(0xFF015C91),
            colorScheme: const ColorScheme.light(
              primary: Color(0xFF015C91),
              onPrimary: Colors.white,
              surface: Colors.white,
              onSurface: Color(0xFF002033),
            ),
            textTheme: const TextTheme(
              bodyLarge: TextStyle(fontFamily: 'Poppins'),
              bodyMedium: TextStyle(fontFamily: 'Poppins'),
              labelLarge: TextStyle(
                fontFamily: 'Poppins',
                fontWeight: FontWeight.bold,
              ),
            ),
            buttonTheme: const ButtonThemeData(
              textTheme: ButtonTextTheme.primary,
            ),
          ),
          child: child!,
        );
      },
    );
    if (picked != null && picked != _selectedDate) {
      setState(() {
        _selectedDate = picked;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    // Kode build tetap sama, tidak ada perubahan di sini
    String displayDate =
        _selectedDate != null
            ? DateFormat('dd MMMM yyyy', 'id').format(_selectedDate!)
            : '20 Februari 1999';

    String dayOnly =
        _selectedDate != null ? DateFormat('dd').format(_selectedDate!) : '20';

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
                  const TextSpan(text: 'Masukan '),
                  TextSpan(
                    text: 'Tanggal Lahir',
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
            Container(
              width: double.infinity,
              height: 120,
              decoration: BoxDecoration(
                color: const Color(0xFFB0CCDD),
                borderRadius: BorderRadius.circular(8),
              ),
              alignment: Alignment.center,
              child: Text(
                dayOnly,
                style: const TextStyle(
                  fontSize: 48,
                  fontWeight: FontWeight.bold,
                  color: Color(0xFF002033),
                  fontFamily: 'Poppins',
                ),
              ),
            ),
            const SizedBox(height: 20),
            GestureDetector(
              onTap: () => _selectDate(context),
              child: Container(
                width: double.infinity,
                padding: const EdgeInsets.symmetric(
                  horizontal: 20,
                  vertical: 18,
                ),
                decoration: BoxDecoration(
                  color: const Color(0xFF015C91),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      displayDate,
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        fontFamily: 'Poppins',
                      ),
                    ),
                    const Icon(Icons.calendar_today, color: Colors.white),
                  ],
                ),
              ),
            ),
            const Spacer(),
            const SizedBox(height: 40),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: _selectedDate != null ? _navigateToNextScreen : null,
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
            const SizedBox(height: 40),
          ],
        ),
      ),
    );
  }
}
