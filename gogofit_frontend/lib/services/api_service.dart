// lib/services/api_service.dart
import 'dart:convert';
import 'package:flutter/material.dart'; // Untuk GlobalKey dan Navigator
import 'package:http/http.dart' as http;

// Import model dan exception
import '../models/user_profile_data.dart';
import '../models/meal_data.dart';
import '../exceptions/unauthorized_exception.dart';
import './auth_token_manager.dart'; // <-- BARU: Impor AuthTokenManager yang sudah dipisah
import '../screens/auth/login_screen.dart'; // <-- Import LoginScreen untuk navigasi

// URL dasar untuk API Laravel Anda
const String apiBaseUrl =
    'http://10.0.2.2:8000/api'; // Contoh untuk emulator Android

class ApiService {
  // PENTING: Gunakan GlobalKey untuk NavigatorState
  // Ini memungkinkan ApiService untuk melakukan navigasi saat terjadi 401
  // tanpa harus memiliki BuildContext di setiap metode API call.
  static final GlobalKey<NavigatorState> navigatorKey =
      GlobalKey<NavigatorState>();

  // Metode internal untuk mengirim semua jenis permintaan HTTP
  // Ini akan menangani penambahan token dan penanganan 401 secara global
  Future<http.Response> _sendRequest(
    String method,
    String endpoint, {
    Map<String, dynamic>? body,
    bool requireAuth = true, // Defaultnya memerlukan autentikasi
  }) async {
    final uri = Uri.parse('$apiBaseUrl/$endpoint');

    // Ambil token hanya jika request memerlukan autentikasi
    String? token;
    if (requireAuth) {
      token = await AuthTokenManager.getAuthToken();
      if (token == null) {
        // Jika token null padahal requireAuth true, langsung throw UnauthorizedException
        debugPrint(
          'Error: Token autentikasi tidak ditemukan untuk endpoint yang memerlukan otentikasi: $endpoint',
        );
        AuthTokenManager.clearAuthToken(); // Pastikan juga dihapus dari SharedPreferences
        if (ApiService.navigatorKey.currentState?.mounted == true) {
          // Pastikan context aktif
          ApiService.navigatorKey.currentState!.pushAndRemoveUntil(
            MaterialPageRoute(builder: (context) => const LoginScreen()),
            (Route<dynamic> route) => false, // Hapus semua route sebelumnya
          );
        }
        throw UnauthorizedException(
          'Token tidak ditemukan. Silakan login kembali.',
        );
      }
    }

    final headers = <String, String>{
      'Content-Type': 'application/json',
      'Accept': 'application/json',
    };

    if (token != null) {
      headers['Authorization'] = 'Bearer $token';
    }

    http.Response response;
    try {
      debugPrint(
        '$method Request to: $uri ${body != null ? 'with body: ${jsonEncode(body)}' : ''} with headers: $headers',
      );
      switch (method.toUpperCase()) {
        case 'GET':
          response = await http.get(uri, headers: headers);
          break;
        case 'POST':
          response = await http.post(
            uri,
            headers: headers,
            body: jsonEncode(body),
          );
          break;
        case 'PUT':
          response = await http.put(
            uri,
            headers: headers,
            body: jsonEncode(body),
          );
          break;
        case 'DELETE':
          response = await http.delete(uri, headers: headers);
          break;
        default:
          throw Exception('Unsupported HTTP method: $method');
      }
    } on http.ClientException catch (e) {
      // Menangani error jaringan (misal: tidak ada internet, server tidak dapat dijangkau)
      debugPrint('Network error during $method $endpoint: $e');
      throw Exception(
        'Network error: Gagal terhubung ke server. Periksa koneksi internet Anda.',
      );
    } catch (e) {
      // Menangani error lainnya yang tidak terduga sebelum respons diterima
      debugPrint('Unhandled error during $method $endpoint: $e');
      rethrow;
    }

    debugPrint(
      '$method Response from $endpoint: ${response.statusCode} | Body: ${response.body}',
    );

    // Penanganan 401 Unauthorized secara global untuk semua request yang memerlukan auth
    if (response.statusCode == 401 && requireAuth) {
      debugPrint(
        'Unauthorized: Token might be invalid or expired. Clearing token and redirecting to login.',
      );
      await AuthTokenManager.clearAuthToken(); // Hapus token yang tidak valid

      // Melakukan navigasi jika navigatorKey sudah terpasang dan context aktif
      if (ApiService.navigatorKey.currentState?.mounted == true) {
        ApiService.navigatorKey.currentState!.pushAndRemoveUntil(
          MaterialPageRoute(builder: (context) => const LoginScreen()),
          (Route<dynamic> route) => false, // Hapus semua route sebelumnya
        );
      } else {
        debugPrint(
          'Warning: navigatorKey is not attached or context is not mounted. Cannot redirect to login automatically.',
        );
      }
      throw UnauthorizedException(); // Lempar exception khusus 401
    }

    // Untuk status code error lainnya (400, 403, 404, 500, dll.)
    if (response.statusCode < 200 || response.statusCode >= 300) {
      final errorBody = jsonDecode(response.body);
      throw Exception(
        'API error: ${response.statusCode} - ${errorBody['message'] ?? 'Unknown error'}',
      );
    }

    return response;
  }

