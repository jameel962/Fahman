import 'package:flutter/material.dart';

class FahmanTypography {
  FahmanTypography._();

  // Common fallback stack to maximize SF availability across platforms
  static const List<String> _sfFallback = <String>[
    'SF Pro Text',
    'SF Pro Display',
    '.SF UI Text',
    '.SF NS',
    'San Francisco',
    'Segoe UI',
    'Roboto',
    'Helvetica Neue',
    'Noto Sans',
    'Arial',
    'system-ui',
    'sans-serif',
  ];

  // Build TextStyle helper with size, height and weight
  static TextStyle _ts(double size, double leading, FontWeight weight) => TextStyle(
        fontFamily: 'SF Pro Text',
        fontFamilyFallback: _sfFallback,
        fontSize: size,
        height: leading / size,
        fontWeight: weight,
      );

  // San Francisco TextTheme based on Apple HIG specs in screenshot
  static final TextTheme sfTextTheme = TextTheme(
    // Large Title 34 / 41
    displayLarge: _ts(34, 41, FontWeight.w700),
    // Title 1 28 / 34
    titleLarge: _ts(28, 34, FontWeight.w600),
    // Title 2 22 / 28
    titleMedium: _ts(22, 28, FontWeight.w600),
    // Title 3 20 / 25
    titleSmall: _ts(20, 25, FontWeight.w600),
    // Headline 17 / 22
    headlineMedium: _ts(17, 22, FontWeight.w600),
    // Body 17 / 22
    bodyLarge: _ts(17, 22, FontWeight.w400),
    // Callout 16 / 21
    bodyMedium: _ts(16, 21, FontWeight.w400),
    // Subhead 15 / 20
    bodySmall: _ts(15, 20, FontWeight.w400),
    // Footnote 13 / 18
    labelLarge: _ts(13, 18, FontWeight.w400),
    // Caption 1 12 / 16
    labelMedium: _ts(12, 16, FontWeight.w400),
    // Caption 2 11 / 13
    labelSmall: _ts(11, 13, FontWeight.w400),
  );
}