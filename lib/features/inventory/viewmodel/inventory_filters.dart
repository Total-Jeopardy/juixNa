import 'package:juix_na/features/inventory/model/inventory_models.dart';

/// Filters for inventory items.
/// Used for filtering items by kind, location, search query, etc.
class InventoryFilters {
  final ItemKind? kind; // INGREDIENT, FINISHED_PRODUCT, PACKAGING
  final int? locationId; // Filter by specific location
  final String? search; // Text search (name or SKU)
  final String? category; // Category filter (for future use)
  final String? brand; // Brand filter (for future use)

  const InventoryFilters({
    this.kind,
    this.locationId,
    this.search,
    this.category,
    this.brand,
  });

  /// Create a copy with updated fields.
  InventoryFilters copyWith({
    ItemKind? kind,
    int? locationId,
    String? search,
    String? category,
    String? brand,
    bool clearKind = false,
    bool clearLocationId = false,
    bool clearSearch = false,
    bool clearCategory = false,
    bool clearBrand = false,
  }) {
    return InventoryFilters(
      kind: clearKind ? null : (kind ?? this.kind),
      locationId: clearLocationId ? null : (locationId ?? this.locationId),
      search: clearSearch ? null : (search ?? this.search),
      category: clearCategory ? null : (category ?? this.category),
      brand: clearBrand ? null : (brand ?? this.brand),
    );
  }

  /// Check if any filter is active.
  bool get hasActiveFilters {
    return kind != null ||
        locationId != null ||
        (search != null && search!.isNotEmpty) ||
        (category != null && category!.isNotEmpty) ||
        (brand != null && brand!.isNotEmpty);
  }

  /// Clear all filters.
  InventoryFilters clearAll() {
    return const InventoryFilters();
  }

  /// Convert filters to query parameters for API calls.
  /// 
  /// Matches API specification:
  /// - `kind`: INGREDIENT | FINISHED_PRODUCT | PACKAGING
  /// - `location_id`: integer (for location-specific endpoints)
  /// - `search`: text search (matches name or SKU)
  /// 
  /// Note: For search, consider debouncing in the UI to avoid
  /// hammering the API on every keystroke (e.g., 300-500ms delay).
  Map<String, dynamic> toQueryParams() {
    final params = <String, dynamic>{};
    if (kind != null) {
      params['kind'] = kind!.value;
    }
    if (locationId != null) {
      params['location_id'] = locationId.toString();
    }
    if (search != null && search!.isNotEmpty) {
      params['search'] = search!;
    }
    // Note: category and brand are not yet supported by API
    return params;
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is InventoryFilters &&
        other.kind == kind &&
        other.locationId == locationId &&
        other.search == search &&
        other.category == category &&
        other.brand == brand;
  }

  @override
  int get hashCode {
    return Object.hash(kind, locationId, search, category, brand);
  }

  @override
  String toString() {
    return 'InventoryFilters(kind: $kind, locationId: $locationId, search: $search)';
  }
}

