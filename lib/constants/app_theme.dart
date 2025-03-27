import 'package:flutter/material.dart';

// Color Palette (Inspired by the Tailwind config)
class AppColors {
  static const Color background = Color(0xFF1A1A2E); // Deep space blue/purple
  static const Color backgroundDark = Color(0xFF161625);
  static const Color orbCyan = Color(0xFF00F5FF);
  static const Color orbMagenta = Color(0xFFFF00FF);
  static const Color orbGold = Color(0xFFFFD700);
  static const Color uiPrimary = Color(0xFFFFFFFF); // White text/icons
  static const Color uiSecondary = Color(0xFFA0A0A0); // Light grey
  static const Color uiBorder = Color(0xFF3A3A5E); // Subtle border
  static const Color feedbackCorrect = Color(0xFF4ADE80); // Green-ish
  static const Color feedbackIncorrect = Color(0xFFF87171); // Red-ish
  static const Color placeholder =
      Color(0x33888899); // Transparent grey for orb placeholder
}

// Typography (Using a system-like font)
class AppTypography {
  static const String fontFamily = 'SystemDefault'; // Rely on system fonts

  static const TextStyle headline1 = TextStyle(
      fontFamily: fontFamily,
      fontSize: 48,
      fontWeight: FontWeight.bold,
      color: AppColors.orbCyan);
  static const TextStyle headline2 = TextStyle(
      fontFamily: fontFamily,
      fontSize: 32,
      fontWeight: FontWeight.w600,
      color: AppColors.uiPrimary);
  static const TextStyle scoreLevelText = TextStyle(
      fontFamily: fontFamily, fontSize: 20, color: AppColors.uiSecondary);
  static const TextStyle scoreLevelValue = TextStyle(
      fontFamily: fontFamily,
      fontSize: 20,
      fontWeight: FontWeight.w600,
      color: AppColors.uiPrimary);
  static const TextStyle bodyText = TextStyle(
      fontFamily: fontFamily, fontSize: 18, color: AppColors.uiSecondary);
  static const TextStyle buttonText = TextStyle(
      fontFamily: fontFamily,
      fontSize: 18,
      fontWeight: FontWeight.w600,
      color: AppColors.backgroundDark);
  static const TextStyle statusText = TextStyle(
      fontFamily: fontFamily, fontSize: 18, color: AppColors.uiSecondary);
}

// Game Constants
class GameConfig {
  static const int maxGridSize = 9; // 3x3 grid
  static const int initialSequenceLength = 3;
  static const Duration presentationSpeed = Duration(milliseconds: 800);
  static const Duration feedbackDelay = Duration(milliseconds: 300);
  static const Duration levelTransitionDelay =
      Duration(milliseconds: 400); // presentationSpeed / 2
  static const int scoreIncrement = 10;
  static const int gridSize = 3; // For layout
}

// App Theme Data
ThemeData buildAppTheme() {
  return ThemeData(
    brightness: Brightness.dark,
    scaffoldBackgroundColor: AppColors.background,
    primaryColor: AppColors.orbCyan,
    fontFamily: AppTypography.fontFamily,
    textTheme: const TextTheme(
      displayLarge: AppTypography.headline1, // Use for main title
      headlineMedium: AppTypography.headline2, // Use for Game Over title
      bodyLarge: AppTypography.bodyText, // Default text
      labelLarge: AppTypography.buttonText, // Button text
    ).apply(
      bodyColor: AppColors.uiPrimary,
      displayColor: AppColors.uiPrimary,
    ),
    elevatedButtonTheme: ElevatedButtonThemeData(
      style: ElevatedButton.styleFrom(
        backgroundColor: AppColors.orbCyan,
        foregroundColor: AppColors.backgroundDark, // Text color
        textStyle: AppTypography.buttonText,
        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12.0),
        ),
      ),
    ),
    // Define other theme properties if needed
  );
}
