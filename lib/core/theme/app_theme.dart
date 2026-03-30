import 'package:flutter/material.dart';
import 'app_colors.dart';
import 'package:tawakad_app/core/navigation/right_to_left_page_transition.dart';

class AppTheme {
  static ThemeData light() {
    final base = ThemeData.light();

    return base.copyWith(
      scaffoldBackgroundColor: AppColors.background,
      colorScheme: base.colorScheme.copyWith(
        brightness: Brightness.light,
        primary: AppColors.primary,
        surface: AppColors.surface,
      ),
      textTheme: const TextTheme(
        displayLarge: TextStyle(
          fontFamily: 'NotoSan',
          fontSize: 80,
          fontWeight: FontWeight.w700,
          color: AppColors.primary,
        ),
        bodyLarge: TextStyle(
          fontFamily: 'Montserrat',
          fontSize: 24,
          fontWeight: FontWeight.w700,
          color: AppColors.textPrimary,
        ),
        bodyMedium: TextStyle(
          fontFamily: 'Montserrat',
          fontSize: 16,
          fontWeight: FontWeight.w400,
          color: AppColors.textPrimary,
        ),
        bodySmall: TextStyle(
          fontFamily: 'Montserrat',
          fontSize: 12,
          fontWeight: FontWeight.w600,
          color: AppColors.textPrimary,
        ),
        headlineLarge: TextStyle(
          fontFamily: 'Montserrat',
          fontSize: 36,
          fontWeight: FontWeight.w700,
          color: AppColors.textPrimary,
        ),
        labelMedium: TextStyle(
          fontFamily: 'Montserrat',
          fontSize: 14,
          fontWeight: FontWeight.w700,
          color: AppColors.textPrimary,
        ),
        labelSmall: TextStyle(
          fontFamily: 'Montserrat',
          fontSize: 12,
          fontWeight: FontWeight.w700,
          color: Colors.white,
          height: 1.5,
        ),
        labelLarge: TextStyle(
          fontFamily: 'Montserrat',
          fontSize: 18,
          fontWeight: FontWeight.w700,
          color: AppColors.buttonText,
        ),
      ),
      textSelectionTheme: const TextSelectionThemeData(
        cursorColor: AppColors.textPrimary,
        selectionHandleColor: AppColors.primary,
      ),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: AppColors.surface,
        contentPadding:
            const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
        hintStyle: const TextStyle(
          fontFamily: 'Montserrat',
          fontWeight: FontWeight.w300,
          fontSize: 16,
          color: AppColors.placeholder,
        ),
        labelStyle: const TextStyle(
          fontFamily: 'Montserrat',
          fontSize: 16,
          fontWeight: FontWeight.w400,
          color: AppColors.textPrimary,
        ),
        floatingLabelStyle: const TextStyle(
          fontFamily: 'Montserrat',
          fontSize: 16,
          fontWeight: FontWeight.w400,
          color: AppColors.textPrimary,
        ),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(30),
          borderSide: const BorderSide(color: AppColors.fieldBorder, width: 1),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(30),
          borderSide: const BorderSide(color: AppColors.fieldBorder, width: 1),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(30),
          borderSide: const BorderSide(color: AppColors.primary, width: 1.5),
        ),
        errorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(30),
          borderSide: const BorderSide(
            color: AppColors.fieldErrorBorder,
            width: 1.5,
          ),
        ),
        focusedErrorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(30),
          borderSide: const BorderSide(
            color: AppColors.fieldErrorBorder,
            width: 1.5,
          ),
        ),
        errorStyle: const TextStyle(
          fontFamily: 'Montserrat',
          fontSize: 12,
          fontWeight: FontWeight.w400,
          color: AppColors.fieldErrorBorder,
          height: 1.3,
        ),
      ),
      pageTransitionsTheme: const PageTransitionsTheme(
        builders: {
          TargetPlatform.android: RightToLeftPageTransitionsBuilder(),
          TargetPlatform.iOS: RightToLeftPageTransitionsBuilder(),
          TargetPlatform.macOS: RightToLeftPageTransitionsBuilder(),
          TargetPlatform.windows: RightToLeftPageTransitionsBuilder(),
          TargetPlatform.linux: RightToLeftPageTransitionsBuilder(),
          TargetPlatform.fuchsia: RightToLeftPageTransitionsBuilder(),
        },
      ),
    );
  }

  static ThemeData dark() {
    final base = ThemeData.dark();

    return base.copyWith(
      scaffoldBackgroundColor: AppDarkColors.background,
      colorScheme: base.colorScheme.copyWith(
        brightness: Brightness.dark,
        primary: AppColors.primary,
        surface: AppDarkColors.surface,
      ),
      textTheme: const TextTheme(
        displayLarge: TextStyle(
          fontFamily: 'NotoSan',
          fontSize: 80,
          fontWeight: FontWeight.w700,
          color: AppColors.primary,
        ),
        bodyLarge: TextStyle(
          fontFamily: 'Montserrat',
          fontSize: 24,
          fontWeight: FontWeight.w700,
          color: AppDarkColors.textPrimary,
        ),
        bodyMedium: TextStyle(
          fontFamily: 'Montserrat',
          fontSize: 16,
          fontWeight: FontWeight.w400,
          color: AppDarkColors.textPrimary,
        ),
        bodySmall: TextStyle(
          fontFamily: 'Montserrat',
          fontSize: 12,
          fontWeight: FontWeight.w600,
          color: AppDarkColors.textPrimary,
        ),
        headlineLarge: TextStyle(
          fontFamily: 'Montserrat',
          fontSize: 36,
          fontWeight: FontWeight.w700,
          color: AppDarkColors.textPrimary,
        ),
        labelMedium: TextStyle(
          fontFamily: 'Montserrat',
          fontSize: 14,
          fontWeight: FontWeight.w700,
          color: AppDarkColors.textPrimary,
        ),
        labelSmall: TextStyle(
          fontFamily: 'Montserrat',
          fontSize: 12,
          fontWeight: FontWeight.w700,
          color: Colors.white,
          height: 1.5,
        ),
        labelLarge: TextStyle(
          fontFamily: 'Montserrat',
          fontSize: 18,
          fontWeight: FontWeight.w700,
          color: Colors.white,
        ),
      ),
      textSelectionTheme: const TextSelectionThemeData(
        cursorColor: AppDarkColors.textPrimary,
        selectionHandleColor: AppColors.primary,
      ),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: AppDarkColors.surface,
        contentPadding:
            const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
        hintStyle: const TextStyle(
          fontFamily: 'Montserrat',
          fontWeight: FontWeight.w300,
          fontSize: 16,
          color: AppDarkColors.placeholder,
        ),
        labelStyle: const TextStyle(
          fontFamily: 'Montserrat',
          fontSize: 16,
          fontWeight: FontWeight.w400,
          color: AppDarkColors.textPrimary,
        ),
        floatingLabelStyle: const TextStyle(
          fontFamily: 'Montserrat',
          fontSize: 16,
          fontWeight: FontWeight.w400,
          color: AppDarkColors.textPrimary,
        ),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(30),
          borderSide:
              const BorderSide(color: AppDarkColors.fieldBorder, width: 1),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(30),
          borderSide:
              const BorderSide(color: AppDarkColors.fieldBorder, width: 1),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(30),
          borderSide: const BorderSide(color: AppColors.primary, width: 1.5),
        ),
        errorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(30),
          borderSide: const BorderSide(
            color: AppColors.fieldErrorBorder,
            width: 1.5,
          ),
        ),
        focusedErrorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(30),
          borderSide: const BorderSide(
            color: AppColors.fieldErrorBorder,
            width: 1.5,
          ),
        ),
        errorStyle: const TextStyle(
          fontFamily: 'Montserrat',
          fontSize: 12,
          fontWeight: FontWeight.w400,
          color: AppColors.fieldErrorBorder,
          height: 1.3,
        ),
      ),
      pageTransitionsTheme: const PageTransitionsTheme(
        builders: {
          TargetPlatform.android: RightToLeftPageTransitionsBuilder(),
          TargetPlatform.iOS: RightToLeftPageTransitionsBuilder(),
          TargetPlatform.macOS: RightToLeftPageTransitionsBuilder(),
          TargetPlatform.windows: RightToLeftPageTransitionsBuilder(),
          TargetPlatform.linux: RightToLeftPageTransitionsBuilder(),
          TargetPlatform.fuchsia: RightToLeftPageTransitionsBuilder(),
        },
      ),
    );
  }
}
