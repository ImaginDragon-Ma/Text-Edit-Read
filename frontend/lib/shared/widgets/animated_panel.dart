import 'package:flutter/material.dart';

/// 可展开/折叠的动画面板 — 弹性动画效果
class AnimatedPanel extends StatelessWidget {
  final bool isExpanded;
  final Duration duration;
  final Curve curve;
  final Widget header;
  final Widget? body;
  final VoidCallback? onToggle;
  final double collapsedHeight;
  final EdgeInsetsGeometry? padding;
  final Color? backgroundColor;
  final BorderRadius? borderRadius;

  const AnimatedPanel({
    super.key,
    required this.isExpanded,
    this.duration = const Duration(milliseconds: 400),
    this.curve = Curves.elasticOut,
    required this.header,
    this.body,
    this.onToggle,
    this.collapsedHeight = 48,
    this.padding,
    this.backgroundColor,
    this.borderRadius,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final bg = backgroundColor ?? theme.cardColor;
    final radius = borderRadius ?? BorderRadius.circular(12);

    return AnimatedContainer(
      duration: duration,
      curve: curve,
      decoration: BoxDecoration(
        color: bg,
        borderRadius: radius,
        boxShadow: isExpanded
            ? [
                BoxShadow(
                  color: theme.shadowColor.withOpacity(0.1),
                  blurRadius: 12,
                  offset: const Offset(0, 4),
                ),
              ]
            : null,
      ),
      clipBehavior: Clip.antiAlias,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          InkWell(
            onTap: onToggle,
            borderRadius: radius,
            child: Container(
              height: collapsedHeight,
              padding: padding ?? const EdgeInsets.symmetric(horizontal: 16),
              alignment: Alignment.centerLeft,
              child: Row(
                children: [
                  Expanded(child: header),
                  AnimatedRotation(
                    turns: isExpanded ? 0.5 : 0,
                    duration: duration,
                    curve: curve,
                    child: Icon(
                      Icons.chevron_right,
                      size: 20,
                      color: theme.colorScheme.onSurface.withOpacity(0.6),
                    ),
                  ),
                ],
              ),
            ),
          ),
          AnimatedCrossFade(
            firstChild: const SizedBox.shrink(),
            secondChild: body ?? const SizedBox.shrink(),
            crossFadeState:
                isExpanded ? CrossFadeState.showSecond : CrossFadeState.showFirst,
            duration: duration,
            sizeCurve: curve,
          ),
        ],
      ),
    );
  }
}
