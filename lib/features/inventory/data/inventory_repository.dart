import 'package:juix_na/core/network/api_result.dart';
import 'package:juix_na/features/inventory/data/inventory_api.dart';
import 'package:juix_na/features/inventory/model/inventory_dtos.dart';
import 'package:juix_na/features/inventory/model/inventory_models.dart';

/// Repository for inventory operations.
/// Wraps InventoryApi and transforms DTOs to domain models.
class InventoryRepository {
  final InventoryApi _inventoryApi;

  InventoryRepository({required InventoryApi inventoryApi})
    : _inventoryApi = inventoryApi;

  /// Get all inventory locations.
  ///
  /// Returns ApiResult<List<Location>>:
  /// - Success: List of Location domain models
  /// - Failure: ApiError from API call
  Future<ApiResult<List<Location>>> getLocations({bool? isActive}) async {
    final result = await _inventoryApi.getLocations(isActive: isActive);

    if (result.isSuccess) {
      final success = result as ApiSuccess<List<LocationDTO>>;
      final locations = success.data
          .map((dto) => Location.fromDTO(dto))
          .toList();
      return ApiSuccess(locations);
    } else {
      final failure = result as ApiFailure<List<LocationDTO>>;
      return ApiFailure<List<Location>>(
        failure.error,
        statusCode: failure.statusCode,
      );
    }
  }

  /// Get inventory items across all locations.
  ///
  /// Returns ApiResult<InventoryItemsResponse>:
  /// - Success: InventoryItemsResponse with items (domain models) and pagination
  /// - Failure: ApiError from API call
  Future<ApiResult<InventoryItemsResponse>> getInventoryItems({
    String? kind,
    String? search,
    int? skip,
    int? limit,
  }) async {
    final result = await _inventoryApi.getInventoryItems(
      kind: kind,
      search: search,
      skip: skip,
      limit: limit,
    );

    if (result.isSuccess) {
      final success = result as ApiSuccess<InventoryItemsResponseDTO>;
      final dto = success.data;

      final items = dto.items
          .map((itemDto) => InventoryItem.fromDTO(itemDto))
          .toList();
      final pagination = PaginationInfo.fromDTO(dto.pagination);

      return ApiSuccess(
        InventoryItemsResponse(items: items, pagination: pagination),
      );
    } else {
      final failure = result as ApiFailure<InventoryItemsResponseDTO>;
      return ApiFailure<InventoryItemsResponse>(
        failure.error,
        statusCode: failure.statusCode,
      );
    }
  }

  /// Get inventory items at a specific location.
  ///
  /// Returns ApiResult<LocationItemsResponse>:
  /// - Success: LocationItemsResponse with location, items (domain models), and pagination
  /// - Failure: ApiError from API call
  Future<ApiResult<LocationItemsResponse>> getLocationItems({
    required int locationId,
    String? kind,
    String? search,
    int? skip,
    int? limit,
  }) async {
    final result = await _inventoryApi.getLocationItems(
      locationId: locationId,
      kind: kind,
      search: search,
      skip: skip,
      limit: limit,
    );

    if (result.isSuccess) {
      final success = result as ApiSuccess<LocationItemsResponseDTO>;
      final dto = success.data;

      final location = Location.fromDTO(dto.location);
      final items = dto.items
          .map((itemDto) => InventoryItem.fromDTO(itemDto))
          .toList();
      final pagination = PaginationInfo.fromDTO(dto.pagination);

      return ApiSuccess(
        LocationItemsResponse(
          location: location,
          items: items,
          pagination: pagination,
        ),
      );
    } else {
      final failure = result as ApiFailure<LocationItemsResponseDTO>;
      return ApiFailure<LocationItemsResponse>(
        failure.error,
        statusCode: failure.statusCode,
      );
    }
  }

  /// Get stock movement history.
  ///
  /// Returns ApiResult<StockMovementsResponse>:
  /// - Success: StockMovementsResponse with movements (domain models) and pagination
  /// - Failure: ApiError from API call
  Future<ApiResult<StockMovementsResponse>> getStockMovements({
    int? itemId,
    int? locationId,
    String? type,
    String? fromDate,
    String? toDate,
    int? skip,
    int? limit,
  }) async {
    final result = await _inventoryApi.getStockMovements(
      itemId: itemId,
      locationId: locationId,
      type: type,
      fromDate: fromDate,
      toDate: toDate,
      skip: skip,
      limit: limit,
    );

    if (result.isSuccess) {
      final success = result as ApiSuccess<StockMovementsResponseDTO>;
      final dto = success.data;

      final movements = dto.transactions
          .map((movementDto) => StockMovement.fromDTO(movementDto))
          .toList();
      final pagination = PaginationInfo.fromDTO(dto.pagination);

      return ApiSuccess(
        StockMovementsResponse(movements: movements, pagination: pagination),
      );
    } else {
      final failure = result as ApiFailure<StockMovementsResponseDTO>;
      return ApiFailure<StockMovementsResponse>(
        failure.error,
        statusCode: failure.statusCode,
      );
    }
  }

