import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:juix_na/core/network/api_result.dart';
import 'package:juix_na/features/inventory/data/inventory_repository.dart';
import 'package:juix_na/features/inventory/model/inventory_models.dart';
import 'package:juix_na/features/inventory/viewmodel/cycle_count_state.dart';
import 'package:juix_na/features/inventory/viewmodel/inventory_overview_vm.dart';

/// Cycle Count ViewModel using Riverpod AsyncNotifier.
/// Manages cycle count form state and operations (spot counts, variance, adjustments).
class CycleCountViewModel extends AsyncNotifier<CycleCountState> {
  InventoryRepository? _repository;

  /// Request token to track in-flight requests and ignore stale responses.
  /// Format: "itemId_locationId" or null if no request in flight.
  /// 
  /// Prevents race condition: if user switches item/location while a system-quantity
  /// load is in-flight, the stale response will be ignored and won't overwrite
  /// the current selection. This eliminates flicker and ensures data consistency.
  String? _currentSystemQuantityRequestToken;

  /// Get InventoryRepository from ref (dependency injection).
  InventoryRepository get _inventoryRepository {
    _repository ??= ref.read(inventoryRepositoryProvider);
    return _repository!;
  }

  @override
  Future<CycleCountState> build() async {
    // On initialization, load locations
    // Items will be loaded when needed (e.g., when opening product picker)
    return await _loadInitialData();
  }

  /// Load initial data (locations).
  Future<CycleCountState> _loadInitialData() async {
    try {
      final result = await _inventoryRepository.getLocations();

      if (result.isSuccess) {
        final success = result as ApiSuccess<List<Location>>;
        final locations = success.data;

        return CycleCountState.initial().copyWith(
          availableLocations: locations,
        );
      } else {
        final failure = result as ApiFailure<List<Location>>;
        return CycleCountState.initial().copyWith(
          error: failure.error.message,
        );
      }
    } catch (e) {
      return CycleCountState.initial().copyWith(
        error: 'Failed to load locations: ${e.toString()}',
      );
    }
  }

  /// Load available products (items) for the picker.
  /// Preserves existing state on error.
  Future<void> loadProducts({int? locationId}) async {
    final currentState = state.value ?? CycleCountState.initial();
    state = AsyncValue.data(currentState.copyWith(isLoadingItems: true));

    try {
      ApiResult result;

      if (locationId != null) {
        // Load items for specific location
        result = await _inventoryRepository.getLocationItems(
          locationId: locationId,
        );
      } else {
        // Load items across all locations
        result = await _inventoryRepository.getInventoryItems();
      }

      if (result.isSuccess) {
        List<InventoryItem> items;

        if (locationId != null) {
          final success = result as ApiSuccess<LocationItemsResponse>;
          items = success.data.items;
        } else {
          final success = result as ApiSuccess<InventoryItemsResponse>;
          items = success.data.items;
        }

        state = AsyncValue.data(
          currentState.copyWith(
            availableItems: items,
            isLoadingItems: false,
            clearError: true,
          ),
        );
      } else {
        final failure = result as ApiFailure;
        // Preserve existing items on error
        state = AsyncValue.data(
          currentState.copyWith(
            error: failure.error.message,
            isLoadingItems: false,
          ),
        );
      }
    } catch (e) {
      // Preserve existing items on exception
      state = AsyncValue.data(
        currentState.copyWith(
          error: 'Failed to load products: ${e.toString()}',
          isLoadingItems: false,
        ),
      );
    }
  }

