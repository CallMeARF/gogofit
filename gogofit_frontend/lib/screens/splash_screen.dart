import 'package:flutter/material.dart';
import 'package:gogofit_frontend/screens/auth/login_screen.dart';
import 'package:gogofit_frontend/services/notification_service.dart'; // Import NotificationService
import 'package:permission_handler/permission_handler.dart'; // Import permission_handler

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
    // WidgetsFlutterBinding.ensureInitialized() sudah di main.dart, tidak perlu lagi di sini

    try {
      // 1. Meminta izin notifikasi secara eksplisit (PENTING untuk API 36.0)
      var status = await Permission.notification.status;
      debugPrint("Initial Notification permission status: $status");

      if (status.isDenied || status.isPermanentlyDenied) {
        final permissionStatus = await Permission.notification.request();
        debugPrint("Permission request result: $permissionStatus");
        if (permissionStatus.isDenied || permissionStatus.isPermanentlyDenied) {
          debugPrint(
            "Izin notifikasi tidak diberikan. Beberapa fitur mungkin tidak berfungsi.",
          );
          // Jika izin tidak diberikan, aplikasi akan tetap berjalan, tapi notifikasi tidak muncul.
        }
      }
      status =
          await Permission
              .notification
              .status; // Perbarui status setelah permintaan
      debugPrint("Final Notification permission status: $status");

      // 2. Inisialisasi NotificationService
      await notificationService.init();
      debugPrint("Local Notification Service initialized!");

      // 3. PICU NOTIFIKASI UJI COBA SEGERA SETELAH INIT (untuk melihat apakah plugin bekerja)
      // BARIS INI DIKOMENTARI/DIHAPUS UNTUK MENGHILANGKAN NOTIFIKASI TEST LAUNCH
      // await notificationService.showLocalNotification(
      //   id: 999, // ID unik
      //   title: 'Gogofit Test Launch',
      //   body: 'Aplikasi berhasil diluncurkan dan notifikasi berfungsi!',
      //   channelId: 'gogofit_test_channel_launch',
      //   channelName: 'Test Launch Notifikasi',
      //   channelDescription: 'Channel untuk menguji notifikasi saat peluncuran',
      //   payload: 'test_launch_payload',
      // );
      // debugPrint("Test notification triggered from SplashScreen.");

      // 4. Jeda untuk splash screen terlihat jelas
      await Future.delayed(const Duration(seconds: 2));
    } catch (e) {
      debugPrint("Error during app initialization: $e");
      // Jika terjadi error serius saat inisialisasi, Anda bisa arahkan ke halaman error
      await Future.delayed(const Duration(seconds: 3));
    }

    if (!mounted) return;

    Navigator.of(context).pushReplacement(
      MaterialPageRoute(builder: (context) => const LoginScreen()),
    );
    debugPrint("Splash screen selesai, navigasi otomatis ke halaman Login...");
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              'Selamat Datang di',
              style: TextStyle(
                color: const Color(0xFF002033),
                fontSize: 24,
                fontWeight: FontWeight.bold,
                fontFamily: 'Poppins',
              ),
            ),
            const SizedBox(height: 40),
            Image(
              image: const AssetImage(
                'assets/images/logo_gogofit.png',
              ), // Pastikan path ini benar
              width: 400,
              height: 400,
            ),
            const SizedBox(height: 20),
            Text(
              'GOGO-FIT',
              style: TextStyle(
                color: const Color(0xFF002033),
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
