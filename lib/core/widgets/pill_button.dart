import 'package:flutter/material.dart';
import 'package:juix_na/app/app_colors.dart';

/// Pill Button Widget - Rounded pill-shaped button with selected/unselected states
///
/// Reusable for filters, period selectors, tabs, etc.
/// Supports customization of colors, icons, badges, and sizes.
class PillButton extends StatelessWidget {
  final String label;
  final bool isSelected;
  final VoidCallback onTap;
  final Widget? leading; // Icon or widget before label
  final Widget? trailing; // Icon or widget after label (e.g., dropdown arrow)
  final Widget? badge; // Badge widget
  final Color? backgroundColor;
  final Color? selectedBackgroundColor;
  final Color? borderColor;
  final Color? selectedBorderColor;
  final Color? textColor;
  final Color? selectedTextColor;
  final EdgeInsets? padding;
  final double? borderRadius;
  final double? fontSize;
  final FontWeight? fontWeight;

  const PillButton({
    super.key,
    required this.label,
    required this.isSelected,
    required this.onTap,
    this.leading,
    this.trailing,
    this.badge,
    this.backgroundColor,
    this.selectedBackgroundColor,
    this.borderColor,
    this.selectedBorderColor,
    this.textColor,
    this.selectedTextColor,
    this.padding,
    this.borderRadius,
    this.fontSize,
    this.fontWeight,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    // Default colors based on selection state
    final bg = isSelected
        ? (selectedBackgroundColor ?? AppColors.deepGreen)
        : (backgroundColor ??
              (isDark ? AppColors.darkPill : theme.colorScheme.surface));
    final textC = isSelected
        ? (selectedTextColor ?? Colors.white)
        : (textColor ??
              (isDark ? AppColors.darkTextPrimary : AppColors.deepGreen));
    final border = isSelected
        ? (selectedBorderColor ?? Colors.transparent)
        : (borderColor ??
              (isDark
                  ? AppColors.borderSubtle.withOpacity(0.3)
                  : AppColors.borderSoft));
    final radius = borderRadius ?? 20.0;

    return InkWell(
      borderRadius: BorderRadius.circular(radius),
      onTap: onTap,
      child: DecoratedBox(
        decoration: BoxDecoration(
          color: bg,
          borderRadius: BorderRadius.circular(radius),
          border: Border.all(color: border),
          boxShadow: isSelected
              ? const [
                  BoxShadow(
                    color: AppColors.shadowSoft,
                    blurRadius: 4,
                    offset: Offset(0, 2),
                  ),
                ]
              : null,
        ),
        child: Padding(
          padding:
              padding ??
              const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              if (leading != null) ...[leading!, const SizedBox(width: 6)],
              Flexible(
                child: Text(
                  label,
                  style: TextStyle(
                    color: textC,
                    fontWeight: fontWeight ?? FontWeight.w700,
                    fontSize: fontSize ?? 14,
                  ),
                  overflow: TextOverflow.ellipsis,
                ),
              ),
              if (badge != null) ...[const SizedBox(width: 6), badge!],
              if (trailing != null && !isSelected) ...[
                const SizedBox(width: 6),
                trailing!,
              ],
            ],
          ),
        ),
      ),
    );
  }
}
