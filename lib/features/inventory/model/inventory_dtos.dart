/// Data Transfer Objects for inventory API requests and responses.
/// These match the backend API contract exactly.

/// Location DTO from locations list endpoint.
class LocationDTO {
  final int id;
  final String name;
  final String? description;
  final bool isActive;
  final String createdAt;
  final String updatedAt;

  const LocationDTO({
    required this.id,
    required this.name,
    this.description,
    required this.isActive,
    required this.createdAt,
    required this.updatedAt,
  });

  factory LocationDTO.fromJson(Map<String, dynamic> json) {
    return LocationDTO(
      id: json['id'] as int,
      name: json['name'] as String,
      description: json['description'] as String?,
      isActive: json['is_active'] as bool,
      createdAt: json['created_at'] as String,
      updatedAt: json['updated_at'] as String,
    );
  }

  Map<String, dynamic> toJson() => {
    'id': id,
    'name': name,
    'description': description,
    'is_active': isActive,
    'created_at': createdAt,
    'updated_at': updatedAt,
  };
}

/// Item location breakdown (stock at a specific location).
class ItemLocationDTO {
  final int locationId;
  final String locationName;
  final String currentStock;

  const ItemLocationDTO({
    required this.locationId,
    required this.locationName,
    required this.currentStock,
  });

  factory ItemLocationDTO.fromJson(Map<String, dynamic> json) {
    return ItemLocationDTO(
      locationId: json['location_id'] as int,
      locationName: json['location_name'] as String,
      currentStock: json['current_stock'] as String,
    );
  }

  Map<String, dynamic> toJson() => {
    'location_id': locationId,
    'location_name': locationName,
    'current_stock': currentStock,
  };
}

/// Inventory item DTO (with location breakdowns).
class InventoryItemDTO {
  final int id;
  final String name;
  final String sku;
  final String unit;
  final String kind; // INGREDIENT | FINISHED_PRODUCT | PACKAGING
  final String? totalQuantity; // Aggregated across all locations
  final String? currentStock; // For location-specific endpoints
  final bool? isLowStock; // For overview endpoint
  final List<ItemLocationDTO>? locations; // Location breakdown

