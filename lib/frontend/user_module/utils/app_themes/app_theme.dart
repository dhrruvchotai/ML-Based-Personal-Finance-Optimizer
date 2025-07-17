// import 'package:flutter/material.dart';
//
// ThemeData lightMode = ThemeData(
//   brightness: Brightness.light,
//   colorScheme: ColorScheme.light(
//     background: const Color(0xFFF4F1FF),
//     surface: const Color(0xFFFFFFFF),
//     primary: const Color(0xFF8B5FBF),
//     secondary: const Color(0xFFE879F9),
//     onBackground: const Color(0xFF2D1B69),
//     onSurface: const Color(0xFFA5A3C7),
//     outline: const Color(0xFF3B4070)
//
//
//   )
// );
//
// ThemeData darkMode = ThemeData(
//     brightness: Brightness.dark,
//   colorScheme: ColorScheme.dark(
//     background: const Color(0xFF0A0B1E),
//     surface: const Color(0xFF1A1B3A),
//     primary: const Color(0xFF8B5FBF),
//     secondary: const Color(0xFFE879F9),
//     onBackground:const  Color(0xFFE8E6FF),
//     onSurface:const Color(0xFF6B6394),
//     outline: const Color(0xFFE1DCFF),
//   )
// );

import 'package:flutter/material.dart';

// Light theme with pastel colors
ThemeData lightMode = ThemeData(
  brightness: Brightness.light,
  colorScheme: const ColorScheme.light(
    background: Color(0xFFF4F6F8),
    surface: Color(0xFFFFFFFF),
    primary: Color(0xFF417FB1),
    secondary: Color(0xFF89C2A5),
    onBackground: Color(0xFF15232D),
    onSurface: Color(0xFF3C4F60),
    outline: Color(0xFFC5CED6),
    tertiary: Color(0xFFF2F7F9),
    onTertiary: Color(0xFF243645),
    error: Color(0xFFFF9999),
    onError: Color(0xFFFFFFFF),
    inversePrimary: Color(0xFF9AD8B8),
    surfaceVariant: Color(0xFFE3EBF1),
    onSurfaceVariant: Color(0xFF4C6170),
    primaryContainer: Color(0xFFB1CDE0),
    onPrimaryContainer: Color(0xFF132B3C),
  ),

  // Card theme
  cardTheme: const CardThemeData(
    elevation: 2,
    shape: RoundedRectangleBorder(
      borderRadius: BorderRadius.all(Radius.circular(16)),
    ),
  ),
  // Elevated button theme
  elevatedButtonTheme: ElevatedButtonThemeData(
    style: ElevatedButton.styleFrom(
      elevation: 0,
      backgroundColor: Color(0xFF7AB2D3), // Pastel blue for buttons
      foregroundColor: Color(0xFFFFFFFF),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
    ),
  ),
  // Input decoration theme
  inputDecorationTheme: InputDecorationTheme(
    border: OutlineInputBorder(
      borderRadius: BorderRadius.circular(12),
      borderSide: const BorderSide(color: Color(0xFFDCE1E6)),
    ),
    enabledBorder: OutlineInputBorder(
      borderRadius: BorderRadius.circular(12),
      borderSide: const BorderSide(color: Color(0xFFDCE1E6)),
    ),
    focusedBorder: OutlineInputBorder(
      borderRadius: BorderRadius.circular(12),
      borderSide: const BorderSide(color: Color(0xFF7AB2D3), width: 2),
    ),
  ),
  // Typography
  textTheme: const TextTheme(
    headlineMedium: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Color(0xFF1A2E35)),
    bodyMedium: TextStyle(fontSize: 14, color: Color(0xFF4A5B66)),
  ),
);

