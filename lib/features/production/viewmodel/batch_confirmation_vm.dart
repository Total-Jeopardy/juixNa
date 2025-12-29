import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:juix_na/core/auth/auth_error_handler.dart';
import 'package:juix_na/core/network/api_result.dart';
import 'package:juix_na/features/production/data/production_repository.dart';
import 'package:juix_na/features/production/model/production_models.dart';
import 'package:juix_na/features/production/viewmodel/batch_confirmation_state.dart';
import 'package:juix_na/features/production/viewmodel/production_providers.dart';

/// Batch Confirmation ViewModel using Riverpod AsyncNotifier.
/// Manages batch input confirmation and stock availability checks.
class BatchConfirmationViewModel extends AsyncNotifier<BatchConfirmationState> {
  ProductionRepository? _repository;

  /// Get ProductionRepository from ref (dependency injection).
  ProductionRepository get _productionRepository {
    _repository ??= ref.read(productionRepositoryProvider);
    return _repository!;
  }

  @override
  Future<BatchConfirmationState> build() async {
    // Start with initial state (batch inputs will be loaded via loadBatchInputs)
    return BatchConfirmationState.initial();
  }

  /// Load batch inputs (ingredients and packaging) and check stock availability.
  /// Preserves existing state on error.
  Future<void> loadBatchInputs(int batchId) async {
    final currentState = state.value ?? BatchConfirmationState.initial();
    state = AsyncValue.data(currentState.copyWith(isLoading: true));

    try {
      // First, load the batch to get batch details
      final batchResult = await _productionRepository.getBatch(id: batchId);
      await AuthErrorHandler.handleUnauthorized(ref, batchResult);

      if (!batchResult.isSuccess) {
        final failure = batchResult as ApiFailure<ProductionBatch>;
        state = AsyncValue.data(
          currentState.copyWith(error: failure.error.message, isLoading: false),
        );
        return;
      }

      final batchSuccess = batchResult as ApiSuccess<ProductionBatch>;
      final batch = batchSuccess.data;

      // Then, load batch inputs (stock availability)
      final inputsResult = await _productionRepository.getBatchInputs(
        batchId: batchId,
      );
      await AuthErrorHandler.handleUnauthorized(ref, inputsResult);

      if (inputsResult.isSuccess) {
        final inputsSuccess = inputsResult as ApiSuccess<BatchInputsData>;
        final inputsData = inputsSuccess.data;

        state = AsyncValue.data(
          BatchConfirmationState(
            batch: batch,
            ingredients: inputsData.ingredients,
            packaging: inputsData.packaging,
            adjustedInputs: null,
            isLoading: false,
            error: null,
          ),
        );
      } else {
        final failure = inputsResult as ApiFailure<BatchInputsData>;
        // Still set batch if it loaded successfully
        state = AsyncValue.data(
          BatchConfirmationState(
            batch: batch,
            ingredients: currentState.ingredients,
            packaging: currentState.packaging,
            adjustedInputs: currentState.adjustedInputs,
            isLoading: false,
            error: failure.error.message,
          ),
        );
      }
    } catch (e) {
      state = AsyncValue.data(
        currentState.copyWith(
          error: 'Failed to load batch inputs: ${e.toString()}',
          isLoading: false,
        ),
      );
    }
  }

  /// Toggle adjust inputs mode (enable/disable quantity adjustments).
  void toggleAdjustInputs() {
    final currentState = state.value ?? BatchConfirmationState.initial();
    state = AsyncValue.data(currentState.toggleAdjustInputs());
  }

  /// Set adjusted input quantity.
  /// Guards against NaN and negative values.
  void setAdjustedInput(int inputId, double quantity) {
    if (quantity.isNaN || quantity < 0) {
      // Don't update state if invalid value
      return;
    }
    final currentState = state.value ?? BatchConfirmationState.initial();
    state = AsyncValue.data(
      currentState.updateAdjustedInput(inputId, quantity),
    );
  }