  // Metode publik yang memanggil _sendRequest
  // Default: requireAuth = true
  Future<http.Response> get(String endpoint) async =>
      _sendRequest('GET', endpoint);
  Future<http.Response> post(
    String endpoint,
    Map<String, dynamic> body, {
    bool requireAuth = true,
  }) async =>
      _sendRequest('POST', endpoint, body: body, requireAuth: requireAuth);
  Future<http.Response> put(String endpoint, Map<String, dynamic> body) async =>
      _sendRequest('PUT', endpoint, body: body);
  Future<http.Response> delete(String endpoint) async =>
      _sendRequest('DELETE', endpoint);

  // Login pengguna (endpoint ini TIDAK memerlukan token, jadi set requireAuth: false)
  Future<Map<String, dynamic>> login(
    String email,
    String password, {
    bool rememberMe = false,
  }) async {
    try {
      final response = await post('auth/login', {
        'email': email,
        'password': password,
      }, requireAuth: false);
      final responseBody = jsonDecode(response.body);

      if (response.statusCode == 200) {
        final token = responseBody['token'];
        if (token != null) {
          // PERBAIKAN UNTUK REMEMBER ME: Teruskan parameter rememberMe
          await AuthTokenManager.setAuthToken(token, rememberMe: rememberMe);
        }
        return {
          'success': true,
          'message': responseBody['message'],
          'user': responseBody['user'],
          'token':
              token, // Penting: kembalikan token juga agar LoginScreen bisa menggunakannya
        };
      } else {
        // Ini akan menangani error selain 401 (karena 401 sudah ditangani di _sendRequest)
        return {
          'success': false,
          'message': responseBody['message'] ?? 'Login failed.',
        };
      }
    } on UnauthorizedException catch (e) {
      // Sangat jarang terjadi di login jika requireAuth false, tapi untuk jaga-jaga
      debugPrint('UnauthorizedException caught during login: $e');
      return {'success': false, 'message': e.message};
    } catch (e) {
      debugPrint('Error during login: $e');
      return {
        'success': false,
        'message':
            e.toString().contains('API error:')
                ? e.toString().split('API error:').last.trim()
                : 'Terjadi kesalahan saat login.',
      };
    }
  }

