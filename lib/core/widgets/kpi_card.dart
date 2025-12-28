import 'package:flutter/material.dart';
import 'package:juix_na/app/app_colors.dart';

/// KPI Card Widget - Displays a key performance indicator with optional trend indicator
///
/// Reusable for dashboard KPIs like Total Sales, Total Expenses, etc.
/// Supports customization of colors, icons, trend indicators, and tap actions.
class KPICard extends StatelessWidget {
  final String title;
  final String value;
  final String? suffix; // e.g., "+15%", "vs last week"
  final IconData? icon;
  final Color? iconColor;
  final Color? backgroundColor;
  final Color? borderColor;
  final Color? titleColor;
  final Color? valueColor;
  final Color? suffixColor;
  final Gradient? backgroundGradient;
  final bool showTrendUp; // Show green upward arrow
  final bool showTrendDown; // Show red downward arrow
  final VoidCallback? onTap;
  final EdgeInsets? padding;
  final double? borderRadius;

  const KPICard({
    super.key,
    required this.title,
    required this.value,
    this.suffix,
    this.icon,
    this.iconColor,
    this.backgroundColor,
    this.borderColor,
    this.titleColor,
    this.valueColor,
    this.suffixColor,
    this.backgroundGradient,
    this.showTrendUp = false,
    this.showTrendDown = false,
    this.onTap,
    this.padding,
    this.borderRadius,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    // Default colors based on theme
    final bg =
        backgroundColor ?? (isDark ? AppColors.darkCard : AppColors.surface);
    final tColor =
        titleColor ?? (isDark ? AppColors.darkTextMuted : AppColors.textMuted);
    final vColor =
        valueColor ??
        (isDark ? AppColors.darkTextPrimary : AppColors.deepGreen);
    final sColor =
        suffixColor ?? (isDark ? AppColors.mangoLight : AppColors.mango);
    final iconBgColor =
        iconColor ?? (isDark ? AppColors.mango : AppColors.mango);
    final border =
        borderColor ??
        (isDark ? AppColors.borderSoft.withOpacity(0.3) : AppColors.borderSoft);
    final radius = borderRadius ?? 18.0;

    Widget content = DecoratedBox(
      decoration: BoxDecoration(
        color: backgroundGradient == null ? bg : null,
        gradient: backgroundGradient,
        borderRadius: BorderRadius.circular(radius),
        border: borderColor != null ? Border.all(color: border) : null,
        boxShadow: const [
          BoxShadow(
            color: AppColors.shadowSoft,
            blurRadius: 10,
            offset: Offset(0, 3),
          ),
        ],
      ),
      child: Padding(
        padding: padding ?? const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: [
            // Title and Icon Row
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Expanded(
                  child: Text(
                    title,
                    style: TextStyle(
                      color: tColor,
                      fontSize: 12,
                      fontWeight: FontWeight.w700,
                      letterSpacing: 0.2,
                    ),
                  ),
                ),
                if (icon != null)
                  Container(
                    width: 32,
                    height: 32,
                    decoration: BoxDecoration(
                      color: iconBgColor.withOpacity(0.15),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Icon(icon, color: iconBgColor, size: 18),
                  ),
              ],
            ),
            const SizedBox(height: 12),
            // Value Row
            Row(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                Text(
                  value,
                  style: TextStyle(
                    color: vColor,
                    fontSize: 28,
                    fontWeight: FontWeight.w800,
                  ),
                ),
                if (suffix != null) ...[
                  const SizedBox(width: 8),
                  Flexible(
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        if (showTrendUp)
                          const Icon(
                            Icons.arrow_upward_rounded,
                            size: 16,
                            color: AppColors.success,
                          )
                        else if (showTrendDown)
                          const Icon(
                            Icons.arrow_downward_rounded,
                            size: 16,
                            color: AppColors.error,
                          ),
                        Text(
                          suffix!,
                          style: TextStyle(
                            color: sColor,
                            fontSize: 12,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ],
            ),
          ],
        ),
      ),
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
