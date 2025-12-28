import 'package:flutter/material.dart';
import 'package:juix_na/app/app_colors.dart';

/// Info Badge Widget - Small badge for counts, tags, status indicators
///
/// Reusable for notification counts, "Coming Soon" tags, "NO ACCESS" badges, etc.
/// Supports customization of colors, sizes, and shapes.
class InfoBadge extends StatelessWidget {
  final String text;
  final Color? backgroundColor;
  final Color? textColor;
  final double? fontSize;
  final FontWeight? fontWeight;
  final EdgeInsets? padding;
  final double? borderRadius;
  final double? minSize; // Minimum width/height for circular badges

  const InfoBadge({
    super.key,
    required this.text,
    this.backgroundColor,
    this.textColor,
    this.fontSize,
    this.fontWeight,
    this.padding,
    this.borderRadius,
    this.minSize,
  });

  /// Factory constructor for notification badge (red dot with count)
  factory InfoBadge.notification({required int count, Key? key}) {
    return InfoBadge(
      key: key,
      text: count > 99 ? '99+' : count.toString(),
      backgroundColor: AppColors.error,
      textColor: Colors.white,
      fontSize: 10,
      fontWeight: FontWeight.w700,
      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
      borderRadius: 999,
      minSize: count > 9 ? 20 : 16,
    );
  }

  /// Factory constructor for "Coming Soon" tag (green)
  factory InfoBadge.comingSoon({Key? key}) {
    return InfoBadge(
      key: key,
      text: 'Coming Soon',
      backgroundColor: AppColors.success.withOpacity(0.15),
      textColor: AppColors.success,
      fontSize: 10,
      fontWeight: FontWeight.w700,
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      borderRadius: 12,
    );
  }

  /// Factory constructor for "Soon" tag (green, smaller)
  factory InfoBadge.soon({Key? key}) {
    return InfoBadge(
      key: key,
      text: 'Soon',
      backgroundColor: AppColors.success.withOpacity(0.15),
      textColor: AppColors.success,
      fontSize: 9,
      fontWeight: FontWeight.w700,
      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 3),
      borderRadius: 10,
    );
  }

  /// Factory constructor for "NO ACCESS" badge (gray)
  factory InfoBadge.noAccess({Key? key}) {
    return InfoBadge(
      key: key,
      text: 'NO ACCESS',
      backgroundColor: AppColors.textMuted.withOpacity(0.15),
      textColor: AppColors.textMuted,
      fontSize: 9,
      fontWeight: FontWeight.w700,
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      borderRadius: 8,
    );
  }

  @override
  Widget build(BuildContext context) {
    final bg = backgroundColor ?? AppColors.mango;
    final tColor = textColor ?? Colors.white;
    final radius = borderRadius ?? 999.0; // Default to fully rounded
    final min = minSize ?? 0.0;

    Widget content = Container(
      padding:
          padding ?? const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      constraints: min > 0
          ? BoxConstraints(minWidth: min, minHeight: min)
          : null,
      decoration: BoxDecoration(
        color: bg,
        borderRadius: BorderRadius.circular(radius),
      ),
      child: Center(
        child: Text(
          text,
          style: TextStyle(
            color: tColor,
            fontSize: fontSize ?? 11,
            fontWeight: fontWeight ?? FontWeight.w700,
          ),
          textAlign: TextAlign.center,
        ),
      ),
    );

    return content;
  }
}

/// Notification Dot - Small red dot for unread notifications
class NotificationDot extends StatelessWidget {
  final double size;

  const NotificationDot({super.key, this.size = 8});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: size,
      height: size,
      decoration: const BoxDecoration(
        color: AppColors.error,
        shape: BoxShape.circle,
      ),
    );
  }
}
