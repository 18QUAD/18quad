import 'package:flutter/material.dart';
import 'colors.dart';
import 'text_styles.dart';

class AppTheme {
  static ThemeData get light => ThemeData(
    scaffoldBackgroundColor: AppColors.background,
    primaryColor: AppColors.accent,
    textTheme: const TextTheme(
      bodyMedium: AppTextStyles.body,
      titleLarge: AppTextStyles.title,
      labelLarge: AppTextStyles.label,
    ),
    inputDecorationTheme: const InputDecorationTheme(
      filled: true,
      fillColor: AppColors.surface,
      labelStyle: AppTextStyles.label,
      border: OutlineInputBorder(),
    ),
    textButtonTheme: TextButtonThemeData(
      style: TextButton.styleFrom(
        foregroundColor: AppColors.accent,
        textStyle: AppTextStyles.button,
      ),
    ),
    elevatedButtonTheme: ElevatedButtonThemeData(
      style: ElevatedButton.styleFrom(
        backgroundColor: AppColors.button,
        foregroundColor: AppColors.textPrimary,
        textStyle: AppTextStyles.button,
      ),
    ),
  );
}