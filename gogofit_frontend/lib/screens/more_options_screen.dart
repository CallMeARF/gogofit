// lib/screens/more_options_screen.dart
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:gogofit_frontend/screens/dashboard_screen.dart';
import 'package:gogofit_frontend/screens/daily_log_screen.dart';
import 'package:gogofit_frontend/screens/select_meal_screen.dart';
import 'package:gogofit_frontend/screens/food_scanner_screen.dart';
import 'package:gogofit_frontend/screens/notifications_screen.dart';
import 'package:gogofit_frontend/models/notification_data.dart';
import 'package:gogofit_frontend/screens/profile_detail_screen.dart';
import 'package:gogofit_frontend/models/user_profile_data.dart';
import 'package:gogofit_frontend/services/api_service.dart';
import 'package:gogofit_frontend/services/auth_token_manager.dart';
import 'package:gogofit_frontend/exceptions/unauthorized_exception.dart';
import 'package:gogofit_frontend/screens/auth/login_screen.dart';

class MoreOptionsScreen extends StatefulWidget {
  const MoreOptionsScreen({super.key});

  @override
  State<MoreOptionsScreen> createState() => _MoreOptionsScreenState();
}

class _MoreOptionsScreenState extends State<MoreOptionsScreen> {
  // PERBAIKAN: Kembalikan definisi warna yang hilang.
  final Color primaryBlueNormal = const Color(0xFF015c91);
  final Color darkerBlue = const Color(0xFF002033);
  final Color lightBlueCardBackground = const Color(0xFFD9E7EF);
  final Color searchBarIconColor = const Color(0xFF6DCFF6);
  final Color white70Opacity = const Color.fromARGB(179, 255, 255, 255);
  final Color black25Opacity = const Color.fromARGB(25, 0, 0, 0);
  final Color darkerBlue70Opacity = const Color.fromARGB(179, 0, 32, 51);
  final Color alertRedColor = const Color(0xFFEF5350);
  final ApiService _apiService = ApiService();

  String _getInitials(String name) {
    if (name.trim().isEmpty) return '?';
    List<String> names = name.trim().split(' ');
    String initials = '';
    if (names.isNotEmpty) {
      initials += names.first.isNotEmpty ? names.first[0] : '';
    }
    if (names.length > 1) {
      initials += names.last.isNotEmpty ? names.last[0] : '';
    }
    return initials.toUpperCase();
  }

