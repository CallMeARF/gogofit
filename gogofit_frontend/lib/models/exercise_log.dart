// lib/models/exercise_log.dart

class ExerciseLog {
  final int id;
  final String activityName;
  final int durationMinutes;
  final int caloriesBurned;
  final DateTime exercisedAt;

  const ExerciseLog({
    required this.id,
    required this.activityName,
    required this.durationMinutes,
    required this.caloriesBurned,
    required this.exercisedAt,
  });

  /// Factory constructor untuk membuat instance ExerciseLog dari JSON map
  /// yang diterima dari API Laravel.
  factory ExerciseLog.fromJson(Map<String, dynamic> json) {
    return ExerciseLog(
      id: json['id'],
      activityName: json['activity_name'],
      durationMinutes: json['duration_minutes'],
      caloriesBurned: json['calories_burned'],
      // Mengonversi string tanggal dari API menjadi objek DateTime di Dart
      exercisedAt: DateTime.parse(json['exercised_at']),
    );
  }

  /// Method untuk mengubah instance ExerciseLog kembali menjadi JSON map.
  /// Berguna jika Anda perlu mengirim objek ini kembali ke API.
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'activity_name': activityName,
      'duration_minutes': durationMinutes,
      'calories_burned': caloriesBurned,
      'exercised_at': exercisedAt.toIso8601String(),
    };
  }
}
