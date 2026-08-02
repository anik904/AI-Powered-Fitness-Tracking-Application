import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class AppTheme {
  static const Color background = Color(0xFFF8F9FA); // Very light grey
  static const Color cardColor = Colors.white;
  static const Color accentColor = Color(0xFF84CC16); // Lime green
  static const Color textPrimary = Color(0xFF111827); // Very dark gray
  static const Color textSecondary = Color(0xFF6B7280); // Gray

  static ThemeData get lightTheme {
    return ThemeData(
      brightness: Brightness.light,
      scaffoldBackgroundColor: background,
      primaryColor: accentColor,
      cardColor: cardColor,
      colorScheme: const ColorScheme.light(
        primary: accentColor,
        secondary: accentColor,
        surface: cardColor,
        background: background,
        onPrimary: Colors.white,
        onSecondary: Colors.white,
        onSurface: textPrimary,
        onBackground: textPrimary,
      ),
      textTheme: GoogleFonts.poppinsTextTheme().copyWith(
        headlineMedium: GoogleFonts.poppins(color: textPrimary, fontWeight: FontWeight.w700, fontSize: 24),
        titleLarge: GoogleFonts.poppins(color: textPrimary, fontWeight: FontWeight.w600, fontSize: 20),
        titleMedium: GoogleFonts.poppins(color: textPrimary, fontWeight: FontWeight.w600, fontSize: 16),
        bodyLarge: GoogleFonts.poppins(color: textPrimary, fontSize: 16, fontWeight: FontWeight.w400),
        bodyMedium: GoogleFonts.poppins(color: textSecondary, fontSize: 14, fontWeight: FontWeight.w400),
      ),

      bottomNavigationBarTheme: const BottomNavigationBarThemeData(
        backgroundColor: cardColor,
        selectedItemColor: accentColor,
        unselectedItemColor: textSecondary,
        showSelectedLabels: false,
        showUnselectedLabels: false,
        elevation: 8,
      ),
      useMaterial3: true,
    );
  }
}
