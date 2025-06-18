// lib/services/api_service.dart
import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import '../models/user_profile_data.dart'; // Pastikan path benar
import '../models/meal_data.dart'; // Pastikan path benar

// URL dasar untuk API Laravel Anda
// PENTING: Ganti dengan IP lokal Anda atau URL server jika deploy
const String apiBaseUrl =
    'http://10.0.2.2:8000/api'; // Contoh untuk emulator Android

// Kelas untuk mengelola token autentikasi
class AuthTokenManager {
  static String? _authToken; // Token saat ini
  static const String _tokenKey = 'auth_token';

  static Future<void> setAuthToken(String token) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_tokenKey, token);
    _authToken = token;
    debugPrint('Auth token saved: $_authToken');
  }

  static Future<String?> getAuthToken() async {
    if (_authToken != null) {
      return _authToken;
    }
    final prefs = await SharedPreferences.getInstance();
    _authToken = prefs.getString(_tokenKey);
    debugPrint('Auth token retrieved: $_authToken');
    return _authToken;
  }

  static Future<void> clearAuthToken() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_tokenKey);
    _authToken = null;
    debugPrint('Auth token cleared.');
  }

  static Future<bool> hasAuthToken() async {
    return (await getAuthToken()) != null;
  }
}

// Kelas ApiService untuk membuat permintaan HTTP
class ApiService {
  Future<http.Response> get(String endpoint) async {
    final uri = Uri.parse('$apiBaseUrl/$endpoint');
    final token = await AuthTokenManager.getAuthToken();

    final headers = <String, String>{
      'Content-Type': 'application/json',
      'Accept': 'application/json',
    };

    if (token != null) {
      headers['Authorization'] = 'Bearer $token';
    }

    debugPrint('GET Request to: $uri with headers: $headers');
    final response = await http.get(uri, headers: headers);
    debugPrint(
      'GET Response from $endpoint: ${response.statusCode} | Body: ${response.body}',
    );
    return response;
  }

  Future<http.Response> post(String endpoint, Map<String, dynamic> body) async {
    final uri = Uri.parse('$apiBaseUrl/$endpoint');
    final token = await AuthTokenManager.getAuthToken();

    final headers = <String, String>{
      'Content-Type': 'application/json',
      'Accept': 'application/json',
    };

    if (token != null) {
      headers['Authorization'] = 'Bearer $token';
    }

    debugPrint('POST Request to: $uri with body: ${jsonEncode(body)}');
    final response = await http.post(
      uri,
      headers: headers,
      body: jsonEncode(body),
    );
    debugPrint(
      'POST Response from $endpoint: ${response.statusCode} | Body: ${response.body}',
    );
    return response;
  }

  Future<http.Response> put(String endpoint, Map<String, dynamic> body) async {
    final uri = Uri.parse('$apiBaseUrl/$endpoint');
    final token = await AuthTokenManager.getAuthToken();

    final headers = <String, String>{
      'Content-Type': 'application/json',
      'Accept': 'application/json',
    };

    if (token != null) {
      headers['Authorization'] = 'Bearer $token';
    }

    debugPrint('PUT Request to: $uri with body: ${jsonEncode(body)}');
    final response = await http.put(
      uri,
      headers: headers,
      body: jsonEncode(body),
    );
    debugPrint(
      'PUT Response from $endpoint: ${response.statusCode} | Body: ${response.body}',
    );
    return response;
  }

  Future<http.Response> delete(String endpoint) async {
    final uri = Uri.parse('$apiBaseUrl/$endpoint');
    final token = await AuthTokenManager.getAuthToken();

    final headers = <String, String>{
      'Content-Type': 'application/json',
      'Accept': 'application/json',
    };

    if (token != null) {
      headers['Authorization'] = 'Bearer $token';
    }

    debugPrint('DELETE Request to: $uri');
    final response = await http.delete(uri, headers: headers);
    debugPrint(
      'DELETE Response from $endpoint: ${response.statusCode} | Body: ${response.body}',
    );
    return response;
  }

  // Login pengguna
  Future<Map<String, dynamic>> login(String email, String password) async {
    final response = await post('auth/login', {
      'email': email,
      'password': password,
    });

    final responseBody = jsonDecode(response.body);

    if (response.statusCode == 200) {
      final token = responseBody['token'];
      if (token != null) {
        await AuthTokenManager.setAuthToken(token);
      }
      return {
        'success': true,
        'message': responseBody['message'],
        'user': responseBody['user'],
      };
    } else {
      return {
        'success': false,
        'message': responseBody['message'] ?? 'Login failed.',
      };
    }
  }

  // Register pengguna
  Future<Map<String, dynamic>> register({
    required String name,
    required String email,
    required String password,
    required String passwordConfirmation,
    String? gender,
    DateTime? birthDate,
    double? heightCm,
    double? currentWeightKg,
    double? targetWeightKg,
    String? purpose,
  }) async {
    final body = {
      'name': name,
      'email': email,
      'password': password,
      'password_confirmation': passwordConfirmation,
      'gender': gender,
      'birth_date': birthDate?.toIso8601String().split('T')[0],
      'height': heightCm,
      'weight': currentWeightKg,
      'target_weight': targetWeightKg,
      'goal': purpose,
    };

    body.removeWhere((key, value) => value == null);

    final response = await post('auth/register', body);
    final responseBody = jsonDecode(response.body);

    if (response.statusCode == 201) {
      final token = responseBody['token'];
      if (token != null) {
        await AuthTokenManager.setAuthToken(token);
      }
      return {
        'success': true,
        'message': responseBody['message'],
        'user': responseBody['user'],
      };
    } else {
      return {
        'success': false,
        'message': responseBody['message'] ?? 'Registration failed.',
      };
    }
  }

