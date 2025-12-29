import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:juix_na/features/auth/view/screens/login_screen.dart';
import 'package:juix_na/features/auth/viewmodel/auth_state.dart';
import 'package:juix_na/features/auth/viewmodel/auth_vm.dart';
import 'package:juix_na/features/dashboard/view/screens/dashboard_screen.dart';
import 'package:juix_na/features/dashboard/view/screens/inventory_clerk_dashboard_screen.dart';
import 'package:juix_na/features/inventory/view/screens/cycle_counts_screen.dart';
import 'package:juix_na/features/inventory/view/screens/inventory_overview_screen.dart';
import 'package:juix_na/features/inventory/view/screens/reorder_alerts_screen.dart';
import 'package:juix_na/features/inventory/view/screens/stock_movement_screen.dart';
import 'package:juix_na/features/inventory/view/screens/stock_transfer_screen.dart';
import 'package:juix_na/features/inventory/view/screens/transfer_history_screen.dart';
import 'package:juix_na/features/production/view/screens/purchase_entry_screen.dart';
import 'package:juix_na/features/production/view/screens/stocking_hub_screen.dart';

/// Router configuration for the app using go_router.
/// Handles authentication guards and route definitions.
final routerProvider = Provider<GoRouter>((ref) {
  // TODO: Re-enable auth state watching when authentication is re-enabled
  // Watch auth state to determine redirects
  // final authState = ref.watch(authViewModelProvider);

  return GoRouter(
    // TODO: Re-enable authentication redirect logic when testing is complete
    // For now, bypass authentication and go straight to dashboard for testing
    initialLocation: '/dashboard',
    debugLogDiagnostics: true,
    redirect: (context, state) {
      // Temporarily disabled authentication checks for testing
      // Always allow access to dashboard and other routes
      return null;

      /* Original auth redirect logic (disabled for testing):
      // Gate redirects during loading/error states to prevent flicker
      // Wait for definitive auth state before redirecting
      if (authState.isLoading) {
        return null; // Don't redirect while loading
      }

      if (authState.hasError) {
        // On error, allow access to login page
        final isOnLoginPage = state.uri.path == '/login';
        if (!isOnLoginPage) {
          return '/login';
        }
        return null;
      }

      // Check auth state from AsyncValue (now we know it's loaded)
      final authStateValue = authState.value;
      final isAuthenticated = authStateValue?.isAuthenticated ?? false;
      final isOnLoginPage = state.uri.path == '/login';

      // If not authenticated and not on login page, redirect to login
      if (!isAuthenticated && !isOnLoginPage) {
        return '/login';
      }

      // If authenticated and on login page, redirect to dashboard
      if (isAuthenticated && isOnLoginPage) {
        return '/dashboard';
      }

      // No redirect needed
      return null;
      */
    },
    // TODO: Re-enable auth state notifier when authentication is re-enabled
    // refreshListenable: _AuthStateNotifier(ref),
    routes: [
      GoRoute(
        path: '/login',
        name: 'login',
        builder: (context, state) => const LoginScreen(),
      ),
      GoRoute(
        path: '/inventory',
        name: 'inventory',
        builder: (context, state) => const InventoryOverviewScreen(),
        routes: [
          GoRoute(
            path: 'movement',
            name: 'stock-movement',
            builder: (context, state) {
              // Optional route parameters: productId, locationId
              // These can be extracted from state.uri.queryParameters if needed
              return const StockMovementScreen();
            },
          ),
          GoRoute(
            path: 'cycle-count',
            name: 'cycle-count',
            builder: (context, state) => const CycleCountsScreen(),
          ),
          GoRoute(
            path: 'reorder-alerts',
            name: 'reorder-alerts',
            builder: (context, state) => const ReorderAlertsScreen(),
          ),
          GoRoute(
            path: 'transfer',
            name: 'stock-transfer',
            builder: (context, state) => const StockTransferScreen(),
            routes: [
              GoRoute(
                path: 'history',
                name: 'transfer-history',
                builder: (context, state) => const TransferHistoryScreen(),
              ),
            ],
          ),
        ],
      ),
      GoRoute(
        path: '/dashboard',
        name: 'dashboard',
        builder: (context, state) => const DashboardScreen(),
      ),
      GoRoute(
        path: '/dashboard/inventory-clerk',
        name: 'inventory-clerk-dashboard',
        builder: (context, state) => const InventoryClerkDashboardScreen(),
      ),
      GoRoute(
        path: '/production/stocking-hub',
        name: 'stocking-hub',
        builder: (context, state) => const StockingHubScreen(),
      ),
      GoRoute(
        path: '/production/purchase-entry',
        name: 'purchase-entry',
        builder: (context, state) => const PurchaseEntryScreen(),
      ),
    ],
    errorBuilder: (context, state) => Scaffold(
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.error_outline, size: 48, color: Colors.red),
            const SizedBox(height: 16),
            Text(
              'Page not found: ${state.uri.path}',
              style: const TextStyle(fontSize: 16),
            ),
            const SizedBox(height: 16),
            ElevatedButton(
              onPressed: () => context.go('/dashboard'),
              child: const Text('Go to Dashboard'),
            ),
          ],
        ),
      ),
    ),
  );
});

/// Listenable wrapper for auth state changes to trigger router redirects.
/// This allows go_router to react to authentication state changes.
///
/// Note: go_router's refreshListenable requires a ChangeNotifier.
/// We watch the auth provider and notify when auth state changes.
class _AuthStateNotifier extends ChangeNotifier {
  final Ref _ref;
  bool? _lastAuthState;
  ProviderSubscription<AsyncValue<AuthState>>? _subscription;

  _AuthStateNotifier(this._ref) {
    // Initialize with current auth state
    final currentState = _ref.read(authViewModelProvider);
    _lastAuthState = currentState.value?.isAuthenticated ?? false;

    // Watch auth state and notify listeners when it changes
    // Store the subscription for proper disposal
    _subscription = _ref.listen<AsyncValue<AuthState>>(authViewModelProvider, (
      previous,
      next,
    ) {
      final currentAuthState = next.value?.isAuthenticated ?? false;
      if (_lastAuthState != currentAuthState) {
        _lastAuthState = currentAuthState;
        notifyListeners();
      }
    });
  }

  @override
  void dispose() {
    // Explicitly close the subscription if it exists
    // (In practice, provider lifecycle will dispose it, but being explicit is cleaner)
    _subscription?.close();
    super.dispose();
  }
}
