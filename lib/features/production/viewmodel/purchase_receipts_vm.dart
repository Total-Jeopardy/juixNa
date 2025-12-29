import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:juix_na/core/auth/auth_error_handler.dart';
import 'package:juix_na/core/network/api_result.dart';
import 'package:juix_na/features/production/data/production_repository.dart';
import 'package:juix_na/features/production/model/production_models.dart';
import 'package:juix_na/features/production/viewmodel/production_providers.dart';
import 'package:juix_na/features/production/viewmodel/purchase_receipts_state.dart';

/// Purchase Receipts ViewModel using Riverpod AsyncNotifier.
/// Manages purchase receipts list and filtering.
class PurchaseReceiptsViewModel extends AsyncNotifier<PurchaseReceiptsState> {
  ProductionRepository? _repository;

  /// Get ProductionRepository from ref (dependency injection).
  ProductionRepository get _productionRepository {
    _repository ??= ref.read(productionRepositoryProvider);
    return _repository!;
  }

  @override
  Future<PurchaseReceiptsState> build() async {
    // On initialization, load receipts
    return await loadReceipts();
  }

  /// Load purchase receipts.
  /// Preserves existing state on error.
  Future<PurchaseReceiptsState> loadReceipts({
    ReceiptStatus? status,
    int? locationId,
  }) async {
    final currentState = state.value ?? PurchaseReceiptsState.initial();
    state = AsyncValue.data(currentState.copyWith(isLoading: true));

    try {
      final result = await _productionRepository.getPurchaseReceipts(
        status: status,
        locationId: locationId,
      );

      // Handle 401 errors (auto-logout)
      await AuthErrorHandler.handleUnauthorized(ref, result);

      if (result.isSuccess) {
        final success = result as ApiSuccess<List<PurchaseReceipt>>;
        final receipts = success.data;

        return PurchaseReceiptsState(
          receipts: receipts,
          selectedStatus: status,
          isLoading: false,
          error: null,
        );
      } else {
        final failure = result as ApiFailure<List<PurchaseReceipt>>;
        // Preserve existing receipts on error
        return PurchaseReceiptsState(
          receipts: currentState.receipts,
          selectedStatus: status ?? currentState.selectedStatus,
          isLoading: false,
          error: failure.error.message,
        );
      }
    } catch (e) {
      // Preserve existing receipts on exception
      return PurchaseReceiptsState(
        receipts: currentState.receipts,
        selectedStatus: currentState.selectedStatus,
        isLoading: false,
        error: 'Failed to load receipts: ${e.toString()}',
      );
    }
  }

  /// Set status filter and reload receipts.
  Future<void> setStatusFilter(ReceiptStatus? status) async {
    // Extract locationId from current state if needed (could be added later)
    await loadReceipts(status: status);
  }

  /// Refresh receipts list (reload from API).
  Future<void> refreshReceipts() async {
    final currentState = state.value ?? PurchaseReceiptsState.initial();
    final status = currentState.selectedStatus;
    await loadReceipts(status: status);
  }

  /// Clear error state.
  void clearError() {
    final currentState = state.value ?? PurchaseReceiptsState.initial();
    state = AsyncValue.data(currentState.copyWith(clearError: true));
  }
}

/// Riverpod provider for PurchaseReceiptsViewModel.
final purchaseReceiptsProvider =
    AsyncNotifierProvider<PurchaseReceiptsViewModel, PurchaseReceiptsState>(() {
      return PurchaseReceiptsViewModel();
    });
