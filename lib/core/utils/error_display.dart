import 'package:flutter/material.dart';
import 'package:juix_na/app/app_colors.dart';
import 'package:juix_na/core/network/api_result.dart';

/// Global utility for displaying API errors consistently across the app.
///
/// Provides standardized snackbars/toasts for different error types.
class ErrorDisplay {
  /// Show a standardized error snackbar based on API error type.
  ///
  /// Automatically handles different error types with appropriate styling:
  /// - Network errors: Shows retry-friendly message
  /// - Validation errors: Shows user-friendly validation message
  /// - 401 errors: Should be handled by AuthErrorHandler (auto-logout)
  /// - Server errors: Shows generic server error message
  static void showError(
    BuildContext context,
    ApiError error, {
    Duration duration = const Duration(seconds: 4),
    VoidCallback? onRetry,
  }) {
    // Don't show snackbar for 401 errors - AuthErrorHandler handles logout
    if (error.type == ApiErrorType.unauthorized) {
      return;
    }

    final message = _getErrorMessage(error);
    final backgroundColor = _getErrorColor(error.type);
    final actionLabel = onRetry != null ? 'Retry' : null;

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Row(
          children: [
            Icon(_getErrorIcon(error.type), color: Colors.white, size: 20),
            const SizedBox(width: 12),
            Expanded(
              child: Text(
                message,
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
          ],
        ),
        backgroundColor: backgroundColor,
        duration: duration,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        margin: const EdgeInsets.all(16),
        action: actionLabel != null && onRetry != null
            ? SnackBarAction(
                label: actionLabel,
                textColor: Colors.white,
                onPressed: onRetry,
              )
            : null,
      ),
    );
  }

  /// Show error from ApiResult (convenience method).
  static void showErrorFromResult<T>(
    BuildContext context,
    ApiResult<T> result, {
    Duration duration = const Duration(seconds: 4),
    VoidCallback? onRetry,
  }) {
    if (result.isFailure) {
      final failure = result as ApiFailure<T>;
      showError(context, failure.error, duration: duration, onRetry: onRetry);
    }
  }

  /// Show a success snackbar.
  static void showSuccess(
    BuildContext context,
    String message, {
    Duration duration = const Duration(seconds: 2),
  }) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Row(
          children: [
            const Icon(
              Icons.check_circle_rounded,
              color: Colors.white,
              size: 20,
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Text(
                message,
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
          ],
        ),
        backgroundColor: AppColors.success,
        duration: duration,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        margin: const EdgeInsets.all(16),
      ),
    );
  }

  /// Get user-friendly error message based on error type.
  static String _getErrorMessage(ApiError error) {
    // Use the error's message if available (may contain server-provided details)
    return error.message;
  }

  /// Get appropriate color for error type.
  static Color _getErrorColor(ApiErrorType type) {
    switch (type) {
      case ApiErrorType.network:
        return AppColors.error; // Red for network issues
      case ApiErrorType.timeout:
        return AppColors.mango; // Orange for timeouts
      case ApiErrorType.validation:
        return AppColors.mango; // Orange for validation errors
      case ApiErrorType.server:
        return AppColors.error; // Red for server errors
      case ApiErrorType.forbidden:
        return AppColors.error; // Red for permission errors
      case ApiErrorType.notFound:
        return AppColors.textMuted; // Gray for not found
      case ApiErrorType.unauthorized:
        return AppColors.error; // Red (though shouldn't be shown)
      case ApiErrorType.cancelled:
        return AppColors.textMuted; // Gray for cancelled
      case ApiErrorType.unknown:
        return AppColors.error; // Red for unknown errors
    }
  }

  /// Get appropriate icon for error type.
  static IconData _getErrorIcon(ApiErrorType type) {
    switch (type) {
      case ApiErrorType.network:
        return Icons.wifi_off_rounded;
      case ApiErrorType.timeout:
        return Icons.timer_off_rounded;
      case ApiErrorType.validation:
        return Icons.error_outline_rounded;
      case ApiErrorType.server:
        return Icons.cloud_off_rounded;
      case ApiErrorType.forbidden:
        return Icons.block_rounded;
      case ApiErrorType.notFound:
        return Icons.search_off_rounded;
      case ApiErrorType.unauthorized:
        return Icons.lock_outline_rounded;
      case ApiErrorType.cancelled:
        return Icons.cancel_outlined;
      case ApiErrorType.unknown:
        return Icons.error_outline_rounded;
    }
  }
}
