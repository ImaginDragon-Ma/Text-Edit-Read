import 'package:flutter/material.dart';
import 'colors.dart';

class AppTheme {
  static ThemeData light() {
    return ThemeData(
      useMaterial3: true,
      brightness: Brightness.light,
      colorSchemeSeed: AppColors.primary,
      scaffoldBackgroundColor: AppColors.surfaceLight,
      cardColor: AppColors.cardLight,
      appBarTheme: const AppBarTheme(
        backgroundColor: AppColors.surfaceLight,
        foregroundColor: AppColors.textPrimaryLight,
        elevation: 0,
        scrolledUnderElevation: 1,
      ),
      drawerTheme: const DrawerThemeData(
        backgroundColor: AppColors.cardLight,
      ),
      tabBarTheme: const TabBarTheme(
        labelColor: AppColors.tabActiveLight,
        unselectedLabelColor: AppColors.tabInactiveLight,
        indicatorColor: AppColors.tabActiveLight,
      ),
      textTheme: const TextTheme(
        bodyLarge: TextStyle(color: AppColors.textPrimaryLight),
        bodyMedium: TextStyle(color: AppColors.textPrimaryLight),
        bodySmall: TextStyle(color: AppColors.textSecondaryLight),
      ),
      dividerColor: Colors.black12,
    );
  }

  static ThemeData dark() {
    return ThemeData(
      useMaterial3: true,
      brightness: Brightness.dark,
      colorSchemeSeed: AppColors.primary,
      scaffoldBackgroundColor: AppColors.surfaceDark,
      cardColor: AppColors.cardDark,
      appBarTheme: const AppBarTheme(
        backgroundColor: AppColors.surfaceDark,
        foregroundColor: AppColors.textPrimaryDark,
        elevation: 0,
        scrolledUnderElevation: 1,
      ),
      drawerTheme: const DrawerThemeData(
        backgroundColor: AppColors.cardDark,
      ),
      tabBarTheme: const TabBarTheme(
        labelColor: AppColors.tabActiveDark,
        unselectedLabelColor: AppColors.tabInactiveDark,
        indicatorColor: AppColors.tabActiveDark,
      ),
      textTheme: const TextTheme(
        bodyLarge: TextStyle(color: AppColors.textPrimaryDark),
        bodyMedium: TextStyle(color: AppColors.textPrimaryDark),
        bodySmall: TextStyle(color: AppColors.textSecondaryDark),
      ),
      dividerColor: Colors.white12,
    );
  }
}
