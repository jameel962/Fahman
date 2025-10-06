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

  // App gradient (soft black, not too dark)
  static const List<Color> appGradient = [
    Color(0xFF141414),
    Color(0xFF1E1E1E),
    Color(0xFF232325),
  ];

  // Purple gradient for inquiry banner (brand tones)
  static const List<Color> inquiryBannerGradient = [
    brand800,
    brand600,
    brand700,
  ];

  // Voice pill gradient using brand tones
  static const List<Color> voicePillGradient = [
    brand900,
    brand700,
  ];
}