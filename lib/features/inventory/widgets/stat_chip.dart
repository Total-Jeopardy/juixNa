import 'package:flutter/material.dart';
import 'package:juix_na/app/app_colors.dart';

class StatChip extends StatelessWidget {
  final String title;
  final String value;
  final String? suffix;
  final Color? background;
  final Gradient? backgroundGradient;
  final Color? borderColor;
  final Color? titleColor;
  final Color? valueColor;
  final Color? suffixColor;

  const StatChip({
    super.key,
    required this.title,
    required this.value,
    this.suffix,
    this.background,
    this.backgroundGradient,
    this.borderColor,
    this.titleColor,
    this.valueColor,
    this.suffixColor,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final bg = background ??
        (isDark ? AppColors.darkPill : AppColors.surface);

    final tColor = titleColor ??
        (isDark ? AppColors.darkTextMuted : AppColors.textMuted);
    final vColor = valueColor ??
        (isDark ? AppColors.darkTextPrimary : AppColors.deepGreen);
    final sColor = suffixColor ??
        (isDark ? AppColors.mangoLight : AppColors.mango);

    return DecoratedBox(
      decoration: BoxDecoration(
        color: backgroundGradient == null ? bg : null,
        gradient: backgroundGradient,
        borderRadius: BorderRadius.circular(40),
        border: borderColor != null ? Border.all(color: borderColor!) : null,
        boxShadow: const [
          BoxShadow(
            color: AppColors.shadowSoft,
            blurRadius: 10,
            offset: Offset(0, 3),
          ),
        ],
      ),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              title,
              style: TextStyle(
                color: tColor,
                fontSize: 13,
                fontWeight: FontWeight.w700,
                letterSpacing: 0.2,
              ),
            ),
            const SizedBox(height: 6),
            Row(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                Text(
                  value,
                  style: TextStyle(
                    color: vColor,
                    fontSize: 24,
                    fontWeight: FontWeight.w800,
                  ),
                ),
                if (suffix != null) ...[
                  const SizedBox(width: 6),
                  Text(
                    suffix!,
                    style: TextStyle(
                      color: sColor,
                      fontSize: 12,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ],
              ],
            ),
          ],
        ),
      ),
    );
  }
}
