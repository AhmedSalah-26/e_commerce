import 'package:flutter/material.dart';
import 'app_colors.dart';

class AppTheme {
  static ThemeData get lightTheme {
    return ThemeData(
      fontFamily: 'Changa',
      primaryColor: AppColours.brownMedium,
      colorScheme: const ColorScheme.light(
        primary: AppColours.brownMedium,
        secondary: AppColours.brownLight,
      ),
      appBarTheme: const AppBarTheme(
        elevation: 0,
        scrolledUnderElevation: 0,
        shadowColor: Colors.transparent,
        surfaceTintColor: Colors.transparent,
      ),
      textTheme: const TextTheme(
        displayLarge: TextStyle(fontFamily: 'Changa'),
        displayMedium: TextStyle(fontFamily: 'Changa'),
        displaySmall: TextStyle(fontFamily: 'Changa'),
        headlineLarge: TextStyle(fontFamily: 'Changa'),
        headlineMedium: TextStyle(fontFamily: 'Changa'),
        headlineSmall: TextStyle(fontFamily: 'Changa'),
        titleLarge: TextStyle(fontFamily: 'Changa'),
        titleMedium: TextStyle(fontFamily: 'Changa'),
        titleSmall: TextStyle(fontFamily: 'Changa'),
        bodyLarge: TextStyle(fontFamily: 'Changa'),
        bodyMedium: TextStyle(fontFamily: 'Changa'),
        bodySmall: TextStyle(fontFamily: 'Changa'),
        labelLarge: TextStyle(fontFamily: 'Changa'),
        labelMedium: TextStyle(fontFamily: 'Changa'),
        labelSmall: TextStyle(fontFamily: 'Changa'),
      ),
      textSelectionTheme: TextSelectionThemeData(
        cursorColor: AppColours.brownMedium,
        selectionColor: AppColours.brownLight.withValues(alpha: 0.4),
        selectionHandleColor: AppColours.brownMedium,
      ),
      inputDecorationTheme: InputDecorationTheme(
        labelStyle: const TextStyle(
          color: AppColours.brownMedium,
          fontFamily: 'Changa',
        ),
        floatingLabelStyle: const TextStyle(
          color: AppColours.brownMedium,
          fontFamily: 'Changa',
        ),
        hintStyle: const TextStyle(
          color: AppColours.greyMedium,
          fontFamily: 'Changa',
        ),
        errorStyle: const TextStyle(
          color: Colors.red,
          fontFamily: 'Changa',
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: AppColours.brownLight, width: 2),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: AppColours.brownLight),
        ),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: AppColours.brownLight),
        ),
        errorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: Colors.red, width: 1),
        ),
        focusedErrorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: Colors.red, width: 2),
        ),
      ),
    );
  }
}
