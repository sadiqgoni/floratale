import 'package:flutter/material.dart';

class FloraTaleTheme {
  static const Color primaryGreen = Color(0xFF2D5016); // Deep forest green
  static const Color secondaryGreen = Color(0xFF4A7C59); // Sage green
  static const Color accentGreen = Color(0xFF7CB518); // Vibrant leaf green

  static const Color earthyBrown = Color(0xFF8B4513); // Saddle brown
  static const Color lightBrown = Color(0xFFD2B48C); // Tan
  static const Color darkBrown = Color(0xFF654321); // Dark brown

  static const Color ochre = Color(0xFFCC7722); // Burnt orange/ochre
  static const Color lightOchre = Color(0xFFE6B800); // Golden yellow
  static const Color darkOchre = Color(0xFF8B4513); // Chocolate

  static const Color background = Color(0xFFF5F5DC); // Beige background
  static const Color surface = Color(0xFFFEFEFE); // Off-white surface
  static const Color textPrimary = Color(0xFF2F2F2F); // Dark gray text
  static const Color textSecondary = Color(0xFF6B6B6B); // Medium gray text

  static ThemeData get lightTheme {
    return ThemeData(
      useMaterial3: true,
      colorScheme: ColorScheme.fromSeed(
        seedColor: primaryGreen,
        brightness: Brightness.light,
        primary: primaryGreen,
        secondary: secondaryGreen,
        tertiary: accentGreen,
        surface: surface,
        onPrimary: Colors.white,
        onSecondary: Colors.white,
        onSurface: textPrimary,
      ),

      appBarTheme: AppBarTheme(
        backgroundColor: primaryGreen,
        foregroundColor: Colors.white,
        elevation: 2,
        shadowColor: earthyBrown.withOpacity(0.3),
      ),

      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: accentGreen,
          foregroundColor: Colors.white,
          elevation: 4,
          shadowColor: earthyBrown.withOpacity(0.3),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
        ),
      ),

      floatingActionButtonTheme: FloatingActionButtonThemeData(
        backgroundColor: accentGreen,
        foregroundColor: Colors.white,
        elevation: 8,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(20),
        ),
      ),

      bottomNavigationBarTheme: const BottomNavigationBarThemeData(
        backgroundColor: surface,
        selectedItemColor: primaryGreen,
        unselectedItemColor: textSecondary,
        elevation: 8,
        type: BottomNavigationBarType.fixed,
      ),

      cardTheme: CardTheme(
        color: surface,
        elevation: 4,
        shadowColor: earthyBrown.withOpacity(0.2),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
        ),
      ),

      textTheme: const TextTheme(
        displayLarge: TextStyle(
          fontSize: 32,
          fontWeight: FontWeight.bold,
          color: textPrimary,
          letterSpacing: -0.5,
        ),
        displayMedium: TextStyle(
          fontSize: 28,
          fontWeight: FontWeight.w600,
          color: textPrimary,
        ),
        displaySmall: TextStyle(
          fontSize: 24,
          fontWeight: FontWeight.w600,
          color: textPrimary,
        ),
        headlineMedium: TextStyle(
          fontSize: 20,
          fontWeight: FontWeight.w600,
          color: textPrimary,
        ),
        headlineSmall: TextStyle(
          fontSize: 18,
          fontWeight: FontWeight.w600,
          color: textPrimary,
        ),
        titleLarge: TextStyle(
          fontSize: 16,
          fontWeight: FontWeight.w500,
          color: textPrimary,
        ),
        bodyLarge: TextStyle(
          fontSize: 16,
          fontWeight: FontWeight.normal,
          color: textPrimary,
        ),
        bodyMedium: TextStyle(
          fontSize: 14,
          fontWeight: FontWeight.normal,
          color: textPrimary,
        ),
        bodySmall: TextStyle(
          fontSize: 12,
          fontWeight: FontWeight.normal,
          color: textSecondary,
        ),
      ),

      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: background,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: earthyBrown.withOpacity(0.3)),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: earthyBrown.withOpacity(0.3)),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: primaryGreen, width: 2),
        ),
        labelStyle: const TextStyle(color: textSecondary),
      ),

      iconTheme: const IconThemeData(
        color: textPrimary,
        size: 24,
      ),

      progressIndicatorTheme: ProgressIndicatorThemeData(
        color: accentGreen,
        linearTrackColor: lightBrown.withOpacity(0.3),
      ),

      scaffoldBackgroundColor: background,
    );
  }

  static ThemeData get darkTheme {
    return ThemeData.dark().copyWith(
      colorScheme: ColorScheme.fromSeed(
        seedColor: primaryGreen,
        brightness: Brightness.dark,
      ),
    );
  }
}