  /// Start production batch.
  /// Returns true on success, false on error.
  /// Preserves existing state on error.
  Future<bool> startProduction() async {
    final currentState = state.value ?? BatchConfirmationState.initial();

    if (currentState.batch == null) {
      state = AsyncValue.data(currentState.copyWith(error: 'Batch not loaded'));
      return false;
    }

    if (!currentState.canStartProduction()) {
      state = AsyncValue.data(
        currentState.copyWith(
          error: 'Cannot start production: shortages exist',
        ),
      );
      return false;
    }

    state = AsyncValue.data(currentState.copyWith(isLoading: true));

    try {
      final batchId = currentState.batch!.id;

      // If adjusted inputs are provided, confirm them first
      if (currentState.adjustedInputs != null &&
          currentState.adjustedInputs!.isNotEmpty) {
        final confirmResult = await _productionRepository.confirmBatchInputs(
          batchId: batchId,
          adjustedInputs: currentState.adjustedInputs,
        );
        await AuthErrorHandler.handleUnauthorized(ref, confirmResult);

        if (!confirmResult.isSuccess) {
          final failure = confirmResult as ApiFailure<BatchInputsData>;
          state = AsyncValue.data(
            currentState.copyWith(
              error: failure.error.message,
              isLoading: false,
            ),
          );
          return false;
        }
      }

      // Start the batch
      final result = await _productionRepository.startBatch(batchId: batchId);
      await AuthErrorHandler.handleUnauthorized(ref, result);

      if (result.isSuccess) {
        // Success - reload batch to get updated state
        final success = result as ApiSuccess<ProductionBatch>;
        final startedBatch = success.data;

        // Update state with started batch and clear loading/error flags
        state = AsyncValue.data(
          BatchConfirmationState(
            batch: startedBatch,
            ingredients: currentState.ingredients,
            packaging: currentState.packaging,
            adjustedInputs: currentState.adjustedInputs,
            isLoading: false,
            error: null,
          ),
        );
        return true;
      } else {
        final failure = result as ApiFailure<ProductionBatch>;
        state = AsyncValue.data(
          currentState.copyWith(error: failure.error.message, isLoading: false),
        );
        return false;
      }
    } catch (e) {
      state = AsyncValue.data(
        currentState.copyWith(
          error: 'Failed to start production: ${e.toString()}',
          isLoading: false,
        ),
      );
      return false;
    }
  }

  /// Save batch as draft (update batch without starting).
  /// Returns true on success, false on error.
  /// Note: This might not be needed if batch is already saved as draft.
  /// Preserves existing state on error.
  Future<bool> saveDraft() async {
    final currentState = state.value ?? BatchConfirmationState.initial();

    if (currentState.batch == null) {
      state = AsyncValue.data(currentState.copyWith(error: 'Batch not loaded'));
      return false;
    }

    // If adjusted inputs are provided, confirm them
    if (currentState.adjustedInputs != null &&
        currentState.adjustedInputs!.isNotEmpty) {
      state = AsyncValue.data(currentState.copyWith(isLoading: true));

      try {
        final result = await _productionRepository.confirmBatchInputs(
          batchId: currentState.batch!.id,
          adjustedInputs: currentState.adjustedInputs,
        );
        await AuthErrorHandler.handleUnauthorized(ref, result);

        if (result.isSuccess) {
          state = AsyncValue.data(currentState.copyWith(isLoading: false));
          return true;
        } else {
          final failure = result as ApiFailure<BatchInputsData>;
          state = AsyncValue.data(
            currentState.copyWith(
              error: failure.error.message,
              isLoading: false,
            ),
          );
          return false;
        }
      } catch (e) {
        state = AsyncValue.data(
          currentState.copyWith(
            error: 'Failed to save draft: ${e.toString()}',
            isLoading: false,
          ),
        );
        return false;
      }
    }

    // Nothing to save if no adjusted inputs
    return true;
  }

  /// Clear error state.
  void clearError() {
    final currentState = state.value ?? BatchConfirmationState.initial();
    state = AsyncValue.data(currentState.copyWith(clearError: true));
  }
}

/// Riverpod provider for BatchConfirmationViewModel.
final batchConfirmationProvider =
    AsyncNotifierProvider<BatchConfirmationViewModel, BatchConfirmationState>(
      () {
        return BatchConfirmationViewModel();
      },
    );
