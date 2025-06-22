// lib/models/user_profile_data.dart
import 'package:flutter/foundation.dart'; // Tetap butuh ini untuk UniqueKey atau debugPrint

// Enum untuk Tujuan Diet, konsisten dengan onboarding
enum DietPurpose {
  loseWeight,
  gainWeight,
  maintainHealth,
  other, // Menambahkan 'other' untuk fleksibilitas
}

// Helper untuk mendapatkan string dari enum (Enum Flutter -> String UI Flutter)
String getDietPurposeString(DietPurpose purpose) {
  switch (purpose) {
    case DietPurpose.loseWeight:
      return 'Menurunkan Berat Badan';
    case DietPurpose.gainWeight:
      return 'Menaikkan Berat Badan';
    case DietPurpose.maintainHealth:
      return 'Menjaga Kesehatan';
    case DietPurpose.other:
      return 'Lainnya';
  }
}

// Helper untuk mendapatkan enum dari string (dari Backend, misal "lose_weight")
DietPurpose getDietPurposeEnum(String? purposeString) {
  // Terima nullable string
  if (purposeString == null) {
    return DietPurpose.other; // Default jika null
  }
  switch (purposeString) {
    case 'lose_weight':
      return DietPurpose.loseWeight;
    case 'gain_weight':
      return DietPurpose.gainWeight;
    case 'stay_healthy':
      return DietPurpose.maintainHealth;
    default:
      return DietPurpose.other; // Default jika tidak cocok dengan string BE
  }
}

// BARU: Helper untuk mendapatkan enum dari string (dari Frontend UI, misal "Menurunkan Berat Badan")
// Ini akan digunakan saat menyimpan data dari UI Flutter ke objek UserProfile
DietPurpose getDietPurposeEnumFromFlutterString(String? flutterPurposeString) {
  if (flutterPurposeString == null) {
    return DietPurpose.other; // Default jika null
  }
  switch (flutterPurposeString) {
    case 'Menurunkan Berat Badan':
      return DietPurpose.loseWeight;
    case 'Menaikkan Berat Badan':
      return DietPurpose.gainWeight;
    case 'Menjaga Kesehatan':
      return DietPurpose.maintainHealth;
    case 'Lainnya':
      return DietPurpose.other;
    default:
      return DietPurpose.other; // Fallback jika string tidak dikenal
  }
}

class UserProfile {
  final String id;
  String name;
  String email;
  String gender;
  DateTime birthDate;
  double heightCm;
  double currentWeightKg; // Tambahkan berat badan saat ini
  double targetWeightKg;
  DietPurpose purpose; // Enum Flutter

  UserProfile({
    String? id,
    required this.name,
    required this.email,
    required this.gender,
    required this.birthDate,
    required this.heightCm,
    required this.currentWeightKg,
    required this.targetWeightKg,
    required this.purpose,
  }) : id = id ?? UniqueKey().toString();

  // BARU: Factory constructor untuk membuat instance UserProfile kosong/default
  factory UserProfile.empty() {
    return UserProfile(
      id: UniqueKey().toString(), // ID unik untuk instance kosong
      name: 'Guest',
      email: 'guest@example.com',
      gender: 'Laki-laki', // Default
      birthDate: DateTime(2000, 1, 1), // Default
      heightCm: 0.0,
      currentWeightKg: 0.0,
      targetWeightKg: 0.0,
      purpose: DietPurpose.other, // Default
    );
  }

  // Metode copyWith untuk membuat instance UserProfile baru dengan beberapa properti yang diubah
  UserProfile copyWith({
    String? id,
    String? name,
    String? email,
    String? gender,
    DateTime? birthDate,
    double? heightCm,
    double? currentWeightKg,
    double? targetWeightKg,
    DietPurpose? purpose,
  }) {
    return UserProfile(
      id: id ?? this.id,
      name: name ?? this.name,
      email: email ?? this.email,
      gender: gender ?? this.gender,
      birthDate: birthDate ?? this.birthDate,
      heightCm: heightCm ?? this.heightCm,
      currentWeightKg: currentWeightKg ?? this.currentWeightKg,
      targetWeightKg: targetWeightKg ?? this.targetWeightKg,
      purpose: purpose ?? this.purpose,
    );
  }

  // Metode untuk konversi ke Map (untuk pengiriman ke BE)
  // Perhatikan: ini mengirimkan nama kolom Flutter dan nilai string/enum Flutter
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'email': email,
      'gender':
          gender, // Pastikan ini 'Laki-laki'/'Perempuan' atau diubah ke 'male'/'female' jika BE butuh itu
      'birthDate': birthDate.toIso8601String(),
      'heightCm': heightCm,
      'currentWeightKg': currentWeightKg,
      'targetWeightKg': targetWeightKg,
      'purpose': getDietPurposeString(
        purpose,
      ), // Menggunakan helper untuk konversi ke string UI
    };
  }

  // Metode untuk konversi dari Map (untuk loading dari BE)
  factory UserProfile.fromJson(Map<String, dynamic> json) {
    String flutterGender;
    if (json['gender'] == 'male') {
      flutterGender = 'Laki-laki';
    } else if (json['gender'] == 'female') {
      flutterGender = 'Perempuan';
    } else {
      flutterGender = 'Lainnya'; // Fallback atau default
    }

    DietPurpose flutterPurpose = getDietPurposeEnum(json['goal'] as String?);

    return UserProfile(
      id: json['id']?.toString() ?? UniqueKey().toString(),
      name: json['name'] as String,
      email: json['email'] as String,
      gender: flutterGender,
      birthDate:
          json['birth_date'] != null
              ? DateTime.parse(json['birth_date'] as String)
              : DateTime(2000, 1, 1),
      heightCm: (json['height'] as num?)?.toDouble() ?? 0.0,
      currentWeightKg: (json['weight'] as num?)?.toDouble() ?? 0.0,
      targetWeightKg: (json['target_weight'] as num?)?.toDouble() ?? 0.0,
      purpose: flutterPurpose,
    );
  }
}

final ValueNotifier<UserProfile> currentUserProfile =
    ValueNotifier<UserProfile>(
      UserProfile(
        name: 'Abdah Syakiroh',
        email: 'abdah.syakiroh@example.com',
        gender: 'Perempuan',
        birthDate: DateTime(1999, 2, 20),
        heightCm: 175.0,
        currentWeightKg: 65.0,
        targetWeightKg: 60.0,
        purpose: DietPurpose.loseWeight,
      ),
    );

void updateCurrentUserProfile(UserProfile updatedProfile) {
  currentUserProfile.value = updatedProfile;
  debugPrint('User Profile Updated: ${updatedProfile.toJson()}');
}
