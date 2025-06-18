// lib/screens/more_options_screen.dart
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart'; // Untuk bottom navigation wave
import 'package:gogofit_frontend/screens/dashboard_screen.dart'; // Untuk navigasi bottom bar
import 'package:gogofit_frontend/screens/daily_log_screen.dart'; // Untuk navigasi bottom bar
import 'package:gogofit_frontend/screens/select_meal_screen.dart'; // Untuk navigasi search bar
import 'package:gogofit_frontend/screens/notifications_screen.dart'; // Import NotificationsScreen
import 'package:gogofit_frontend/models/notification_data.dart'; // Import notification_data.dart
import 'package:gogofit_frontend/screens/profile_detail_screen.dart'; // Import ProfileDetailScreen
import 'package:gogofit_frontend/models/user_profile_data.dart'; // BARU: Import UserProfile model
import 'package:gogofit_frontend/services/api_service.dart'; // BARU: Import ApiService untuk logout
import 'package:gogofit_frontend/screens/auth/login_screen.dart'; // BARU: Import LoginScreen untuk navigasi setelah logout

class MoreOptionsScreen extends StatefulWidget {
  const MoreOptionsScreen({super.key});

  @override
  State<MoreOptionsScreen> createState() => _MoreOptionsScreenState();
}

class _MoreOptionsScreenState extends State<MoreOptionsScreen> {
  // Definisi warna yang konsisten dari Dashboard/DailyLogScreen
  final Color primaryBlueNormal = const Color(0xFF015c91);
  final Color darkerBlue = const Color(0xFF002033);
  final Color lightBlueCardBackground = const Color(0xFFD9E7EF);
  final Color searchBarIconColor = const Color(0xFF6DCFF6);

  final Color white70Opacity = const Color.fromARGB(179, 255, 255, 255);
  final Color black25Opacity = const Color.fromARGB(25, 0, 0, 0);
  final Color black51Opacity = const Color.fromARGB(51, 0, 0, 0);
  final Color darkerBlue70Opacity = const Color.fromARGB(179, 0, 32, 51);
  final Color alertRedColor = const Color(0xFFEF5350);

  final ApiService _apiService = ApiService(); // Inisialisasi ApiService

  @override
  void initState() {
    super.initState();
    // Tidak perlu addListener di sini, ValueListenableBuilder akan menangani
  }

  // Fungsi untuk konfirmasi logout
  void _confirmLogout() {
    showDialog(
      context: context,
      builder: (BuildContext dialogContext) {
        return AlertDialog(
          title: const Text(
            'Konfirmasi Logout',
            style: TextStyle(
              fontFamily: 'Poppins',
              fontWeight: FontWeight.bold,
            ),
          ),
          content: const Text(
            'Anda yakin ingin keluar?',
            style: TextStyle(fontFamily: 'Poppins'),
          ),
          actions: <Widget>[
            TextButton(
              child: Text(
                'Batal',
                style: TextStyle(
                  fontFamily: 'Poppins',
                  color: primaryBlueNormal,
                ),
              ),
              onPressed: () {
                Navigator.of(dialogContext).pop(); // Tutup dialog
              },
            ),
            TextButton(
              child: const Text(
                'Logout',
                style: TextStyle(fontFamily: 'Poppins', color: Colors.red),
              ),
              onPressed: () {
                Navigator.of(dialogContext).pop(); // Tutup dialog
                _performLogout(); // Lanjutkan proses logout
              },
            ),
          ],
        );
      },
    );
  }

