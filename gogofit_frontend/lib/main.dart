import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:gogofit_frontend/screens/splash_screen.dart'; // Import SplashScreen
import 'package:gogofit_frontend/models/notification_data.dart'; // Import notification_data.dart
// Tidak perlu mengimpor notification_service di sini lagi

void main() {
  // Pastikan ini ada di awal sekali. Ini sangat krusial untuk inisialisasi plugin.
  WidgetsFlutterBinding.ensureInitialized(); // <<<--- PASTIKAN ADA DAN HANYA SATU DI SINI

  // Hanya panggil addDummyNotifications di sini untuk mengisi data notifikasi in-app
  addDummyNotifications();
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    const MaterialColor primaryMaterialColor =
        MaterialColor(0xFF015C91, <int, Color>{
          50: Color(0xFFE6EFF4),
          100: Color(0xFFD9E7EF),
          200: Color(0xFFB0CCDD),
          300: Color(0xFF015C91),
          400: Color(0xFF015383),
          500: Color(0xFF014A74),
          600: Color(0xFF01456D),
          700: Color(0xFF013757),
          800: Color(0xFF002841),
          900: Color(0xFF002033),
        });

    return MaterialApp(
      title: 'GoGoFit App',
      theme: ThemeData(
        fontFamily: 'Poppins',
        primaryColor: const Color(0xFF015C91),
        primarySwatch: primaryMaterialColor,
        appBarTheme: const AppBarTheme(
          backgroundColor: Color(0xFF015C91),
          foregroundColor: Colors.white,
        ),
        elevatedButtonTheme: ElevatedButtonThemeData(
          style: ElevatedButton.styleFrom(
            foregroundColor: Colors.white,
            backgroundColor: const Color(0xFF015C91),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(8),
            ),
            padding: const EdgeInsets.symmetric(vertical: 15),
            textStyle: const TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              fontFamily: 'Poppins',
            ),
          ),
        ),
        textButtonTheme: TextButtonThemeData(
          style: TextButton.styleFrom(
            foregroundColor: const Color(0xFF015C91),
            textStyle: const TextStyle(fontFamily: 'Poppins'),
          ),
        ),
        inputDecorationTheme: InputDecorationTheme(
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(8),
            borderSide: BorderSide(color: Colors.grey.shade400),
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(8),
            borderSide: const BorderSide(color: Color(0xFF015C91), width: 2),
          ),
          enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(8),
            borderSide: BorderSide(color: Colors.grey.shade300),
          ),
          contentPadding: const EdgeInsets.symmetric(
            vertical: 12,
            horizontal: 16,
          ),
          labelStyle: TextStyle(
            color: Colors.grey.shade600,
            fontFamily: 'Poppins',
          ),
          hintStyle: TextStyle(
            color: Colors.grey.shade400,
            fontFamily: 'Poppins',
          ),
          prefixIconColor: Colors.grey.shade500,
          suffixIconColor: Colors.grey.shade500,
        ),
        textTheme: const TextTheme(
          displayLarge: TextStyle(fontFamily: 'Poppins'),
          displayMedium: TextStyle(fontFamily: 'Poppins'),
          displaySmall: TextStyle(fontFamily: 'Poppins'),
          headlineLarge: TextStyle(fontFamily: 'Poppins'),
          headlineMedium: TextStyle(fontFamily: 'Poppins'),
          headlineSmall: TextStyle(fontFamily: 'Poppins'),
          titleLarge: TextStyle(fontFamily: 'Poppins'),
          titleMedium: TextStyle(fontFamily: 'Poppins'),
          titleSmall: TextStyle(fontFamily: 'Poppins'),
          bodyLarge: TextStyle(fontFamily: 'Poppins'),
          bodyMedium: TextStyle(fontFamily: 'Poppins'),
          bodySmall: TextStyle(fontFamily: 'Poppins'),
          labelLarge: TextStyle(fontFamily: 'Poppins'),
          labelMedium: TextStyle(fontFamily: 'Poppins'),
          labelSmall: TextStyle(fontFamily: 'Poppins'),
        ),
      ),
      localizationsDelegates: const [
        GlobalMaterialLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
      ],
      supportedLocales: const [Locale('en', ''), Locale('id', '')],
      locale: const Locale('id', ''),

      home: const SplashScreen(),
      debugShowCheckedModeBanner: false,
    );
  }
}
