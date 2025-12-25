import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:juix_na/bootstrap.dart';
import 'package:juix_na/core/network/api_result.dart';
import 'package:juix_na/features/inventory/data/inventory_api.dart';
import 'package:juix_na/features/inventory/data/inventory_repository.dart';
import 'package:juix_na/features/inventory/model/inventory_models.dart';
import 'package:juix_na/features/inventory/viewmodel/inventory_filters.dart';
import 'package:juix_na/features/inventory/viewmodel/inventory_overview_state.dart';

/// Inventory Overview ViewModel using Riverpod AsyncNotifier.
/// Manages inventory overview state: items, KPIs, locations, filters.
class InventoryOverviewViewModel extends AsyncNotifier<InventoryOverviewState> {
  InventoryRepository? _repository;

  /// Get InventoryRepository from ref (dependency injection).
  InventoryRepository get _inventoryRepository {
    _repository ??= ref.read(inventoryRepositoryProvider);
    return _repository!;
  }

  @override
  Future<InventoryOverviewState> build() async {
    // On initialization, load locations and overview data
    return await _loadInitialData();
  }

  /// Load initial data (locations and overview in parallel).
  /// Preserves existing data if one call fails.
  Future<InventoryOverviewState> _loadInitialData() async {
    try {
      // Load locations and overview in parallel for better performance
      final locationsFuture = _inventoryRepository.getLocations();
      final overviewFuture = _inventoryRepository.getInventoryOverview();

      final results = await Future.wait([locationsFuture, overviewFuture]);
      final locationsResult = results[0] as ApiResult<List<Location>>;
      final overviewResult = results[1] as ApiResult<InventoryOverview>;

      // Extract locations (preserve existing if call fails)
      final locations = locationsResult.isSuccess
          ? (locationsResult as ApiSuccess<List<Location>>).data
          : <Location>[];

      // Extract overview (preserve existing data if call fails)
      String? error;
      List<InventoryItem> items = [];
      InventoryOverviewKPIs? kpis;

      if (overviewResult.isSuccess) {
        final success = overviewResult as ApiSuccess<InventoryOverview>;
        final overview = success.data;
        items = overview.items;
        kpis = overview.kpis;
      } else {
        final failure = overviewResult as ApiFailure<InventoryOverview>;
        error = failure.error.message;
        // Preserve existing items/kpis if available
        items = state.value?.items ?? [];
        kpis = state.value?.kpis;
      }

      return InventoryOverviewState(
        items: items,
        kpis: kpis,
        locations: locations,
        isLoading: false,
        isLoadingKPIs: false,
        isLoadingLocations: false,
        error: error,
      );
    } catch (e) {
      // On exception, preserve existing data
      final currentState = state.value;
      return InventoryOverviewState(
        items: currentState?.items ?? [],
        kpis: currentState?.kpis,
        locations: currentState?.locations ?? [],
        error: 'Failed to load inventory data: ${e.toString()}',
        isLoading: false,
        isLoadingKPIs: false,
        isLoadingLocations: false,
      );
    }
  }

