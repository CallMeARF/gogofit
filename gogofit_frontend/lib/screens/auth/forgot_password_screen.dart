// lib/screens/auth/forgot_password_screen.dart
import 'package:flutter/material.dart';
import 'package:gogofit_frontend/services/api_service.dart'; // Import ApiService
import 'package:gogofit_frontend/exceptions/unauthorized_exception.dart'; // BARU: Import UnauthorizedException

class ForgotPasswordScreen extends StatefulWidget {
  const ForgotPasswordScreen({super.key});

  @override
  State<ForgotPasswordScreen> createState() => _ForgotPasswordScreenState();
}

class _ForgotPasswordScreenState extends State<ForgotPasswordScreen> {
  final TextEditingController _emailController = TextEditingController();
  final ApiService _apiService = ApiService();
  bool _isLoading = false; // State untuk loading saat mengirim permintaan

  // FIX: Definisi warna disesuaikan agar konsisten dengan LoginScreen
  final Color primaryAppColor = const Color(
    0xFF015C91,
  ); // Warna biru utama aplikasi
  final Color darkerTextColor = const Color(
    0xFF002033,
  ); // Warna teks lebih gelap
  final Color mainButtonColor = const Color(
    0xFF01456D,
  ); // Warna tombol utama (Masuk/Kirim)
  final Color hintTextColor = Colors.grey.shade400; // Warna teks petunjuk input
  final Color greyTextColor =
      Colors.grey.shade600; // Warna teks abu-abu umum (seperti 'Atau')
  final Color shadowColorOpacity = const Color.fromARGB(
    51,
    0,
    0,
    0,
  ); // Warna shadow dengan opacity (black20Opacity / black51Opacity)

  @override
  void dispose() {
    _emailController.dispose();
    super.dispose();
  }

  void _sendResetLink() async {
    final String email = _emailController.text.trim();

    if (email.isEmpty) {
      _showAlertDialog('Error', 'Mohon masukkan alamat email Anda.');
      return;
    }

    setState(() {
      _isLoading = true; // Tampilkan loading
    });

    try {
      // Memanggil ApiService.forgotPassword(). requireAuth: false sudah diatur di ApiService
      final response = await _apiService.forgotPassword(email);

      if (!mounted) return;
      setState(() {
        _isLoading = false; // Sembunyikan loading
      });

      if (response['success']) {
        _showAlertDialog(
          'Sukses',
          response['message'] ??
              'Tautan reset kata sandi telah dikirim ke email Anda.',
          () {
            if (!mounted) return;
            // Kembali ke LoginScreen setelah sukses
            // Karena ini dipanggil dari LoginScreen via Navigator.push, Navigator.pop sudah cukup.
            Navigator.pop(context);
          },
        );
      } else {
        _showAlertDialog(
          'Error',
          response['message'] ??
              'Gagal mengirim tautan reset. Mohon coba lagi.',
        );
      }
    } on UnauthorizedException catch (e) {
      // Ini seharusnya tidak terjadi di sini karena forgotPassword di ApiService memiliki requireAuth: false.
      // Namun, jika terjadi, ApiService sudah memicu redirect.
      if (!mounted) return;
      setState(() {
        _isLoading = false; // Sembunyikan loading
      });
      debugPrint('Forgot Password Error (UnauthorizedException): ${e.message}');
      // Tidak perlu menampilkan dialog error jika ApiService sudah me-redirect
      // _showAlertDialog('Error', e.message); // Opsional: Tampilkan jika ingin memberi tahu pengguna
    } catch (e) {
      // Tangani error lain yang tidak terduga, termasuk 'API error:' dari ApiService
      if (!mounted) return;
      setState(() {
        _isLoading = false; // Sembunyikan loading
      });
      debugPrint('Forgot Password Error: $e');
      _showAlertDialog(
        'Error',
        'Terjadi kesalahan: ${e.toString().contains('Exception:') ? e.toString().split('Exception:').last.trim() : 'Mohon periksa koneksi internet Anda atau coba lagi nanti.'}',
      );
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
              child: Text(
                'OK',
                style: TextStyle(fontFamily: 'Poppins', color: primaryAppColor),
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
        backgroundColor: darkerTextColor,
        elevation: 0,
        title: const Text(
          'Lupa Kata Sandi',
          style: TextStyle(
            color: Colors.white,
            fontSize: 20,
            fontWeight: FontWeight.bold,
            fontFamily: 'Poppins',
          ),
        ),
        centerTitle: true,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.white, size: 28),
          onPressed: () {
            Navigator.pop(context);
          },
        ),
      ),
      body:
          _isLoading
              ? const Center(
                child: CircularProgressIndicator(color: Colors.blueAccent),
              )
              : SingleChildScrollView(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const SizedBox(height: 40),
                    Text(
                      'Setel Ulang Kata Sandi',
                      style: TextStyle(
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                        color: darkerTextColor,
                        fontFamily: 'Poppins',
                      ),
                    ),
                    const SizedBox(height: 10),
                    Text(
                      'Masukkan alamat email Anda untuk menerima tautan pengaturan ulang kata sandi.',
                      style: TextStyle(
                        fontSize: 14,
                        color: greyTextColor,
                        fontFamily: 'Poppins',
                      ),
                    ),
                    const SizedBox(height: 40),
                    TextField(
                      controller: _emailController,
                      keyboardType: TextInputType.emailAddress,
                      decoration: InputDecoration(
                        hintText: 'Email',
                        hintStyle: TextStyle(
                          color: hintTextColor,
                          fontFamily: 'Poppins',
                        ),
                        prefixIcon: Icon(
                          Icons.email_outlined,
                          color: primaryAppColor,
                        ),
                        border: const UnderlineInputBorder(
                          borderSide: BorderSide(color: Colors.grey),
                        ),
                        enabledBorder: const UnderlineInputBorder(
                          borderSide: BorderSide(color: Colors.grey),
                        ),
                        focusedBorder: UnderlineInputBorder(
                          borderSide: BorderSide(color: primaryAppColor),
                        ),
                      ),
                      style: const TextStyle(fontFamily: 'Poppins'),
                    ),
                    const SizedBox(height: 40),
                    SizedBox(
                      width: double.infinity,
                      height: 55,
                      child: ElevatedButton(
                        onPressed: _sendResetLink,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: mainButtonColor,
                          foregroundColor: Colors.white,
                          padding: const EdgeInsets.symmetric(vertical: 18),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(8),
                          ),
                          elevation: 5,
                          shadowColor: shadowColorOpacity,
                          textStyle: const TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                            fontFamily: 'Poppins',
                          ),
                        ),
                        child: const Text('Kirim Tautan Reset'),
                      ),
                    ),
                  ],
                ),
              ),
    );
  }
}
