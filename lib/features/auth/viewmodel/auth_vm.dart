import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:juix_na/bootstrap.dart';
import 'package:juix_na/core/network/api_result.dart';
import 'package:juix_na/features/auth/data/auth_api.dart';
import 'package:juix_na/features/auth/data/auth_repository.dart';
import 'package:juix_na/features/auth/model/user_models.dart';
import 'package:juix_na/features/auth/viewmodel/auth_state.dart';

/// Authentication ViewModel using Riverpod AsyncNotifier.
/// Manages authentication state and operations (login, logout, check status).
class AuthViewModel extends AsyncNotifier<AuthState> {
  AuthRepository? _repository;

  /// Get AuthRepository from ref (dependency injection).
  AuthRepository get _authRepository {
    _repository ??= ref.read(authRepositoryProvider);
    return _repository!;
  }

  @override
  Future<AuthState> build() async {
    // On app start, check if user is already authenticated
    return checkAuthStatus();
  }

  /// Check authentication status by verifying if token exists.
  ///
  /// For v1, we assume token is valid if it exists.
  /// In future, we could validate token with backend.
  Future<AuthState> checkAuthStatus() async {
    state = const AsyncValue.loading();

    try {
      final isAuthenticated = await _authRepository.isAuthenticated();

      if (isAuthenticated) {
        // Token exists, but we don't have user data yet
        // For v1, we'll set to unauthenticated and require re-login
        // In future, we could fetch user data from token or validate with backend
        return const AuthStateUnauthenticated();
      } else {
        return const AuthStateUnauthenticated();
      }
    } catch (e) {
      return AuthStateError(
        'Failed to check authentication status',
        details: e.toString(),
      );
    }
  }

  /// Login with email and password.
  ///
  /// Updates state to loading, then authenticated or error.
  Future<void> login({required String email, required String password}) async {
    state = const AsyncValue.loading();

    final result = await _authRepository.login(
      email: email,
      password: password,
    );

    if (result.isSuccess) {
      final success = result as ApiSuccess<User>;
      final user = success.data;
      state = AsyncValue.data(AuthStateAuthenticated(user));
    } else {
      final failure = result as ApiFailure<User>;
      final error = failure.error;
      state = AsyncValue.data(
        AuthStateError(error.message, details: error.details?.toString()),
      );
    }
  }

  /// Logout current user.
  ///
  /// Clears token and sets state to unauthenticated.
  Future<void> logout() async {
    state = const AsyncValue.loading();

    try {
      await _authRepository.logout();
      state = const AsyncValue.data(AuthStateUnauthenticated());
    } catch (e) {
      state = AsyncValue.data(
        AuthStateError('Failed to logout', details: e.toString()),
      );
    }
  }

  /// Clear error state (useful for UI to dismiss error messages).
  void clearError() {
    final currentState = state.value;
    if (currentState != null && currentState.isError) {
      state = const AsyncValue.data(AuthStateUnauthenticated());
    }
  }
}

/// Riverpod provider for AuthRepository.
/// Requires ApiClient and TokenStore providers from bootstrap.
final authRepositoryProvider = Provider<AuthRepository>((ref) {
  final apiClient = ref.watch(apiClientProvider);
  final tokenStore = ref.watch(tokenStoreProvider);
  return AuthRepository(
    authApi: AuthApi(apiClient: apiClient),
    tokenStore: tokenStore,
  );
});

/// Riverpod provider for AuthViewModel.
final authViewModelProvider = AsyncNotifierProvider<AuthViewModel, AuthState>(
  () {
    return AuthViewModel();
  },
);

/// Derived provider for current user (null if not authenticated).
final currentUserProvider = Provider<User?>((ref) {
  final authState = ref.watch(authViewModelProvider);
  return authState.value?.userOrNull;
});

/// Derived provider for authentication status (true if authenticated).
final isAuthenticatedProvider = Provider<bool>((ref) {
  final authState = ref.watch(authViewModelProvider);
  return authState.value?.isAuthenticated ?? false;
});

/// Derived provider for user roles (empty list if not authenticated).
final userRolesProvider = Provider<List<String>>((ref) {
  final user = ref.watch(currentUserProvider);
  return user?.roles ?? [];
});

/// Derived provider for user permissions (empty list if not authenticated).
final userPermissionsProvider = Provider<List<String>>((ref) {
  final user = ref.watch(currentUserProvider);
  return user?.permissions ?? [];
});
