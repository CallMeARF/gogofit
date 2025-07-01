// lib/models/user_profile_data.dart
import 'package:flutter/material.dart'; // PERBAIKAN: Tambahkan import ini untuk tipe data Color.

// Enum untuk Tujuan Diet
enum DietPurpose { loseWeight, gainWeight, maintainHealth }

// Helper untuk mendapatkan string dari enum (Enum Flutter -> String UI Flutter)
String getDietPurposeString(DietPurpose purpose) {
  switch (purpose) {
    case DietPurpose.loseWeight:
      return 'Menurunkan Berat Badan';
    case DietPurpose.gainWeight:
      return 'Menaikkan Berat Badan';
    case DietPurpose.maintainHealth:
      return 'Menjaga Kesehatan';
  }
}

// Helper untuk mendapatkan enum dari string (dari Backend)
DietPurpose getDietPurposeEnum(String? purposeString) {
  if (purposeString == null) {
    return DietPurpose.maintainHealth;
  }
  switch (purposeString) {
    case 'lose_weight':
      return DietPurpose.loseWeight;
    case 'gain_weight':
      return DietPurpose.gainWeight;
    case 'stay_healthy':
    case 'other':
      return DietPurpose.maintainHealth;
    default:
      return DietPurpose.maintainHealth;
  }
}

// Helper untuk mendapatkan enum dari string (dari Frontend UI)
DietPurpose getDietPurposeEnumFromFlutterString(String? flutterPurposeString) {
  if (flutterPurposeString == null) {
    return DietPurpose.maintainHealth;
  }
  switch (flutterPurposeString) {
    case 'Menurunkan Berat Badan':
      return DietPurpose.loseWeight;
    case 'Menaikkan Berat Badan':
      return DietPurpose.gainWeight;
    case 'Menjaga Kesehatan':
    case 'Lainnya':
      return DietPurpose.maintainHealth;
    default:
      return DietPurpose.maintainHealth;
  }
}

// Helper untuk mendapatkan string Backend dari enum DietPurpose
String getDietPurposeBackendString(DietPurpose purpose) {
  switch (purpose) {
    case DietPurpose.loseWeight:
      return 'lose_weight';
    case DietPurpose.gainWeight:
      return 'gain_weight';
    case DietPurpose.maintainHealth:
      return 'stay_healthy';
  }
}

// ================================================================
// Enum untuk Tingkat Aktivitas Fisik (Activity Level)
enum ActivityLevel {
  sedentary,
  lightlyActive,
  moderatelyActive,
  veryActive,
  superActive,
}

// Helper untuk mendapatkan string UI dari enum ActivityLevel
String getActivityLevelString(ActivityLevel level) {
  switch (level) {
    case ActivityLevel.sedentary:
      return 'Sangat Sedikit (tidak/sedikit olahraga)';
    case ActivityLevel.lightlyActive:
      return 'Ringan (olahraga 1-3 hari/minggu)';
    case ActivityLevel.moderatelyActive:
      return 'Sedang (olahraga 3-5 hari/minggu)';
    case ActivityLevel.veryActive:
      return 'Berat (olahraga 6-7 hari/minggu)';
    case ActivityLevel.superActive:
      return 'Sangat Berat (olahraga intens setiap hari/pekerjaan fisik)';
  }
}

// Helper untuk mendapatkan enum ActivityLevel dari string UI
ActivityLevel getActivityLevelEnumFromFlutterString(
  String? flutterActivityString,
) {
  if (flutterActivityString == null) {
    return ActivityLevel.sedentary;
  }
  switch (flutterActivityString) {
    case 'Sangat Sedikit (tidak/sedikit olahraga)':
      return ActivityLevel.sedentary;
    case 'Ringan (olahraga 1-3 hari/minggu)':
      return ActivityLevel.lightlyActive;
    case 'Sedang (olahraga 3-5 hari/minggu)':
      return ActivityLevel.moderatelyActive;
    case 'Berat (olahraga 6-7 hari/minggu)':
      return ActivityLevel.veryActive;
    case 'Sangat Berat (olahraga intens setiap hari/pekerjaan fisik)':
      return ActivityLevel.superActive;
    default:
      return ActivityLevel.sedentary;
  }
}

// Helper untuk mendapatkan enum ActivityLevel dari string Backend
ActivityLevel getActivityLevelEnumFromBackendString(
  String? backendActivityString,
) {
  if (backendActivityString == null) {
    return ActivityLevel.sedentary;
  }
  switch (backendActivityString) {
    case 'sedentary':
      return ActivityLevel.sedentary;
    case 'lightly_active':
      return ActivityLevel.lightlyActive;
    case 'moderately_active':
      return ActivityLevel.moderatelyActive;
    case 'very_active':
      return ActivityLevel.veryActive;
    case 'super_active':
      return ActivityLevel.superActive;
    default:
      return ActivityLevel.sedentary;
  }
}

