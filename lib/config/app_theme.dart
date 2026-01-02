import 'package:flutter/material.dart';

class AppTheme {
  // Snapp brand colors (Green theme)
  static const Color snappPrimary = Color(0xFF28AE5F); // سبز اصلی اسنپ
  static const Color snappSecondary = Color(0xFF1E8B4F); // سبز تیره‌تر
  static const Color snappAccent = Color(0xFF4BCF7A); // سبز روشن‌تر
  static const Color snappPrimaryLight = Color(0xFFE8F7F0); // سبز خیلی روشن
  static const Color snappDark = Color(0xFF1A1A1A);
  static const Color snappGray = Color(0xFF6B7280);
  static const Color snappLightGray = Color(0xFFF3F4F6);

  // Persian font family - Using system default until fonts are added
  static const String persianFont = 'Roboto';

  static ThemeData get lightTheme {
    return ThemeData(
      useMaterial3: true,
      fontFamily: persianFont,

      // Color scheme
      colorScheme: const ColorScheme.light(
        primary: snappPrimary,
        secondary: snappSecondary,
        tertiary: snappAccent,
        surface: Colors.white,
        onPrimary: Colors.white,
        onSecondary: Colors.white,
        onSurface: snappDark,
      ),

      // App bar theme
      appBarTheme: const AppBarTheme(
        backgroundColor: snappPrimary,
        foregroundColor: Colors.white,
        elevation: 0,
        centerTitle: true,
        titleTextStyle: TextStyle(
          fontFamily: persianFont,
          fontSize: 20,
          fontWeight: FontWeight.bold,
          color: Colors.white,
        ),
      ),

      // Elevated button theme
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: snappPrimary,
          foregroundColor: Colors.white,
          elevation: 2,
          shadowColor: snappPrimary.withValues(alpha: 0.3),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
          textStyle: const TextStyle(
            fontFamily: persianFont,
            fontSize: 16,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),

      // Text button theme
      textButtonTheme: TextButtonThemeData(
        style: TextButton.styleFrom(
          foregroundColor: snappPrimary,
          textStyle: const TextStyle(
            fontFamily: persianFont,
            fontSize: 14,
            fontWeight: FontWeight.w600,
          ),
        ),
      ),

      // Input decoration theme
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: Colors.white,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: BorderSide(color: snappGray.withValues(alpha: 0.3)),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: BorderSide(color: snappGray.withValues(alpha: 0.3)),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: const BorderSide(color: snappPrimary, width: 2),
        ),
        errorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: const BorderSide(color: Colors.red, width: 2),
        ),
        labelStyle: const TextStyle(fontFamily: persianFont, color: snappGray),
        hintStyle: const TextStyle(fontFamily: persianFont, color: snappGray),
      ),

      // Card theme
      cardTheme: CardThemeData(
        elevation: 2,
        shadowColor: snappGray.withValues(alpha: 0.1),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        color: Colors.white,
      ),

      // Text theme
      textTheme: const TextTheme(
        displayLarge: TextStyle(
          fontFamily: persianFont,
          fontSize: 32,
          fontWeight: FontWeight.bold,
          color: snappDark,
        ),
        displayMedium: TextStyle(
          fontFamily: persianFont,
          fontSize: 28,
          fontWeight: FontWeight.bold,
          color: snappDark,
        ),
        displaySmall: TextStyle(
          fontFamily: persianFont,
          fontSize: 24,
          fontWeight: FontWeight.bold,
          color: snappDark,
        ),
        headlineLarge: TextStyle(
          fontFamily: persianFont,
          fontSize: 22,
          fontWeight: FontWeight.w600,
          color: snappDark,
        ),
        headlineMedium: TextStyle(
          fontFamily: persianFont,
          fontSize: 20,
          fontWeight: FontWeight.w600,
          color: snappDark,
        ),
        headlineSmall: TextStyle(
          fontFamily: persianFont,
          fontSize: 18,
          fontWeight: FontWeight.w600,
          color: snappDark,
        ),
        titleLarge: TextStyle(
          fontFamily: persianFont,
          fontSize: 16,
          fontWeight: FontWeight.w600,
          color: snappDark,
        ),
        titleMedium: TextStyle(
          fontFamily: persianFont,
          fontSize: 14,
          fontWeight: FontWeight.w500,
          color: snappDark,
        ),
        titleSmall: TextStyle(
          fontFamily: persianFont,
          fontSize: 12,
          fontWeight: FontWeight.w500,
          color: snappDark,
        ),
        bodyLarge: TextStyle(
          fontFamily: persianFont,
          fontSize: 16,
          fontWeight: FontWeight.normal,
          color: snappDark,
        ),
        bodyMedium: TextStyle(
          fontFamily: persianFont,
          fontSize: 14,
          fontWeight: FontWeight.normal,
          color: snappDark,
        ),
        bodySmall: TextStyle(
          fontFamily: persianFont,
          fontSize: 12,
          fontWeight: FontWeight.normal,
          color: snappGray,
        ),
        labelLarge: TextStyle(
          fontFamily: persianFont,
          fontSize: 14,
          fontWeight: FontWeight.w500,
          color: snappDark,
        ),
        labelMedium: TextStyle(
          fontFamily: persianFont,
          fontSize: 12,
          fontWeight: FontWeight.w500,
          color: snappGray,
        ),
        labelSmall: TextStyle(
          fontFamily: persianFont,
          fontSize: 10,
          fontWeight: FontWeight.w500,
          color: snappGray,
        ),
      ),
    );
  }

  // Snack bar theme
  static SnackBarThemeData get snackBarTheme {
    return const SnackBarThemeData(
      backgroundColor: snappDark,
      contentTextStyle: TextStyle(fontFamily: persianFont, color: Colors.white),
      actionTextColor: snappPrimary,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.all(Radius.circular(12)),
      ),
    );
  }

  // Custom colors for specific use cases
  static const Color successColor = snappPrimary;
  static const Color warningColor = Color(0xFFFFA500);
  static const Color errorColor = Color(0xFFEF4444);
  static const Color infoColor = snappSecondary;
}
