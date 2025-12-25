/// Domain models for inventory module.
/// These are clean, type-safe models used throughout the app.
/// Convert from DTOs using factory constructors.

import 'package:juix_na/features/inventory/model/inventory_dtos.dart';

/// Item kind enum.
enum ItemKind {
  ingredient('INGREDIENT'),
  finishedProduct('FINISHED_PRODUCT'),
  packaging('PACKAGING');

  final String value;
  const ItemKind(this.value);

  static ItemKind? fromString(String? value) {
    if (value == null) return null;
    for (final kind in ItemKind.values) {
      if (kind.value == value.toUpperCase()) {
        return kind;
      }
    }
    return null;
  }
}

/// Stock movement type enum.
enum MovementType {
  in_('IN'),
  out('OUT'),
  adjust('ADJUST'),
  transfer('TRANSFER');

  final String value;
  const MovementType(this.value);

  static MovementType? fromString(String? value) {
    if (value == null) return null;
    for (final type in MovementType.values) {
      if (type.value == value.toUpperCase()) {
        return type;
      }
    }
    return null;
  }
}

/// Location model.
class Location {
  final int id;
  final String name;
  final String? description;
  final bool isActive;
  final DateTime createdAt;
  final DateTime updatedAt;

  const Location({
    required this.id,
    required this.name,
    this.description,
    required this.isActive,
    required this.createdAt,
    required this.updatedAt,
  });

  factory Location.fromDTO(LocationDTO dto) {
    return Location(
      id: dto.id,
      name: dto.name,
      description: dto.description,
      isActive: dto.isActive,
      createdAt: DateTime.parse(dto.createdAt),
      updatedAt: DateTime.parse(dto.updatedAt),
    );
  }

  @override
  String toString() => 'Location(id: $id, name: $name)';
}

/// Item location breakdown (stock at a specific location).
class ItemLocation {
  final int locationId;
  final String locationName;
  final double currentStock; // Parsed from string

  const ItemLocation({
    required this.locationId,
    required this.locationName,
    required this.currentStock,
  });

  factory ItemLocation.fromDTO(ItemLocationDTO dto) {
    return ItemLocation(
      locationId: dto.locationId,
      locationName: dto.locationName,
      currentStock: double.tryParse(dto.currentStock) ?? 0.0,
    );
  }

  @override
  String toString() =>
      'ItemLocation(locationId: $locationId, stock: $currentStock)';
}

/// Inventory item model.
class InventoryItem {
  final int id;
  final String name;
  final String sku;
  final String unit;
  final ItemKind kind;
  final double? totalQuantity; // Aggregated across all locations
  final double? currentStock; // For location-specific views
  final bool? isLowStock;
  final List<ItemLocation>? locations; // Location breakdown

  const InventoryItem({
    required this.id,
    required this.name,
    required this.sku,
    required this.unit,
    required this.kind,
    this.totalQuantity,
    this.currentStock,
    this.isLowStock,
    this.locations,
  });

  factory InventoryItem.fromDTO(InventoryItemDTO dto) {
    return InventoryItem(
      id: dto.id,
      name: dto.name,
      sku: dto.sku,
      unit: dto.unit,
      kind: ItemKind.fromString(dto.kind) ?? ItemKind.finishedProduct,
      totalQuantity: dto.totalQuantity != null
          ? double.tryParse(dto.totalQuantity!)
          : null,
      currentStock:
          dto.currentStock != null ? double.tryParse(dto.currentStock!) : null,
      isLowStock: dto.isLowStock,
      locations: dto.locations?.map((l) => ItemLocation.fromDTO(l)).toList(),
    );
  }

  /// Get stock at a specific location.
  double? getStockAtLocation(int locationId) {
    return locations
        ?.firstWhere(
          (l) => l.locationId == locationId,
          orElse: () => const ItemLocation(
            locationId: -1,
            locationName: '',
            currentStock: 0.0,
          ),
        )
        .currentStock;
  }

  /// Get display quantity (total or current stock).
  double getDisplayQuantity() {
    return currentStock ?? totalQuantity ?? 0.0;
  }

  @override
  String toString() =>
      'InventoryItem(id: $id, name: $name, sku: $sku, kind: ${kind.value})';
}

