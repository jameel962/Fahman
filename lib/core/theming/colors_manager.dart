import 'package:flutter/material.dart';

class AppColors {
  AppColors._();

  // Brand (Purple) palette — updated
  static const MaterialColor brand = MaterialColor(_brandPrimary, <int, Color>{
    50: Color(0xFFF2F0FF),
    100: Color(0xFFE6E0FF),
    200: Color(0xFFD3CCFF),
    300: Color(0xFFC0B8FF),
    400: Color(0xFFB0A9FF),
    500: Color(0xFFA79FFF),
    600: Color(0xFFA099FF), // 600
    700: Color(0xFFB850C1), // 700
    800: Color(0xFF9852DA), // 800
    900: Color(0xFF6955FD), // 900
  });
  static const int _brandPrimary = 0xFFA099FF; // seed from 600

  // Direct access helpers (purple)

  static const Color brand900 = Color(0xFF6955FD);
  static const Color brand800 = Color(0xFF9852DA);
  static const Color brand700 = Color(0xFFB850C1);
  static const Color brand600 = Color(0xFFA099FF);
  static const Color brand500 = Color(0xFFA79FFF);
  static const Color brand400 = Color(0xFFB0A9FF);
  static const Color brand300 = Color(0xFFC0B8FF);
  static const Color brand200 = Color(0xFFD3CCFF);
  static const Color brand100 = Color(0xFFE6E0FF);
  static const Color brand50 = Color(0xFFF2F0FF);

  // Neutral (Black/Gray) palette — updated
  static const Color black = Color(0xFF000000);
  static const Color neutral900 = Color(0xFF333333);
  static const Color neutral800 = Color(0xFF454545);
  static const Color neutral700 = Color(0xFF4F4F4F);
  static const Color neutral600 = Color(0xFF5D5D5D);
  static const Color neutral500 = Color(0xFF6D6D6D);
  static const Color neutral400 = Color(0xFF888888);
  static const Color neutral300 = Color(0xFFB0B0B0);
  static const Color neutral200 = Color(0xFFD1D1D1);
  static const Color neutral100 = Color(0xFFE7E7E7);
  static const Color neutral50 = Color(0xFFF6F6F6);

  // Accent mauve for highlighted text mapped to brand800
  static const Color accentMauve = brand800;

  // App gradient (dark blue/purple gradient like the screenshots)
  static const List<Color> appGradient = [
    Color(0xFF1a1a2e), // Dark navy blue top
    Color(0xFF16213e), // Deep blue middle
    Color(0xFF0f1419), // Almost black bottom
  ];

  // Alternative gradients for different screens
  static const List<Color> darkGradient = [
    Color(0xFF0f0f0f),
    Color(0xFF1a1a1a),
    Color(0xFF121212),
  ];

  static const List<Color> blueGradient = [
    Color(0xFF1e3a5f), // Deep blue
    Color(0xFF1a2942), // Navy
    Color(0xFF0f1419), // Dark
  ];

  // Purple gradient for inquiry banner (brand tones)
  static const List<Color> inquiryBannerGradient = [
    brand800,
    brand600,
    brand700,
  ];

  // Voice pill gradient using brand tones
  static const List<Color> voicePillGradient = [brand900, brand700];

  // Card/Container backgrounds for dark theme
  static const Color cardBackground = Color(0xFF1a1a2e);
  static const Color inputFieldBackground = Color(0xFF0d0d1a);
  static const Color inputFieldBorder = Color(0xFF2a2a4e);
}
