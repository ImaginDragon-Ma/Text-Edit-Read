import 'dart:ui';
import 'package:flutter/material.dart';

/// 毛玻璃效果面板 — BackdropFilter + ClipRect + 半透明背景
class GlassPanel extends StatelessWidget {
  final Widget child;
  final double blur;
  final double opacity;
  final Color? tintColor;
  final BorderRadius? borderRadius;
  final EdgeInsetsGeometry? padding;
  final EdgeInsetsGeometry? margin;
  final BoxBorder? border;

  const GlassPanel({
    super.key,
    required this.child,
    this.blur = 20,
    this.opacity = 0.6,
    this.tintColor,
    this.borderRadius,
    this.padding,
    this.margin,
    this.border,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final baseColor = tintColor ??
        (isDark
            ? const Color(0x1A1A1614)
            : const Color(0x99FFFBF5));

    return Container(
      margin: margin,
      decoration: BoxDecoration(
        borderRadius: borderRadius ?? BorderRadius.circular(12),
        border: border ??
            Border.all(
              color: isDark
                  ? const Color(0x33FFFFFF)
                  : const Color(0x332C2520),
              width: 0.5,
            ),
      ),
      child: ClipRRect(
        borderRadius: borderRadius ?? BorderRadius.circular(12),
        child: BackdropFilter(
          filter: ImageFilter.blur(sigmaX: blur, sigmaY: blur),
          child: Container(
            padding: padding,
            decoration: BoxDecoration(
              color: baseColor.withOpacity(opacity),
              borderRadius: borderRadius ?? BorderRadius.circular(12),
            ),
            child: child,
          ),
        ),
      ),
    );
  }
}
