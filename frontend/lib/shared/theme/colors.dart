import 'package:flutter/material.dart';

/// 暖色调主题色板 — 琥珀/金色主色，参考 Koodo Reader 对比布局
class AppColors {
  AppColors._();

  // ── Primary: 琥珀色系 ──
  static const Color primary = Color(0xFFF59E0B);
  static const Color primaryLight = Color(0xFFFCD34D);
  static const Color primaryDark = Color(0xFFD97706);

  // ── Light Theme ──
  static const Color lightBackground = Color(0xFFFFFBF5);
  static const Color lightSurface = Color(0xFFFFF7ED);
  static const Color lightCard = Color(0xFFFFFFFF);
  static const Color lightTextPrimary = Color(0xFF3D2B1F);
  static const Color lightTextSecondary = Color(0xFF8B7355);
  static const Color lightTextHint = Color(0xFFB8A68E);
  static const Color lightDivider = Color(0xFFE8DFD3);
  static const Color lightSidebar = Color(0xFF2C2520);
  static const Color lightSidebarText = Color(0xFFF5F0EB);
  static const Color lightSidebarActive = Color(0xFFF59E0B);
  static const Color lightStatusBar = Color(0xFFF5F0EB);

  // ── Dark Theme ──
  static const Color darkBackground = Color(0xFF1A1614);
  static const Color darkSurface = Color(0xFF242019);
  static const Color darkCard = Color(0xFF2C2520);
  static const Color darkTextPrimary = Color(0xFFF5F0EB);
  static const Color darkTextSecondary = Color(0xFFA89882);
  static const Color darkTextHint = Color(0xFF6B5E50);
  static const Color darkDivider = Color(0xFF3D362F);
  static const Color darkSidebar = Color(0xFF0F0D0B);
  static const Color darkSidebarText = Color(0xFFD4C8B8);
  static const Color darkSidebarActive = Color(0xFFFBBF24);
  static const Color darkStatusBar = Color(0xFF0F0D0B);

  // ── Semantic ──
  static const Color error = Color(0xFFDC2626);
  static const Color success = Color(0xFF16A34A);
  static const Color warning = Color(0xFFEA580C);
  static const Color info = Color(0xFF2563EB);

  // ── Glass ──
  static const Color glassLight = Color(0x33FFFFFF);
  static const Color glassDark = Color(0x1A0F0D0B);
}