/// Pagination information.
class PaginationInfo {
  final int skip;
  final int limit;
  final int total;
  final int? page;
  final int? pageSize;
  final int? totalPages;

  const PaginationInfo({
    required this.skip,
    required this.limit,
    required this.total,
    this.page,
    this.pageSize,
    this.totalPages,
  });

  factory PaginationInfo.fromDTO(PaginationDTO dto) {
    return PaginationInfo(
      skip: dto.skip,
      limit: dto.limit,
      total: dto.total,
      page: dto.page,
      pageSize: dto.pageSize,
      totalPages: dto.totalPages,
    );
  }

  /// Check if there are more pages.
  bool get hasMore {
    if (page != null && totalPages != null) {
      return page! < totalPages!;
    }
    return (skip + limit) < total;
  }

  /// Get current page number (1-indexed).
  int get currentPage {
    if (page != null) return page!;
    return (skip ~/ limit) + 1;
  }

  @override
  String toString() =>
      'PaginationInfo(page: ${currentPage}, total: $total, hasMore: $hasMore)';
}

/// Stock movement transaction model.
class StockMovement {
  final int id;
  final int itemId;
  final String itemName;
  final int locationId;
  final String locationName;
  final double quantity; // Parsed from string
  final MovementType type;
  final String reason; // SALE, BREAKAGE, etc.
  final String? reference;
  final DateTime createdAt;
  final String? createdBy;

  const StockMovement({
    required this.id,
    required this.itemId,
    required this.itemName,
    required this.locationId,
    required this.locationName,
    required this.quantity,
    required this.type,
    required this.reason,
    this.reference,
    required this.createdAt,
    this.createdBy,
  });

  factory StockMovement.fromDTO(StockMovementDTO dto) {
    return StockMovement(
      id: dto.id,
      itemId: dto.itemId,
      itemName: dto.itemName,
      locationId: dto.locationId,
      locationName: dto.locationName,
      quantity: double.tryParse(dto.quantity) ?? 0.0,
      type: MovementType.fromString(dto.type) ?? MovementType.adjust,
      reason: dto.reason,
      reference: dto.reference,
      createdAt: DateTime.parse(dto.createdAt),
      createdBy: dto.createdBy,
    );
  }

  /// Check if this is a stock-in movement.
  bool get isStockIn => type == MovementType.in_ || quantity > 0;

  /// Check if this is a stock-out movement.
  bool get isStockOut => type == MovementType.out || quantity < 0;

  @override
  String toString() =>
      'StockMovement(id: $id, item: $itemName, type: ${type.value}, qty: $quantity)';
}

/// Inventory overview KPIs model.
class InventoryOverviewKPIs {
  final int totalItems;
  final int totalSkus;
  final double totalQuantityAllLocations;
  final int lowStockItems;
  final int outOfStockItems;

  const InventoryOverviewKPIs({
    required this.totalItems,
    required this.totalSkus,
    required this.totalQuantityAllLocations,
    required this.lowStockItems,
    required this.outOfStockItems,
  });

  factory InventoryOverviewKPIs.fromDTO(InventoryOverviewKPIsDTO dto) {
    return InventoryOverviewKPIs(
      totalItems: dto.totalItems,
      totalSkus: dto.totalSkus,
      totalQuantityAllLocations:
          double.tryParse(dto.totalQuantityAllLocations) ?? 0.0,
      lowStockItems: dto.lowStockItems,
      outOfStockItems: dto.outOfStockItems,
    );
  }

  @override
  String toString() =>
      'InventoryOverviewKPIs(totalItems: $totalItems, lowStock: $lowStockItems)';
}

/// Inventory overview model (KPIs + items + pagination).
class InventoryOverview {
  final InventoryOverviewKPIs kpis;
  final PaginationInfo pagination;
  final List<InventoryItem> items;

  const InventoryOverview({
    required this.kpis,
    required this.pagination,
    required this.items,
  });

  factory InventoryOverview.fromDTO(InventoryOverviewResponseDTO dto) {
    return InventoryOverview(
      kpis: InventoryOverviewKPIs.fromDTO(dto.kpis),
      pagination: PaginationInfo.fromDTO(dto.page),
      items: dto.items.map((item) => InventoryItem.fromDTO(item)).toList(),
    );
  }

  @override
  String toString() =>
      'InventoryOverview(items: ${items.length}, kpis: $kpis)';
}

