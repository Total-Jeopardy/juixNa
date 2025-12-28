import 'package:flutter/material.dart';
import 'package:juix_na/app/app_colors.dart';

/// Selector Button Widget - Button that opens a picker/modal (e.g., location, date, filter)
///
/// Reusable for dropdown selectors, filter buttons, etc.
/// Supports customization of colors, icons, and layout.
class SelectorButton extends StatelessWidget {
  final String label;
  final IconData? leadingIcon;
  final IconData? trailingIcon; // Default: expand_more or keyboard_arrow_down
  final VoidCallback onTap;
  final Color? backgroundColor;
  final Color? borderColor;
  final Color? textColor;
  final Color? iconColor;
  final EdgeInsets? padding;
  final double? borderRadius;
  final double? fontSize;
  final FontWeight? fontWeight;

  const SelectorButton({
    super.key,
    required this.label,
    this.leadingIcon,
    this.trailingIcon,
    required this.onTap,
    this.backgroundColor,
    this.borderColor,
    this.iconColor,
    this.textColor,
    this.padding,
    this.borderRadius,
    this.fontSize,
    this.fontWeight,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    // Default colors
    final bg = backgroundColor ?? (isDark ? AppColors.darkCard : Colors.white);
    final border = borderColor ?? Colors.transparent;
    final tColor =
        textColor ?? (isDark ? AppColors.darkTextMuted : AppColors.textMuted);
    final iColor =
        iconColor ?? (isDark ? AppColors.darkTextPrimary : AppColors.deepGreen);
    final radius = borderRadius ?? 16.0;
    final trailing = trailingIcon ?? Icons.expand_more_rounded;

    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(radius),
      child: Container(
        padding:
            padding ?? const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
        decoration: BoxDecoration(
          color: bg,
          borderRadius: BorderRadius.circular(radius),
          border: border != Colors.transparent
              ? Border.all(color: border)
              : null,
          boxShadow: const [
            BoxShadow(
              color: AppColors.shadowSoft,
              blurRadius: 4,
              offset: Offset(0, 2),
            ),
          ],
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            if (leadingIcon != null) ...[
              Icon(leadingIcon, color: iColor, size: 18),
              const SizedBox(width: 8),
            ],
            // Label text
            Flexible(
              child: Text(
                label,
                style: TextStyle(
                  color: tColor,
                  fontWeight: fontWeight ?? FontWeight.w700,
                  fontSize: fontSize ?? 13,
                ),
                overflow: TextOverflow.ellipsis,
                maxLines: 1,
              ),
            ),
            const SizedBox(width: 4),
            // Trailing icon (dropdown indicator)
            Icon(trailing, color: iColor, size: 18),
          ],
        ),
      ),
    );
  }
}