// Dark theme with pastel colors
ThemeData darkMode = ThemeData(
  brightness: Brightness.dark,
  colorScheme: const ColorScheme.dark(
    // Main background - Deep charcoal for a sleek look
    background: Color(0xFF1C2526),
    // Surface - Dark gray for cards and inputs
    surface: Color(0xFF2E3A3B),
    // Primary brand color - Pastel blue for consistency
    primary: Color(0xFF7AB2D3),
    // Secondary accent - Pastel mint green
    secondary: Color(0xFFA8D5BA),
    // Text colors
    onBackground: Color(0xFFEFF3F5),
    onSurface: Color(0xFFB0C4D0),
    // Border and outline colors
    outline: Color(0xFF5E7380),
    // Additional colors
    tertiary: Color(0xFF3A4B4D),
    onTertiary: Color(0xFFEFF3F5),
    // Error colors - Soft coral for alerts
    error: Color(0xFFFF9999),
    onError: Color(0xFF2E3A3B),
    // Success/positive colors - Soft green for goal progress
    inversePrimary: Color(0xFFB2E4C9),
    // Additional semantic colors
    surfaceVariant: Color(0xFF4A5B66),
    onSurfaceVariant: Color(0xFFB0C4D0),
    primaryContainer: Color(0xFF1A3C4E),
    onPrimaryContainer: Color(0xFFD6E8F2),
  ),
  // Card theme
  cardTheme: const CardThemeData(
    elevation: 2,
    color: Color(0xFF2E3A3B),
    shape: RoundedRectangleBorder(
      borderRadius: BorderRadius.all(Radius.circular(16)),
    ),
  ),
  // Elevated button theme
  elevatedButtonTheme: ElevatedButtonThemeData(
    style: ElevatedButton.styleFrom(
      elevation: 0,
      backgroundColor: Color(0xFF7AB2D3), // Pastel blue for buttons
      foregroundColor: Color(0xFFEFF3F5),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
    ),
  ),
  // Input decoration theme
  inputDecorationTheme: InputDecorationTheme(
    border: OutlineInputBorder(
      borderRadius: BorderRadius.circular(12),
      borderSide: const BorderSide(color: Color(0xFF5E7380)),
    ),
    enabledBorder: OutlineInputBorder(
      borderRadius: BorderRadius.circular(12),
      borderSide: const BorderSide(color: Color(0xFF5E7380)),
    ),
    focusedBorder: OutlineInputBorder(
      borderRadius: BorderRadius.circular(12),
      borderSide: const BorderSide(color: Color(0xFF7AB2D3), width: 2),
    ),
  ),
  // Typography
  textTheme: const TextTheme(
    headlineMedium: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Color(0xFFEFF3F5)),
    bodyMedium: TextStyle(fontSize: 14, color: Color(0xFFB0C4D0)),
  ),
);

// Professional color constants with pastel tones
class AppColors {
  // Light mode colors
  static const lightPrimary = Color(0xFF7AB2D3); // Pastel blue
  static const lightSecondary = Color(0xFFA8D5BA); // Pastel mint green
  static const lightBackground = Color(0xFFF5F6F5); // Pastel off-white
  static const lightSurface = Color(0xFFFFFFFF); // Pure white
  static const lightSuccess = Color(0xFFB2E4C9); // Soft green
  static const lightWarning = Color(0xFFFBCFAB); // Soft peach
  static const lightError = Color(0xFFFF9999); // Soft coral
  static const lightInfo = Color(0xFFB3CDE0); // Light pastel blue

  // Dark mode colors
  static const darkPrimary = Color(0xFF7AB2D3); // Pastel blue
  static const darkSecondary = Color(0xFFA8D5BA); // Pastel mint green
  static const darkBackground = Color(0xFF1C2526); // Deep charcoal
  static const darkSurface = Color(0xFF2E3A3B); // Dark gray
  static const darkSuccess = Color(0xFFB2E4C9); // Soft green
  static const darkWarning = Color(0xFFFBCFAB); // Soft peach
  static const darkError = Color(0xFFFF9999); // Soft coral
  static const darkInfo = Color(0xFFB3CDE0); // Light pastel blue

  // Neutral colors
  static const neutral50 = Color(0xFFF8FAFB);
  static const neutral100 = Color(0xFFEFF3F5);
  static const neutral200 = Color(0xFFDCE1E6);
  static const neutral300 = Color(0xFFB0C4D0);
  static const neutral400 = Color(0xFF8A9CA8);
  static const neutral500 = Color(0xFF5E7380);
  static const neutral600 = Color(0xFF4A5B66);
  static const neutral700 = Color(0xFF3A4B4D);
  static const neutral800 = Color(0xFF2E3A3B);
  static const neutral900 = Color(0xFF1C2526);

  // Status colors
  static const statusSuccess = Color(0xFFB2E4C9); // Soft green
  static const statusWarning = Color(0xFFFBCFAB); // Soft peach
  static const statusError = Color(0xFFFF9999); // Soft coral
  static const statusInfo = Color(0xFFB3CDE0); // Light pastel blue
}