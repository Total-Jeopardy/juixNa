import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:juix_na/core/network/api_result.dart';
import 'package:juix_na/features/inventory/data/inventory_repository.dart';
import 'package:juix_na/features/inventory/model/inventory_models.dart';
import 'package:juix_na/features/inventory/viewmodel/inventory_overview_vm.dart';
import 'package:juix_na/features/inventory/viewmodel/stock_transfer_state.dart';

/// Stock Transfer ViewModel using Riverpod AsyncNotifier.
/// Manages stock transfer form state and operations (transferring stock between locations).
class StockTransferViewModel extends AsyncNotifier<StockTransferState> {
  InventoryRepository? _repository;

  /// Request token to track in-flight requests and ignore stale responses.
  /// Format: "itemId_locationId" or null if no request in flight.
  String? _currentStockRequestToken;

  /// Get InventoryRepository from ref (dependency injection).
  InventoryRepository get _inventoryRepository {
    _repository ??= ref.read(inventoryRepositoryProvider);
    return _repository!;
  }

  @override
  Future<StockTransferState> build() async {
    // On initialization, load locations
    // Items will be loaded when needed (e.g., when opening product picker)
    return await _loadInitialData();
  }

  /// Load initial data (locations).
  Future<StockTransferState> _loadInitialData() async {
    try {
      final result = await _inventoryRepository.getLocations();

      if (result.isSuccess) {
        final success = result as ApiSuccess<List<Location>>;
        final locations = success.data;

        return StockTransferState.initial().copyWith(
          availableLocations: locations,
        );
      } else {
        final failure = result as ApiFailure<List<Location>>;
        return StockTransferState.initial().copyWith(
          error: failure.error.message,
        );
      }
    } catch (e) {
      return StockTransferState.initial().copyWith(
        error: 'Failed to load locations: ${e.toString()}',
      );
    }
  }