  /// Get system quantity for selected item and location.
  /// This is what the system thinks is currently in stock.
  /// Preserves existing state on error.
  /// 
  /// Uses request token to prevent stale responses: if item/location changes
  /// while a request is in-flight, the stale response will be ignored.
  Future<void> getSystemQuantity({
    required int itemId,
    required int locationId,
  }) async {
    final currentState = state.value ?? CycleCountState.initial();
    
    // Create request token for this specific item+location combination
    final requestToken = '${itemId}_$locationId';
    _currentSystemQuantityRequestToken = requestToken;
    
    state = AsyncValue.data(
      currentState.copyWith(isLoadingSystemQuantity: true),
    );

    try {
      final result = await _inventoryRepository.getLocationItems(
        locationId: locationId,
      );

      // Check if this response is still valid (item/location hasn't changed)
      if (_currentSystemQuantityRequestToken != requestToken) {
        // Request is stale - item or location changed while request was in-flight
        // Don't update state with stale data
        return;
      }

      if (result.isSuccess) {
        final success = result as ApiSuccess<LocationItemsResponse>;
        final items = success.data.items;

        // Find the selected item in the location items
        // If item is not found at this location, quantity is 0.0
        final item = items.firstWhere(
          (i) => i.id == itemId,
          orElse: () => InventoryItem(
            id: itemId,
            name: '',
            sku: '',
            unit: '',
            kind: ItemKind.finishedProduct,
            currentStock: 0.0, // Item not found at location = 0 stock
            totalQuantity: 0.0,
          ),
        );

        // Get system quantity from database: prefer currentStock (location-specific) 
        // over totalQuantity (all locations), default to 0.0 if both are null
        final systemQuantity = item.currentStock ?? item.totalQuantity ?? 0.0;

        // Double-check token before applying (item/location might have changed during processing)
        if (_currentSystemQuantityRequestToken == requestToken) {
          state = AsyncValue.data(
            currentState.copyWith(
              systemQuantity: systemQuantity,
              isLoadingSystemQuantity: false,
              clearError: true,
            ),
          );
        }
        // If token doesn't match, silently ignore (stale response)
      } else {
        final failure = result as ApiFailure<LocationItemsResponse>;
        // Only apply error if request is still current
        if (_currentSystemQuantityRequestToken == requestToken) {
          // Preserve existing system quantity on error
          state = AsyncValue.data(
            currentState.copyWith(
              error: failure.error.message,
              isLoadingSystemQuantity: false,
            ),
          );
        }
      }
    } catch (e) {
      // Only apply error if request is still current
      if (_currentSystemQuantityRequestToken == requestToken) {
        // Preserve existing system quantity on exception
        state = AsyncValue.data(
          currentState.copyWith(
            error: 'Failed to load system quantity: ${e.toString()}',
            isLoadingSystemQuantity: false,
          ),
        );
      }
    } finally {
      // Clear token if this was the current request
      if (_currentSystemQuantityRequestToken == requestToken) {
        _currentSystemQuantityRequestToken = null;
      }
    }
  }

  /// Update selected item.
  /// Automatically loads system quantity if location is selected.
  Future<void> selectItem(InventoryItem? item) async {
    final currentState = state.value ?? CycleCountState.initial();
    state = AsyncValue.data(
      currentState.copyWith(
        selectedItem: item,
        clearSystemQuantity: true,
        clearCountedQuantity: true,
      ),
    );

    // If location is also selected, load system quantity
    if (item != null && currentState.selectedLocationId != null) {
      await getSystemQuantity(
        itemId: item.id,
        locationId: currentState.selectedLocationId!,
      );
    }
  }

  /// Update selected location.
  /// Automatically loads system quantity if item is selected.
  Future<void> selectLocation(int? locationId) async {
    final currentState = state.value ?? CycleCountState.initial();
    state = AsyncValue.data(
      currentState.copyWith(
        selectedLocationId: locationId,
        clearSystemQuantity: true,
        clearCountedQuantity: true,
      ),
    );

    // If item is also selected, load system quantity
    if (locationId != null && currentState.selectedItem != null) {
      await getSystemQuantity(
        itemId: currentState.selectedItem!.id,
        locationId: locationId,
      );
    }
  }

  /// Update date.
  void setDate(DateTime date) {
    final currentState = state.value ?? CycleCountState.initial();
    state = AsyncValue.data(
      currentState.copyWith(date: date),
    );
  }

  /// Update counted quantity.
  void setCountedQuantity(double? quantity) {
    final currentState = state.value ?? CycleCountState.initial();
    state = AsyncValue.data(
      currentState.copyWith(countedQuantity: quantity),
    );
  }

  /// Update note.
  void setNote(String? note) {
    final currentState = state.value ?? CycleCountState.initial();
    state = AsyncValue.data(
      currentState.copyWith(note: note),
    );
  }

