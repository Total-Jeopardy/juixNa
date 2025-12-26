import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:juix_na/features/auth/view/screens/login_screen.dart';
import 'package:juix_na/features/auth/viewmodel/auth_state.dart';
import 'package:juix_na/features/auth/viewmodel/auth_vm.dart';

/// Auth guard widget that shows appropriate screen based on authentication status.
///
/// - If authenticated: shows [authenticatedChild]
/// - If unauthenticated: shows [LoginScreen]
/// - If loading: shows loading indicator
class AuthGuard extends ConsumerWidget {
  final Widget authenticatedChild;

  const AuthGuard({super.key, required this.authenticatedChild});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final authState = ref.watch(authViewModelProvider);

    return authState.when(
      data: (state) {
        if (state.isAuthenticated) {
          return authenticatedChild;
        } else {
          return const LoginScreen();
        }
      },
      loading: () =>
          const Scaffold(body: Center(child: CircularProgressIndicator())),
      error: (error, stack) => Scaffold(
        body: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(Icons.error_outline, size: 48, color: Colors.red),
              const SizedBox(height: 16),
              Text('Error: ${error.toString()}'),
              const SizedBox(height: 16),
              ElevatedButton(
                onPressed: () {
                  // Retry by refreshing auth state
                  ref.invalidate(authViewModelProvider);
                },
                child: const Text('Retry'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

/// Helper function to check if user is authenticated.
/// Useful for conditional navigation or UI rendering.
bool isUserAuthenticated(WidgetRef ref) {
  final authState = ref.read(authViewModelProvider);
  return authState.value?.isAuthenticated ?? false;
}

/// Helper function to require authentication.
/// Throws if user is not authenticated (for use in protected functions).
void requireAuthentication(WidgetRef ref) {
  if (!isUserAuthenticated(ref)) {
    throw Exception('User must be authenticated to perform this action');
  }
}
