import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:juix_na/core/auth/auth_error_handler.dart';
import 'package:juix_na/core/network/api_result.dart';
import 'package:juix_na/features/production/data/production_repository.dart';
import 'package:juix_na/features/production/model/production_models.dart';
import 'package:juix_na/features/production/viewmodel/production_providers.dart';
import 'package:juix_na/features/production/viewmodel/receipt_review_state.dart';

/// Receipt Review ViewModel using Riverpod AsyncNotifier.
/// Manages receipt review and approval/rejection operations.
class ReceiptReviewViewModel extends AsyncNotifier<ReceiptReviewState> {
  ProductionRepository? _repository;

  /// Get ProductionRepository from ref (dependency injection).
  ProductionRepository get _productionRepository {
    _repository ??= ref.read(productionRepositoryProvider);
    return _repository!;
  }

  @override
  Future<ReceiptReviewState> build() async {
    // Start with initial state (receipt will be loaded via loadReceipt)
    return ReceiptReviewState.initial();
  }

  /// Load receipt details by ID.
  /// Preserves existing state on error.
  Future<void> loadReceipt(int id) async {
    final currentState = state.value ?? ReceiptReviewState.initial();
    state = AsyncValue.data(currentState.copyWith(isLoading: true));

    try {
      final result = await _productionRepository.getPurchaseReceipt(id: id);

      // Handle 401 errors (auto-logout)
      await AuthErrorHandler.handleUnauthorized(ref, result);

      if (result.isSuccess) {
        final success = result as ApiSuccess<PurchaseReceipt>;
        final receipt = success.data;

        // Initialize receiving quantities from receipt items
        var newState = ReceiptReviewState(
          receipt: receipt,
          receivingQuantities: {},
          isLoading: false,
          isSubmitting: false,
          error: null,
        );
        newState = newState.initializeReceivingQuantities();

        state = AsyncValue.data(newState);
      } else {
        final failure = result as ApiFailure<PurchaseReceipt>;
        state = AsyncValue.data(
          currentState.copyWith(error: failure.error.message, isLoading: false),
        );
      }
    } catch (e) {
      state = AsyncValue.data(
        currentState.copyWith(
          error: 'Failed to load receipt: ${e.toString()}',
          isLoading: false,
        ),
      );
    }
  }

  /// Set receiving quantity for a specific item.
  /// Guards against NaN and negative values.
  void setReceivingQuantity(int itemId, double quantity) {
    if (quantity.isNaN || quantity < 0) {
      // Don't update state if invalid value
      return;
    }
    final currentState = state.value ?? ReceiptReviewState.initial();
    state = AsyncValue.data(
      currentState.updateReceivingQuantity(itemId, quantity),
    );
  }

  /// Approve and receive receipt.
  /// Returns true on success, false on error.
  /// Preserves existing state on error.
  Future<bool> approveReceipt() async {
    final currentState = state.value ?? ReceiptReviewState.initial();

    if (currentState.receipt == null) {
      state = AsyncValue.data(
        currentState.copyWith(error: 'Receipt not loaded'),
      );
      return false;
    }

    if (!currentState.canApprove()) {
      state = AsyncValue.data(
        currentState.copyWith(error: 'Receipt cannot be approved'),
      );
      return false;
    }

    state = AsyncValue.data(currentState.copyWith(isSubmitting: true));

    try {
      final result = await _productionRepository.reviewReceipt(
        id: currentState.receipt!.id,
        action: 'approve',
        receivingQuantities: currentState.receivingQuantities.isEmpty
            ? null
            : currentState.receivingQuantities,
      );

      // Handle 401 errors (auto-logout)
      await AuthErrorHandler.handleUnauthorized(ref, result);

      if (result.isSuccess) {
        // Success - reload receipt to get updated state
        final success = result as ApiSuccess<PurchaseReceipt>;
        final updatedReceipt = success.data;

        // Update state with approved receipt and clear submitting/error flags
        var newState = ReceiptReviewState(
          receipt: updatedReceipt,
          receivingQuantities: currentState.receivingQuantities,
          isLoading: false,
          isSubmitting: false,
          error: null,
        );

        state = AsyncValue.data(newState);
        return true;
      } else {
        final failure = result as ApiFailure<PurchaseReceipt>;
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
          error: 'Failed to approve receipt: ${e.toString()}',
          isSubmitting: false,
        ),
      );
      return false;
    }
  }

  /// Reject receipt.
  /// Returns true on success, false on error.
  /// Preserves existing state on error.
  Future<bool> rejectReceipt() async {
    final currentState = state.value ?? ReceiptReviewState.initial();

    if (currentState.receipt == null) {
      state = AsyncValue.data(
        currentState.copyWith(error: 'Receipt not loaded'),
      );
      return false;
    }

    state = AsyncValue.data(currentState.copyWith(isSubmitting: true));

    try {
      final result = await _productionRepository.reviewReceipt(
        id: currentState.receipt!.id,
        action: 'reject',
        receivingQuantities: null,
      );

      // Handle 401 errors (auto-logout)
      await AuthErrorHandler.handleUnauthorized(ref, result);

      if (result.isSuccess) {
        // Success - reload receipt to get updated state
        final success = result as ApiSuccess<PurchaseReceipt>;
        final updatedReceipt = success.data;

        // Update state with rejected receipt and clear submitting/error flags
        var newState = ReceiptReviewState(
          receipt: updatedReceipt,
          receivingQuantities: currentState.receivingQuantities,
          isLoading: false,
          isSubmitting: false,
          error: null,
        );

        state = AsyncValue.data(newState);
        return true;
      } else {
        final failure = result as ApiFailure<PurchaseReceipt>;
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
          error: 'Failed to reject receipt: ${e.toString()}',
          isSubmitting: false,
        ),
      );
      return false;
    }
  }

  /// Clear error state.
  void clearError() {
    final currentState = state.value ?? ReceiptReviewState.initial();
    state = AsyncValue.data(currentState.copyWith(clearError: true));
  }
}

/// Riverpod provider for ReceiptReviewViewModel.
final receiptReviewProvider =
    AsyncNotifierProvider<ReceiptReviewViewModel, ReceiptReviewState>(() {
      return ReceiptReviewViewModel();
    });