  /// Create/save cycle count (records the count without adjusting stock).
  /// This is a local operation - the count is saved in state.
  /// To actually adjust stock, use adjustStockFromCount().
  Future<bool> createCycleCount() async {
    final currentState = state.value ?? CycleCountState.initial();

    // Validate form
    if (!currentState.isValid) {
      final fieldErrors = <String, String>{};
      if (currentState.selectedItem == null) {
        fieldErrors['item'] = 'Item is required';
      }
      if (currentState.selectedLocationId == null) {
        fieldErrors['location'] = 'Location is required';
      }
      if (currentState.systemQuantity == null) {
        fieldErrors['systemQuantity'] = 'System quantity is required';
      }
      if (currentState.countedQuantity == null) {
        fieldErrors['countedQuantity'] = 'Counted quantity is required';
      }

      state = AsyncValue.data(
        currentState.copyWith(
          fieldErrors: fieldErrors,
        ),
      );
      return false;
    }

    // Cycle count is just recorded in state
    // No API call needed - the count is ready for adjustment
    return true;
  }

  /// Adjust stock based on cycle count variance.
  /// Calculates variance (counted - system) and applies it as an adjustment.
  /// Preserves existing state on error.
  /// 
  /// Note on persistence: On successful adjustment, the form is reset to initial
  /// state (clears selected item, location, quantities) but keeps loaded
  /// locations/items for faster subsequent selections. This is the expected
  /// behavior for v1. If persistence of last selection is needed in the future,
  /// we can modify this to preserve selected item/location while clearing quantities.
  Future<bool> adjustStockFromCount() async {
    final currentState = state.value ?? CycleCountState.initial();

    // Validate that we have all required data
    if (currentState.selectedItem == null ||
        currentState.selectedLocationId == null ||
        currentState.systemQuantity == null ||
        currentState.countedQuantity == null) {
      state = AsyncValue.data(
        currentState.copyWith(
          error: 'Please complete the cycle count before adjusting stock',
        ),
      );
      return false;
    }

    // Calculate variance (counted - system)
    final variance = currentState.countedQuantity! - currentState.systemQuantity!;

    // If no variance, no adjustment needed
    if (variance == 0.0) {
      state = AsyncValue.data(
        currentState.copyWith(
          error: 'No variance detected. Counted quantity matches system quantity.',
        ),
      );
      return false;
    }

    state = AsyncValue.data(currentState.copyWith(isSubmitting: true));

    try {
      // Apply adjustment: variance is the adjustment amount
      // Positive variance = stock gain (adjustment in)
      // Negative variance = stock loss (adjustment out)
      final result = await _inventoryRepository.adjustStock(
        itemId: currentState.selectedItem!.id,
        locationId: currentState.selectedLocationId!,
        quantity: variance.toStringAsFixed(3), // API expects string with 3 decimals
        reason: 'CYCLE_COUNT',
        reference: 'CC-${DateTime.now().millisecondsSinceEpoch}',
        note: currentState.note ??
            'Cycle count adjustment: System=${currentState.systemQuantity}, Counted=${currentState.countedQuantity}',
      );

      if (result.isSuccess) {
        // Success - reset form to initial state but keep locations/items
        state = AsyncValue.data(
          CycleCountState.initial().copyWith(
            availableLocations: currentState.availableLocations,
            availableItems: currentState.availableItems,
          ),
        );
        return true;
      } else {
        final failure = result as ApiFailure<StockAdjustment>;
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
          error: 'Failed to adjust stock from cycle count: ${e.toString()}',
          isSubmitting: false,
        ),
      );
      return false;
    }
  }

  /// Clear error state.
  void clearError() {
    final currentState = state.value ?? CycleCountState.initial();
    state = AsyncValue.data(
      currentState.copyWith(
        clearError: true,
        clearFieldErrors: true,
      ),
    );
  }

  /// Reset form to initial state (keeps loaded locations/items).
  /// 
  /// Note: After successful stock adjustment, the form is reset to allow
  /// starting a new cycle count. This is the expected behavior for v1.
  /// If persistence of last selection is needed in the future, we can
  /// modify this to preserve selected item/location while clearing quantities.
  void resetForm() {
    final currentState = state.value ?? CycleCountState.initial();
    state = AsyncValue.data(
      CycleCountState.initial().copyWith(
        availableLocations: currentState.availableLocations,
        availableItems: currentState.availableItems,
      ),
    );
  }
}

/// Riverpod provider for CycleCountViewModel.
final cycleCountProvider =
    AsyncNotifierProvider<CycleCountViewModel, CycleCountState>(
  () {
    return CycleCountViewModel();
  },
);

/// Extension to get first element or null from list (generic).
extension InventoryItemListExtension on List<InventoryItem> {
  InventoryItem? get firstOrNull => isEmpty ? null : first;
}

