import 'package:flutter/material.dart';

var kDarkColorScheme = ColorScheme.fromSeed(
  brightness: Brightness.dark,
  seedColor: const Color(0xFF0091FF),
);

class AppColors {
  // Light mode
  static const background = Color(0xFFF7FAFC);
  static const surface = Color(0xFFFFFFFF);

  static const primary = Color(0xFF0091FF);
  static const linkSoft = Color(0xFF639FE8);

  static const progressBackground = Color(0xFFD3E4F8);

  static const textPrimary = Color(0xFF000000);
  static const placeholder = Color(0xFF92A8C8);
  static const textbreak = Color(0xFF9CA3AF);

  static const fieldBorder = Color(0xFFCFD6DE);

  static const buttonText = Color(0xFFE8E8E8);

  static const icon = Color(0xFF494646);

  static const Color fieldErrorFill = Color(0xFFFAEBEB);
  static const Color fieldErrorBorder = Color(0xFFD74242);

  static const Color speechBubble = Color(0xFF5E57F5);
}

class AppDarkColors {
  static const background = Color(0xFF0E1116);
  static const surface = Color(0xFF171B22);

  static const textPrimary = Color(0xFFF5F7FA);
  static const placeholder = Color(0xFF8E9AAF);
  static const fieldBorder = Color(0xFF313844);

  static const icon = Color(0xFFD1D5DB);
  static const progressBackground = Color(0xFF23364D);
}
