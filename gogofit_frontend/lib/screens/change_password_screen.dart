// lib/screens/change_password_screen.dart

import 'package:flutter/material.dart';
import 'package:gogofit_frontend/services/api_service.dart'; // Import ApiService
import 'package:gogofit_frontend/screens/auth/login_screen.dart'; // Untuk navigasi setelah ubah password/logout

class ChangePasswordScreen extends StatefulWidget {
  const ChangePasswordScreen({super.key});

  @override
  State<ChangePasswordScreen> createState() => _ChangePasswordScreenState();
}

class _ChangePasswordScreenState extends State<ChangePasswordScreen> {
  final TextEditingController _oldPasswordController = TextEditingController();
  final TextEditingController _newPasswordController = TextEditingController();
  final TextEditingController _confirmNewPasswordController =
      TextEditingController();

  bool _obscureOldPassword = true;
  bool _obscureNewPassword = true;
  bool _obscureConfirmNewPassword = true;

  final Color primaryBlueNormal = const Color(0xFF015c91);
  final Color darkerBlue = const Color(0xFF002033);
  final Color lightBlueCardBackground = const Color(
    0xFFD9E7EF,
  ); // Warna untuk tombol/background lain
  final Color accentBlueColor = const Color(
    0xFF015c91,
  ); // Warna aksen untuk border/focus

  final ApiService _apiService = ApiService(); // Inisialisasi ApiService
  bool _isLoading = false; // State untuk loading saat submit

  @override
  void dispose() {
    _oldPasswordController.dispose();
    _newPasswordController.dispose();
    _confirmNewPasswordController.dispose();
    super.dispose();
  }

