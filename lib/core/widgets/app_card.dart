import 'package:flutter/material.dart';
import 'package:juix_na/app/app_colors.dart';

/// App Card Widget - Base card container with consistent styling
///
/// Reusable for cards throughout the app. Supports customization of colors, borders, shadows, and padding.
class AppCard extends StatelessWidget {
  final Widget child;
  final Color? backgroundColor;
  final Color? borderColor;
  final double? borderWidth;
  final double? borderRadius;
  final List<BoxShadow>? boxShadow;
  final EdgeInsets? padding;
  final EdgeInsets? margin;
  final VoidCallback? onTap; // Makes card tappable
  final double? elevation;

  const AppCard({
    super.key,
    required this.child,
    this.backgroundColor,
    this.borderColor,
    this.borderWidth,
    this.borderRadius,
    this.boxShadow,
    this.padding,
    this.margin,
    this.onTap,
    this.elevation,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    // Default colors
    final bg =
        backgroundColor ?? (isDark ? AppColors.darkCard : AppColors.surface);
    final border =
        borderColor ??
        (isDark ? AppColors.borderSoft.withOpacity(0.3) : AppColors.borderSoft);
    final radius = borderRadius ?? 18.0;
    final width = borderWidth ?? 1.0;
    final shadow =
        boxShadow ??
        (elevation != null && elevation! > 0
            ? [
                BoxShadow(
                  color: AppColors.shadowSoft,
                  blurRadius: elevation! * 2,
                  offset: Offset(0, elevation!),
                ),
              ]
            : const [
                BoxShadow(
                  color: AppColors.shadowSoft,
                  blurRadius: 10,
                  offset: Offset(0, 4),
                ),
              ]);

    Widget content = Container(
      padding: padding ?? const EdgeInsets.all(16),
      margin: margin,
      decoration: BoxDecoration(
        color: bg,
        borderRadius: BorderRadius.circular(radius),
        border: borderColor != null
            ? Border.all(color: border, width: width)
            : null,
        boxShadow: shadow,
      ),
      child: child,
    );

    if (onTap != null) {
      return InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(radius),
        child: content,
      );
    }

    return content;
  }
}
