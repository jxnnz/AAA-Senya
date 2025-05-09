import 'package:flutter/material.dart';

class AppColors {
  static const Color primaryBlue = Color(0xFF2C3F6D);
  static const Color accentOrange = Color(0xFFFF8C42);
  static const Color lightBlue = Color(0xFF8AB6F9);
  static const Color softOrange = Color(0xFFFFB677);
  static const Color background = Color(0xFFF5F7FA);
  static const Color text = Color(0xFF1A1A1A);
  static const Color card = Colors.white;
  static const Color error = Color(0xFFE82C36);

  // Status & Icon Colors
  static const Color streakActive = accentOrange;
  static const Color streakInactive = Color(0xFFC1C7D0);
  static const Color heartRed = Color(0xFFE74C3C);
  static const Color rubiesGold = Color(0xFFFFA500);
  static const Color editBlue = Color(0xFF4A90E2);
  static const Color deleteRed = Color(0xFFE53935);
  static const Color lockedGray = Color(0xFF7B8AA0);
  static const Color trophyGold = Color(0xFFF1C40F);
}

class AppTheme {
  static ThemeData get lightTheme {
    return ThemeData(
      brightness: Brightness.light,
      scaffoldBackgroundColor: AppColors.background,
      primaryColor: AppColors.primaryBlue,
      colorScheme: ColorScheme.light(
        primary: AppColors.primaryBlue,
        secondary: AppColors.accentOrange,
        error: AppColors.error,
      ),
      fontFamily: '',

      // AppBar Style
      appBarTheme: const AppBarTheme(
        backgroundColor: AppColors.primaryBlue,
        foregroundColor: Colors.white,
        elevation: 0,
      ),

      // Elevated Button
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: AppColors.accentOrange,
          foregroundColor: Colors.white,
          textStyle: const TextStyle(fontWeight: FontWeight.bold),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
        ),
      ),

      // Outlined Button
      outlinedButtonTheme: OutlinedButtonThemeData(
        style: OutlinedButton.styleFrom(
          foregroundColor: AppColors.primaryBlue,
          side: const BorderSide(color: AppColors.primaryBlue),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
        ),
      ),

      // Text Theme
      textTheme: const TextTheme(
        headlineLarge: TextStyle(
          fontSize: 32,
          fontWeight: FontWeight.bold,
          color: AppColors.text,
        ),
        titleMedium: TextStyle(
          fontSize: 20,
          fontWeight: FontWeight.bold,
          color: AppColors.text,
        ),
        bodyMedium: TextStyle(fontSize: 16, color: AppColors.text),
        labelLarge: TextStyle(
          fontSize: 14,
          fontWeight: FontWeight.w500,
          color: AppColors.text,
        ),
      ),

      // Card Theme
      cardTheme: CardTheme(
        color: AppColors.card,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        elevation: 4,
        shadowColor: Colors.grey.withOpacity(0.2),
      ),

      // Icon Theme
      iconTheme: const IconThemeData(color: AppColors.primaryBlue),

      // Progress Indicator
      progressIndicatorTheme: const ProgressIndicatorThemeData(
        color: AppColors.accentOrange,
        linearTrackColor: AppColors.lightBlue,
      ),
    );
  }
}
