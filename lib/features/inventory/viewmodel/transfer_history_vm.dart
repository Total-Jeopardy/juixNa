import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:juix_na/core/network/api_result.dart';
import 'package:juix_na/features/inventory/data/inventory_repository.dart';
import 'package:juix_na/features/inventory/model/inventory_models.dart';
import 'package:juix_na/features/inventory/viewmodel/inventory_overview_vm.dart';
import 'package:juix_na/features/inventory/viewmodel/transfer_history_state.dart';

/// Transfer History ViewModel using Riverpod AsyncNotifier.
/// Manages transfer history (stock movements with type: TRANSFER).
class TransferHistoryViewModel extends AsyncNotifier<TransferHistoryState> {
  InventoryRepository? _repository;

  /// Get InventoryRepository from ref (dependency injection).
  InventoryRepository get _inventoryRepository {
    _repository ??= ref.read(inventoryRepositoryProvider);
    return _repository!;
  }

  @override
  Future<TransferHistoryState> build() async {
    // On initialization, load locations and transfers
    return await _loadInitialData();
  }

  /// Load initial data (locations and transfers).
  /// Preserves existing data if one call fails.
  Future<TransferHistoryState> _loadInitialData() async {
    final currentState = state.value ?? TransferHistoryState.initial();
    state = AsyncValue.data(
      currentState.copyWith(isLoading: true, isLoadingLocations: true),
    );

    try {
      // Load locations and set up default date range (this week)
      final locationsResult = await _inventoryRepository.getLocations();
      List<Location> locations = [];
      if (locationsResult.isSuccess) {
        locations = (locationsResult as ApiSuccess<List<Location>>).data;
      }

      // Set up default date range (this week)
      final now = DateTime.now();
      final startOfWeek = now.subtract(Duration(days: now.weekday - 1));
      final fromDate = DateTime(startOfWeek.year, startOfWeek.month, startOfWeek.day);

      // Load transfers with default date range
      await loadTransfers(fromDate: fromDate);

      // Update state with locations
      final transfersState = state.value ?? TransferHistoryState.initial();
      state = AsyncValue.data(
        transfersState.copyWith(
          availableLocations: locations,
          isLoadingLocations: false,
        ),
      );

      return state.value ?? TransferHistoryState.initial();
    } catch (e) {
      state = AsyncValue.data(
        currentState.copyWith(
          error: 'Failed to load data: ${e.toString()}',
          isLoading: false,
          isLoadingLocations: false,
        ),
      );
      return state.value ?? TransferHistoryState.initial();
    }
  }

  /// Load transfers (stock movements with type: TRANSFER).
  /// Preserves existing state on error.
  Future<void> loadTransfers({
    DateTime? fromDate,
    DateTime? toDate,
    int? locationId,
    int? itemId,
  }) async {
    final currentState = state.value ?? TransferHistoryState.initial();
    state = AsyncValue.data(currentState.copyWith(isLoading: true));

    try {
      // Format dates as ISO strings
      String? fromDateStr;
      String? toDateStr;
      if (fromDate != null) {
        fromDateStr = fromDate.toIso8601String().split('T')[0]; // Date only
      }
      if (toDate != null) {
        toDateStr = toDate.toIso8601String().split('T')[0]; // Date only
      }

      final result = await _inventoryRepository.getStockMovements(
        type: MovementType.transfer.value, // Filter for TRANSFER type only
        fromDate: fromDateStr,
        toDate: toDateStr,
        locationId: locationId,
        itemId: itemId,
        limit: 100, // Load up to 100 transfers
      );

      if (result.isSuccess) {
        final success = result as ApiSuccess<StockMovementsResponse>;
        final movements = success.data.movements;
        final pagination = success.data.pagination;

        state = AsyncValue.data(
          currentState.copyWith(
            transfers: movements,
            fromDate: fromDate ?? currentState.fromDate,
            toDate: toDate ?? currentState.toDate,
            selectedLocationId: locationId ?? currentState.selectedLocationId,
            selectedItemId: itemId ?? currentState.selectedItemId,
            isLoading: false,
            pagination: pagination,
            clearError: true,
          ),
        );
        } else {
        final failure = result as ApiFailure<StockMovementsResponse>;
        // Preserve existing transfers on error
        state = AsyncValue.data(
          currentState.copyWith(
            error: failure.error.message,
            isLoading: false,
          ),
        );
      }
    } catch (e) {
      // Preserve existing transfers on exception
      state = AsyncValue.data(
        currentState.copyWith(
          error: 'Failed to load transfers: ${e.toString()}',
          isLoading: false,
        ),
      );
    }
  }

  /// Set date range filter.
  Future<void> setDateRange({
    DateTime? fromDate,
    DateTime? toDate,
  }) async {
    await loadTransfers(
      fromDate: fromDate,
      toDate: toDate,
      locationId: state.value?.selectedLocationId,
      itemId: state.value?.selectedItemId,
    );
  }

  /// Filter by location (source location).
  Future<void> filterByLocation(int? locationId) async {
    await loadTransfers(
      fromDate: state.value?.fromDate,
      toDate: state.value?.toDate,
      locationId: locationId,
      itemId: state.value?.selectedItemId,
    );
  }

  /// Filter by product (item).
  Future<void> filterByItem(int? itemId) async {
    await loadTransfers(
      fromDate: state.value?.fromDate,
      toDate: state.value?.toDate,
      locationId: state.value?.selectedLocationId,
      itemId: itemId,
    );
  }

  /// Clear location filter.
  Future<void> clearLocationFilter() async {
    await filterByLocation(null);
  }

  /// Clear item filter.
  Future<void> clearItemFilter() async {
    await filterByItem(null);
  }

  /// Clear all filters.
  Future<void> clearFilters() async {
    final currentState = state.value ?? TransferHistoryState.initial();
    state = AsyncValue.data(
      currentState.copyWith(
        clearFromDate: true,
        clearToDate: true,
        clearSelectedLocation: true,
        clearSelectedItem: true,
        clearStatusFilter: true,
      ),
    );
    await loadTransfers();
  }

  /// Refresh transfers (reload with current filters).
  Future<void> refresh() async {
    final currentState = state.value ?? TransferHistoryState.initial();
    await loadTransfers(
      fromDate: currentState.fromDate,
      toDate: currentState.toDate,
      locationId: currentState.selectedLocationId,
      itemId: currentState.selectedItemId,
    );
  }

  /// Clear error state.
  void clearError() {
    final currentState = state.value ?? TransferHistoryState.initial();
    state = AsyncValue.data(
      currentState.copyWith(clearError: true),
    );
  }
}

/// Riverpod provider for TransferHistoryViewModel.
final transferHistoryProvider =
    AsyncNotifierProvider<TransferHistoryViewModel, TransferHistoryState>(
  () {
    return TransferHistoryViewModel();
  },
);

