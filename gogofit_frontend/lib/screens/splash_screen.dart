// lib/screens/splash_screen.dart

import 'package:flutter/material.dart';
import 'package:gogofit_frontend/screens/auth/login_screen.dart';
import 'package:gogofit_frontend/screens/dashboard_screen.dart';
import 'package:gogofit_frontend/services/notification_service.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:gogofit_frontend/services/api_service.dart';
import 'package:gogofit_frontend/services/auth_token_manager.dart'; // BARU: Import AuthTokenManager
import 'package:gogofit_frontend/models/user_profile_data.dart';
import 'package:gogofit_frontend/exceptions/unauthorized_exception.dart'; // BARU: Import UnauthorizedException

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  @override
  void initState() {
    super.initState();
    _initializeAppAndNavigate();
  }

  Future<void> _initializeAppAndNavigate() async {
    try {
      // 1. Meminta izin notifikasi secara eksplisit
      var status = await Permission.notification.status;
      debugPrint("Initial Notification permission status: $status");

      if (status.isDenied || status.isPermanentlyDenied) {
        final permissionStatus = await Permission.notification.request();
        debugPrint("Permission request result: $permissionStatus");
        if (permissionStatus.isDenied || permissionStatus.isPermanentlyDenied) {
          debugPrint(
            "Izin notifikasi tidak diberikan. Beberapa fitur mungkin tidak berfungsi.",
          );
        }
      }
      status = await Permission.notification.status;
      debugPrint("Final Notification permission status: $status");

      // 2. Inisialisasi NotificationService
      await notificationService.init();
      debugPrint("Local Notification Service initialized!");

      // 3. Jeda untuk splash screen terlihat jelas
      await Future.delayed(const Duration(seconds: 2));

      // 4. Periksa status login untuk navigasi
      bool isLoggedIn = await AuthTokenManager.hasAuthToken();
      debugPrint("User logged in status: $isLoggedIn");

      if (!mounted) return;

      if (isLoggedIn) {
        try {
          // Memanggil getUserProfile. Jika token invalid, ApiService akan throw UnauthorizedException
          final userProfile = await ApiService().getUserProfile();

          if (!mounted) return; // Check mounted after await

          if (userProfile != null) {
            currentUserProfile.value =
                userProfile; // Perbarui data profil global
            Navigator.of(context).pushReplacement(
              MaterialPageRoute(builder: (context) => const DashboardScreen()),
            );
            debugPrint("Splash screen selesai, auto-login ke DashboardScreen.");
          } else {
            // Jika userProfile null, bisa jadi karena ApiService sudah memicu redirect
            // atau ada masalah lain selain 401. Dalam kasus ini, kita harus ke LoginScreen.
            await AuthTokenManager.clearAuthToken(); // Pastikan token bersih
            if (!mounted) return;
            Navigator.of(context).pushReplacement(
              MaterialPageRoute(builder: (context) => const LoginScreen()),
            );
            debugPrint(
              "Splash screen selesai, profil tidak dapat dimuat, mengarahkan ke LoginScreen.",
            );
          }
        } on UnauthorizedException catch (e) {
          // Exception ini akan tertangkap jika ApiService mendeteksi 401.
          // ApiService sudah akan memicu clearToken dan redirect ke LoginScreen.
          debugPrint(
            "Splash screen: Caught UnauthorizedException: ${e.message}. Redirect handled by ApiService.",
          );
          // Tidak perlu melakukan navigasi lagi di sini karena sudah di-handle oleh ApiService.
        } catch (e) {
          // Menangkap error lain saat mengambil profil (misalnya, masalah jaringan)
          debugPrint("Error fetching user profile during auto-login: $e");
          await AuthTokenManager.clearAuthToken(); // Hapus token jika ada error
          if (!mounted) return;
          Navigator.of(context).pushReplacement(
            MaterialPageRoute(builder: (context) => const LoginScreen()),
          );
          debugPrint(
            "Splash screen selesai, error saat auto-login, mengarahkan ke LoginScreen.",
          );
        }
      } else {
        // Jika tidak ada token (isLoggedIn false)
        Navigator.of(context).pushReplacement(
          MaterialPageRoute(builder: (context) => const LoginScreen()),
        );
        debugPrint(
          "Splash screen selesai, tidak ada token, mengarahkan ke LoginScreen.",
        );
      }
    } catch (e) {
      // Menangkap error umum selama inisialisasi aplikasi (di luar API call)
      debugPrint("Error during app initialization: $e");
      await Future.delayed(
        const Duration(seconds: 1),
      ); // Jeda sebentar sebelum redirect
      if (!mounted) return;
      Navigator.of(context).pushReplacement(
        MaterialPageRoute(builder: (context) => const LoginScreen()),
      );
      debugPrint(
        "Splash screen selesai, terjadi error, mengarahkan ke LoginScreen.",
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Text(
              'Selamat Datang di',
              style: TextStyle(
                color: Color(0xFF002033),
                fontSize: 24,
                fontWeight: FontWeight.bold,
                fontFamily: 'Poppins',
              ),
            ),
            const SizedBox(height: 40),
            const Image(
              image: AssetImage('assets/images/logo_gogofit.png'),
              width: 400,
              height: 400,
            ),
            const SizedBox(height: 20),
            const Text(
              'GOGO-FIT',
              style: TextStyle(
                color: Color(0xFF002033),
                fontSize: 32,
                fontWeight: FontWeight.bold,
                letterSpacing: 2.0,
                fontFamily: 'Poppins',
              ),
            ),
            const SizedBox(height: 50),
            const CircularProgressIndicator(
              valueColor: AlwaysStoppedAnimation<Color>(Colors.blueAccent),
            ),
          ],
        ),
      ),
    );
  }
}