  /// Transfer stock between locations.
  ///
  /// Returns ApiResult<StockTransfer>:
  /// - Success: StockTransfer domain model with transfer details
  /// - Failure: ApiError from API call
  Future<ApiResult<StockTransfer>> transferStock({
    required int itemId,
    required int fromLocationId,
    required int toLocationId,
    required String quantity,
    String? reference,
    String? note,
  }) async {
    final result = await _inventoryApi.transferStock(
      itemId: itemId,
      fromLocationId: fromLocationId,
      toLocationId: toLocationId,
      quantity: quantity,
      reference: reference,
      note: note,
    );

    if (result.isSuccess) {
      final success = result as ApiSuccess<StockTransferResponseDTO>;
      final dto = success.data;

      // Convert DTO to domain model
      // Note: StockTransferResponseDTO doesn't have a domain model yet,
      // so we'll create a simple one or return the DTO fields as a model
      final transfer = StockTransfer.fromDTO(dto);

      return ApiSuccess(transfer);
    } else {
      final failure = result as ApiFailure<StockTransferResponseDTO>;
      return ApiFailure<StockTransfer>(
        failure.error,
        statusCode: failure.statusCode,
      );
    }
  }

  /// Adjust stock (manual IN/OUT).
  ///
  /// Returns ApiResult<StockAdjustment>:
  /// - Success: StockAdjustment domain model with adjustment details
  /// - Failure: ApiError from API call
  Future<ApiResult<StockAdjustment>> adjustStock({
    required int itemId,
    required int locationId,
    required String quantity,
    required String reason,
    String? reference,
    String? note,
  }) async {
    final result = await _inventoryApi.adjustStock(
      itemId: itemId,
      locationId: locationId,
      quantity: quantity,
      reason: reason,
      reference: reference,
      note: note,
    );

    if (result.isSuccess) {
      final success = result as ApiSuccess<StockAdjustmentResponseDTO>;
      final dto = success.data;

      // Convert DTO to domain model
      final adjustment = StockAdjustment.fromDTO(dto);

      return ApiSuccess(adjustment);
    } else {
      final failure = result as ApiFailure<StockAdjustmentResponseDTO>;
      return ApiFailure<StockAdjustment>(
        failure.error,
        statusCode: failure.statusCode,
      );
    }
  }

  /// Get inventory overview (KPIs + items + pagination).
  ///
  /// Returns ApiResult<InventoryOverview>:
  /// - Success: InventoryOverview domain model with KPIs, items, and pagination
  /// - Failure: ApiError from API call
  Future<ApiResult<InventoryOverview>> getInventoryOverview({
    int? locationId,
    String? kind,
    String? search,
    int? page,
    int? pageSize,
  }) async {
    final result = await _inventoryApi.getInventoryOverview(
      locationId: locationId,
      kind: kind,
      search: search,
      page: page,
      pageSize: pageSize,
    );

    if (result.isSuccess) {
      final success = result as ApiSuccess<InventoryOverviewResponseDTO>;
      final dto = success.data;

      // Convert DTO to domain model (already has fromDTO factory)
      final overview = InventoryOverview.fromDTO(dto);

      return ApiSuccess(overview);
    } else {
      final failure = result as ApiFailure<InventoryOverviewResponseDTO>;
      return ApiFailure<InventoryOverview>(
        failure.error,
        statusCode: failure.statusCode,
      );
    }
  }
}

/// Response wrapper for inventory items list.
class InventoryItemsResponse {
  final List<InventoryItem> items;
  final PaginationInfo pagination;

  const InventoryItemsResponse({required this.items, required this.pagination});
}

/// Response wrapper for location items list.
class LocationItemsResponse {
  final Location location;
  final List<InventoryItem> items;
  final PaginationInfo pagination;

  const LocationItemsResponse({
    required this.location,
    required this.items,
    required this.pagination,
  });
}

/// Response wrapper for stock movements list.
class StockMovementsResponse {
  final List<StockMovement> movements;
  final PaginationInfo pagination;

  const StockMovementsResponse({
    required this.movements,
    required this.pagination,
  });
}

/// Stock transfer domain model.
class StockTransfer {
  final int id;
  final int itemId;
  final int fromLocationId;
  final int toLocationId;
  final double quantity;
  final String? reference;
  final String? note;
  final DateTime createdAt;
  final int createdById;

  const StockTransfer({
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

  factory StockTransfer.fromDTO(StockTransferResponseDTO dto) {
    return StockTransfer(
      id: dto.id,
      itemId: dto.itemId,
      fromLocationId: dto.fromLocationId,
      toLocationId: dto.toLocationId,
      quantity: double.tryParse(dto.quantity) ?? 0.0,
      reference: dto.reference,
      note: dto.note,
      createdAt: DateTime.parse(dto.createdAt),
      createdById: dto.createdById,
    );
  }
}

/// Stock adjustment domain model.
class StockAdjustment {
  final int id;
  final int itemId;
  final int locationId;
  final double quantity;
  final MovementType type;
  final String reason;
  final String? reference;
  final String? note;
  final DateTime createdAt;
  final int createdById;

  const StockAdjustment({
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

  factory StockAdjustment.fromDTO(StockAdjustmentResponseDTO dto) {
    return StockAdjustment(
      id: dto.id,
      itemId: dto.itemId,
      locationId: dto.locationId,
      quantity: double.tryParse(dto.quantity) ?? 0.0,
      type: MovementType.fromString(dto.type) ?? MovementType.adjust,
      reason: dto.reason,
      reference: dto.reference,
      note: dto.note,
      createdAt: DateTime.parse(dto.createdAt),
      createdById: dto.createdById,
    );
  }

  /// Check if this is a stock-in adjustment.
  bool get isStockIn => quantity > 0;

  /// Check if this is a stock-out adjustment.
  bool get isStockOut => quantity < 0;
}
