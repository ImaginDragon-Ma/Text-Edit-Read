import 'package:flutter/material.dart';
import 'colors.dart';

/// 中文排版优化文本样式 — 行高 1.8、字间距 0.5
class AppTextStyles {
  AppTextStyles._();

  static const double _lineHeight = 1.8;
  static const double _letterSpacing = 0.5;

  // ── Light ──
  static const TextTheme light = TextTheme(
    headlineLarge: TextStyle(
      fontSize: 28,
      fontWeight: FontWeight.bold,
      color: AppColors.lightTextPrimary,
      height: _lineHeight,
      letterSpacing: _letterSpacing,
    ),
    headlineMedium: TextStyle(
      fontSize: 22,
      fontWeight: FontWeight.w600,
      color: AppColors.lightTextPrimary,
      height: _lineHeight,
      letterSpacing: _letterSpacing,
    ),
    headlineSmall: TextStyle(
      fontSize: 18,
      fontWeight: FontWeight.w600,
      color: AppColors.lightTextPrimary,
      height: _lineHeight,
      letterSpacing: _letterSpacing,
    ),
    titleLarge: TextStyle(
      fontSize: 16,
      fontWeight: FontWeight.w600,
      color: AppColors.lightTextPrimary,
      height: _lineHeight,
      letterSpacing: _letterSpacing,
    ),
    bodyLarge: TextStyle(
      fontSize: 16,
      color: AppColors.lightTextPrimary,
      height: _lineHeight,
      letterSpacing: _letterSpacing,
    ),
    bodyMedium: TextStyle(
      fontSize: 14,
      color: AppColors.lightTextPrimary,
      height: _lineHeight,
      letterSpacing: _letterSpacing,
    ),
    bodySmall: TextStyle(
      fontSize: 12,
      color: AppColors.lightTextSecondary,
      height: _lineHeight,
      letterSpacing: _letterSpacing,
    ),
    labelSmall: TextStyle(
      fontSize: 11,
      color: AppColors.lightTextHint,
      height: _lineHeight,
      letterSpacing: _letterSpacing,
    ),
  );

  // ── Dark ──
  static const TextTheme dark = TextTheme(
    headlineLarge: TextStyle(
      fontSize: 28,
      fontWeight: FontWeight.bold,
      color: AppColors.darkTextPrimary,
      height: _lineHeight,
      letterSpacing: _letterSpacing,
    ),
    headlineMedium: TextStyle(
      fontSize: 22,
      fontWeight: FontWeight.w600,
      color: AppColors.darkTextPrimary,
      height: _lineHeight,
      letterSpacing: _letterSpacing,
    ),
    headlineSmall: TextStyle(
      fontSize: 18,
      fontWeight: FontWeight.w600,
      color: AppColors.darkTextPrimary,
      height: _lineHeight,
      letterSpacing: _letterSpacing,
    ),
    titleLarge: TextStyle(
      fontSize: 16,
      fontWeight: FontWeight.w600,
      color: AppColors.darkTextPrimary,
      height: _lineHeight,
      letterSpacing: _letterSpacing,
    ),
    bodyLarge: TextStyle(
      fontSize: 16,
      color: AppColors.darkTextPrimary,
      height: _lineHeight,
      letterSpacing: _letterSpacing,
    ),
    bodyMedium: TextStyle(
      fontSize: 14,
      color: AppColors.darkTextPrimary,
      height: _lineHeight,
      letterSpacing: _letterSpacing,
    ),
    bodySmall: TextStyle(
      fontSize: 12,
      color: AppColors.darkTextSecondary,
      height: _lineHeight,
      letterSpacing: _letterSpacing,
    ),
    labelSmall: TextStyle(
      fontSize: 11,
      color: AppColors.darkTextHint,
      height: _lineHeight,
      letterSpacing: _letterSpacing,
    ),
  );

  // ── Editor-specific ──
  static const TextStyle editorBody = TextStyle(
    fontSize: 16,
    height: _lineHeight,
    letterSpacing: _letterSpacing,
  );
}
