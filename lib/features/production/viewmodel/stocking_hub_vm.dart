import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:juix_na/core/auth/auth_error_handler.dart';
import 'package:juix_na/core/network/api_result.dart';
import 'package:juix_na/features/production/data/production_repository.dart';
import 'package:juix_na/features/production/model/production_models.dart';
import 'package:juix_na/features/production/viewmodel/production_providers.dart';
import 'package:juix_na/features/production/viewmodel/stocking_hub_state.dart';

/// Stocking Hub ViewModel using Riverpod AsyncNotifier.
/// Manages recent activity feed for production/inventory operations.
class StockingHubViewModel extends AsyncNotifier<StockingHubState> {
  ProductionRepository? _repository;

  /// Get ProductionRepository from ref (dependency injection).
  ProductionRepository get _productionRepository {
    _repository ??= ref.read(productionRepositoryProvider);
    return _repository!;
  }

  @override
  Future<StockingHubState> build() async {
    // On initialization, load recent activity
    return await loadRecentActivity();
  }

  /// Load recent activity feed.
  /// Preserves existing state on error.
  Future<StockingHubState> loadRecentActivity({int? limit}) async {
    final currentState = state.value ?? StockingHubState.initial();
    state = AsyncValue.data(currentState.copyWith(isLoading: true));

    try {
      final result = await _productionRepository.getRecentActivity(
        limit: limit,
      );

      // Handle 401 errors (auto-logout)
      await AuthErrorHandler.handleUnauthorized(ref, result);

      if (result.isSuccess) {
        final success = result as ApiSuccess<List<ActivityItem>>;
        final activities = success.data;

        return StockingHubState(
          recentActivity: activities,
          isLoading: false,
          error: null,
        );
      } else {
        final failure = result as ApiFailure<List<ActivityItem>>;
        // Preserve existing activity on error
        return StockingHubState(
          recentActivity: currentState.recentActivity,
          isLoading: false,
          error: failure.error.message,
        );
      }
    } catch (e) {
      // Preserve existing activity on exception
      return StockingHubState(
        recentActivity: currentState.recentActivity,
        isLoading: false,
        error: 'Failed to load activity: ${e.toString()}',
      );
    }
  }

  /// Refresh activity feed (reload from API).
  Future<void> refreshActivity() async {
    await loadRecentActivity();
  }

  /// Clear error state.
  void clearError() {
    final currentState = state.value ?? StockingHubState.initial();
    state = AsyncValue.data(currentState.copyWith(clearError: true));
  }
}

/// Riverpod provider for StockingHubViewModel.
final stockingHubProvider =
    AsyncNotifierProvider<StockingHubViewModel, StockingHubState>(() {
      return StockingHubViewModel();
    });
