import 'package:flutter/material.dart';
import 'package:juix_na/app/app_colors.dart';

/// Status Chip Widget - Displays status information with icon, text, and optional timestamp
///
/// Reusable for online/offline indicators, sync status, connection status, etc.
/// Supports customization of colors, icons, and layout.
class StatusChip extends StatelessWidget {
  final String label;
  final IconData? icon;
  final Color? iconColor;
  final Color? backgroundColor;
  final Color? textColor;
  final String? timestamp; // e.g., "2m ago", "Last updated 10:30 AM"
  final EdgeInsets? padding;
  final double? borderRadius;
  final double? iconSize;
  final double? fontSize;

  const StatusChip({
    super.key,
    required this.label,
    this.icon,
    this.iconColor,
    this.backgroundColor,
    this.textColor,
    this.timestamp,
    this.padding,
    this.borderRadius,
    this.iconSize,
    this.fontSize,
  });

  /// Factory constructor for online status
  factory StatusChip.online({String? timestamp, Key? key}) {
    return StatusChip(
      key: key,
      label: 'ONLINE',
      icon: Icons.wifi_rounded,
      iconColor: AppColors.success,
      backgroundColor: AppColors.success.withOpacity(0.15),
      textColor: AppColors.success,
      timestamp: timestamp,
    );
  }

  /// Factory constructor for offline status
  factory StatusChip.offline({String? timestamp, Key? key}) {
    return StatusChip(
      key: key,
      label: 'OFFLINE',
      icon: Icons.wifi_off_rounded,
      iconColor: AppColors.error,
      backgroundColor: AppColors.error.withOpacity(0.15),
      textColor: AppColors.error,
      timestamp: timestamp,
    );
  }

  /// Factory constructor for updating/syncing status
  factory StatusChip.updating({Key? key}) {
    return StatusChip(
      key: key,
      label: 'UPDATING...',
      icon: Icons.sync_rounded,
      iconColor: AppColors.mango,
      backgroundColor: AppColors.mango.withOpacity(0.15),
      textColor: AppColors.mango,
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    // Default colors
    final bg =
        backgroundColor ?? (isDark ? AppColors.darkPill : AppColors.surface);
    final tColor =
        textColor ?? (isDark ? AppColors.darkTextPrimary : AppColors.deepGreen);
    final iColor = iconColor ?? tColor;
    final radius = borderRadius ?? 16.0;
    final iSize = iconSize ?? 14.0;
    final fSize = fontSize ?? 11.0;

    return Container(
      padding:
          padding ?? const EdgeInsets.symmetric(horizontal: 10, vertical: 10),
      decoration: BoxDecoration(
        color: bg,
        borderRadius: BorderRadius.circular(radius),
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
          if (icon != null) ...[
            Icon(icon, color: iColor, size: iSize),
            const SizedBox(width: 6),
          ],
          // Status label
          Text(
            label,
            style: TextStyle(
              color: tColor,
              fontWeight: FontWeight.w700,
              fontSize: fSize,
              letterSpacing: 0.3,
            ),
          ),
          // Timestamp (separated with bullet)
          if (timestamp != null) ...[
            const SizedBox(width: 4),
            Text(
              '\u2022', // Unicode bullet
              style: TextStyle(color: tColor.withOpacity(0.5), fontSize: fSize),
            ),
            const SizedBox(width: 4),
            Flexible(
              child: Text(
                timestamp!,
                style: TextStyle(
                  color: tColor.withOpacity(0.8),
                  fontWeight: FontWeight.w500,
                  fontSize: fSize - 1,
                ),
                overflow: TextOverflow.ellipsis,
              ),
            ),
          ],
        ],
      ),
    );
  }
}
