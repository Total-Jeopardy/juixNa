import 'package:juix_na/features/inventory/model/inventory_models.dart';
import 'package:juix_na/features/inventory/viewmodel/inventory_filters.dart';

/// State for inventory overview screen.
/// Contains items, KPIs, locations, filters, and loading/error states.
class InventoryOverviewState {
  final List<InventoryItem> items;
  final InventoryOverviewKPIs? kpis;
  final List<Location> locations;
  final int? selectedLocationId;
  final InventoryFilters filters;
  final bool isLoading;
  final bool isLoadingItems;
  final bool isLoadingKPIs;
  final bool isLoadingLocations;
  final String? error;

  const InventoryOverviewState({
    this.items = const [],
    this.kpis,
    this.locations = const [],
    this.selectedLocationId,
    this.filters = const InventoryFilters(),
    this.isLoading = false,
    this.isLoadingItems = false,
    this.isLoadingKPIs = false,
    this.isLoadingLocations = false,
    this.error,
  });

  /// Create a copy with updated fields.
  InventoryOverviewState copyWith({
    List<InventoryItem>? items,
    InventoryOverviewKPIs? kpis,
    List<Location>? locations,
    int? selectedLocationId,
    InventoryFilters? filters,
    bool? isLoading,
    bool? isLoadingItems,
    bool? isLoadingKPIs,
    bool? isLoadingLocations,
    String? error,
    bool clearKpis = false,
    bool clearError = false,
    bool clearSelectedLocation = false,
  }) {
    return InventoryOverviewState(
      items: items ?? this.items,
      kpis: clearKpis ? null : (kpis ?? this.kpis),
      locations: locations ?? this.locations,
      selectedLocationId: clearSelectedLocation
          ? null
          : (selectedLocationId ?? this.selectedLocationId),
      filters: filters ?? this.filters,
      isLoading: isLoading ?? this.isLoading,
      isLoadingItems: isLoadingItems ?? this.isLoadingItems,
      isLoadingKPIs: isLoadingKPIs ?? this.isLoadingKPIs,
      isLoadingLocations: isLoadingLocations ?? this.isLoadingLocations,
      error: clearError ? null : (error ?? this.error),
    );
  }

  /// Create loading state.
  factory InventoryOverviewState.loading() {
    return const InventoryOverviewState(isLoading: true);
  }

  /// Create error state.
  factory InventoryOverviewState.error(String error) {
    return InventoryOverviewState(error: error, isLoading: false);
  }

  /// Create initial/empty state.
  factory InventoryOverviewState.initial() {
    return const InventoryOverviewState();
  }

  /// Check if state has data loaded.
  bool get hasData => items.isNotEmpty || kpis != null;

  /// Check if state is in error state.
  bool get hasError => error != null && error!.isNotEmpty;

  /// Check if any loading operation is in progress.
  bool get isAnyLoading =>
      isLoading || isLoadingItems || isLoadingKPIs || isLoadingLocations;

  /// Get selected location (if any).
  Location? get selectedLocation {
    if (selectedLocationId == null) return null;
    return locations.firstWhere(
      (loc) => loc.id == selectedLocationId,
      orElse: () =>
          locations.firstOrNull ??
          Location(
            id: -1,
            name: '',
            isActive: false,
            createdAt: DateTime(1970),
            updatedAt: DateTime(1970),
          ),
    );
  }

  @override
  String toString() {
    return 'InventoryOverviewState('
        'items: ${items.length}, '
        'kpis: ${kpis != null}, '
        'locations: ${locations.length}, '
        'selectedLocationId: $selectedLocationId, '
        'isLoading: $isLoading, '
        'isLoadingItems: $isLoadingItems, '
        'isLoadingKPIs: $isLoadingKPIs, '
        'isLoadingLocations: $isLoadingLocations, '
        'error: $error'
        ')';
  }
}

/// Extension to get first element or null from list.
extension ListExtension<T> on List<T> {
  T? get firstOrNull => isEmpty ? null : first;
}
