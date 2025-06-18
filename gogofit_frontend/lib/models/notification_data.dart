// lib/models/notification_data.dart
import 'package:flutter/material.dart';
// import 'package:flutter/foundation.dart'; // Baris ini dihapus karena tidak diperlukan secara langsung di file ini

enum NotificationType {
  info,
  warning, // Peringatan (misal: kalori berlebih)
  reminder, // Pengingat (misal: waktu makan)
  achievement, // Pencapaian (misal: target tercapai)
}

class AppNotification {
  final String id;
  final String title;
  final String message;
  final DateTime timestamp;
  bool isRead;
  final NotificationType type;

  AppNotification({
    String? id,
    required this.title,
    required this.message,
    required this.timestamp,
    this.isRead = false,
    this.type = NotificationType.info,
  }) : id = id ?? DateTime.now().microsecondsSinceEpoch.toString();

  IconData get icon {
    switch (type) {
      case NotificationType.info:
        return Icons.info_outline;
      case NotificationType.warning:
        return Icons.warning_amber_rounded;
      case NotificationType.reminder:
        return Icons.access_time;
      case NotificationType.achievement:
        return Icons.emoji_events_outlined;
    }
  }

  Color get iconColor {
    switch (type) {
      case NotificationType.info:
        return Colors.blueAccent;
      case NotificationType.warning:
        return Colors.orange;
      case NotificationType.reminder:
        return Colors.purple;
      case NotificationType.achievement:
        return Colors.green;
    }
  }

  AppNotification copyWith({
    String? id,
    String? title,
    String? message,
    DateTime? timestamp,
    bool? isRead,
    NotificationType? type,
  }) {
    return AppNotification(
      id: id ?? this.id,
      title: title ?? this.title,
      message: message ?? this.message,
      timestamp: timestamp ?? this.timestamp,
      isRead: isRead ?? this.isRead,
      type: type ?? this.type,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'title': title,
      'message': message,
      'timestamp': timestamp.toIso8601String(),
      'isRead': isRead,
      'type': type.toString().split('.').last,
    };
  }
}

final ValueNotifier<List<AppNotification>> appNotifications =
    ValueNotifier<List<AppNotification>>([]);

// Fungsi untuk menambahkan notifikasi baru
// Memperbaiki logika duplikasi agar lebih akurat dengan ID atau Judul/Tipe
void addNotification(AppNotification newNotification) {
  final today = DateTime.now();

  // Untuk notifikasi WARNING dan ACHIEVEMENT, kita hanya ingin satu jenis notifikasi per hari.
  // Contoh: hanya satu "Peringatan Kalori Berlebih!" per hari.
  // Dan hanya satu "Target Kalori Tercapai!" per hari.
  if (newNotification.type == NotificationType.warning ||
      newNotification.type == NotificationType.achievement) {
    // Cek apakah ada notifikasi dengan JUDUL dan TIPE yang sama untuk hari ini
    final bool titleTypeExistsForToday = appNotifications.value.any(
      (n) =>
          n.title == newNotification.title &&
          n.type == newNotification.type &&
          n.timestamp.year == today.year &&
          n.timestamp.month == today.month &&
          n.timestamp.day == today.day,
    );

    if (titleTypeExistsForToday) {
      debugPrint(
        'Notifikasi serupa (Warning/Achievement) sudah ada untuk hari ini: ${newNotification.title}. Tidak ditambahkan duplikat.',
      );
      return; // Jangan tambahkan jika sudah ada
    }
  }

  // Untuk tipe notifikasi lain (info, reminder) atau jika tidak ada duplikasi warning/achievement,
  // atau jika ID unik tidak ditemukan (untuk notifikasi yang lebih umum seperti pengingat yang bisa berulang)
  // Tambahkan hanya jika TIDAK ADA notifikasi dengan ID yang persis sama.
  final bool idExists = appNotifications.value.any(
    (n) => n.id == newNotification.id,
  );

  if (!idExists) {
    appNotifications.value = [...appNotifications.value, newNotification];
    appNotifications.value.sort(
      (a, b) => b.timestamp.compareTo(a.timestamp),
    ); // Urutkan dari terbaru
  } else {
    debugPrint(
      'Notifikasi dengan ID ${newNotification.id} sudah ada. Tidak ditambahkan duplikat ID.',
    );
  }
}

void markNotificationAsRead(String id) {
  appNotifications.value =
      appNotifications.value.map((notification) {
        return notification.id == id
            ? notification.copyWith(isRead: true)
            : notification;
      }).toList();
}

void deleteNotification(String id) {
  appNotifications.value =
      appNotifications.value
          .where((notification) => notification.id != id)
          .toList();
}

// FUNGSI BARU: Untuk menghapus notifikasi spesifik berdasarkan judul dan tipe untuk hari ini
void removeSpecificNotificationForToday(
  String titlePart,
  NotificationType type,
) {
  final today = DateTime.now();
  appNotifications.value =
      appNotifications.value.where((notification) {
        // Pertahankan notifikasi jika:
        // 1. Tipe atau judulnya tidak cocok (bukan yang ingin dihapus)
        // 2. Jika tanggalnya berbeda (notifikasi dari hari lain)
        return !(notification.type == type &&
            notification.title.contains(titlePart) &&
            notification.timestamp.year == today.year &&
            notification.timestamp.month == today.month &&
            notification.timestamp.day == today.day);
      }).toList();
  // debugPrint('DEBUG: Mencoba menghapus notifikasi "$titlePart" (${type.name}) untuk hari ini.'); // Tetap pakai jika perlu debug
}

// Fungsi helper untuk memeriksa apakah notifikasi spesifik sudah ada untuk hari ini
// Berdasarkan bagian judul dan tipe notifikasi
bool hasSpecificNotificationForToday(String titlePart, NotificationType type) {
  final today = DateTime.now();
  return appNotifications.value.any(
    (notification) =>
        notification.type == type &&
        notification.title.contains(titlePart) &&
        notification.timestamp.year == today.year &&
        notification.timestamp.month == today.month &&
        notification.timestamp.day == today.day,
  );
}

void addDummyNotifications() {
  if (appNotifications.value.isEmpty) {
    // Hanya tambahkan jika kosong
    appNotifications.value = [
      // MENGHAPUS dummy "Peringatan Kalori Berlebih!" dan "Target Gula Tercapai!"
      AppNotification(
        id: 'lunch_reminder_dummy',
        title: 'Waktunya Makan Siang',
        message: 'Kamu belum mencatat makan siang. Yuk, isi sekarang!',
        timestamp: DateTime.now().subtract(const Duration(hours: 1)),
        type: NotificationType.reminder,
        isRead: false,
      ),
      AppNotification(
        id: 'welcome_info_dummy',
        title: 'Informasi Penting',
        message: 'Selamat datang di Gogofit! Mulai catat makanan Anda.',
        timestamp: DateTime.now().subtract(const Duration(days: 1)),
        type: NotificationType.info,
        isRead: false,
      ),
    ];
    appNotifications.value.sort(
      (a, b) => b.timestamp.compareTo(a.timestamp),
    ); // Urutkan dari terbaru
  }
}

int getUnreadNotificationCount() {
  return appNotifications.value
      .where((notification) => !notification.isRead)
      .length;
}
