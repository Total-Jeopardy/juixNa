import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:juix_na/app/app_colors.dart';

/// Reusable error overlay component that displays a modal error message
/// with blurred backdrop. Blocks interactions behind it.
///
/// Used to display blocking errors that require user action (e.g., retry).
class ErrorOverlay extends StatelessWidget {
  /// Title/headline for the error message
  final String title;

  /// Detailed error message/body copy
  final String message;

  /// Callback when "Try Again" button is pressed
  final VoidCallback onRetry;

  /// Optional secondary action label (e.g., "Open Inventory")
  final String? secondaryLabel;

  /// Optional callback for secondary action
  final VoidCallback? onSecondary;

  /// Optional text for footer (e.g., "Last successful update: 2m ago")
  final String? lastUpdatedText;

  /// Optional callback to dismiss the overlay (e.g., tap outside)
  /// If null, overlay cannot be dismissed without taking an action
  final VoidCallback? onDismiss;

  const ErrorOverlay({
    super.key,
    required this.title,
    required this.message,
    required this.onRetry,
    this.secondaryLabel,
    this.onSecondary,
    this.lastUpdatedText,
    this.onDismiss,
  });

  @override
  Widget build(BuildContext context) {
    return BackdropFilter(
      filter: ImageFilter.blur(sigmaX: 5, sigmaY: 5),
      child: GestureDetector(
        onTap: onDismiss,
        child: Container(
          color: Colors.black.withOpacity(0.3),
          child: Center(
            child: GestureDetector(
              onTap: () {}, // Prevent tap through to backdrop
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 32),
                child: ConstrainedBox(
                  constraints: const BoxConstraints(maxWidth: 320),
                  child: _ErrorCard(
                    title: title,
                    message: message,
                    onRetry: onRetry,
                    secondaryLabel: secondaryLabel,
                    onSecondary: onSecondary,
                    lastUpdatedText: lastUpdatedText,
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

/// Error card content
class _ErrorCard extends StatelessWidget {
  final String title;
  final String message;
  final VoidCallback onRetry;
  final String? secondaryLabel;
  final VoidCallback? onSecondary;
  final String? lastUpdatedText;

  const _ErrorCard({
    required this.title,
    required this.message,
    required this.onRetry,
    this.secondaryLabel,
    this.onSecondary,
    this.lastUpdatedText,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // Error icon in light peach circle
          Container(
            width: 90,
            height: 90,
            decoration: BoxDecoration(
              color: const Color(0xFFFFE5D6), // Light peach background
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(
              Icons.cloud_off_outlined,
              size: 48,
              color: AppColors.mango.withOpacity(0.7), // Muted orange
            ),
          ),

          const SizedBox(height: 18),

          // Headline
          Text(
            title,
            style: Theme.of(context).textTheme.titleLarge?.copyWith(
              fontWeight: FontWeight.bold,
              color: AppColors.deepGreen,
              fontSize: 18,
            ),
            textAlign: TextAlign.center,
          ),

          const SizedBox(height: 9),

          // Body copy
          Text(
            message,
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
              color: AppColors.textSecondary,
              fontSize: 13,
              height: 1.5,
            ),
            textAlign: TextAlign.center,
          ),

          const SizedBox(height: 24),

          // Primary CTA button "Try Again" with gradient (orange to yellow)
          Container(
            width: double.infinity,
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [
                  AppColors.mango, // Orange
                  const Color(0xFFFFBD3B), // Yellow
                ],
                begin: Alignment.centerLeft,
                end: Alignment.centerRight,
              ),
              borderRadius: BorderRadius.circular(12),
            ),
            child: ElevatedButton(
              onPressed: onRetry,
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.transparent,
                shadowColor: Colors.transparent,
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(vertical: 12),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                elevation: 0,
              ),
              child: const Text(
                'Try Again',
                style: TextStyle(fontSize: 15, fontWeight: FontWeight.w600),
              ),
            ),
          ),

          // Secondary CTA button (optional)
          if (secondaryLabel != null && onSecondary != null) ...[
            const SizedBox(height: 12),
            TextButton(
              onPressed: onSecondary,
              style: TextButton.styleFrom(
                padding: const EdgeInsets.symmetric(vertical: 6),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    secondaryLabel!,
                    style: TextStyle(
                      color: AppColors.mango,
                      fontSize: 13,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                  const SizedBox(width: 4),
                  Icon(Icons.arrow_forward, size: 16, color: AppColors.mango),
                ],
              ),
            ),
          ],

          // Footer with last updated text (optional)
          if (lastUpdatedText != null) ...[
            const SizedBox(height: 16),
            Padding(
              padding: const EdgeInsets.only(top: 8),
              child: Text(
                lastUpdatedText!,
                style: TextStyle(
                  color: AppColors.textSecondary.withOpacity(0.7),
                  fontSize: 11,
                  fontWeight: FontWeight.w400,
                ),
                textAlign: TextAlign.center,
              ),
            ),
          ],
        ],
      ),
    );
  }
}