  @override
  void initState() {
    super.initState();
  }

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
                Navigator.of(dialogContext).pop();
              },
            ),
            TextButton(
              child: const Text(
                'Logout',
                style: TextStyle(fontFamily: 'Poppins', color: Colors.red),
              ),
              onPressed: () {
                Navigator.of(dialogContext).pop();
                _performLogout();
              },
            ),
          ],
        );
      },
    );
  }

  void _performLogout() async {
    try {
      final response = await _apiService.logout();

      if (!mounted) return;

      if (response['success']) {
        debugPrint('Logout berhasil. Mengarahkan ke LoginScreen.');
        Navigator.of(context).pushAndRemoveUntil(
          MaterialPageRoute(builder: (context) => const LoginScreen()),
          (Route<dynamic> route) => false,
        );
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(response['message'] ?? 'Logout gagal.')),
        );
        if (!mounted) return;
        Navigator.of(context).pushAndRemoveUntil(
          MaterialPageRoute(builder: (context) => const LoginScreen()),
          (Route<dynamic> route) => false,
        );
      }
    } on UnauthorizedException catch (e) {
      if (!mounted) return;
      debugPrint(
        'Logout Error (UnauthorizedException): ${e.message}. Redirect handled by ApiService.',
      );
    } catch (e) {
      if (!mounted) return;
      debugPrint('Logout Error: $e');
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            'Terjadi kesalahan saat logout: ${e.toString().contains('Exception:') ? e.toString().split('Exception:').last.trim() : 'Unknown error'}',
          ),
        ),
      );
      if (!mounted) return;
      AuthTokenManager.clearAuthToken();
      Navigator.of(context).pushAndRemoveUntil(
        MaterialPageRoute(builder: (context) => const LoginScreen()),
        (Route<dynamic> route) => false,
      );
    }
  }

  // BARU: Fungsi untuk menampilkan dialog "Segera Hadir"
  void _showComingSoonDialog() {
    showDialog(
      context: context,
      builder: (BuildContext dialogContext) {
        return AlertDialog(
          title: const Text(
            'Fitur Belum Tersedia',
            style: TextStyle(
              fontFamily: 'Poppins',
              fontWeight: FontWeight.bold,
            ),
          ),
          content: const Text(
            'Mohon maaf, fitur ini sedang dalam pengembangan dan akan segera hadir!',
            style: TextStyle(fontFamily: 'Poppins'),
          ),
          actions: <Widget>[
            TextButton(
              child: Text(
                'OK',
                style: TextStyle(
                  fontFamily: 'Poppins',
                  color: primaryBlueNormal,
                ),
              ),
              onPressed: () {
                Navigator.of(dialogContext).pop();
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
        backgroundColor: Colors.white,
        elevation: 0,
        scrolledUnderElevation: 0.0,
        shadowColor: Colors.transparent,
        leading: IconButton(
          icon: Icon(Icons.person, color: primaryBlueNormal, size: 28),
          onPressed: () {
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
            Center(
              child: ValueListenableBuilder<UserProfile>(
                valueListenable: currentUserProfile,
                builder: (context, profile, child) {
                  return Column(
                    children: [
                      CircleAvatar(
                        radius: 60,
                        backgroundColor: profile.avatarColor,
                        child: Text(
                          _getInitials(profile.name),
                          style: const TextStyle(
                            fontSize: 48,
                            color: Colors.white,
                            fontWeight: FontWeight.bold,
                            fontFamily: 'Poppins',
                          ),
                        ),
                      ),
                      const SizedBox(height: 16),
                      Text(
                        profile.name,
                        style: TextStyle(
                          fontSize: 24,
                          fontWeight: FontWeight.bold,
                          color: darkerBlue,
                          fontFamily: 'Poppins',
                        ),
                      ),
                      Text(
                        profile.email,
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
            _buildMenuItem(
              context,
              icon: Icons.person,
              label: 'Profil Saya',
              onTap: () {
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
              onTap: _showComingSoonDialog,
              isDeferred: true,
            ),
            _buildMenuItem(
              context,
              icon: Icons.bar_chart,
              label: 'Laporan Mingguan',
              onTap: _showComingSoonDialog,
              isDeferred: true,
            ),
            _buildMenuItem(
              context,
              icon: Icons.settings,
              label: 'Setelan',
              onTap: _showComingSoonDialog,
              isDeferred: true,
            ),
            _buildMenuItem(
              context,
              icon: Icons.privacy_tip,
              label: 'Pusat Privasi',
              onTap: _showComingSoonDialog,
              isDeferred: true,
            ),
            const SizedBox(height: 24),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: _confirmLogout,
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
        height: 170,
        color: Colors.transparent,
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
                height: 170,
              ),
            ),
            Positioned(
              bottom: 0,
              left: 0,
              right: 0,
              child: BottomNavigationBar(
                backgroundColor: Colors.transparent,
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
                currentIndex: 2,
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
                  }
                },
              ),
            ),
            Positioned(
              bottom: 95,
              left: 40,
              right: 40,
              child: Container(
                // <-- UBAH DARI GestureDetector MENJADI Container
                height: 40.0,
                padding: const EdgeInsets.symmetric(horizontal: 16.0),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(30.0),
                  boxShadow: [
                    BoxShadow(
                      color: black25Opacity,
                      blurRadius: 10,
                      offset: const Offset(0, 5),
                    ),
                  ],
                ),
                child: Row(
                  children: [
                    Icon(Icons.search, color: searchBarIconColor, size: 20),
                    const SizedBox(width: 8),
                    Expanded(
                      child: TextField(
                        readOnly: true,
                        onTap: () {
                          // <-- NAVIGASI KE SELECT_MEAL_SCREEN
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => const SelectMealScreen(),
                            ),
                          );
                        },
                        decoration: InputDecoration(
                          hintText: 'Cari Makanan',
                          hintStyle: TextStyle(
                            color: Colors.grey.shade600,
                            fontFamily: 'Poppins',
                            fontSize: 14,
                          ),
                          border: InputBorder.none,
                          isDense: true,
                          contentPadding: EdgeInsets.zero,
                        ),
                        style: const TextStyle(
                          fontFamily: 'Poppins',
                          fontSize: 14,
                        ),
                        textAlignVertical: TextAlignVertical.center,
                      ),
                    ),
                    IconButton(
                      // <-- NAVIGASI KE FOOD_SCANNER_SCREEN
                      icon: Icon(
                        Icons.camera_alt,
                        color: searchBarIconColor,
                        size: 30,
                      ),
                      onPressed: () {
                        // Pergi ke FoodScannerScreen saat ikon kamera ditekan
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => const FoodScannerScreen(),
                          ),
                        );
                      },
                      padding: EdgeInsets.zero,
                      constraints: const BoxConstraints(),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildMenuItem(
    BuildContext context, {
    required IconData icon,
    required String label,
    required VoidCallback onTap,
    int? unreadCount,
    bool isDeferred = false, // BARU: Tambahkan parameter ini
  }) {
    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      elevation: 3,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      color: lightBlueCardBackground,
      child: InkWell(
        onTap:
            isDeferred
                ? _showComingSoonDialog
                : onTap, // PERBAIKAN: Jika ditunda, panggil dialog
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          child: Row(
            children: [
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
                child: Row(
                  // PERBAIKAN: Gunakan Row untuk menampung label dan status
                  mainAxisAlignment:
                      MainAxisAlignment
                          .spaceBetween, // Agar teks status di kanan
                  children: [
                    Text(
                      label,
                      style: TextStyle(
                        color: darkerBlue,
                        fontSize: 18,
                        fontFamily: 'Poppins',
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                    if (isDeferred) // BARU: Tampilkan teks "Belum Tersedia"
                      Padding(
                        padding: const EdgeInsets.only(left: 8.0),
                        child: Text(
                          'Belum Tersedia',
                          style: TextStyle(
                            color: Colors.grey.shade600,
                            fontSize: 12,
                            fontFamily: 'Poppins',
                            fontStyle: FontStyle.italic,
                          ),
                        ),
                      ),
                  ],
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
