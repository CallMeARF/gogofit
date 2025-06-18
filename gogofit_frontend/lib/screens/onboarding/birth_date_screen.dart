// lib/screens/onboarding/birth_date_screen.dart

import 'package:flutter/material.dart';
import 'package:intl/intl.dart'; // Untuk format tanggal
import 'package:gogofit_frontend/screens/onboarding/height_screen.dart'; // Import halaman tinggi badan

class BirthDateScreen extends StatefulWidget {
  // BARU: Menerima data registrasi awal dari GenderScreen
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
    // Pastikan locale default diatur ke Indonesia untuk DateFormat
    // Ini idealnya diatur sekali di main.dart, tapi kita bisa pastikan di sini juga.
    // Jika sudah diatur di main.dart, baris ini bisa diabaikan.
    Intl.defaultLocale = 'id';

    // Inisialisasi tanggal default dari data jika ada, jika tidak, gunakan tanggal default mockup
    if (widget.registrationData.containsKey('birthDate') &&
        widget.registrationData['birthDate'] != null) {
      _selectedDate = widget.registrationData['birthDate'];
    } else {
      _selectedDate = DateTime(1999, 2, 20); // Default sesuai mockup
    }
  }

  void _navigateToNextScreen() {
    if (_selectedDate == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Mohon pilih tanggal lahir Anda.')),
      );
      return;
    }

    // Akumulasikan data yang sudah ada dan tambahkan data baru dari layar ini
    final updatedRegistrationData = Map<String, dynamic>.from(
      widget.registrationData,
    );
    updatedRegistrationData['birthDate'] =
        _selectedDate; // Simpan tanggal lahir yang dipilih

    debugPrint(
      'Tanggal lahir dipilih: $_selectedDate, melanjutkan ke Height Screen dengan data: $updatedRegistrationData',
    );
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          'Tanggal lahir dipilih: ${DateFormat('dd MMMM yyyy', 'id').format(_selectedDate!)}',
        ),
      ),
    );

    // Navigasi ke halaman HeightScreen dengan meneruskan data yang sudah terakumulasi
    Navigator.of(context).push(
      MaterialPageRoute(
        builder:
            (context) => HeightScreen(
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
    // Jika diskip, pastikan birthDate menjadi null di data
    updatedRegistrationData['birthDate'] = null;

    debugPrint(
      'Skip Onboarding dari Birth Date Screen menuju Height Screen dengan data: $updatedRegistrationData',
    );
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text(
          'Melewati pengisian tanggal lahir, melanjutkan ke tinggi badan',
        ),
      ),
    );
    // Navigasi ke halaman HeightScreen saat tombol 'Skip' ditekan
    Navigator.of(context).push(
      MaterialPageRoute(
        builder:
            (context) => HeightScreen(
              registrationData:
                  updatedRegistrationData, // Teruskan data yang sudah terakumulasi
            ),
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
            primaryColor: const Color(0xFF015C91), // Normal Blue
            colorScheme: const ColorScheme.light(
              primary: Color(
                0xFF015C91,
              ), // Normal Blue (warna header, bulan terpilih)
              onPrimary: Colors.white, // Teks pada header DatePicker
              surface: Colors.white, // Background utama DatePicker
              onSurface: Color(0xFF002033), // Teks tanggal, bulan, tahun
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
    // Format tanggal untuk tampilan utama (contoh: "20 Februari 1999")
    // Menggunakan locale 'id' untuk format Indonesia
    String displayDate =
        _selectedDate != null
            ? DateFormat('dd MMMM yyyy', 'id').format(_selectedDate!)
            : '20 Februari 1999'; // Default jika belum ada tanggal terpilih

    // Ambil hanya hari dalam format 2 digit
    String dayOnly =
        _selectedDate != null ? DateFormat('dd').format(_selectedDate!) : '23';

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
                  const TextSpan(text: 'Masukan '),
                  TextSpan(
                    text: 'Tanggal Lahir',
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
            // Kotak besar untuk menampilkan hari
            Container(
              width: double.infinity,
              height: 120,
              decoration: BoxDecoration(
                color: const Color(0xFFB0CCDD), // Light :active Blue
                borderRadius: BorderRadius.circular(
                  8,
                ), // Mengubah ke 8px agar lebih kotak
              ),
              alignment: Alignment.center,
              child: Text(
                dayOnly, // Menampilkan hanya hari
                style: const TextStyle(
                  fontSize: 48,
                  fontWeight: FontWeight.bold,
                  color: Color(0xFF002033), // Darker Blue
                  fontFamily: 'Poppins', // Font Poppins
                ),
              ),
            ),
            const SizedBox(height: 20),
            // Container untuk menampilkan tanggal lengkap dan icon kalender
            GestureDetector(
              onTap: () => _selectDate(context),
              child: Container(
                width: double.infinity,
                padding: const EdgeInsets.symmetric(
                  horizontal: 20,
                  vertical: 18,
                ),
                decoration: BoxDecoration(
                  color: const Color(0xFF015C91), // Normal Blue
                  borderRadius: BorderRadius.circular(
                    8,
                  ), // Mengubah ke 8px agar lebih kotak
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      displayDate, // Menampilkan tanggal dengan format Indonesia
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        fontFamily: 'Poppins', // Font Poppins
                      ),
                    ),
                    const Icon(Icons.calendar_today, color: Colors.white),
                  ],
                ),
              ),
            ),
            const Spacer(), // Mendorong semua konten di atas ke atas layar
            const SizedBox(
              height: 40,
            ), // Jarak antara konten atas dan tombol Next
            // Tombol "Next"
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed:
                    _selectedDate != null
                        ? _navigateToNextScreen // Panggil fungsi navigasi
                        : null, // Tombol dinonaktifkan jika belum ada tanggal terpilih
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
