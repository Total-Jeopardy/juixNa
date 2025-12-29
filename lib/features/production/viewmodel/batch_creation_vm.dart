import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:juix_na/core/auth/auth_error_handler.dart';
import 'package:juix_na/core/network/api_result.dart';
import 'package:juix_na/features/production/data/production_repository.dart';
import 'package:juix_na/features/production/model/production_models.dart';
import 'package:juix_na/features/production/viewmodel/batch_creation_state.dart';
import 'package:juix_na/features/production/viewmodel/production_providers.dart';

/// Batch Creation ViewModel using Riverpod Notifier.
/// Manages batch creation form state and operations.
class BatchCreationViewModel extends Notifier<BatchCreationState> {
  ProductionRepository? _repository;

  /// Get ProductionRepository from ref (dependency injection).
  ProductionRepository get _productionRepository {
    _repository ??= ref.read(productionRepositoryProvider);
    return _repository!;
  }

  @override
  BatchCreationState build() {
    // Start with initial state (no async loading needed)
    return BatchCreationState.initial();
  }

  /// Set selected product.
  void setProduct(int? productId) {
    state = state.copyWith(productId: productId);
  }

  /// Set production date.
  void setProductionDate(DateTime date) {
    state = state.copyWith(productionDate: date);
  }

  /// Set location.
  void setLocation(int? locationId) {
    state = state.copyWith(locationId: locationId);
  }

  /// Set planned output quantity.
  /// Guards against NaN and negative values.
  void setPlannedOutput(double output) {
    if (output.isNaN || output < 0) {
      // Don't update state if invalid value
      return;
    }
    state = state.copyWith(plannedOutput: output);
  }

  /// Set batch notes.
  void setNotes(String? notes) {
    state = state.copyWith(notes: notes);
  }

  /// Save batch as draft.
  /// Returns true on success, false on error.
  /// Preserves existing state on error.
  Future<bool> saveDraft() async {
    // Validate form
    if (!state.isValid()) {
      state = state.copyWith(
        error:
            'Please fill in all required fields (product, location, planned output)',
      );
      return false;
    }

    state = state.copyWith(isLoading: true, error: null);

    try {
      final result = await _productionRepository.createBatch(
        productId: state.productId!,
        productionDate: state.productionDate,
        locationId: state.locationId!,
        plannedOutput: state.plannedOutput,
        notes: state.notes,
      );

      // Handle 401 errors (auto-logout)
      await AuthErrorHandler.handleUnauthorized(ref, result);

      if (result.isSuccess) {
        // Success - reset form
        state = state.reset();
        return true;
      } else {
        final failure = result as ApiFailure<ProductionBatch>;
        state = state.copyWith(error: failure.error.message, isLoading: false);
        return false;
      }
    } catch (e) {
      state = state.copyWith(
        error: 'Failed to save draft: ${e.toString()}',
        isLoading: false,
      );
      return false;
    }
  }

  /// Continue to confirmation screen.
  /// Validates form and returns batch ID if valid, null otherwise.
  /// This method should be called before navigation to confirm inputs screen.
  Future<int?> continueToConfirmation() async {
    // Validate form
    if (!state.isValid()) {
      state = state.copyWith(
        error:
            'Please fill in all required fields (product, location, planned output)',
      );
      return null;
    }

    state = state.copyWith(isLoading: true, error: null);

    try {
      final result = await _productionRepository.createBatch(
        productId: state.productId!,
        productionDate: state.productionDate,
        locationId: state.locationId!,
        plannedOutput: state.plannedOutput,
        notes: state.notes,
      );

      // Handle 401 errors (auto-logout)
      await AuthErrorHandler.handleUnauthorized(ref, result);

      if (result.isSuccess) {
        final success = result as ApiSuccess<ProductionBatch>;
        final batch = success.data;
        // Return batch ID for navigation
        return batch.id;
      } else {
        final failure = result as ApiFailure<ProductionBatch>;
        state = state.copyWith(error: failure.error.message, isLoading: false);
        return null;
      }
    } catch (e) {
      state = state.copyWith(
        error: 'Failed to create batch: ${e.toString()}',
        isLoading: false,
      );
      return null;
    }
  }

  /// Reset form to initial state.
  void reset() {
    state = state.reset();
  }

  /// Validate form data.
  /// Returns true if valid, false otherwise.
  bool validate() {
    return state.isValid();
  }

  /// Clear error state.
  void clearError() {
    state = state.copyWith(clearError: true);
  }
}

/// Riverpod provider for BatchCreationViewModel.
final batchCreationProvider =
    NotifierProvider<BatchCreationViewModel, BatchCreationState>(() {
      return BatchCreationViewModel();
    });
