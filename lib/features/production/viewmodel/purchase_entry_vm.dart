import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:juix_na/core/auth/auth_error_handler.dart';
import 'package:juix_na/core/network/api_result.dart';
import 'package:juix_na/features/production/data/production_repository.dart';
import 'package:juix_na/features/production/model/production_models.dart';
import 'package:juix_na/features/production/viewmodel/production_providers.dart';
import 'package:juix_na/features/production/viewmodel/purchase_entry_state.dart';

/// Purchase Entry ViewModel using Riverpod Notifier.
/// Manages purchase entry form state and operations.
class PurchaseEntryViewModel extends Notifier<PurchaseEntryState> {
  ProductionRepository? _repository;

  /// Get ProductionRepository from ref (dependency injection).
  ProductionRepository get _productionRepository {
    _repository ??= ref.read(productionRepositoryProvider);
    return _repository!;
  }

  @override
  PurchaseEntryState build() {
    // Start with initial state (no async loading needed)
    return PurchaseEntryState.initial();
  }

  /// Set selected supplier.
  void setSupplier(int? supplierId) {
    state = state.copyWith(supplierId: supplierId);
  }

  /// Set purchase date.
  void setDate(DateTime date) {
    state = state.copyWith(date: date);
  }

  /// Set reference/invoice number.
  void setRefInvoice(String? refInvoice) {
    state = state.copyWith(refInvoice: refInvoice);
  }

  /// Add an item to the purchase entry.
  void addItem(PurchaseItem item) {
    state = state.addItem(item);
  }

  /// Remove an item by index.
  void removeItem(int index) {
    state = state.removeItem(index);
  }

  /// Update an item at a specific index.
  void updateItem(int index, PurchaseItem item) {
    state = state.updateItem(index, item);
  }

  /// Toggle mark as received flag.
  void toggleMarkAsReceived() {
    state = state.copyWith(markAsReceived: !state.markAsReceived);
  }

  /// Save purchase entry.
  /// Returns true on success, false on error.
  /// Preserves existing state on error.
  Future<bool> savePurchase() async {
    // Validate form
    if (!state.isValid()) {
      state = state.copyWith(
        error: 'Please select a supplier and add at least one item',
      );
      return false;
    }

    // Validate using domain model
    final purchaseEntry = state.toPurchaseEntry();
    if (!purchaseEntry.isValid()) {
      state = state.copyWith(error: 'Invalid purchase entry data');
      return false;
    }

    state = state.copyWith(isLoading: true, error: null);

    try {
      final result = await _productionRepository.createPurchaseEntry(
        entry: purchaseEntry,
      );

      // Handle 401 errors (auto-logout)
      await AuthErrorHandler.handleUnauthorized(ref, result);

      if (result.isSuccess) {
        // Success - reset form
        state = state.reset();
        return true;
      } else {
        final failure = result as ApiFailure<PurchaseReceipt>;
        state = state.copyWith(error: failure.error.message, isLoading: false);
        return false;
      }
    } catch (e) {
      state = state.copyWith(
        error: 'Failed to save purchase: ${e.toString()}',
        isLoading: false,
      );
      return false;
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

/// Riverpod provider for PurchaseEntryViewModel.
final purchaseEntryProvider =
    NotifierProvider<PurchaseEntryViewModel, PurchaseEntryState>(() {
      return PurchaseEntryViewModel();
    });
