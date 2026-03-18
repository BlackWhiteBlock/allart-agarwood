import 'package:flutter/material.dart';
import 'app_colors.dart';
import 'app_typography.dart';

/// 众艺链 App 主题
class AppTheme {
  AppTheme._();

  /// 东方极简主题 (V1)
  static ThemeData get orientalMinimal {
    return ThemeData(
      useMaterial3: true,
      brightness: Brightness.light,
      scaffoldBackgroundColor: AppColors.cream,
      primaryColor: AppColors.agarwoodBrown,
      colorScheme: const ColorScheme.light(
        primary: AppColors.agarwoodBrown,
        secondary: AppColors.agarwoodLight,
        surface: AppColors.cardBackground,
        background: AppColors.cream,
        error: AppColors.error,
        onPrimary: Colors.white,
        onSecondary: AppColors.textPrimary,
        onSurface: AppColors.textPrimary,
        onBackground: AppColors.textPrimary,
        onError: Colors.white,
      ),

      // AppBar
      appBarTheme: const AppBarTheme(
        backgroundColor: Colors.transparent,
        elevation: 0,
        scrolledUnderElevation: 0,
        centerTitle: true,
        titleTextStyle: TextStyle(
          fontFamily: AppTypography.displayFont,
          fontSize: 20,
          fontWeight: FontWeight.w600,
          color: AppColors.textPrimary,
        ),
        iconTheme: IconThemeData(color: AppColors.textPrimary),
      ),

      // Card
      cardTheme: CardTheme(
        color: AppColors.cardBackground,
        elevation: 0,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
        ),
        margin: const EdgeInsets.symmetric(horizontal: 0, vertical: 8),
      ),

      // ElevatedButton
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: AppColors.agarwoodBrown,
          foregroundColor: Colors.white,
          elevation: 0,
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 14),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          textStyle: AppTypography.labelLarge,
        ),
      ),

      // OutlinedButton
      outlinedButtonTheme: OutlinedButtonThemeData(
        style: OutlinedButton.styleFrom(
          foregroundColor: AppColors.agarwoodBrown,
          side: const BorderSide(color: AppColors.agarwoodBrown, width: 1.5),
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 14),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          textStyle: AppTypography.labelLarge,
        ),
      ),

      // Input
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: AppColors.cardBackground,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: BorderSide.none,
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: const BorderSide(color: AppColors.divider, width: 1),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: const BorderSide(color: AppColors.agarwoodBrown, width: 1.5),
        ),
        contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
        hintStyle: AppTypography.bodyMedium.copyWith(color: AppColors.textTertiary),
      ),

      // BottomNavigationBar
      bottomNavigationBarTheme: const BottomNavigationBarThemeData(
        backgroundColor: AppColors.cardBackground,
        selectedItemColor: AppColors.agarwoodBrown,
        unselectedItemColor: AppColors.textTertiary,
        type: BottomNavigationBarType.fixed,
        elevation: 8,
        selectedLabelStyle: TextStyle(
          fontFamily: AppTypography.bodyFont,
          fontSize: 11,
          fontWeight: FontWeight.w600,
        ),
        unselectedLabelStyle: TextStyle(
          fontFamily: AppTypography.bodyFont,
          fontSize: 11,
          fontWeight: FontWeight.w400,
        ),
      ),

      // Divider
      dividerTheme: const DividerThemeData(
        color: AppColors.divider,
        thickness: 1,
        space: 1,
      ),

      // Text
      textTheme: const TextTheme(
        headlineLarge: AppTypography.h1,
        headlineMedium: AppTypography.h2,
        headlineSmall: AppTypography.h3,
        bodyLarge: AppTypography.bodyLarge,
        bodyMedium: AppTypography.bodyMedium,
        bodySmall: AppTypography.bodySmall,
        labelLarge: AppTypography.labelLarge,
        labelMedium: AppTypography.labelMedium,
        labelSmall: AppTypography.labelSmall,
      ),
    );
  }

  /// 赛博未来主题 (V2) - 预留
  static ThemeData get cyberFuture {
    return orientalMinimal.copyWith(
      scaffoldBackgroundColor: const Color(0xFF0A0A0A),
      brightness: Brightness.dark,
      colorScheme: const ColorScheme.dark(
        primary: Color(0xFF00E5FF),
        secondary: Color(0xFF7C4DFF),
        surface: Color(0xFF1A1A2E),
        background: Color(0xFF0A0A0A),
      ),
    );
  }
}
