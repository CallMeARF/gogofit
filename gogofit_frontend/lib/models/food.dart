// lib/models/food.dart

class Food {
  final int id;
  final String name;
  final double calories;
  final double protein;
  final double carbohydrates;
  final double fat;
  final double saturatedFat;
  final double sugar;
  final String? imageUrl; // URL gambar bisa jadi null

  const Food({
    required this.id,
    required this.name,
    required this.calories,
    required this.protein,
    required this.carbohydrates,
    required this.fat,
    required this.saturatedFat,
    required this.sugar,
    this.imageUrl,
  });

  /// Factory constructor untuk membuat instance Food dari JSON map
  /// yang diterima dari API Laravel.
  factory Food.fromJson(Map<String, dynamic> json) {
    return Food(
      id: json['id'],
      name: json['name'],
      // Menggunakan toDouble() untuk memastikan tipe data konsisten
      calories: (json['calories'] as num).toDouble(),
      protein: (json['protein'] as num).toDouble(),
      carbohydrates: (json['carbohydrates'] as num).toDouble(),
      fat: (json['fat'] as num).toDouble(),
      saturatedFat: (json['saturated_fat'] as num).toDouble(),
      sugar: (json['sugar'] as num).toDouble(),
      imageUrl: json['image'],
    );
  }

  /// Method untuk mengubah instance Food kembali menjadi JSON map.
  /// Berguna jika Anda perlu mengirim objek ini kembali ke API (misal: untuk add/update).
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'calories': calories,
      'protein': protein,
      'carbohydrates': carbohydrates,
      'fat': fat,
      'saturated_fat': saturatedFat,
      'sugar': sugar,
      'image': imageUrl,
    };
  }
}
