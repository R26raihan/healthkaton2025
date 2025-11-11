import 'package:flutter/material.dart';

/// Theme configuration untuk aplikasi
/// Menggunakan warna gradasi hijau-ungu sesuai design Healthathon
class AppTheme {
  // Colors berdasarkan design Healthathon 2025
  static const Color primaryGreen = Color(0xFF4CAF50); // Hijau cerah (#4CAF50)
  static const Color primaryPurple = Color(0xFF673AB7); // Ungu tua (#673AB7)
  static const Color buttonGreen = Color(0xFF28A745); // Hijau solid untuk tombol (#28A745)
  static const Color accentYellow = Color(0xFFFFC107); // Kuning aksen (#FFC107)
  
  // Standard colors
  static const Color primaryColor = primaryGreen;
  static const Color secondaryColor = primaryPurple;
  static const Color errorColor = Color(0xFFD32F2F);
  static const Color successColor = buttonGreen;
  static const Color backgroundColor = Color(0xFFF5F5F5);
  static const Color textWhite = Colors.white;
  
  static ThemeData get lightTheme {
    return ThemeData(
      useMaterial3: true,
      colorScheme: ColorScheme.fromSeed(
        seedColor: primaryGreen,
        primary: primaryGreen,
        secondary: primaryPurple,
        error: errorColor,
      ),
      scaffoldBackgroundColor: backgroundColor,
      appBarTheme: const AppBarTheme(
        centerTitle: true,
        elevation: 0,
        backgroundColor: Colors.white,
        foregroundColor: Colors.black87,
      ),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: buttonGreen,
          foregroundColor: textWhite,
          padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 16),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(8),
          ),
        ),
      ),
      inputDecorationTheme: InputDecorationTheme(
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
        ),
        filled: true,
        fillColor: Colors.white,
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
      ),
    );
  }
  
  /// Gradient colors untuk background (hijau ke ungu)
  static const List<Color> gradientColors = [
    primaryGreen,  // Kiri: Hijau cerah
    primaryPurple, // Kanan: Ungu tua
  ];
  
  /// Gradient untuk latar belakang
  static LinearGradient get backgroundGradient {
    return LinearGradient(
      begin: Alignment.topLeft,
      end: Alignment.bottomRight,
      colors: gradientColors,
    );
  }
  
  /// Gradient horizontal (kiri ke kanan)
  static LinearGradient get horizontalGradient {
    return LinearGradient(
      begin: Alignment.centerLeft,
      end: Alignment.centerRight,
      colors: gradientColors,
    );
  }
}