  // Register pengguna (endpoint ini TIDAK memerlukan token)
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
    // BARU: Tambahkan parameter activityLevel
    String? activityLevel,
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
      // BARU: Tambahkan activity_level ke body request
      'activity_level': activityLevel,
    };

    body.removeWhere((key, value) => value == null);

    try {
      final response = await post(
        'auth/register',
        body,
        requireAuth: false,
      ); // Register tidak memerlukan token
      final responseBody = jsonDecode(response.body);

      if (response.statusCode == 201) {
        final token = responseBody['token'];
        if (token != null) {
          // Asumsi register selalu ingin rememberMe true secara default
          await AuthTokenManager.setAuthToken(
            token,
            rememberMe: true, // Asumsi ini selalu true setelah register
          );
        }
        return {
          'success': true,
          'message': responseBody['message'],
          'user': responseBody['user'],
          'token': token, // Kembalikan token juga
        };
      } else {
        return {
          'success': false,
          'message': responseBody['message'] ?? 'Registration failed.',
        };
      }
    } on UnauthorizedException catch (e) {
      debugPrint('UnauthorizedException caught during register: $e');
      return {'success': false, 'message': e.message};
    } catch (e) {
      debugPrint('Error during register: $e');
      return {
        'success': false,
        'message':
            e.toString().contains('API error:')
                ? e.toString().split('API error:').last.trim()
                : 'Terjadi kesalahan saat pendaftaran.',
      };
    }
  }

  // Mendapatkan profil pengguna
  Future<UserProfile?> getUserProfile() async {
    try {
      final response = await get(
        'user/profile',
      ); // _sendRequest akan throw UnauthorizedException jika 401

      final responseBody = jsonDecode(response.body);
      return UserProfile.fromJson(responseBody);
    } on UnauthorizedException {
      // Ini berarti ApiService sudah melakukan clear token dan redirect.
      return null;
    } catch (e) {
      debugPrint('Error fetching user profile: $e');
      // Anda bisa melemparkan exception ini lagi atau mengembalikan null/default
      // Tergantung bagaimana Anda ingin UI menanganinya (misalnya, menampilkan pesan error)
      rethrow;
    }
  }

  // Memperbarui profil pengguna
  Future<Map<String, dynamic>> updateProfile(UserProfile profile) async {
    // Perbaikan: Mapping gender dan purpose ke string BE di sini
    String? beGender;
    if (profile.gender == 'Laki-laki') {
      beGender = 'male';
    } else if (profile.gender == 'Perempuan') {
      beGender = 'female';
    }

    String? beGoal = _mapPurposeEnumToString(profile.purpose);
    String? beActivityLevel = getActivityLevelBackendString(
      profile.activityLevel,
    ); // BARU: Ambil activity level backend string

    final Map<String, dynamic> body = {
      'name': profile.name,
      'email': profile.email,
      'gender': beGender, // Gunakan gender yang sudah dipetakan
      'birth_date': profile.birthDate.toIso8601String().split('T')[0],
      'height': profile.heightCm,
      'weight': profile.currentWeightKg,
      'target_weight': profile.targetWeightKg,
      'goal': beGoal, // Gunakan goal yang sudah dipetakan
      'activity_level':
          beActivityLevel, // BARU: Tambahkan activity level ke body update
    };

    body.removeWhere((key, value) => value == null);

    try {
      // PERBAIKAN UNTUK METHOD PUT/POST: Ganti 'put' menjadi 'post'
      final response = await post('update-profile', body);
      final responseBody = jsonDecode(response.body);

      return {
        'success': true,
        'message': responseBody['message'],
        'user': responseBody['user'],
      };
    } on UnauthorizedException {
      // Sudah di-handle di _sendRequest (redirect), cukup kembalikan data error lokal
      return {
        'success': false,
        'message': 'Autentikasi gagal. Silakan login kembali.',
        'statusCode': 401,
      };
    } catch (e) {
      debugPrint('Error updating profile: $e');
      return {
        'success': false,
        'message':
            'Terjadi kesalahan saat memperbarui profil: ${e.toString().contains('API error:') ? e.toString().split('API error:').last.trim() : 'Unknown error'}',
      };
    }
  }

  // --- API untuk Logout ---
  Future<Map<String, dynamic>> logout() async {
    try {
      final response = await post(
        'auth/logout',
        {},
      ); // Pastikan ini juga menggunakan POST
      final responseBody = jsonDecode(response.body);

      if (response.statusCode == 200) {
        await AuthTokenManager.clearAuthToken(); // Clear token setelah berhasil logout
        return {'success': true, 'message': responseBody['message']};
      } else {
        // Jika status code bukan 200, atau ada masalah lain, anggap logout gagal
        // dan tetap coba clear token dan arahkan ke login sebagai langkah pengamanan.
        debugPrint(
          'Logout API call failed with status code ${response.statusCode}: ${response.body}',
        );
        await AuthTokenManager.clearAuthToken(); // Clear token meskipun API gagal
        if (ApiService.navigatorKey.currentState?.mounted == true) {
          ApiService.navigatorKey.currentState!.pushAndRemoveUntil(
            MaterialPageRoute(builder: (context) => const LoginScreen()),
            (Route<dynamic> route) => false,
          );
        }
        return {
          'success': false,
          'message': responseBody['message'] ?? 'Logout failed.',
        };
      }
    } on UnauthorizedException {
      // Jika sudah unauthorized, _sendRequest sudah menghapus token dan melakukan redirect.
      debugPrint(
        'UnauthorizedException caught during logout. Redirect already handled.',
      );
      return {
        'success': false,
        'message': 'Anda sudah logout atau sesi tidak valid.',
        'statusCode': 401,
      };
    } catch (e) {
      debugPrint('Error during logout: $e');
      await AuthTokenManager.clearAuthToken(); // Safety clear token
      if (ApiService.navigatorKey.currentState?.mounted == true) {
        ApiService.navigatorKey.currentState!.pushAndRemoveUntil(
          MaterialPageRoute(builder: (context) => const LoginScreen()),
          (Route<dynamic> route) => false,
        );
      }
      return {
        'success': false,
        'message':
            'Terjadi kesalahan saat logout: ${e.toString().contains('API error:') ? e.toString().split('API error:').last.trim() : 'Unknown error'}',
      };
    }
  }

  // API untuk mengubah password pengguna
  Future<Map<String, dynamic>> changePassword({
    required String oldPassword,
    required String newPassword,
    required String newPasswordConfirmation,
  }) async {
    final body = {
      'old_password': oldPassword,
      'new_password': newPassword,
      'new_password_confirmation': newPasswordConfirmation,
    };

    try {
      final response = await post('auth/change-password', body);
      final responseBody = jsonDecode(response.body);

      return {
        'success': true,
        'message': responseBody['message'] ?? 'Password berhasil diubah.',
      };
    } on UnauthorizedException {
      return {
        'success': false,
        'message': 'Autentikasi gagal. Silakan login kembali.',
        'statusCode': 401,
      };
    } catch (e) {
      debugPrint('Error changing password: $e');
      return {
        'success': false,
        'message':
            'Terjadi kesalahan saat mengubah password: ${e.toString().contains('API error:') ? e.toString().split('API error:').last.trim() : 'Unknown error'}',
      };
    }
  }

  // Method untuk forgot password (mengirim email reset link) (endpoint ini TIDAK memerlukan token)
  Future<Map<String, dynamic>> forgotPassword(String email) async {
    try {
      final response = await post('auth/forgot-password', {
        'email': email,
      }, requireAuth: false);
      final responseBody = jsonDecode(response.body);

      return {
        'success': true,
        'message':
            responseBody['message'] ??
            'Tautan reset telah dikirim ke email Anda.',
      };
    } on UnauthorizedException catch (e) {
      // Ini seharusnya tidak terjadi jika requireAuth false, tapi untuk jaga-jaga
      debugPrint('UnauthorizedException caught during forgot password: $e');
      return {'success': false, 'message': e.message};
    } catch (e) {
      debugPrint('Error during forgot password request: $e');
      return {
        'success': false,
        'message':
            e.toString().contains('API error:')
                ? e.toString().split('API error:').last.trim()
                : 'Terjadi kesalahan saat meminta reset password.',
      };
    }
  }

  // --- API untuk Food Logs ---
  Future<List<MealEntry>> getFoodLogs({DateTime? date}) async {
    String endpoint = 'food-logs';
    if (date != null) {
      endpoint += '?date=${date.toIso8601String().split('T')[0]}';
    }

    try {
      final response = await get(
        endpoint,
      ); // Akan throw UnauthorizedException jika 401

      List<dynamic> data = jsonDecode(response.body)['data'];
      return data.map((json) => MealEntry.fromJson(json)).toList();
    } on UnauthorizedException {
      // Ini berarti ApiService sudah melakukan clear token dan redirect.
      return [];
    } catch (e) {
      debugPrint('Error fetching food logs: $e');
      rethrow;
    }
  }

  Future<Map<String, dynamic>> addFoodLog(MealEntry meal) async {
    try {
      final response = await post('food-logs', meal.toJson());
      final responseBody = jsonDecode(response.body);

      return {
        'success': true,
        'message': responseBody['message'],
        'log': responseBody['data'],
      };
    } on UnauthorizedException {
      return {
        'success': false,
        'message': 'Autentikasi gagal. Silakan login kembali.',
        'statusCode': 401,
      };
    } catch (e) {
      debugPrint('Error adding food log: $e');
      return {
        'success': false,
        'message':
            'Terjadi kesalahan saat menambah log makanan: ${e.toString().contains('API error:') ? e.toString().split('API error:').last.trim() : 'Unknown error'}',
      };
    }
  }

  Future<Map<String, dynamic>> updateFoodLog(MealEntry meal) async {
    if (meal.id == null) {
      debugPrint('Error: Attempted to update food log with null ID.');
      return {
        'success': false,
        'message':
            'Tidak dapat memperbarui santapan: ID tidak ditemukan (ID null).',
      };
    }
    try {
      final response = await put('food-logs/${meal.id}', meal.toJson());
      final responseBody = jsonDecode(response.body);

      return {
        'success': true,
        'message': responseBody['message'],
        'log': responseBody['data'],
      };
    } on UnauthorizedException {
      return {
        'success': false,
        'message': 'Autentikasi gagal. Silakan login kembali.',
        'statusCode': 401,
      };
    } catch (e) {
      debugPrint('Error updating food log: $e');
      if (e.toString().contains('404')) {
        return {
          'success': false,
          'message':
              'Santapan tidak ditemukan di server. Mungkin sudah dihapus.',
          'statusCode': 404,
        };
      }
      return {
        'success': false,
        'message':
            'Terjadi kesalahan saat memperbarui log makanan: ${e.toString().contains('API error:') ? e.toString().split('API error:').last.trim() : 'Unknown error'}',
      };
    }
  }

  Future<Map<String, dynamic>> deleteFoodLog(String id) async {
    try {
      final response = await delete('food-logs/$id');
      final responseBody = jsonDecode(response.body);

      return {'success': true, 'message': responseBody['message']};
    } on UnauthorizedException {
      return {
        'success': false,
        'message': 'Autentikasi gagal. Silakan login kembali.',
        'statusCode': 401,
      };
    } catch (e) {
      debugPrint('Error deleting food log: $e');
      if (e.toString().contains('404')) {
        return {
          'success': false,
          'message':
              'Santapan tidak ditemukan di server. Mungkin sudah dihapus.',
          'statusCode': 404,
        };
      }
      return {
        'success': false,
        'message':
            'Terjadi kesalahan saat menghapus log makanan: ${e.toString().contains('API error:') ? e.toString().split('API error:').last.trim() : 'Unknown error'}',
      };
    }
  }

  // Helper untuk memetakan DietPurpose enum (Flutter) ke string goal (BE)
  String? _mapPurposeEnumToString(DietPurpose purpose) {
    switch (purpose) {
      case DietPurpose.loseWeight:
        return 'lose_weight';
      case DietPurpose.gainWeight:
        return 'gain_weight';
      case DietPurpose.maintainHealth:
        return 'stay_healthy';
      // case DietPurpose.other: // DIHAPUS, JANGAN DITAMBAHKAN KEMBALI
      //   return null; // DIHAPUS
    }
  }
}
