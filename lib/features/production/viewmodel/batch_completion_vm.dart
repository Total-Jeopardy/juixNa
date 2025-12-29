import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:juix_na/core/auth/auth_error_handler.dart';
import 'package:juix_na/core/network/api_result.dart';
import 'package:juix_na/features/production/data/production_repository.dart';
import 'package:juix_na/features/production/model/production_models.dart';
import 'package:juix_na/features/production/viewmodel/batch_completion_state.dart';
import 'package:juix_na/features/production/viewmodel/production_providers.dart';

/// Batch Completion ViewModel using Riverpod AsyncNotifier.
/// Manages batch completion operations (recording actual output and wastage).
class BatchCompletionViewModel extends AsyncNotifier<BatchCompletionState> {
  ProductionRepository? _repository;

  /// Get ProductionRepository from ref (dependency injection).
  ProductionRepository get _productionRepository {
    _repository ??= ref.read(productionRepositoryProvider);
    return _repository!;
  }

  @override
  Future<BatchCompletionState> build() async {
    // Start with initial state (batch will be loaded via loadBatch)
    return BatchCompletionState.initial();
  }

  /// Load batch details by ID.
  /// Preserves existing state on error.
  Future<void> loadBatch(int id) async {
    final currentState = state.value ?? BatchCompletionState.initial();
    state = AsyncValue.data(currentState.copyWith(isLoading: true));

    try {
      final result = await _productionRepository.getBatch(id: id);

      // Handle 401 errors (auto-logout)
      await AuthErrorHandler.handleUnauthorized(ref, result);

      if (result.isSuccess) {
        final success = result as ApiSuccess<ProductionBatch>;
        final batch = success.data;

        state = AsyncValue.data(
          BatchCompletionState(
            batch: batch,
            actualOutput: null,
            wastage: null,
            isLoading: false,
            isSubmitting: false,
            error: null,
          ),
        );
      } else {
        final failure = result as ApiFailure<ProductionBatch>;
        state = AsyncValue.data(
          currentState.copyWith(error: failure.error.message, isLoading: false),
        );
      }
    } catch (e) {
      state = AsyncValue.data(
        currentState.copyWith(
          error: 'Failed to load batch: ${e.toString()}',
          isLoading: false,
        ),
      );
    }
  }

  /// Set actual output quantity.
  /// Guards against NaN and negative values.
  void setActualOutput(double output) {
    if (output.isNaN || output < 0) {
      // Don't update state if invalid value
      return;
    }
    final currentState = state.value ?? BatchCompletionState.initial();
    state = AsyncValue.data(currentState.copyWith(actualOutput: output));
  }

  /// Set wastage details.
  void setWastage(BatchWastage wastage) {
    final currentState = state.value ?? BatchCompletionState.initial();
    state = AsyncValue.data(currentState.copyWith(wastage: wastage));
  }

  /// Remove wastage (set to null).
  void removeWastage() {
    final currentState = state.value ?? BatchCompletionState.initial();
    state = AsyncValue.data(currentState.copyWith(wastage: null));
  }

  /// Calculate variance percentage (calculated from state, no API call needed).
  double? calculateVariance() {
    final currentState = state.value ?? BatchCompletionState.initial();
    return currentState.calculateVariance();
  }

  /// Complete batch (record final output and wastage).
  /// Returns true on success, false on error.
  /// Preserves existing state on error.
  Future<bool> completeBatch() async {
    final currentState = state.value ?? BatchCompletionState.initial();

    if (currentState.batch == null) {
      state = AsyncValue.data(currentState.copyWith(error: 'Batch not loaded'));
      return false;
    }

    if (!currentState.isValid()) {
      state = AsyncValue.data(
        currentState.copyWith(
          error: 'Please enter actual output quantity (wastage is optional)',
        ),
      );
      return false;
    }

    state = AsyncValue.data(currentState.copyWith(isSubmitting: true));

    try {
      final result = await _productionRepository.completeBatch(
        batchId: currentState.batch!.id,
        actualOutput: currentState.actualOutput!,
        wastage: currentState.wastage,
      );

      // Handle 401 errors (auto-logout)
      await AuthErrorHandler.handleUnauthorized(ref, result);

      if (result.isSuccess) {
        // Success - reload batch to get updated state
        final success = result as ApiSuccess<ProductionBatch>;
        final completedBatch = success.data;

        // Update state with completed batch and clear submitting/error flags
        state = AsyncValue.data(
          BatchCompletionState(
            batch: completedBatch,
            actualOutput: currentState.actualOutput,
            wastage: currentState.wastage,
            isLoading: false,
            isSubmitting: false,
            error: null,
          ),
        );
        return true;
      } else {
        final failure = result as ApiFailure<ProductionBatch>;
        state = AsyncValue.data(
          currentState.copyWith(
            error: failure.error.message,
            isSubmitting: false,
          ),
        );
        return false;
      }
    } catch (e) {
      state = AsyncValue.data(
        currentState.copyWith(
          error: 'Failed to complete batch: ${e.toString()}',
          isSubmitting: false,
        ),
      );
      return false;
    }
  }

  /// Save batch progress (save without completing).
  /// Returns true on success, false on error.
  /// TODO: This is currently a placeholder that only validates the form.
  /// Actual save progress endpoint would need to be implemented in the backend API.
  /// Once available, call a repository method to save progress (actualOutput + wastage) without completing.
  Future<bool> saveProgress() async {
    final currentState = state.value ?? BatchCompletionState.initial();

    if (currentState.batch == null) {
      state = AsyncValue.data(currentState.copyWith(error: 'Batch not loaded'));
      return false;
    }

    // Validate that actual output is set (required for saving progress)
    if (currentState.actualOutput == null || currentState.actualOutput! <= 0) {
      state = AsyncValue.data(
        currentState.copyWith(error: 'Please enter actual output quantity'),
      );
      return false;
    }

    // TODO: Implement actual save progress endpoint call when backend supports it
    // For now, just validate - no network call is made
    // Example implementation once endpoint exists:
    // final result = await _productionRepository.saveBatchProgress(...);
    // await AuthErrorHandler.handleUnauthorized(ref, result);
    // if (result.isSuccess) { return true; } else { ... return false; }

    return true;
  }

  /// Clear error state.
  void clearError() {
    final currentState = state.value ?? BatchCompletionState.initial();
    state = AsyncValue.data(currentState.copyWith(clearError: true));
  }
}

/// Riverpod provider for BatchCompletionViewModel.
final batchCompletionProvider =
    AsyncNotifierProvider<BatchCompletionViewModel, BatchCompletionState>(() {
      return BatchCompletionViewModel();
    });
