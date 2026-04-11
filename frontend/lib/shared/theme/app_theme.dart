import 'package:flutter/material.dart';
import 'colors.dart';

class AppTheme {
  AppTheme._();

  static const String _fontFamily = 'Noto Sans SC';

  static ThemeData light() {
    final scheme = ColorScheme.fromSeed(
      seedColor: AppColors.primary,
      brightness: Brightness.light,
      primary: AppColors.primary,
      surface: AppColors.lightSurface,
      onSurface: AppColors.lightTextPrimary,
    );
    return ThemeData(
      useMaterial3: true,
      brightness: Brightness.light,
      colorScheme: scheme,
      scaffoldBackgroundColor: AppColors.lightBackground,
      cardColor: AppColors.lightCard,
      fontFamily: _fontFamily,
      appBarTheme: AppBarTheme(
        backgroundColor: AppColors.lightBackground,
        foregroundColor: AppColors.lightTextPrimary,
        elevation: 0,
        scrolledUnderElevation: 1,
        surfaceTintColor: Colors.transparent,
      ),
      drawerTheme: const DrawerThemeData(
        backgroundColor: AppColors.lightSidebar,
      ),
      navigationRailTheme: const NavigationRailThemeData(
        backgroundColor: AppColors.lightSidebar,
        selectedIconTheme: IconThemeData(color: AppColors.lightSidebarActive),
        unselectedIconTheme: IconThemeData(color: AppColors.lightSidebarText),
        indicatorColor: Color(0x33F59E0B),
      ),
      tabBarTheme: const TabBarThemeData(
        labelColor: AppColors.primary,
        unselectedLabelColor: AppColors.lightTextHint,
        indicatorColor: AppColors.primary,
      ),
      floatingActionButtonTheme: const FloatingActionButtonThemeData(
        backgroundColor: AppColors.primary,
        foregroundColor: AppColors.lightTextPrimary,
      ),
      dividerColor: AppColors.lightDivider,
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: AppColors.lightSurface,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
          borderSide: BorderSide(color: AppColors.lightDivider),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
          borderSide: BorderSide(color: AppColors.lightDivider),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
          borderSide: const BorderSide(color: AppColors.primary, width: 1.5),
        ),
        hintStyle: TextStyle(color: AppColors.lightTextHint),
      ),
    );
  }

  static ThemeData dark() {
    final scheme = ColorScheme.fromSeed(
      seedColor: const Color(0xFFFBBF24),
      brightness: Brightness.dark,
      primary: const Color(0xFFFBBF24),
      surface: AppColors.darkSurface,
      onSurface: AppColors.darkTextPrimary,
    );
    return ThemeData(
      useMaterial3: true,
      brightness: Brightness.dark,
      colorScheme: scheme,
      scaffoldBackgroundColor: AppColors.darkBackground,
      cardColor: AppColors.darkCard,
      fontFamily: _fontFamily,
      appBarTheme: AppBarTheme(
        backgroundColor: AppColors.darkBackground,
        foregroundColor: AppColors.darkTextPrimary,
        elevation: 0,
        scrolledUnderElevation: 1,
        surfaceTintColor: Colors.transparent,
      ),
      drawerTheme: const DrawerThemeData(
        backgroundColor: AppColors.darkSidebar,
      ),
      navigationRailTheme: const NavigationRailThemeData(
        backgroundColor: AppColors.darkSidebar,
        selectedIconTheme: IconThemeData(color: AppColors.darkSidebarActive),
        unselectedIconTheme: IconThemeData(color: AppColors.darkSidebarText),
        indicatorColor: Color(0x33FBBF24),
      ),
      tabBarTheme: const TabBarThemeData(
        labelColor: Color(0xFFFBBF24),
        unselectedLabelColor: AppColors.darkTextHint,
        indicatorColor: Color(0xFFFBBF24),
      ),
      floatingActionButtonTheme: const FloatingActionButtonThemeData(
        backgroundColor: Color(0xFFFBBF24),
        foregroundColor: AppColors.darkTextPrimary,
      ),
      dividerColor: AppColors.darkDivider,
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: AppColors.darkSurface,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
          borderSide: BorderSide(color: AppColors.darkDivider),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
          borderSide: BorderSide(color: AppColors.darkDivider),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
          borderSide: const BorderSide(color: Color(0xFFFBBF24), width: 1.5),
        ),
        hintStyle: TextStyle(color: AppColors.darkTextHint),
      ),
    );
  }
}
