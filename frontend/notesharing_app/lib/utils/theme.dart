import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class AppTheme {
  // Ultra Modern Light Palette
  static const Color bgLight = Color(0xFFF0F2F5); // Soft Cloud White
  static const Color bgCard = Colors.white; // Pure White for cards
  static const Color bgCardLight = Color(0xFFF8F9FA); // Slightly off-white
  
  // High Contrast Neon Accents (Adjusted for Light Mode)
  static const Color primaryColor = Color(0xFF6200EE); // Deep Violet
  static const Color primaryLight = Color(0xFFB794F6); 
  static const Color accentCyan = Color(0xFF00B0FF); // Vivid Cyan
  static const Color accentPink = Color(0xFFFF4081); // Hot Pink
  static const Color accentAmber = Color(0xFFFFAB00);
  static const Color accentOrange = Color(0xFFFF6D00);
  static const Color accentTeal = Color(0xFF00BFA5);
  static const Color accentPurple = Color(0xFFAA00FF);
  
  // Status Colors
  static const Color success = Color(0xFF00C853); 
  static const Color error = Color(0xFFD50000); 
  static const Color warning = Color(0xFFFFD600); 
  
  // Glass Colors (Light Mode)
  static const Color glassWhite = Colors.white;
  static const Color glassBorder = Colors.white54;
  
  // Text Colors (High Contrast)
  static const Color textPrimary = Color(0xFF1D1B26); // Almost Black
  static const Color textSecondary = Color(0xFF636979); // Slate Grey
  static const Color textMuted = Color(0xFF9CA3AF);

  // Gradients
  static const LinearGradient primaryGradient = LinearGradient(
    colors: [Color(0xFF6200EE), Color(0xFFB000FF)],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );
  
  static const LinearGradient cyberGradient = LinearGradient(
    colors: [Color(0xFF00B0FF), Color(0xFF6200EE)],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );

  static const LinearGradient cardGradient = LinearGradient(
    colors: [Colors.white, Color(0xFFF8F9FA)],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );

  static ThemeData get lightTheme {
    return ThemeData(
      useMaterial3: true,
      brightness: Brightness.light,
      scaffoldBackgroundColor: bgLight,
      primaryColor: primaryColor,
      textTheme: GoogleFonts.outfitTextTheme(ThemeData.light().textTheme).apply(
        bodyColor: textPrimary,
        displayColor: textPrimary,
      ),
      colorScheme: const ColorScheme.light(
        primary: primaryColor,
        secondary: accentCyan,
        surface: bgCard,
        background: bgLight,
        error: error,
      ),
      appBarTheme: const AppBarTheme(
        backgroundColor: Colors.transparent,
        elevation: 0,
        centerTitle: true,
        iconTheme: IconThemeData(color: textPrimary),
        titleTextStyle: TextStyle(color: textPrimary, fontSize: 20, fontWeight: FontWeight.bold),
      ),
      // Fix for CardThemeData compatibility
      cardTheme: const CardThemeData(
        color: bgCard, 
        elevation: 5,
        shadowColor: Color(0x1A000000), // Soft shadow
        margin: EdgeInsets.all(8),
      ),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: Colors.white,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: const BorderSide(color: Color(0xFFE0E0E0)),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: const BorderSide(color: Color(0xFFE0E0E0)),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: const BorderSide(color: primaryColor, width: 2),
        ),
        contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 20),
        hintStyle: const TextStyle(color: textMuted),
        labelStyle: const TextStyle(color: textSecondary),
      ),
      iconTheme: const IconThemeData(color: textSecondary),
    );
  }
}
