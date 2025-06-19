// lib/screens/auth/login_screen.dart

import 'package:flutter/material.dart';
import 'package:gogofit_frontend/screens/auth/register_screen.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:gogofit_frontend/services/api_service.dart'; // Import ApiService untuk login nyata
import 'package:gogofit_frontend/screens/dashboard_screen.dart'; // Import DashboardScreen
import 'package:gogofit_frontend/models/user_profile_data.dart'; // Import UserProfile model

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  bool _obscurePassword = true;
  bool _rememberMe = false; // State untuk checkbox "Ingatkan saya"
  final ApiService _apiService = ApiService(); // Inisialisasi ApiService

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  void _login() async {
    final String email = _emailController.text.trim();
    final String password = _passwordController.text;

    if (email.isEmpty || password.isEmpty) {
      _showAlertDialog('Error', 'Email dan Password harus diisi.');
      return;
    }

    _showLoadingDialog(); // Tampilkan loading dialog

    try {
      // FIX: Meneruskan nilai _rememberMe ke ApiService.login()
      final response = await _apiService.login(
        email,
        password,
        rememberMe: _rememberMe,
      );

      if (!mounted) return;
      Navigator.of(context).pop(); // Tutup loading dialog

      if (response['success']) {
        final UserProfile? fetchedProfile = await _apiService.getUserProfile();

        if (!mounted) return;

        if (fetchedProfile != null) {
          currentUserProfile.value = fetchedProfile;
          debugPrint(
            'User profile updated after successful login: ${fetchedProfile.name}',
          );
        } else {
          debugPrint('Failed to fetch user profile immediately after login.');
        }

        _showAlertDialog(
          'Sukses',
          response['message'] ?? 'Login berhasil!',
          () {
            if (!mounted) return;
            Navigator.of(context).pushAndRemoveUntil(
              MaterialPageRoute(builder: (context) => const DashboardScreen()),
              (Route<dynamic> route) => false,
            );
          },
        );
      } else {
        _showAlertDialog(
          'Error',
          response['message'] ?? 'Login gagal. Cek email dan password Anda.',
        );
      }
    } catch (e) {
      if (!mounted) return;
      Navigator.of(context).pop(); // Tutup loading dialog
      debugPrint('Login Error: $e');
      _showAlertDialog(
        'Error',
        'Terjadi kesalahan saat login. Mohon coba lagi.',
      );
    }
  }

  void _showLoadingDialog() {
    showDialog(
      context: context,
      barrierDismissible: false, // Tidak bisa ditutup dengan tap di luar
      builder: (BuildContext dialogContext) {
        return const AlertDialog(
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              CircularProgressIndicator(),
              SizedBox(height: 16),
              Text("Loading..."),
            ],
          ),
        );
      },
    );
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
    final double waveAreaHeight = 300;
    final double appBarHeight = 0.0;
    final double statusBarHeight = MediaQuery.of(context).padding.top;

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: PreferredSize(
        preferredSize: Size.fromHeight(appBarHeight),
        child: AppBar(backgroundColor: Colors.transparent, elevation: 0),
      ),
      body: SingleChildScrollView(
        child: Column(
          children: [
            SizedBox(
              width: MediaQuery.of(context).size.width,
              height: waveAreaHeight + statusBarHeight,
              child: Stack(
                alignment: Alignment.topLeft,
                children: [
                  SvgPicture.asset(
                    'assets/images/wave_background.svg',
                    width: MediaQuery.of(context).size.width,
                    height: waveAreaHeight + statusBarHeight,
                    fit: BoxFit.fill,
                  ),
                  Positioned(
                    left: 50,
                    top: statusBarHeight + 200,
                    child: const Text(
                      'Masuk',
                      style: TextStyle(
                        fontSize: 36,
                        fontWeight: FontWeight.bold,
                        color: Colors.black,
                        fontFamily: 'Poppins',
                      ),
                    ),
                  ),
                ],
              ),
            ),
            Padding(
              padding: const EdgeInsets.symmetric(
                horizontal: 20.0,
                vertical: 30.0,
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const SizedBox(height: 10),
                  TextField(
                    controller: _emailController,
                    style: const TextStyle(fontFamily: 'Poppins'),
                    decoration: InputDecoration(
                      hintText: 'Email',
                      hintStyle: TextStyle(
                        color: Colors.grey.shade400,
                        fontFamily: 'Poppins',
                      ),
                      prefixIcon: const Icon(
                        Icons.email_outlined,
                        color: Color(0xFF015C91),
                      ),
                      border: const UnderlineInputBorder(
                        borderSide: BorderSide(color: Colors.grey),
                      ),
                      enabledBorder: const UnderlineInputBorder(
                        borderSide: BorderSide(color: Colors.grey),
                      ),
                      focusedBorder: const UnderlineInputBorder(
                        borderSide: BorderSide(color: Color(0xFF015C91)),
                      ),
                    ),
                    keyboardType: TextInputType.emailAddress,
                  ),
                  const SizedBox(height: 20),
                  TextField(
                    controller: _passwordController,
                    obscureText: _obscurePassword,
                    style: const TextStyle(fontFamily: 'Poppins'),
                    decoration: InputDecoration(
                      hintText: 'Password',
                      hintStyle: TextStyle(
                        color: Colors.grey.shade400,
                        fontFamily: 'Poppins',
                      ),
                      prefixIcon: const Icon(
                        Icons.lock_outline,
                        color: Color(0xFF015C91),
                      ),
                      border: const UnderlineInputBorder(
                        borderSide: BorderSide(color: Colors.grey),
                      ),
                      enabledBorder: const UnderlineInputBorder(
                        borderSide: BorderSide(color: Colors.grey),
                      ),
                      focusedBorder: const UnderlineInputBorder(
                        borderSide: BorderSide(color: Color(0xFF015C91)),
                      ),
                      suffixIcon: IconButton(
                        icon: Icon(
                          _obscurePassword
                              ? Icons.visibility_off_outlined
                              : Icons.visibility_outlined,
                          color: const Color(0xFF015C91),
                        ),
                        onPressed: () {
                          setState(() {
                            _obscurePassword = !_obscurePassword;
                          });
                        },
                      ),
                    ),
                  ),
                  const SizedBox(height: 10),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Row(
                        children: [
                          Checkbox(
                            value: _rememberMe,
                            onChanged: (bool? newValue) {
                              setState(() {
                                _rememberMe = newValue ?? false;
                              });
                            },
                            activeColor: const Color(0xFF015C91),
                            checkColor: Colors.white,
                          ),
                          const Text(
                            'Ingatkan saya',
                            style: TextStyle(
                              color: Color(0xFF002033),
                              fontFamily: 'Poppins',
                            ),
                          ),
                        ],
                      ),
                      TextButton(
                        onPressed: () {
                          debugPrint('Lupa password?');
                        },
                        child: Text(
                          'Lupa password?',
                          style: TextStyle(
                            color: Theme.of(context).primaryColor,
                            fontFamily: 'Poppins',
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 30),
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton(
                      onPressed: _login,
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
                      child: const Text('Masuk'),
                    ),
                  ),
                  const SizedBox(height: 20),
                  Center(
                    child: Text(
                      'Atau',
                      style: TextStyle(
                        color: Colors.grey.shade600,
                        fontFamily: 'Poppins',
                      ),
                    ),
                  ),
                  const SizedBox(height: 20),
                  Center(
                    child: TextButton.icon(
                      onPressed: () {
                        debugPrint('Login dengan Google');
                      },
                      icon: Image.asset(
                        'assets/images/google_logo.png',
                        height: 45,
                        width: 45,
                      ),
                      label: const Text(''),
                      style: TextButton.styleFrom(
                        foregroundColor: Colors.grey.shade700,
                        backgroundColor: Colors.transparent,
                        elevation: 0,
                        padding: EdgeInsets.zero,
                        textStyle: const TextStyle(fontFamily: 'Poppins'),
                      ),
                    ),
                  ),
                  const SizedBox(height: 40),
                  Center(
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        const Text(
                          'Belum punya akun?',
                          style: TextStyle(
                            color: Color(0xFF002033),
                            fontFamily: 'Poppins',
                          ),
                        ),
                        TextButton(
                          onPressed: () {
                            Navigator.of(context).pushReplacement(
                              MaterialPageRoute(
                                builder: (context) => const RegisterScreen(),
                              ),
                            );
                          },
                          child: Text(
                            'Daftar',
                            style: TextStyle(
                              color: Theme.of(context).primaryColor,
                              fontFamily: 'Poppins',
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