// Helper untuk mendapatkan string Backend dari enum ActivityLevel
String getActivityLevelBackendString(ActivityLevel level) {
  switch (level) {
    case ActivityLevel.sedentary:
      return 'sedentary';
    case ActivityLevel.lightlyActive:
      return 'lightly_active';
    case ActivityLevel.moderatelyActive:
      return 'moderately_active';
    case ActivityLevel.veryActive:
      return 'very_active';
    case ActivityLevel.superActive:
      return 'super_active';
  }
}
// ================================================================

class UserProfile {
  final String id;
  String name;
  String email;
  String gender;
  DateTime birthDate;
  double heightCm;
  double currentWeightKg;
  double targetWeightKg;
  DietPurpose purpose;
  ActivityLevel activityLevel;

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
    this.activityLevel = ActivityLevel.sedentary,
  }) : id = id ?? UniqueKey().toString();

  factory UserProfile.initial() {
    return UserProfile(
      id: UniqueKey().toString(),
      name: '',
      email: '',
      gender: 'Laki-laki',
      birthDate: DateTime.now(),
      heightCm: 0.0,
      currentWeightKg: 0.0,
      targetWeightKg: 0.0,
      purpose: DietPurpose.maintainHealth,
      activityLevel: ActivityLevel.sedentary,
    );
  }

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
    ActivityLevel? activityLevel,
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
      activityLevel: activityLevel ?? this.activityLevel,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'email': email,
      'gender':
          gender == 'Laki-laki'
              ? 'male'
              : (gender == 'Perempuan' ? 'female' : 'other'),
      'birth_date': birthDate.toIso8601String().split('T')[0],
      'height': heightCm,
      'weight': currentWeightKg,
      'target_weight': targetWeightKg,
      'goal': getDietPurposeBackendString(purpose),
      'activity_level': getActivityLevelBackendString(activityLevel),
    };
  }

  factory UserProfile.fromJson(Map<String, dynamic> json) {
    String flutterGender;
    if (json['gender'] == 'male') {
      flutterGender = 'Laki-laki';
    } else if (json['gender'] == 'female') {
      flutterGender = 'Perempuan';
    } else {
      flutterGender = 'Lainnya';
    }

    DietPurpose flutterPurpose = getDietPurposeEnum(json['goal'] as String?);
    ActivityLevel fetchedActivityLevel = getActivityLevelEnumFromBackendString(
      json['activity_level'] as String?,
    );

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
      activityLevel: fetchedActivityLevel,
    );
  }

  int get age {
    final now = DateTime.now();
    int age = now.year - birthDate.year;
    if (now.month < birthDate.month ||
        (now.month == birthDate.month && now.day < birthDate.day)) {
      age--;
    }
    return age;
  }

  double get bmr {
    if (gender == 'Laki-laki') {
      return (10 * currentWeightKg) + (6.25 * heightCm) - (5 * age) + 5;
    } else if (gender == 'Perempuan') {
      return (10 * currentWeightKg) + (6.25 * heightCm) - (5 * age) - 161;
    }
    return 0.0;
  }

  double get tdee {
    double activityFactor;
    switch (activityLevel) {
      case ActivityLevel.sedentary:
        activityFactor = 1.2;
        break;
      case ActivityLevel.lightlyActive:
        activityFactor = 1.375;
        break;
      case ActivityLevel.moderatelyActive:
        activityFactor = 1.55;
        break;
      case ActivityLevel.veryActive:
        activityFactor = 1.725;
        break;
      case ActivityLevel.superActive:
        activityFactor = 1.9;
        break;
    }
    return bmr * activityFactor;
  }

  double get calculatedTargetCalories {
    switch (purpose) {
      case DietPurpose.loseWeight:
        return tdee - 500;
      case DietPurpose.gainWeight:
        return tdee + 500;
      case DietPurpose.maintainHealth:
        return tdee;
    }
  }

  double get calculatedTargetSugar {
    return (calculatedTargetCalories * 0.10) / 4;
  }

  // PERBAIKAN: Menambahkan getter untuk warna avatar.
  Color get avatarColor {
    final List<Color> colors = [
      Colors.blue.shade400,
      Colors.green.shade400,
      Colors.red.shade400,
      Colors.orange.shade400,
      Colors.purple.shade400,
      Colors.teal.shade400,
      Colors.indigo.shade400,
      Colors.brown.shade400,
    ];
    if (name.isEmpty) return Colors.grey.shade400;

    final int hash = name.codeUnitAt(0);
    return colors[hash % colors.length];
  }
}

final ValueNotifier<UserProfile> currentUserProfile =
    ValueNotifier<UserProfile>(UserProfile.initial());

void resetCurrentUserProfile() {
  currentUserProfile.value = UserProfile.initial();
  debugPrint('Global user profile has been reset.');
}

void updateCurrentUserProfile(UserProfile updatedProfile) {
  currentUserProfile.value = updatedProfile;
  debugPrint('User Profile Updated: ${updatedProfile.toJson()}');
}
