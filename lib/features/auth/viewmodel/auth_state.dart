import '../model/user_models.dart';

/// Authentication state for the app.
/// Sealed class pattern for type-safe state management.
sealed class AuthState {
  const AuthState();
}

/// Initial state - app just started, checking authentication status.
class AuthStateInitial extends AuthState {
  const AuthStateInitial();
}

/// Loading state - authentication operation in progress (login, checking token, etc.).
class AuthStateLoading extends AuthState {
  const AuthStateLoading();
}

/// Authenticated state - user is logged in.
class AuthStateAuthenticated extends AuthState {
  final User user;

  const AuthStateAuthenticated(this.user);

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is AuthStateAuthenticated &&
          runtimeType == other.runtimeType &&
          user == other.user;

  @override
  int get hashCode => user.hashCode;
}

/// Unauthenticated state - no user logged in.
class AuthStateUnauthenticated extends AuthState {
  const AuthStateUnauthenticated();
}

/// Error state - authentication operation failed.
class AuthStateError extends AuthState {
  final String message;
  final String? details;

  const AuthStateError(this.message, {this.details});

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is AuthStateError &&
          runtimeType == other.runtimeType &&
          message == other.message &&
          details == other.details;

  @override
  int get hashCode => message.hashCode ^ (details?.hashCode ?? 0);
}

/// Extension methods for convenient state checking.
extension AuthStateExtensions on AuthState {
  /// Check if state is authenticated.
  bool get isAuthenticated => this is AuthStateAuthenticated;

  /// Check if state is loading.
  bool get isLoading => this is AuthStateLoading;

  /// Check if state is error.
  bool get isError => this is AuthStateError;

  /// Check if state is unauthenticated.
  bool get isUnauthenticated => this is AuthStateUnauthenticated;

  /// Get user if authenticated, null otherwise.
  User? get userOrNull {
    if (this is AuthStateAuthenticated) {
      return (this as AuthStateAuthenticated).user;
    }
    return null;
  }

  /// Get error message if error state, null otherwise.
  String? get errorMessage {
    if (this is AuthStateError) {
      return (this as AuthStateError).message;
    }
    return null;
  }
}


