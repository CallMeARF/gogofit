// lib/screens/notifications_screen.dart
import 'package:flutter/material.dart';
import 'package:gogofit_frontend/models/notification_data.dart'; // Import data notifikasi

class NotificationsScreen extends StatefulWidget {
  const NotificationsScreen({super.key});

  @override
  State<NotificationsScreen> createState() => _NotificationsScreenState();
}

class _NotificationsScreenState extends State<NotificationsScreen> {
  // Definisi warna yang konsisten
  final Color primaryBlueNormal = const Color(0xFF015c91);
  final Color darkerBlue = const Color(0xFF002033);
  final Color lightBlueCardBackground = const Color(0xFFD9E7EF);

  final Color darkerBlue70Opacity = const Color.fromARGB(179, 0, 32, 51);
  final Color darkerBlue60Opacity = const Color.fromARGB(153, 0, 32, 51);

  @override
  void initState() {
    super.initState();
    addDummyNotifications();
    appNotifications.addListener(_updateScreen);
  }

  @override
  void dispose() {
    appNotifications.removeListener(_updateScreen);
    super.dispose();
  }

  void _updateScreen() {
    setState(() {
      // Rebuild UI saat daftar notifikasi berubah
    });
  }

  // Fungsi konfirmasi hapus notifikasi
  void _confirmDeleteNotification(AppNotification notification) {
    showDialog(
      context: context,
      builder: (BuildContext dialogContext) {
        return AlertDialog(
          title: const Text(
            'Hapus Pemberitahuan?',
            style: TextStyle(
              fontFamily: 'Poppins',
              fontWeight: FontWeight.bold,
            ),
          ),
          content: Text(
            'Anda yakin ingin menghapus "${notification.title}"?',
            style: const TextStyle(fontFamily: 'Poppins'),
          ),
          actions: <Widget>[
            TextButton(
              child: const Text(
                'Batal',
                style: TextStyle(fontFamily: 'Poppins', color: Colors.grey),
              ),
              onPressed: () {
                Navigator.of(dialogContext).pop();
              },
            ),
            TextButton(
              child: const Text(
                'Hapus',
                style: TextStyle(fontFamily: 'Poppins', color: Colors.red),
              ),
              onPressed: () {
                deleteNotification(notification.id); // Panggil fungsi delete
                Navigator.of(dialogContext).pop(); // Tutup dialog
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text(
                      'Pemberitahuan dihapus: ${notification.title}',
                    ),
                  ),
                );
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
        scrolledUnderElevation: 0.0,
        shadowColor: Colors.transparent,
        leading: IconButton(
          icon: Icon(Icons.arrow_back_ios, color: Colors.white, size: 24),
          onPressed: () {
            Navigator.pop(context);
          },
        ),
        title: Text(
          'Pemberitahuan',
          style: TextStyle(
            color: Colors.white,
            fontSize: 24,
            fontWeight: FontWeight.bold,
            fontFamily: 'Poppins',
          ),
        ),
        centerTitle: true,
        actions: const [SizedBox(width: 48)],
      ),
      body: ValueListenableBuilder<List<AppNotification>>(
        valueListenable: appNotifications,
        builder: (context, notifications, child) {
          if (notifications.isEmpty) {
            return Center(
              child: Text(
                'Tidak ada pemberitahuan saat ini.',
                style: TextStyle(
                  fontSize: 16,
                  color: darkerBlue60Opacity,
                  fontFamily: 'Poppins',
                ),
              ),
            );
          }
          return ListView.builder(
            padding: const EdgeInsets.all(16.0),
            itemCount: notifications.length,
            itemBuilder: (context, index) {
              final notification = notifications[index];
              return _buildNotificationCard(notification);
            },
          );
        },
      ),
    );
  }

  Widget _buildNotificationCard(AppNotification notification) {
    // KOREKSI: Mengganti penggunaan .red, .green, .blue dengan nilai RGB literal
    final Color primaryBlueNormalTransparent = Color.fromARGB(
      (255 * 0.1).round(), // Alpha
      1, // Red dari 0x015c91
      92, // Green dari 0x015c91
      145, // Blue dari 0x015c91
    );

    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      elevation: 4,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      color:
          notification.isRead
              ? lightBlueCardBackground
              : primaryBlueNormalTransparent,
      child: InkWell(
        onTap: () {
          debugPrint('Notification card tapped: ${notification.title}');
        },
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Icon(
                notification.icon,
                color:
                    notification.isRead
                        ? darkerBlue70Opacity
                        : notification.iconColor,
                size: 30,
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      notification.title,
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: notification.isRead ? darkerBlue : darkerBlue,
                        fontFamily: 'Poppins',
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      notification.message,
                      style: TextStyle(
                        fontSize: 14,
                        color:
                            notification.isRead
                                ? darkerBlue60Opacity
                                : darkerBlue,
                        fontFamily: 'Poppins',
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      '${notification.timestamp.hour.toString().padLeft(2, '0')}:${notification.timestamp.minute.toString().padLeft(2, '0')} - '
                      '${notification.timestamp.day}/${notification.timestamp.month}/${notification.timestamp.year}',
                      style: TextStyle(
                        fontSize: 12,
                        color:
                            notification.isRead
                                ? darkerBlue60Opacity
                                : darkerBlue,
                        fontFamily: 'Poppins',
                      ),
                    ),
                  ],
                ),
              ),
              // Tombol untuk menandai sudah dibaca
              if (!notification.isRead)
                IconButton(
                  icon: Icon(
                    Icons.mark_email_read_outlined,
                    color: primaryBlueNormal,
                  ),
                  onPressed: () {
                    markNotificationAsRead(notification.id);
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: Text(
                          'Pemberitahuan "${notification.title}" ditandai sudah dibaca.',
                        ),
                      ),
                    );
                  },
                ),
              // Tombol untuk menghapus notifikasi
              IconButton(
                icon: Icon(
                  Icons.delete_outline,
                  color: Color.fromARGB(
                    (255 * (notification.isRead ? 0.5 : 1.0)).round(),
                    244,
                    67,
                    54,
                  ),
                ),
                onPressed: () {
                  _confirmDeleteNotification(notification);
                },
              ),
            ],
          ),
        ),
      ),
    );
  }
}