  // Mendapatkan profil pengguna
  Future<UserProfile?> getUserProfile() async {
    final response = await get('user/profile');

    if (response.statusCode == 200) {
      final responseBody = jsonDecode(response.body);
      return UserProfile.fromJson(responseBody);
    } else if (response.statusCode == 401) {
      debugPrint('Unauthorized: Token might be invalid or expired.');
      await AuthTokenManager.clearAuthToken();
      return null;
    } else {
      debugPrint(
        'Failed to load user profile: ${response.statusCode} ${response.body}',
      );
      return null;
    }
  }

  // Memperbarui profil pengguna
  Future<Map<String, dynamic>> updateProfile(UserProfile profile) async {
    final Map<String, dynamic> body = {
      'name': profile.name,
      'email': profile.email,
      // Map gender dari FE string ke BE string
      'gender':
          profile.gender == 'Laki-laki'
              ? 'male'
              : (profile.gender == 'Perempuan' ? 'female' : null),
      'birth_date': profile.birthDate.toIso8601String().split('T')[0],
      'height': profile.heightCm,
      'weight': profile.currentWeightKg,
      'target_weight': profile.targetWeightKg,
      // Map purpose dari FE enum ke BE string
      'goal': _mapPurposeEnumToString(profile.purpose), // Gunakan helper baru
    };

    body.removeWhere((key, value) => value == null);

    final response = await post('update-profile', body);

    final responseBody = jsonDecode(response.body);

    if (response.statusCode == 200) {
      return {
        'success': true,
        'message': responseBody['message'],
        'user': responseBody['user'],
      };
    } else {
      debugPrint(
        'Update profile failed: ${response.statusCode} ${response.body}',
      );
      return {
        'success': false,
        'message': responseBody['message'] ?? 'Update profile failed.',
      };
    }
  }

  // BARU: Helper untuk memetakan DietPurpose enum (Flutter) ke string goal (BE)
  String? _mapPurposeEnumToString(DietPurpose purpose) {
    switch (purpose) {
      case DietPurpose.loseWeight:
        return 'lose_weight';
      case DietPurpose.gainWeight:
        return 'gain_weight';
      case DietPurpose.maintainHealth:
        return 'stay_healthy';
      case DietPurpose.other:
        return null; // 'Lainnya' di FE, kirim null ke BE
    }
  }

  // --- API untuk Logout ---
  Future<Map<String, dynamic>> logout() async {
    final response = await post(
      'auth/logout',
      {},
    ); // Panggil endpoint logout BE
    final responseBody = jsonDecode(response.body);

    if (response.statusCode == 200) {
      await AuthTokenManager.clearAuthToken(); // Pastikan token dihapus
      return {'success': true, 'message': responseBody['message']};
    } else {
      debugPrint('Logout failed: ${response.statusCode} ${response.body}');
      return {
        'success': false,
        'message': responseBody['message'] ?? 'Logout failed.',
      };
    }
  }

  // --- API untuk Food Logs ---
  Future<Map<String, dynamic>> addFoodLog(MealEntry meal) async {
    final response = await post('food-logs', meal.toJson());
    final responseBody = jsonDecode(response.body);

    if (response.statusCode == 201) {
      return {
        'success': true,
        'message': responseBody['message'],
        'log': responseBody['data'],
      };
    } else {
      debugPrint(
        'Failed to add food log: ${response.statusCode} ${response.body}',
      );
      return {
        'success': false,
        'message': responseBody['message'] ?? 'Failed to add food log.',
      };
    }
  }

  Future<List<MealEntry>> getFoodLogs({DateTime? date}) async {
    String endpoint = 'food-logs';
    if (date != null) {
      endpoint += '?date=${date.toIso8601String().split('T')[0]}';
    }

    final response = await get(endpoint);

    if (response.statusCode == 200) {
      List<dynamic> data = jsonDecode(response.body)['data'];
      return data.map((json) => MealEntry.fromJson(json)).toList();
    } else {
      debugPrint(
        'Failed to get food logs: ${response.statusCode} ${response.body}',
      );
      return [];
    }
  }

  Future<Map<String, dynamic>> updateFoodLog(MealEntry meal) async {
    final response = await put('food-logs/${meal.id}', meal.toJson());
    final responseBody = jsonDecode(response.body);

    if (response.statusCode == 200) {
      return {
        'success': true,
        'message': responseBody['message'],
        'log': responseBody['data'],
      };
    } else {
      debugPrint(
        'Failed to update food log: ${response.statusCode} ${response.body}',
      );
      return {
        'success': false,
        'message': responseBody['message'] ?? 'Failed to update food log.',
      };
    }
  }

  Future<Map<String, dynamic>> deleteFoodLog(String id) async {
    final response = await delete('food-logs/$id');
    final responseBody = jsonDecode(response.body);

    if (response.statusCode == 200) {
      return {'success': true, 'message': responseBody['message']};
    } else {
      debugPrint(
        'Failed to delete food log: ${response.statusCode} ${response.body}',
      );
      return {
        'success': false,
        'message': responseBody['message'] ?? 'Failed to delete food log.',
      };
    }
  }
}