  const InventoryItemDTO({
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

  factory InventoryItemDTO.fromJson(Map<String, dynamic> json) {
    // Handle locations array (optional)
    final locationsData = json['locations'] as List<dynamic>?;
    final locations = locationsData
        ?.map((e) => ItemLocationDTO.fromJson(e as Map<String, dynamic>))
        .toList();

    return InventoryItemDTO(
      id: json['id'] as int,
      name: json['name'] as String,
      sku: json['sku'] as String,
      unit: json['unit'] as String,
      kind: json['kind'] as String,
      totalQuantity: json['total_quantity'] as String?,
      currentStock: json['current_stock'] as String?,
      isLowStock: json['is_low_stock'] as bool?,
      locations: locations,
    );
  }

  Map<String, dynamic> toJson() => {
    'id': id,
    'name': name,
    'sku': sku,
    'unit': unit,
    'kind': kind,
    if (totalQuantity != null) 'total_quantity': totalQuantity,
    if (currentStock != null) 'current_stock': currentStock,
    if (isLowStock != null) 'is_low_stock': isLowStock,
    if (locations != null)
      'locations': locations!.map((e) => e.toJson()).toList(),
  };
}

/// Pagination info DTO.
class PaginationDTO {
  final int skip;
  final int limit;
  final int total;
  final int? page;
  final int? pageSize;
  final int? totalPages;

  const PaginationDTO({
    required this.skip,
    required this.limit,
    required this.total,
    this.page,
    this.pageSize,
    this.totalPages,
  });

  factory PaginationDTO.fromJson(Map<String, dynamic> json) {
    return PaginationDTO(
      skip: json['skip'] as int? ?? json['page'] as int? ?? 0,
      limit: json['limit'] as int? ?? json['page_size'] as int? ?? 0,
      total: json['total'] as int? ?? json['total_items'] as int? ?? 0,
      page: json['page'] as int?,
      pageSize: json['page_size'] as int?,
      totalPages: json['total_pages'] as int?,
    );
  }

  Map<String, dynamic> toJson() => {
    if (skip != 0) 'skip': skip,
    if (limit != 0) 'limit': limit,
    'total': total,
    if (page != null) 'page': page,
    if (pageSize != null) 'page_size': pageSize,
    if (totalPages != null) 'total_pages': totalPages,
  };
}

/// Response DTO for inventory items list (all locations).
class InventoryItemsResponseDTO {
  final List<InventoryItemDTO> items;
  final PaginationDTO pagination;

  const InventoryItemsResponseDTO({
    required this.items,
    required this.pagination,
  });

  factory InventoryItemsResponseDTO.fromJson(Map<String, dynamic> json) {
    final itemsData = json['items'] as List<dynamic>;
    final items = itemsData
        .map((e) => InventoryItemDTO.fromJson(e as Map<String, dynamic>))
        .toList();

    return InventoryItemsResponseDTO(
      items: items,
      pagination: PaginationDTO.fromJson(
        json['pagination'] as Map<String, dynamic>,
      ),
    );
  }
}

/// Response DTO for items at a specific location.
class LocationItemsResponseDTO {
  final LocationDTO location;
  final List<InventoryItemDTO> items;
  final PaginationDTO pagination;

  const LocationItemsResponseDTO({
    required this.location,
    required this.items,
    required this.pagination,
  });

  factory LocationItemsResponseDTO.fromJson(Map<String, dynamic> json) {
    final itemsData = json['items'] as List<dynamic>;
    final items = itemsData
        .map((e) => InventoryItemDTO.fromJson(e as Map<String, dynamic>))
        .toList();

    return LocationItemsResponseDTO(
      location: LocationDTO.fromJson(json['location'] as Map<String, dynamic>),
      items: items,
      pagination: PaginationDTO.fromJson(
        json['pagination'] as Map<String, dynamic>,
      ),
    );
  }
}

/// Stock movement transaction DTO.
class StockMovementDTO {
  final int id;
  final int itemId;
  final String itemName;
  final int locationId;
  final String locationName;
  final String quantity;
  final String type; // IN | OUT | ADJUST | TRANSFER
  final String reason; // SALE, BREAKAGE, etc.
  final String? reference;
  final String createdAt;
  final String? createdBy; // Email or user identifier

  const StockMovementDTO({
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

  factory StockMovementDTO.fromJson(Map<String, dynamic> json) {
    return StockMovementDTO(
      id: json['id'] as int,
      itemId: json['item_id'] as int,
      itemName: json['item_name'] as String,
      locationId: json['location_id'] as int,
      locationName: json['location_name'] as String,
      quantity: json['quantity'] as String,
      type: json['type'] as String,
      reason: json['reason'] as String,
      reference: json['reference'] as String?,
      createdAt: json['created_at'] as String,
      createdBy: json['created_by'] as String?,
    );
  }

  Map<String, dynamic> toJson() => {
    'id': id,
    'item_id': itemId,
    'item_name': itemName,
    'location_id': locationId,
    'location_name': locationName,
    'quantity': quantity,
    'type': type,
    'reason': reason,
    if (reference != null) 'reference': reference,
    'created_at': createdAt,
    if (createdBy != null) 'created_by': createdBy,
  };
}

/// Response DTO for stock movements list.
class StockMovementsResponseDTO {
  final List<StockMovementDTO> transactions;
  final PaginationDTO pagination;

  const StockMovementsResponseDTO({
    required this.transactions,
    required this.pagination,
  });

  factory StockMovementsResponseDTO.fromJson(Map<String, dynamic> json) {
    final transactionsData = json['transactions'] as List<dynamic>;
    final transactions = transactionsData
        .map((e) => StockMovementDTO.fromJson(e as Map<String, dynamic>))
        .toList();

    return StockMovementsResponseDTO(
      transactions: transactions,
      pagination: PaginationDTO.fromJson(
        json['pagination'] as Map<String, dynamic>,
      ),
    );
  }
}

/// Request DTO for stock transfer.
class StockTransferRequestDTO {
  final int itemId;
  final int fromLocationId;
  final int toLocationId;
  final String quantity;
  final String? reference;
  final String? note;

  const StockTransferRequestDTO({
    required this.itemId,
    required this.fromLocationId,
    required this.toLocationId,
    required this.quantity,
    this.reference,
    this.note,
  });

  Map<String, dynamic> toJson() => {
    'item_id': itemId,
    'from_location_id': fromLocationId,
    'to_location_id': toLocationId,
    'quantity': quantity,
    if (reference != null) 'reference': reference,
    if (note != null) 'note': note,
  };
}

/// Response DTO for stock transfer.
class StockTransferResponseDTO {
  final int id;
  final int itemId;
  final int fromLocationId;
  final int toLocationId;
  final String quantity;
  final String? reference;
  final String? note;
  final String createdAt;
  final int createdById;

  const StockTransferResponseDTO({
    required this.id,
    required this.itemId,
    required this.fromLocationId,
    required this.toLocationId,
    required this.quantity,
    this.reference,
    this.note,
    required this.createdAt,
    required this.createdById,
  });

  factory StockTransferResponseDTO.fromJson(Map<String, dynamic> json) {
    return StockTransferResponseDTO(
      id: json['id'] as int,
      itemId: json['item_id'] as int,
      fromLocationId: json['from_location_id'] as int,
      toLocationId: json['to_location_id'] as int,
      quantity: json['quantity'] as String,
      reference: json['reference'] as String?,
      note: json['note'] as String?,
      createdAt: json['created_at'] as String,
      createdById: json['created_by_id'] as int,
    );
  }
}

/// Request DTO for stock adjustment.
class StockAdjustmentRequestDTO {
  final int itemId;
  final int locationId;
  final String quantity; // Positive = IN, negative = OUT
  final String reason; // BREAKAGE, etc.
  final String? reference;
  final String? note;

  const StockAdjustmentRequestDTO({
    required this.itemId,
    required this.locationId,
    required this.quantity,
    required this.reason,
    this.reference,
    this.note,
  });

  Map<String, dynamic> toJson() => {
    'item_id': itemId,
    'location_id': locationId,
    'quantity': quantity,
    'reason': reason,
    if (reference != null) 'reference': reference,
    if (note != null) 'note': note,
  };
}

/// Response DTO for stock adjustment.
class StockAdjustmentResponseDTO {
  final int id;
  final int itemId;
  final int locationId;
  final String quantity;
  final String type; // ADJUST
  final String reason;
  final String? reference;
  final String? note;
  final String createdAt;
  final int createdById;

  const StockAdjustmentResponseDTO({
    required this.id,
    required this.itemId,
    required this.locationId,
    required this.quantity,
    required this.type,
    required this.reason,
    this.reference,
    this.note,
    required this.createdAt,
    required this.createdById,
  });

  factory StockAdjustmentResponseDTO.fromJson(Map<String, dynamic> json) {
    return StockAdjustmentResponseDTO(
      id: json['id'] as int,
      itemId: json['item_id'] as int,
      locationId: json['location_id'] as int,
      quantity: json['quantity'] as String,
      type: json['type'] as String,
      reason: json['reason'] as String,
      reference: json['reference'] as String?,
      note: json['note'] as String?,
      createdAt: json['created_at'] as String,
      createdById: json['created_by_id'] as int,
    );
  }
}

/// KPIs DTO for inventory overview.
class InventoryOverviewKPIsDTO {
  final int totalItems;
  final int totalSkus;
  final String totalQuantityAllLocations;
  final int lowStockItems;
  final int outOfStockItems;

  const InventoryOverviewKPIsDTO({
    required this.totalItems,
    required this.totalSkus,
    required this.totalQuantityAllLocations,
    required this.lowStockItems,
    required this.outOfStockItems,
  });

  factory InventoryOverviewKPIsDTO.fromJson(Map<String, dynamic> json) {
    return InventoryOverviewKPIsDTO(
      totalItems: json['total_items'] as int,
      totalSkus: json['total_skus'] as int,
      totalQuantityAllLocations: json['total_quantity_all_locations'] as String,
      lowStockItems: json['low_stock_items'] as int,
      outOfStockItems: json['out_of_stock_items'] as int,
    );
  }

  Map<String, dynamic> toJson() => {
    'total_items': totalItems,
    'total_skus': totalSkus,
    'total_quantity_all_locations': totalQuantityAllLocations,
    'low_stock_items': lowStockItems,
    'out_of_stock_items': outOfStockItems,
  };
}

/// Response DTO for inventory overview (KPIs + items + pagination).
class InventoryOverviewResponseDTO {
  final InventoryOverviewKPIsDTO kpis;
  final PaginationDTO page; // Uses page/page_size format
  final List<InventoryItemDTO> items;

  const InventoryOverviewResponseDTO({
    required this.kpis,
    required this.page,
    required this.items,
  });

  factory InventoryOverviewResponseDTO.fromJson(Map<String, dynamic> json) {
    final itemsData = json['items'] as List<dynamic>;
    final items = itemsData
        .map((e) => InventoryItemDTO.fromJson(e as Map<String, dynamic>))
        .toList();

    return InventoryOverviewResponseDTO(
      kpis: InventoryOverviewKPIsDTO.fromJson(
        json['kpis'] as Map<String, dynamic>,
      ),
      page: PaginationDTO.fromJson(json['page'] as Map<String, dynamic>),
      items: items,
    );
  }
}
