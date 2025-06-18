// lib/models/meal_data.dart
import 'package:flutter/foundation.dart';

class MealEntry {
  final String id;
  final String name;
  final double calories;
  final double fat;
  final double saturatedFat;
  final double carbs;
  final double protein;
  final double sugar;
  final DateTime timestamp;
  final String mealType; // 'Sarapan', 'Makan Siang', dll.

  MealEntry({
    String? id,
    required this.name,
    required this.calories,
    required this.fat,
    this.saturatedFat = 0.0,
    required this.carbs,
    required this.protein,
    required this.sugar,
    required this.timestamp,
    required this.mealType,
  }) : id = id ?? DateTime.now().microsecondsSinceEpoch.toString();

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'calories': calories,
      'fat': fat,
      'saturated_fat': saturatedFat, // Nama kolom BE
      'carbohydrates': carbs, // Nama kolom BE
      'protein': protein,
      'sugar': sugar,
      'consumed_at': timestamp.toIso8601String(), // Nama kolom BE
      'meal_type': mealType, // Nama kolom BE
    };
  }

  // FIX: fromJson Factory Constructor yang benar
  factory MealEntry.fromJson(Map<String, dynamic> json) {
    return MealEntry(
      id:
          json['id']?.toString() ??
          UniqueKey().toString(), // Pastikan ID adalah String
      name: json['name'] as String,
      calories: (json['calories'] as num?)?.toDouble() ?? 0.0,
      fat: (json['fat'] as num?)?.toDouble() ?? 0.0,
      saturatedFat:
          (json['saturated_fat'] as num?)?.toDouble() ?? 0.0, // Nama kolom BE
      carbs:
          (json['carbohydrates'] as num?)?.toDouble() ?? 0.0, // Nama kolom BE
      protein: (json['protein'] as num?)?.toDouble() ?? 0.0,
      sugar: (json['sugar'] as num?)?.toDouble() ?? 0.0,
      timestamp:
          json['consumed_at'] != null
              ? DateTime.parse(json['consumed_at'] as String)
              : DateTime.now(), // Nama kolom BE
      mealType:
          (json['meal_type'] as String?) ??
          'Camilan', // Nama kolom BE, dengan default
    );
  }

  MealEntry copyWith({
    String? id,
    String? name,
    double? calories,
    double? fat,
    double? saturatedFat,
    double? carbs,
    double? protein,
    double? sugar,
    DateTime? timestamp,
    String? mealType,
  }) {
    return MealEntry(
      id: id ?? this.id,
      name: name ?? this.name,
      calories: calories ?? this.calories,
      fat: fat ?? this.fat,
      saturatedFat: saturatedFat ?? this.saturatedFat,
      carbs: carbs ?? this.carbs,
      protein: protein ?? this.protein,
      sugar: sugar ?? this.sugar,
      timestamp: timestamp ?? this.timestamp,
      mealType: mealType ?? this.mealType,
    );
  }
}

final ValueNotifier<List<MealEntry>> userMeals = ValueNotifier<List<MealEntry>>(
  [],
);

void deleteMealEntry(String id) {
  userMeals.value = userMeals.value.where((meal) => meal.id != id).toList();
}

void updateMealEntry(MealEntry updatedMeal) {
  userMeals.value =
      userMeals.value.map((meal) {
        return meal.id == updatedMeal.id ? updatedMeal : meal;
      }).toList();
}

double calculateTotalCalories() {
  final today = DateTime.now();
  final filteredMeals =
      userMeals.value
          .where(
            (meal) =>
                meal.timestamp.year == today.year &&
                meal.timestamp.month == today.month &&
                meal.timestamp.day == today.day,
          )
          .toList();
  final total = filteredMeals.fold(0.0, (sum, meal) => sum + meal.calories);
  debugPrint(
    'DEBUG Meal Data: Kalori Hari Ini (${today.day}/${today.month}/${today.year}): $total kkal',
  );
  return total;
}

double calculateTotalSugar() {
  final today = DateTime.now();
  final filteredMeals =
      userMeals.value
          .where(
            (meal) =>
                meal.timestamp.year == today.year &&
                meal.timestamp.month == today.month &&
                meal.timestamp.day == today.day,
          )
          .toList();
  final total = filteredMeals.fold(0.0, (sum, meal) => sum + meal.sugar);
  debugPrint(
    'DEBUG Meal Data: Gula Hari Ini (${today.day}/${today.month}/${today.year}): $total gram',
  );
  return total;
}
