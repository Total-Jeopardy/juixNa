import 'package:flutter/material.dart';
import 'package:juix_na/app/app_colors.dart';

/// Action Card Widget - Displays an action item with icon, title, subtitle, and optional badge
///
/// Reusable for Quick Actions, menu items, navigation cards, etc.
/// Supports customization of colors, icons, badges, and accessibility indicators.
class ActionCard extends StatelessWidget {
  final IconData icon;
  final String title;
  final String? subtitle;
  final Color? iconColor;
  final Color? backgroundColor;
  final Color? borderColor;
  final Color? titleColor;
  final Color? subtitleColor;
  final VoidCallback? onTap;
  final Widget?
  badge; // e.g., notification dot, "Coming Soon" tag, "NO ACCESS" badge
  final Widget? trailing; // e.g., chevron icon
  final EdgeInsets? padding;
  final EdgeInsets? margin;
  final double? borderRadius;
  final double? iconSize;
  final double? iconContainerSize;

  const ActionCard({
    super.key,
    required this.icon,
    required this.title,
    this.subtitle,
    this.iconColor,
    this.backgroundColor,
    this.borderColor,
    this.titleColor,
    this.subtitleColor,
    this.onTap,
    this.badge,
    this.trailing,
    this.padding,
    this.margin,
    this.borderRadius,
    this.iconSize,
    this.iconContainerSize,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    // Default colors
    final bg = backgroundColor ?? (isDark ? AppColors.darkCard : Colors.white);
    final border =
        borderColor ??
        (isDark ? AppColors.borderSoft.withOpacity(0.3) : AppColors.borderSoft);
    final iconBgColor = iconColor ?? AppColors.mango;
    final tColor =
        titleColor ??
        (isDark ? AppColors.darkTextPrimary : AppColors.deepGreen);
    final sColor =
        subtitleColor ??
        (isDark ? AppColors.darkTextMuted : AppColors.textMuted);
    final radius = borderRadius ?? 12.0;
    final iSize = iconSize ?? 24.0;
    final iContainerSize = iconContainerSize ?? 48.0;

    Widget content = Container(
      padding:
          padding ?? const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
      margin: margin ?? const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
      decoration: BoxDecoration(
        color: bg,
        borderRadius: BorderRadius.circular(radius),
        border: Border.all(color: border, width: 1),
        boxShadow: onTap != null
            ? const [
                BoxShadow(
                  color: AppColors.shadowSoft,
                  blurRadius: 4,
                  offset: Offset(0, 2),
                ),
              ]
            : null,
      ),
      child: Row(
        children: [
          // Icon Container
          Stack(
            clipBehavior: Clip.none,
            children: [
              Container(
                width: iContainerSize,
                height: iContainerSize,
                decoration: BoxDecoration(
                  color: iconBgColor.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(radius),
                ),
                child: Icon(icon, color: iconBgColor, size: iSize),
              ),
              // Badge positioned on top-right of icon
              if (badge != null) Positioned(top: -4, right: -4, child: badge!),
            ],
          ),
          const SizedBox(width: 16),
          // Title and Subtitle
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  title,
                  style: TextStyle(
                    color: tColor,
                    fontWeight: FontWeight.w700,
                    fontSize: 16,
                  ),
                ),
                if (subtitle != null) ...[
                  const SizedBox(height: 4),
                  Text(
                    subtitle!,
                    style: TextStyle(
                      color: sColor,
                      fontSize: 13,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ],
              ],
            ),
          ),
          // Trailing widget (default chevron if tappable)
          if (trailing != null)
            trailing!
          else if (onTap != null)
            const Icon(
              Icons.chevron_right,
              color: AppColors.textMuted,
              size: 20,
            ),
        ],
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
