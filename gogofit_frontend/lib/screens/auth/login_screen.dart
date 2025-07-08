// lib/screens/auth/login_screen.dart

import 'package:flutter/material.dart';
import 'package:gogofit_frontend/screens/auth/register_screen.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:gogofit_frontend/services/api_service.dart';
import 'package:gogofit_frontend/screens/dashboard_screen.dart';
import 'package:gogofit_frontend/models/user_profile_data.dart';
import 'package:gogofit_frontend/screens/auth/forgot_password_screen.dart';
import 'package:gogofit_frontend/exceptions/unauthorized_exception.dart'; // BARU: Import UnauthorizedException

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
      // Memanggil ApiService.login(). Parameter rememberMe akan diteruskan,
      // dan logika persistensi token (melalui AuthTokenManager) sudah ditangani di dalam ApiService.login().
      final response = await _apiService.login(
        email,
        password,
        rememberMe: _rememberMe, // Pastikan ini diteruskan
      );

      if (!mounted) return;
      // Pastikan dialog loading ditutup sebelum tindakan lain
      Navigator.of(context).pop();

      if (response['success']) {
        // PERBAIKAN: Hapus kode penyimpanan token di sini.
        // Logika penyimpanan token sudah dipindahkan ke ApiService.login()
        // dan AuthTokenManager.
        // if (response.containsKey('token')) {
        //     String token = response['token'];
        //     await AuthTokenManager.setAuthToken(token, rememberMe: _rememberMe);
        // }

        // Setelah login berhasil, coba ambil profil pengguna
        final UserProfile? fetchedProfile = await _apiService.getUserProfile();

        if (!mounted) return;

        if (fetchedProfile != null) {
          currentUserProfile.value = fetchedProfile;
          debugPrint(
            'User profile updated after successful login: ${fetchedProfile.name}',
          );
        } else {
          // Jika profil null, bisa jadi karena UnauthorizedException yang sudah ditangani ApiService (redirect)
          // atau error lain yang tidak 401. Log saja.
          debugPrint(
            'Failed to fetch user profile immediately after login, possibly due to API Service redirect or other error.',
          );
        }

        // Tampilkan dialog sukses dan kemudian navigasi ke Dashboard
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
        // Jika login gagal (respons success: false)
        _showAlertDialog(
          'Error',
          response['message'] ?? 'Login gagal. Cek email dan password Anda.',
        );
      }
    } on UnauthorizedException catch (e) {
      // Ini seharusnya jarang terjadi di sini karena login() di ApiService memiliki requireAuth: false.
      // Namun jika terjadi, ini berarti token yang mungkin ada (misal dari sesi sebelumnya) dianggap invalid
      // oleh server dan ApiService sudah memicunya untuk redirect ke LoginScreen lagi.
      if (!mounted) return;
      Navigator.of(context).pop(); // Tutup loading dialog jika masih terbuka
      debugPrint('Login Error (UnauthorizedException): ${e.message}');
      // ApiService sudah melakukan redirect, jadi tidak perlu navigasi lagi di sini
      _showAlertDialog('Error', e.message);
    } catch (e) {
      // Tangani error lain yang tidak terduga
      if (!mounted) return;
      Navigator.of(context).pop(); // Tutup loading dialog
      debugPrint('Login Error: $e');
      _showAlertDialog(
        'Error',
        'Terjadi kesalahan saat login: ${e.toString().contains('Exception:') ? e.toString().split('Exception:').last.trim() : 'Mohon coba lagi.'}',
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
                          // Navigasi ke ForgotPasswordScreen
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder:
                                  (context) => const ForgotPasswordScreen(),
                            ),
                          );
                          debugPrint('Navigasi ke ForgotPasswordScreen');
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
                  // BARU: Sembunyikan bagian "Atau" dan Login Google
                  Offstage(
                    offstage: true, // Set to true untuk menyembunyikan
                    child: Column(
                      children: [
                        Center(
                          child: Text(
                            'Atau',
                            style: TextStyle(
                              color: Colors.grey.shade600,
                              fontFamily: 'Poppins',
                            ),
                          ),
                        ),
                        SizedBox(height: 20),
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
                            label: Text(''),
                            style: TextButton.styleFrom(
                              foregroundColor: Colors.grey.shade700,
                              backgroundColor: Colors.transparent,
                              elevation: 0,
                              padding: EdgeInsets.zero,
                              textStyle: TextStyle(fontFamily: 'Poppins'),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 20),
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
