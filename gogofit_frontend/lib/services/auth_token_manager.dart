// lib/services/auth_token_manager.dart
import 'package:flutter/material.dart'; // Hanya untuk debugPrint
import 'package:shared_preferences/shared_preferences.dart';

class AuthTokenManager {
  static String? _authToken;
  static const String _tokenKey = 'auth_token';

  // PERBAIKAN: Tambahkan parameter `rememberMe`
  static Future<void> setAuthToken(
    String token, {
    bool rememberMe = false,
  }) async {
    final prefs = await SharedPreferences.getInstance();
    if (rememberMe) {
      await prefs.setString(_tokenKey, token);
      debugPrint('Auth token saved persistently (Remember Me ON): $token');
    } else {
      // Jika rememberMe OFF, pastikan token dihapus dari penyimpanan persisten
      // Ini penting agar setelah full restart, token tidak ditemukan.
      await prefs.remove(_tokenKey);
      debugPrint('Auth token NOT saved persistently (Remember Me OFF).');
    }
    _authToken = token; // Selalu simpan di memori untuk sesi aplikasi saat ini
    debugPrint('Auth token stored in memory for current session: $_authToken');
  }

  static Future<String?> getAuthToken() async {
    // Prioritaskan token di memori untuk performa
    if (_authToken != null) {
      debugPrint('Auth token retrieved from memory: $_authToken');
      return _authToken;
    }
    // Jika tidak ada di memori, coba ambil dari penyimpanan persisten (SharedPreferences)
    final prefs = await SharedPreferences.getInstance();
    _authToken = prefs.getString(_tokenKey);
    debugPrint('Auth token retrieved from SharedPreferences: $_authToken');
    return _authToken;
  }

  static Future<void> clearAuthToken() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_tokenKey); // Hapus dari persistent storage
    _authToken = null; // Hapus dari memory
    debugPrint('Auth token cleared from memory and SharedPreferences.');
  }

  static Future<bool> hasAuthToken() async {
    // Memanggil getAuthToken akan mencoba mengambil dari memori, lalu SharedPreferences.
    // Ini sudah sesuai.
    return (await getAuthToken()) != null;
  }
}