  /// Load inventory items (with current filters).
  /// Preserves existing data on error.
  Future<void> loadInventoryItems() async {
    final currentState = state.value ?? InventoryOverviewState.initial();
    state = AsyncValue.data(currentState.copyWith(isLoadingItems: true));

    try {
      final filters = currentState.filters;
      final locationId = filters.locationId ?? currentState.selectedLocationId;

      ApiResult result;

      if (locationId != null) {
        // Load items for specific location
        result = await _inventoryRepository.getLocationItems(
          locationId: locationId,
          kind: filters.kind?.value,
          search: filters.search,
        );
      } else {
        // Load items across all locations
        result = await _inventoryRepository.getInventoryItems(
          kind: filters.kind?.value,
          search: filters.search,
        );
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
            items: items,
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
          error: 'Failed to load items: ${e.toString()}',
          isLoadingItems: false,
        ),
      );
    }
  }

  /// Load inventory overview (KPIs + items).
  /// Preserves existing data on error.
  Future<void> loadKPIs() async {
    final currentState = state.value ?? InventoryOverviewState.initial();
    state = AsyncValue.data(currentState.copyWith(isLoadingKPIs: true));

    try {
      final filters = currentState.filters;
      final locationId = filters.locationId ?? currentState.selectedLocationId;

      final result = await _inventoryRepository.getInventoryOverview(
        locationId: locationId,
        kind: filters.kind?.value,
        search: filters.search,
      );

      if (result.isSuccess) {
        final success = result as ApiSuccess<InventoryOverview>;
        final overview = success.data;

        state = AsyncValue.data(
          currentState.copyWith(
            items: overview.items,
            kpis: overview.kpis,
            isLoadingKPIs: false,
            clearError: true,
          ),
        );
      } else {
        final failure = result as ApiFailure<InventoryOverview>;
        // Preserve existing items/kpis on error
        state = AsyncValue.data(
          currentState.copyWith(
            error: failure.error.message,
            isLoadingKPIs: false,
          ),
        );
      }
    } catch (e) {
      // Preserve existing items/kpis on exception
      state = AsyncValue.data(
        currentState.copyWith(
          error: 'Failed to load KPIs: ${e.toString()}',
          isLoadingKPIs: false,
        ),
      );
    }
  }

  /// Load all locations.
  /// Preserves existing locations on error.
  Future<void> loadLocations() async {
    final currentState = state.value ?? InventoryOverviewState.initial();
    state = AsyncValue.data(currentState.copyWith(isLoadingLocations: true));

    try {
      final result = await _inventoryRepository.getLocations();

      if (result.isSuccess) {
        final success = result as ApiSuccess<List<Location>>;
        final locations = success.data;

        state = AsyncValue.data(
          currentState.copyWith(
            locations: locations,
            isLoadingLocations: false,
            clearError: true,
          ),
        );
      } else {
        final failure = result as ApiFailure<List<Location>>;
        // Preserve existing locations on error
        state = AsyncValue.data(
          currentState.copyWith(
            error: failure.error.message,
            isLoadingLocations: false,
          ),
        );
      }
    } catch (e) {
      // Preserve existing locations on exception
      state = AsyncValue.data(
        currentState.copyWith(
          error: 'Failed to load locations: ${e.toString()}',
          isLoadingLocations: false,
        ),
      );
    }
  }

  /// Refresh inventory data (reload overview).
  Future<void> refreshInventory() async {
    await loadKPIs();
  }

  /// Apply filters and reload data.
  Future<void> applyFilters(InventoryFilters filters) async {
    state = AsyncValue.data(
      (state.value ?? InventoryOverviewState.initial()).copyWith(
        filters: filters,
      ),
    );

    // Reload data with new filters
    await loadKPIs();
  }

  /// Select a location and reload data.
  Future<void> selectLocation(int? locationId) async {
    state = AsyncValue.data(
      (state.value ?? InventoryOverviewState.initial()).copyWith(
        selectedLocationId: locationId,
        // Update filters to include location
        filters: (state.value?.filters ?? const InventoryFilters())
            .copyWith(locationId: locationId),
      ),
    );

    // Reload data for selected location
    await loadKPIs();
  }

  /// Clear error state.
  void clearError() {
    state = AsyncValue.data(
      (state.value ?? InventoryOverviewState.initial()).copyWith(
        clearError: true,
      ),
    );
  }
}

/// Riverpod provider for InventoryApi.
final inventoryApiProvider = Provider<InventoryApi>((ref) {
  final apiClient = ref.watch(apiClientProvider);
  return InventoryApi(apiClient: apiClient);
});

/// Riverpod provider for InventoryRepository.
final inventoryRepositoryProvider = Provider<InventoryRepository>((ref) {
  final inventoryApi = ref.watch(inventoryApiProvider);
  return InventoryRepository(inventoryApi: inventoryApi);
});

/// Riverpod provider for InventoryOverviewViewModel.
final inventoryOverviewProvider =
    AsyncNotifierProvider<InventoryOverviewViewModel, InventoryOverviewState>(
  () {
    return InventoryOverviewViewModel();
  },
);

/// Derived provider for inventory items (for easy access).
final inventoryItemsProvider = Provider<List<InventoryItem>>((ref) {
  final state = ref.watch(inventoryOverviewProvider);
  return state.value?.items ?? [];
});

/// Derived provider for inventory KPIs (for easy access).
final inventoryKPIsProvider = Provider<InventoryOverviewKPIs?>((ref) {
  final state = ref.watch(inventoryOverviewProvider);
  return state.value?.kpis;
});

/// Derived provider for locations (for easy access).
final inventoryLocationsProvider = Provider<List<Location>>((ref) {
  final state = ref.watch(inventoryOverviewProvider);
  return state.value?.locations ?? [];
});

