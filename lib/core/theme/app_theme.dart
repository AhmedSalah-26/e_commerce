import 'package:flutter/material.dart';
import 'app_colors.dart';

class AppTheme {
  static ThemeData get lightTheme {
    return ThemeData(
      fontFamily: 'Changa',
      brightness: Brightness.light,
      primaryColor: AppColours.brownMedium,
      scaffoldBackgroundColor: AppColours.background,
      colorScheme: const ColorScheme.light(
        primary: AppColours.brownMedium,
        secondary: AppColours.brownLight,
        surface: AppColours.white,
        onSurface: AppColours.black,
        outline: AppColours.outlineLight,
        error: AppColours.error,
      ),
      appBarTheme: const AppBarTheme(
        elevation: 0,
        scrolledUnderElevation: 0,
        shadowColor: Colors.transparent,
        surfaceTintColor: Colors.transparent,
      ),
      dialogTheme: DialogThemeData(
        backgroundColor: AppColours.white,
        surfaceTintColor: Colors.transparent,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(24),
        ),
        elevation: 8,
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

  static ThemeData get darkTheme {
    return ThemeData(
      fontFamily: 'Changa',
      brightness: Brightness.dark,
      primaryColor: AppColours.brownLight,
      scaffoldBackgroundColor: AppColours.darkBackground,
      colorScheme: const ColorScheme.dark(
        primary: AppColours.brownLight,
        secondary: AppColours.brownMedium,
        surface: AppColours.darkSurface,
        onSurface: AppColours.white,
        outline: AppColours.outlineDark,
        error: Color(0xFFEF5350),
      ),
      appBarTheme: const AppBarTheme(
        elevation: 0,
        scrolledUnderElevation: 0,
        shadowColor: Colors.transparent,
        surfaceTintColor: Colors.transparent,
        backgroundColor: AppColours.darkSurface,
      ),
      dialogTheme: DialogThemeData(
        backgroundColor: AppColours.darkSurface,
        surfaceTintColor: Colors.transparent,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(24),
        ),
        elevation: 8,
      ),
      cardTheme: const CardThemeData(
        color: AppColours.darkCard,
      ),
      textTheme: const TextTheme(
        displayLarge: TextStyle(fontFamily: 'Changa', color: AppColours.white),
        displayMedium: TextStyle(fontFamily: 'Changa', color: AppColours.white),
        displaySmall: TextStyle(fontFamily: 'Changa', color: AppColours.white),
        headlineLarge: TextStyle(fontFamily: 'Changa', color: AppColours.white),
        headlineMedium:
            TextStyle(fontFamily: 'Changa', color: AppColours.white),
        headlineSmall: TextStyle(fontFamily: 'Changa', color: AppColours.white),
        titleLarge: TextStyle(fontFamily: 'Changa', color: AppColours.white),
        titleMedium: TextStyle(fontFamily: 'Changa', color: AppColours.white),
        titleSmall: TextStyle(fontFamily: 'Changa', color: AppColours.white),
        bodyLarge: TextStyle(fontFamily: 'Changa', color: AppColours.white),
        bodyMedium: TextStyle(fontFamily: 'Changa', color: AppColours.white),
        bodySmall:
            TextStyle(fontFamily: 'Changa', color: AppColours.darkGreyLight),
        labelLarge: TextStyle(fontFamily: 'Changa', color: AppColours.white),
        labelMedium: TextStyle(fontFamily: 'Changa', color: AppColours.white),
        labelSmall:
            TextStyle(fontFamily: 'Changa', color: AppColours.darkGreyLight),
      ),
      textSelectionTheme: TextSelectionThemeData(
        cursorColor: AppColours.brownLight,
        selectionColor: AppColours.brownLight.withValues(alpha: 0.4),
        selectionHandleColor: AppColours.brownLight,
      ),
      inputDecorationTheme: InputDecorationTheme(
        labelStyle: const TextStyle(
          color: AppColours.brownLight,
          fontFamily: 'Changa',
        ),
        floatingLabelStyle: const TextStyle(
          color: AppColours.brownLight,
          fontFamily: 'Changa',
        ),
        hintStyle: const TextStyle(
          color: AppColours.darkGreyMedium,
          fontFamily: 'Changa',
        ),
        errorStyle: const TextStyle(
          color: Color(0xFFEF5350),
          fontFamily: 'Changa',
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: AppColours.brownLight, width: 2),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: AppColours.outlineDark),
        ),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: AppColours.outlineDark),
        ),
        errorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: Color(0xFFEF5350), width: 1),
        ),
        focusedErrorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: Color(0xFFEF5350), width: 2),
        ),
      ),
    );
  }
}