  /// Load available products (items) for the picker.
  /// Preserves existing state on error.
  Future<void> loadProducts({int? locationId}) async {
    final currentState = state.value ?? StockTransferState.initial();
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

  /// Load available stock for selected item and from-location.
  /// Used for validation (ensuring transfer doesn't exceed available stock).
  /// Preserves existing state on error.
  /// 
  /// Uses request token to prevent stale responses: if item/location changes
  /// while a request is in-flight, the stale response will be ignored.
  Future<void> getAvailableStock({
    required int itemId,
    required int locationId,
  }) async {
    final currentState = state.value ?? StockTransferState.initial();
    
    // Create request token for this specific item+location combination
    final requestToken = '${itemId}_$locationId';
    _currentStockRequestToken = requestToken;
    
    state = AsyncValue.data(
      currentState.copyWith(isLoadingAvailableStock: true),
    );

    try {
      final result = await _inventoryRepository.getLocationItems(
        locationId: locationId,
      );

      // Check if this response is still valid (item/location hasn't changed)
      if (_currentStockRequestToken != requestToken) {
        // Request is stale - item or location changed while request was in-flight
        // Don't update state with stale data
        return;
      }

      if (result.isSuccess) {
        final success = result as ApiSuccess<LocationItemsResponse>;
        final items = success.data.items;

        // Find the selected item in the location items
        final item = items.firstWhere(
          (i) => i.id == itemId,
          orElse: () => items.firstOrNull ?? const InventoryItem(
            id: -1,
            name: '',
            sku: '',
            unit: '',
            kind: ItemKind.finishedProduct,
          ),
        );

        final availableStock = item.currentStock ?? item.totalQuantity ?? 0.0;

        // Double-check token before applying (item/location might have changed during processing)
        if (_currentStockRequestToken == requestToken) {
          state = AsyncValue.data(
            currentState.copyWith(
              availableStock: availableStock,
              isLoadingAvailableStock: false,
              clearError: true,
            ),
          );
        }
        // If token doesn't match, silently ignore (stale response)
      } else {
        final failure = result as ApiFailure<LocationItemsResponse>;
        // Only apply error if request is still current
        if (_currentStockRequestToken == requestToken) {
          // Preserve existing available stock on error
          state = AsyncValue.data(
            currentState.copyWith(
              error: failure.error.message,
              isLoadingAvailableStock: false,
            ),
          );
        }
      }
    } catch (e) {
      // Only apply error if request is still current
      if (_currentStockRequestToken == requestToken) {
        // Preserve existing available stock on exception
        state = AsyncValue.data(
          currentState.copyWith(
            error: 'Failed to load available stock: ${e.toString()}',
            isLoadingAvailableStock: false,
          ),
        );
      }
    } finally {
      // Clear token if this was the current request
      if (_currentStockRequestToken == requestToken) {
        _currentStockRequestToken = null;
      }
    }
  }

  /// Update selected item.
  /// Automatically loads available stock if from-location is selected.
  Future<void> selectItem(InventoryItem? item) async {
    final currentState = state.value ?? StockTransferState.initial();
    state = AsyncValue.data(
      currentState.copyWith(
        selectedItem: item,
        clearAvailableStock: true,
      ),
    );

    // If from-location is also selected, load available stock
    if (item != null && currentState.fromLocationId != null) {
      await getAvailableStock(
        itemId: item.id,
        locationId: currentState.fromLocationId!,
      );
    }
  }

  /// Update from-location.
  /// Automatically loads available stock if item is selected.
  Future<void> setFromLocation(int? locationId) async {
    final currentState = state.value ?? StockTransferState.initial();
    state = AsyncValue.data(
      currentState.copyWith(
        fromLocationId: locationId,
        clearAvailableStock: true,
      ),
    );

    // If item is also selected, load available stock
    if (locationId != null && currentState.selectedItem != null) {
      await getAvailableStock(
        itemId: currentState.selectedItem!.id,
        locationId: locationId,
      );
    }
  }

  /// Update to-location.
  void setToLocation(int? locationId) {
    final currentState = state.value ?? StockTransferState.initial();
    state = AsyncValue.data(
      currentState.copyWith(toLocationId: locationId),
    );
  }

  /// Update quantity.
  void setQuantity(double quantity) {
    final currentState = state.value ?? StockTransferState.initial();
    state = AsyncValue.data(
      currentState.copyWith(quantity: quantity),
    );
  }

  /// Update date.
  void setDate(DateTime date) {
    final currentState = state.value ?? StockTransferState.initial();
    state = AsyncValue.data(
      currentState.copyWith(date: date),
    );
  }

  /// Update reference.
  void setReference(String? reference) {
    final currentState = state.value ?? StockTransferState.initial();
    state = AsyncValue.data(
      currentState.copyWith(reference: reference),
    );
  }

  /// Update note.
  void setNote(String? note) {
    final currentState = state.value ?? StockTransferState.initial();
    state = AsyncValue.data(
      currentState.copyWith(note: note),
    );
  }

  /// Create stock transfer.
  /// Preserves existing state on error.
  Future<bool> createStockTransfer() async {
    final currentState = state.value ?? StockTransferState.initial();

    // Validate form
    if (!currentState.isValid) {
      final fieldErrors = <String, String>{};
      if (currentState.selectedItem == null) {
        fieldErrors['item'] = 'Item is required';
      }
      if (currentState.fromLocationId == null) {
        fieldErrors['fromLocation'] = 'From location is required';
      }
      if (currentState.toLocationId == null) {
        fieldErrors['toLocation'] = 'To location is required';
      }
      if (currentState.hasSameLocations) {
        fieldErrors['locations'] = currentState.locationError ?? '';
      }
      if (currentState.quantity <= 0) {
        fieldErrors['quantity'] = 'Quantity must be greater than 0';
      }
      if (currentState.quantityExceedsAvailable) {
        fieldErrors['quantity'] = currentState.quantityError ?? '';
      }

      state = AsyncValue.data(
        currentState.copyWith(
          fieldErrors: fieldErrors,
        ),
      );
      return false;
    }

    state = AsyncValue.data(currentState.copyWith(isSubmitting: true));

    try {
      final result = await _inventoryRepository.transferStock(
        itemId: currentState.selectedItem!.id,
        fromLocationId: currentState.fromLocationId!,
        toLocationId: currentState.toLocationId!,
        quantity: currentState.quantity.toStringAsFixed(3), // API expects string with 3 decimals
        reference: currentState.reference,
        note: currentState.note,
      );

      if (result.isSuccess) {
        // Success - reset form to initial state but keep locations/items
        state = AsyncValue.data(
          StockTransferState.initial().copyWith(
            availableLocations: currentState.availableLocations,
            availableItems: currentState.availableItems,
          ),
        );
        return true;
      } else {
        final failure = result as ApiFailure<StockTransfer>;
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
          error: 'Failed to create stock transfer: ${e.toString()}',
          isSubmitting: false,
        ),
      );
      return false;
    }
  }

  /// Clear error state.
  void clearError() {
    final currentState = state.value ?? StockTransferState.initial();
    state = AsyncValue.data(
      currentState.copyWith(
        clearError: true,
        clearFieldErrors: true,
      ),
    );
  }

  /// Reset form to initial state (keeps loaded locations/items).
  void resetForm() {
    final currentState = state.value ?? StockTransferState.initial();
    state = AsyncValue.data(
      StockTransferState.initial().copyWith(
        availableLocations: currentState.availableLocations,
        availableItems: currentState.availableItems,
      ),
    );
  }
}

/// Riverpod provider for StockTransferViewModel.
final stockTransferProvider =
    AsyncNotifierProvider<StockTransferViewModel, StockTransferState>(
  () {
    return StockTransferViewModel();
  },
);

/// Extension to get first element or null from list (generic).
extension InventoryItemListExtension on List<InventoryItem> {
  InventoryItem? get firstOrNull => isEmpty ? null : first;
}