  // Fungsi untuk melakukan logout
  void _performLogout() async {
    try {
      final response = await _apiService.logout();

      // PENTING: Cek `mounted` setelah `await _apiService.logout()`
      if (!mounted) {
        debugPrint('Widget not mounted after logout API call.');
        return;
      }

      // Pastikan response adalah Map dan memiliki kunci 'success' sebelum mengaksesnya
      // Error 'unnecessary_type_check' sebelumnya muncul karena Dart Analyzer sudah cukup pintar
      // untuk menyimpulkan tipe `response` dari `_apiService.logout()`.
      // Saya mengembalikan ini ke bentuk yang lebih sederhana agar tidak ada peringatan type check.
      // Jika _apiService.logout() bisa mengembalikan non-Map, Anda harus menangani `CastError`
      // atau membuat return type _apiService.logout() lebih spesifik (misal Future<Map<String, dynamic>>).
      if (response['success']) {
        // Baris 109 yang dimaksud pada error gambar
        await AuthTokenManager.clearAuthToken();
        // PENTING: Cek `mounted` lagi setelah `await AuthTokenManager.clearAuthToken()`
        if (!mounted) {
          debugPrint('Widget not mounted after clearAuthToken (success).');
          return;
        }
        debugPrint('Logout berhasil. Mengarahkan ke LoginScreen.');
        Navigator.of(context).pushAndRemoveUntil(
          MaterialPageRoute(builder: (context) => const LoginScreen()),
          (Route<dynamic> route) => false,
        );
      } else {
        // Cek apakah response memiliki statusCode dan bukan 404
        if (response['statusCode'] != 404) {
          // Baris 126 yang dimaksud pada error gambar
          await AuthTokenManager.clearAuthToken();
          // PENTING: Cek `mounted` lagi setelah `await AuthTokenManager.clearAuthToken()`
          if (!mounted) {
            debugPrint('Widget not mounted after clearAuthToken (failure).');
            return;
          }
          Navigator.of(context).pushAndRemoveUntil(
            MaterialPageRoute(builder: (context) => const LoginScreen()),
            (Route<dynamic> route) => false,
          );
        }
        // PENTING: Cek `mounted` sebelum `ScaffoldMessenger.of(context)`
        if (!mounted) {
          debugPrint('Widget not mounted before showSnackBar (failure).');
          return;
        }
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(response['message'] ?? 'Logout gagal.')),
        );
      }
    } catch (e) {
      debugPrint('Logout Error: $e');
      // PENTING: Cek `mounted` sebelum `ScaffoldMessenger.of(context)` di blok catch
      if (!mounted) {
        debugPrint('Widget not mounted after logout API call (error catch).');
        return;
      }
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Terjadi kesalahan saat logout: $e')),
      );
      // Jika terjadi error, tetap coba clear token dan arahkan ke login
      // PERHATIAN: Pastikan AuthTokenManager.clearAuthToken() di sini tidak memerlukan `await`
      // jika memang didesain tidak asinkron, atau tambahkan `await` jika asinkron
      // dan cek `mounted` setelahnya. Saya biarkan tanpa `await` sesuai kode Anda yang terakhir.
      AuthTokenManager.clearAuthToken();
      // PENTING: Cek `mounted` sebelum `Navigator.of(context)` di blok catch
      if (!mounted) {
        debugPrint('Widget not mounted before final navigation (error catch).');
        return;
      }
      Navigator.of(context).pushAndRemoveUntil(
        MaterialPageRoute(builder: (context) => const LoginScreen()),
        (Route<dynamic> route) => false,
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        scrolledUnderElevation: 0.0,
        shadowColor: Colors.transparent,
        leading: IconButton(
          icon: Icon(Icons.person, color: primaryBlueNormal, size: 28),
          onPressed: () {
            debugPrint(
              'Navigasi ke halaman Profil (dari ikon person di MoreOptions AppBar)',
            );
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => const ProfileDetailScreen(),
              ),
            );
          },
        ),
        title: Text(
          'GOGOFIT',
          style: TextStyle(
            color: darkerBlue,
            fontSize: 24,
            fontWeight: FontWeight.bold,
            fontFamily: 'Poppins',
          ),
        ),
        centerTitle: true,
        actions: [
          ValueListenableBuilder<List<AppNotification>>(
            valueListenable: appNotifications,
            builder: (context, notifications, child) {
              final int unreadCount = getUnreadNotificationCount();
              return Stack(
                children: [
                  IconButton(
                    icon: Icon(
                      Icons.notifications,
                      color: primaryBlueNormal,
                      size: 28,
                    ),
                    onPressed: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => const NotificationsScreen(),
                        ),
                      );
                    },
                  ),
                  if (unreadCount > 0)
                    Positioned(
                      right: 8,
                      top: 8,
                      child: Container(
                        padding: const EdgeInsets.all(2),
                        decoration: BoxDecoration(
                          color: alertRedColor,
                          borderRadius: BorderRadius.circular(6),
                        ),
                        constraints: const BoxConstraints(
                          minWidth: 12,
                          minHeight: 12,
                        ),
                        child: Text(
                          unreadCount.toString(),
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 8,
                            fontFamily: 'Poppins',
                          ),
                          textAlign: TextAlign.center,
                        ),
                      ),
                    ),
                ],
              );
            },
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            // Bagian Foto Profil dan Nama Pengguna
            Center(
              // FIX: Gunakan ValueListenableBuilder untuk nama dan email dinamis
              child: ValueListenableBuilder<UserProfile>(
                valueListenable: currentUserProfile,
                builder: (context, profile, child) {
                  return Column(
                    children: [
                      CircleAvatar(
                        radius: 60,
                        backgroundColor: lightBlueCardBackground,
                        backgroundImage: const AssetImage(
                          'assets/images/placeholder_profile.png',
                        ),
                      ),
                      const SizedBox(height: 16),
                      Text(
                        profile.name, // Menampilkan nama pengguna yang login
                        style: TextStyle(
                          fontSize: 24,
                          fontWeight: FontWeight.bold,
                          color: darkerBlue,
                          fontFamily: 'Poppins',
                        ),
                      ),
                      Text(
                        profile.email, // Menampilkan email pengguna yang login
                        style: TextStyle(
                          fontSize: 16,
                          color: Colors.grey.shade600,
                          fontFamily: 'Poppins',
                        ),
                      ),
                      const SizedBox(height: 24),
                    ],
                  );
                },
              ),
            ),

            // Daftar Menu
            _buildMenuItem(
              context,
              icon: Icons.person,
              label: 'Profil Saya',
              onTap: () {
                debugPrint('Navigasi ke Halaman Profil Saya');
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => const ProfileDetailScreen(),
                  ),
                );
              },
            ),
            ValueListenableBuilder<List<AppNotification>>(
              valueListenable: appNotifications,
              builder: (context, notifications, child) {
                final int currentUnreadCount = getUnreadNotificationCount();
                return _buildMenuItem(
                  context,
                  icon: Icons.notifications,
                  label: 'Pemberitahuan',
                  onTap: () {
                    debugPrint('Navigasi ke Halaman Pemberitahuan');
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => const NotificationsScreen(),
                      ),
                    );
                  },
                  unreadCount: currentUnreadCount,
                );
              },
            ),
            _buildMenuItem(
              context,
              icon: Icons.food_bank,
              label: 'Nutrisi',
              onTap: () {
                debugPrint('Navigasi ke Halaman Nutrisi');
                // Tambahkan navigasi ke halaman Nutrisi di sini
              },
            ),
            _buildMenuItem(
              context,
              icon: Icons.bar_chart,
              label: 'Laporan Mingguan',
              onTap: () {
                debugPrint('Navigasi ke Halaman Laporan Mingguan');
                // Tambahkan navigasi ke halaman Laporan Mingguan di sini
              },
            ),
            _buildMenuItem(
              context,
              icon: Icons.settings,
              label: 'Setelan',
              onTap: () {
                debugPrint('Navigasi ke Halaman Setelan');
                // Tambahkan navigasi ke halaman Setelan di sini
              },
            ),
            _buildMenuItem(
              context,
              icon: Icons.privacy_tip,
              label: 'Pusat Privasi',
              onTap: () {
                debugPrint('Navigasi ke Halaman Pusat Privasi');
                // Tambahkan navigasi ke halaman Pusat Privasi di sini
              },
            ),
            const SizedBox(height: 24),
            // Tombol Logout
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: _confirmLogout, // Panggil fungsi konfirmasi logout
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.redAccent,
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(vertical: 15),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10),
                  ),
                  elevation: 5,
                  textStyle: const TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    fontFamily: 'Poppins',
                  ),
                ),
                child: const Text('Logout'),
              ),
            ),
          ],
        ),
      ),
      bottomNavigationBar: Container(
        height: 170, // Tinggi yang cukup untuk gelombang dan navigation bar
        color:
            Colors
                .transparent, // Background transparan karena sudah ada gelombang SVG
        child: Stack(
          alignment: Alignment.bottomCenter,
          children: [
            Positioned(
              bottom: 0,
              left: 0,
              right: 0,
              child: SvgPicture.asset(
                'assets/images/bottom_wave_nav.svg',
                fit: BoxFit.fill,
                colorFilter: ColorFilter.mode(
                  primaryBlueNormal,
                  BlendMode.srcIn,
                ),
                height: 170, // Sesuaikan dengan tinggi Container
              ),
            ),
            Positioned(
              bottom: 0,
              left: 0,
              right: 0,
              child: BottomNavigationBar(
                backgroundColor:
                    Colors.transparent, // Transparan agar gelombang terlihat
                elevation: 0,
                selectedItemColor: Colors.white,
                unselectedItemColor: white70Opacity,
                selectedLabelStyle: const TextStyle(
                  fontFamily: 'Poppins',
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                ),
                unselectedLabelStyle: TextStyle(
                  fontFamily: 'Poppins',
                  color: white70Opacity,
                ),
                showUnselectedLabels: true,
                items: const [
                  BottomNavigationBarItem(
                    icon: Icon(Icons.dashboard),
                    label: 'Dasbor',
                  ),
                  BottomNavigationBarItem(
                    icon: Icon(Icons.menu_book),
                    label: 'Buku Harian',
                  ),
                  BottomNavigationBarItem(
                    icon: Icon(Icons.more_horiz),
                    label: 'Lainnya',
                  ),
                ],
                currentIndex: 2, // Mengatur indeks ke "Lainnya"
                onTap: (index) {
                  if (index == 0) {
                    Navigator.pushReplacement(
                      context,
                      MaterialPageRoute(
                        builder: (context) => const DashboardScreen(),
                      ),
                    );
                  } else if (index == 1) {
                    Navigator.pushReplacement(
                      context,
                      MaterialPageRoute(
                        builder: (context) => const DailyLogScreen(),
                      ),
                    );
                  } else if (index == 2) {
                    debugPrint('Already on More Options Screen');
                  }
                },
              ),
            ),
            // Floating Search Bar
            Positioned(
              bottom: 95, // Posisikan di atas BottomNavigationBar
              left: 40,
              right: 40,
              child: GestureDetector(
                onTap: () {
                  debugPrint(
                    'Search bar text tapped! Navigating to SelectMealScreen.',
                  );
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => const SelectMealScreen(),
                    ),
                  );
                },
                child: Container(
                  height: 40.0, // Tinggi search bar
                  padding: const EdgeInsets.symmetric(horizontal: 16.0),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(30.0), // Bentuk kapsul
                    boxShadow: [
                      BoxShadow(
                        color: black25Opacity, // Warna shadow transparan
                        blurRadius: 10,
                        offset: const Offset(0, 5), // Posisi shadow
                      ),
                    ],
                  ),
                  child: Row(
                    children: [
                      Icon(Icons.search, color: searchBarIconColor, size: 20),
                      const SizedBox(width: 8),
                      Expanded(
                        child: TextField(
                          readOnly: true, // Tidak bisa diketik langsung
                          decoration: InputDecoration(
                            hintText: 'Cari Makanan',
                            hintStyle: TextStyle(
                              color: Colors.grey.shade600,
                              fontFamily: 'Poppins',
                              fontSize: 14,
                            ),
                            border:
                                InputBorder.none, // Hilangkan border default
                            isDense: true, // Jaga agar input tetap ringkas
                            contentPadding:
                                EdgeInsets.zero, // Hapus padding default
                          ),
                          style: const TextStyle(
                            fontFamily: 'Poppins',
                            fontSize: 14,
                          ),
                          textAlignVertical:
                              TextAlignVertical.center, // Vertikal tengah
                        ),
                      ),
                      IconButton(
                        icon: Icon(
                          Icons.camera_alt,
                          color: searchBarIconColor,
                          size: 30, // Ukuran ikon kamera yang lebih besar
                        ),
                        onPressed: () {
                          debugPrint(
                            'Camera icon tapped! Navigating to SelectMealScreen for search.',
                          );
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => const SelectMealScreen(),
                            ),
                          );
                        },
                        padding: EdgeInsets.zero, // Hapus padding default
                        constraints:
                            const BoxConstraints(), // Hapus batasan ukuran ikon
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  // Widget helper untuk item menu
  Widget _buildMenuItem(
    BuildContext context, {
    required IconData icon,
    required String label,
    required VoidCallback onTap,
    int? unreadCount,
  }) {
    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      elevation: 3,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      color: lightBlueCardBackground,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          child: Row(
            children: [
              // Icon dan Badge (jika ada unreadCount > 0)
              Stack(
                children: [
                  Icon(icon, color: primaryBlueNormal, size: 28),
                  if (unreadCount != null && unreadCount > 0)
                    Positioned(
                      right: 0,
                      top: 0,
                      child: Container(
                        padding: const EdgeInsets.all(3),
                        decoration: BoxDecoration(
                          color: alertRedColor,
                          borderRadius: BorderRadius.circular(10),
                          border: Border.all(color: Colors.white, width: 1.5),
                        ),
                        constraints: const BoxConstraints(
                          minWidth: 18,
                          minHeight: 18,
                        ),
                        child: Text(
                          unreadCount.toString(),
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 10,
                            fontFamily: 'Poppins',
                            fontWeight: FontWeight.bold,
                          ),
                          textAlign: TextAlign.center,
                        ),
                      ),
                    ),
                ],
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Text(
                  label,
                  style: TextStyle(
                    color: darkerBlue,
                    fontSize: 18,
                    fontFamily: 'Poppins',
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ),
              Icon(
                Icons.arrow_forward_ios,
                color: darkerBlue70Opacity,
                size: 18,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
