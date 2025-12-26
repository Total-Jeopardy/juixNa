import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:juix_na/core/network/api_result.dart';
import 'package:juix_na/features/auth/viewmodel/auth_vm.dart';

/// Global error handler for authentication-related API errors.
///
/// Handles 401 (Unauthorized) errors by automatically logging out the user.
/// This ensures that expired/invalid tokens trigger logout and redirect to login.
class AuthErrorHandler {
  /// Handle API result and auto-logout on 401 errors.
  ///
  /// Call this after any API call that might return 401:
  /// ```dart
  /// final result = await api.get(...);
  /// await AuthErrorHandler.handleUnauthorized(ref, result);
  /// ```
  ///
  /// If result is a 401 error, automatically logs out the user.
  ///
  /// Works with both `Ref` (for ViewModels) and `WidgetRef` (for Widgets),
  /// as `WidgetRef` extends `Ref`.
  static Future<void> handleUnauthorized<T>(
    Ref ref,
    ApiResult<T> result,
  ) async {
    if (result.isFailure) {
      final failure = result as ApiFailure<T>;
      if (failure.error.type == ApiErrorType.unauthorized) {
        // Token expired or invalid - logout user
        await ref.read(authViewModelProvider.notifier).logout();
      }
    }
  }

  /// Check if an API error is an authentication error (401).
  static bool isUnauthorizedError<T>(ApiResult<T> result) {
    if (result.isFailure) {
      final failure = result as ApiFailure<T>;
      return failure.error.type == ApiErrorType.unauthorized;
    }
    return false;
  }
}