  void _changePassword() async {
    final String oldPassword = _oldPasswordController.text.trim();
    final String newPassword = _newPasswordController.text.trim();
    final String confirmNewPassword = _confirmNewPasswordController.text.trim();

    if (oldPassword.isEmpty ||
        newPassword.isEmpty ||
        confirmNewPassword.isEmpty) {
      _showAlertDialog('Error', 'Semua field harus diisi.');
      return;
    }

    if (newPassword.length < 8) {
      _showAlertDialog('Error', 'Kata sandi baru minimal 8 karakter.');
      return;
    }

    if (newPassword != confirmNewPassword) {
      _showAlertDialog(
        'Error',
        'Kata sandi baru dan konfirmasinya tidak cocok!',
      );
      return;
    }

    setState(() {
      _isLoading = true; // Mulai loading
    });

    try {
      // FIX: Implementasi panggilan API ke backend Laravel untuk mengubah password
      final response = await _apiService.changePassword(
        oldPassword: oldPassword,
        newPassword: newPassword,
        newPasswordConfirmation: confirmNewPassword,
      );

      // Cek mounted setelah await
      if (!mounted) return;

      if (response['success']) {
        _showAlertDialog(
          'Sukses',
          response['message'] ??
              'Kata sandi berhasil diubah! Silakan login kembali.',
          () async {
            if (!mounted) return;
            // Setelah ubah password, log out pengguna dan arahkan ke login
            await AuthTokenManager.clearAuthToken(); // Hapus token
            if (!mounted) return;
            Navigator.of(context).pushAndRemoveUntil(
              MaterialPageRoute(builder: (context) => const LoginScreen()),
              (Route<dynamic> route) => false,
            );
          },
        );
      } else {
        _showAlertDialog(
          'Error',
          response['message'] ??
              'Gagal mengubah kata sandi. Periksa kata sandi lama Anda atau coba lagi.',
        );
      }
    } catch (e) {
      if (!mounted) return;
      debugPrint('Change Password Error: $e');
      _showAlertDialog(
        'Error',
        'Terjadi kesalahan saat mengubah kata sandi: $e',
      );
    } finally {
      setState(() {
        _isLoading = false; // Selesai loading
      });
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
                style: TextStyle(fontFamily: 'Poppins', color: accentBlueColor),
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
        backgroundColor: primaryBlueNormal,
        elevation: 0,
        title: const Text(
          'Ubah Kata Sandi',
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
                child: CircularProgressIndicator(color: Colors.blue),
              )
              : SingleChildScrollView(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Kata Sandi Lama',
                      style: TextStyle(
                        color: Color(0xFF002033),
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        fontFamily: 'Poppins',
                      ),
                    ),
                    const SizedBox(height: 8),
                    TextField(
                      controller: _oldPasswordController,
                      obscureText: _obscureOldPassword,
                      style: const TextStyle(fontFamily: 'Poppins'),
                      decoration: InputDecoration(
                        hintText: 'Masukkan kata sandi lama',
                        hintStyle: TextStyle(
                          color: Colors.grey.shade500,
                          fontFamily: 'Poppins',
                          fontSize: 14,
                        ),
                        enabledBorder: UnderlineInputBorder(
                          borderSide: BorderSide(
                            color: Colors.grey.shade400,
                            width: 1.5,
                          ),
                        ),
                        focusedBorder: UnderlineInputBorder(
                          borderSide: BorderSide(
                            color: accentBlueColor,
                            width: 2.0,
                          ),
                        ),
                        contentPadding: const EdgeInsets.symmetric(
                          vertical: 12,
                        ),
                        isDense: true,
                        suffixIcon: IconButton(
                          icon: Icon(
                            _obscureOldPassword
                                ? Icons.visibility_off_outlined
                                : Icons.visibility_outlined,
                            color: Colors.grey.shade600,
                          ),
                          onPressed: () {
                            setState(() {
                              _obscureOldPassword = !_obscureOldPassword;
                            });
                          },
                        ),
                      ),
                    ),
                    const SizedBox(height: 24),
                    const Text(
                      'Kata Sandi Baru',
                      style: TextStyle(
                        color: Color(0xFF002033),
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        fontFamily: 'Poppins',
                      ),
                    ),
                    const SizedBox(height: 8),
                    TextField(
                      controller: _newPasswordController,
                      obscureText: _obscureNewPassword,
                      style: const TextStyle(fontFamily: 'Poppins'),
                      decoration: InputDecoration(
                        hintText: 'Masukkan kata sandi baru',
                        hintStyle: TextStyle(
                          color: Colors.grey.shade500,
                          fontFamily: 'Poppins',
                          fontSize: 14,
                        ),
                        enabledBorder: UnderlineInputBorder(
                          borderSide: BorderSide(
                            color: Colors.grey.shade400,
                            width: 1.5,
                          ),
                        ),
                        focusedBorder: UnderlineInputBorder(
                          borderSide: BorderSide(
                            color: accentBlueColor,
                            width: 2.0,
                          ),
                        ),
                        contentPadding: const EdgeInsets.symmetric(
                          vertical: 12,
                        ),
                        isDense: true,
                        suffixIcon: IconButton(
                          icon: Icon(
                            _obscureNewPassword
                                ? Icons.visibility_off_outlined
                                : Icons.visibility_outlined,
                            color: Colors.grey.shade600,
                          ),
                          onPressed: () {
                            setState(() {
                              _obscureNewPassword = !_obscureNewPassword;
                            });
                          },
                        ),
                      ),
                    ),
                    const SizedBox(height: 24),
                    const Text(
                      'Konfirmasi Kata Sandi Baru',
                      style: TextStyle(
                        color: Color(0xFF002033),
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        fontFamily: 'Poppins',
                      ),
                    ),
                    const SizedBox(height: 8),
                    TextField(
                      controller: _confirmNewPasswordController,
                      obscureText: _obscureConfirmNewPassword,
                      style: const TextStyle(fontFamily: 'Poppins'),
                      decoration: InputDecoration(
                        hintText: 'Konfirmasi kata sandi baru',
                        hintStyle: TextStyle(
                          color: Colors.grey.shade500,
                          fontFamily: 'Poppins',
                          fontSize: 14,
                        ),
                        enabledBorder: UnderlineInputBorder(
                          borderSide: BorderSide(
                            color: Colors.grey.shade400,
                            width: 1.5,
                          ),
                        ),
                        focusedBorder: UnderlineInputBorder(
                          borderSide: BorderSide(
                            color: accentBlueColor,
                            width: 2.0,
                          ),
                        ),
                        contentPadding: const EdgeInsets.symmetric(
                          vertical: 12,
                        ),
                        isDense: true,
                        suffixIcon: IconButton(
                          icon: Icon(
                            _obscureConfirmNewPassword
                                ? Icons.visibility_off_outlined
                                : Icons.visibility_outlined,
                            color: Colors.grey.shade600,
                          ),
                          onPressed: () {
                            setState(() {
                              _obscureConfirmNewPassword =
                                  !_obscureConfirmNewPassword;
                            });
                          },
                        ),
                      ),
                    ),
                    const SizedBox(height: 30),
                    SizedBox(
                      width: double.infinity,
                      height: 55,
                      child: ElevatedButton(
                        onPressed: _changePassword,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: accentBlueColor,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                          elevation: 5,
                        ),
                        child: const Text(
                          'Ubah Kata Sandi',
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                            fontFamily: 'Poppins',
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(height: 30),
                  ],
                ),
              ),
    );
  }
}
