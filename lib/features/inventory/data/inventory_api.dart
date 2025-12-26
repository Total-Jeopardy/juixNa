import 'package:juix_na/core/network/api_client.dart';
import 'package:juix_na/core/network/api_result.dart';
import 'package:juix_na/features/inventory/model/inventory_dtos.dart';

/// API client for inventory endpoints.
/// Uses the shared ApiClient for HTTP requests.
class InventoryApi {
  final ApiClient _apiClient;

  InventoryApi({required ApiClient apiClient}) : _apiClient = apiClient;

  /// Get all inventory locations.
  ///
  /// Endpoint: GET /api/inventory/locations/
  /// Query params: is_active (optional, default: true)
  ///
  /// Returns ApiResult<List<LocationDTO>>:
  /// - Success: List of LocationDTO
  /// - Failure: ApiError with message and type
  Future<ApiResult<List<LocationDTO>>> getLocations({bool? isActive}) async {
    final query = <String, dynamic>{};
    if (isActive != null) {
      query['is_active'] = isActive.toString();
    }

    return _apiClient.get<List<LocationDTO>>(
      '/api/inventory/locations/',
      query: query.isEmpty ? null : query,
      parse: (json) {
        final list = json as List<dynamic>;
        return list
            .map((e) => LocationDTO.fromJson(e as Map<String, dynamic>))
            .toList();
      },
    );
  }

  /// Get inventory items across all locations.
  ///
  /// Endpoint: GET /api/inventory/items/
  /// Query params: kind, search, skip, limit (all optional)
  ///
  /// Returns ApiResult<InventoryItemsResponseDTO>:
  /// - Success: InventoryItemsResponseDTO with items and pagination
  /// - Failure: ApiError with message and type
  Future<ApiResult<InventoryItemsResponseDTO>> getInventoryItems({
    String? kind,
    String? search,
    int? skip,
    int? limit,
  }) async {
    final query = <String, dynamic>{};
    if (kind != null) query['kind'] = kind;
    if (search != null && search.isNotEmpty) query['search'] = search;
    if (skip != null) query['skip'] = skip.toString();
    if (limit != null) query['limit'] = limit.toString();

    return _apiClient.get<InventoryItemsResponseDTO>(
      '/api/inventory/items/',
      query: query.isEmpty ? null : query,
      parse: (json) =>
          InventoryItemsResponseDTO.fromJson(json as Map<String, dynamic>),
    );
  }

  /// Get inventory items at a specific location.
  ///
  /// Endpoint: GET /api/inventory/locations/{location_id}/items/
  /// Path param: location_id
  /// Query params: kind, search, skip, limit (all optional)
  ///
  /// Returns ApiResult<LocationItemsResponseDTO>:
  /// - Success: LocationItemsResponseDTO with location, items, and pagination
  /// - Failure: ApiError with message and type
  Future<ApiResult<LocationItemsResponseDTO>> getLocationItems({
    required int locationId,
    String? kind,
    String? search,
    int? skip,
    int? limit,
  }) async {
    final query = <String, dynamic>{};
    if (kind != null) query['kind'] = kind;
    if (search != null && search.isNotEmpty) query['search'] = search;
    if (skip != null) query['skip'] = skip.toString();
    if (limit != null) query['limit'] = limit.toString();

    return _apiClient.get<LocationItemsResponseDTO>(
      '/api/inventory/locations/$locationId/items/',
      query: query.isEmpty ? null : query,
      parse: (json) =>
          LocationItemsResponseDTO.fromJson(json as Map<String, dynamic>),
    );
  }

  /// Get stock movement history.
  ///
  /// Endpoint: GET /api/inventory/stock/movements/
  /// Query params: item_id, location_id, type, from_date, to_date, skip, limit (all optional)
  ///
  /// Returns ApiResult<StockMovementsResponseDTO>:
  /// - Success: StockMovementsResponseDTO with transactions and pagination
  /// - Failure: ApiError with message and type
  Future<ApiResult<StockMovementsResponseDTO>> getStockMovements({
    int? itemId,
    int? locationId,
    String? type, // IN | OUT | ADJUST | TRANSFER
    String? fromDate, // ISO date or datetime
    String? toDate, // ISO date or datetime
    int? skip,
    int? limit,
  }) async {
    final query = <String, dynamic>{};
    if (itemId != null) query['item_id'] = itemId.toString();
    if (locationId != null) query['location_id'] = locationId.toString();
    if (type != null) query['type'] = type;
    if (fromDate != null) query['from_date'] = fromDate;
    if (toDate != null) query['to_date'] = toDate;
    if (skip != null) query['skip'] = skip.toString();
    if (limit != null) query['limit'] = limit.toString();

    return _apiClient.get<StockMovementsResponseDTO>(
      '/api/inventory/stock/movements/',
      query: query.isEmpty ? null : query,
      parse: (json) =>
          StockMovementsResponseDTO.fromJson(json as Map<String, dynamic>),
    );
  }

  /// Transfer stock between locations.
  ///
  /// Endpoint: POST /api/inventory/stock/transfer/
  /// Request body: StockTransferRequestDTO
  ///
  /// Returns ApiResult<StockTransferResponseDTO>:
  /// - Success: StockTransferResponseDTO with transfer details
  /// - Failure: ApiError with message and type
  Future<ApiResult<StockTransferResponseDTO>> transferStock({
    required int itemId,
    required int fromLocationId,
    required int toLocationId,
    required String quantity,
    String? reference,
    String? note,
  }) async {
    final request = StockTransferRequestDTO(
      itemId: itemId,
      fromLocationId: fromLocationId,
      toLocationId: toLocationId,
      quantity: quantity,
      reference: reference,
      note: note,
    );

    return _apiClient.post<StockTransferResponseDTO>(
      '/api/inventory/stock/transfer/',
      body: request.toJson(),
      parse: (json) =>
          StockTransferResponseDTO.fromJson(json as Map<String, dynamic>),
    );
  }

  /// Adjust stock (manual IN/OUT).
  ///
  /// Endpoint: POST /api/inventory/stock/adjust/
  /// Request body: StockAdjustmentRequestDTO
  /// Note: Positive quantity = adjustment in, negative = adjustment out
  ///
  /// Returns ApiResult<StockAdjustmentResponseDTO>:
  /// - Success: StockAdjustmentResponseDTO with adjustment details
  /// - Failure: ApiError with message and type
  Future<ApiResult<StockAdjustmentResponseDTO>> adjustStock({
    required int itemId,
    required int locationId,
    required String quantity, // Positive = IN, negative = OUT
    required String reason, // BREAKAGE, etc.
    String? reference,
    String? note,
  }) async {
    final request = StockAdjustmentRequestDTO(
      itemId: itemId,
      locationId: locationId,
      quantity: quantity,
      reason: reason,
      reference: reference,
      note: note,
    );

    return _apiClient.post<StockAdjustmentResponseDTO>(
      '/api/inventory/stock/adjust/',
      body: request.toJson(),
      parse: (json) =>
          StockAdjustmentResponseDTO.fromJson(json as Map<String, dynamic>),
    );
  }

  /// Get inventory overview (KPIs + items + pagination).
  ///
  /// Endpoint: GET /api/inventory/overview/
  /// Query params: location_id, kind, search, page, page_size (all optional)
  /// Status: Planned - backend will implement; mobile should code against this contract
  ///
  /// Returns ApiResult<InventoryOverviewResponseDTO>:
  /// - Success: InventoryOverviewResponseDTO with KPIs, items, and pagination
  /// - Failure: ApiError with message and type
  Future<ApiResult<InventoryOverviewResponseDTO>> getInventoryOverview({
    int? locationId,
    String? kind,
    String? search,
    int? page,
    int? pageSize,
  }) async {
    final query = <String, dynamic>{};
    if (locationId != null) query['location_id'] = locationId.toString();
    if (kind != null) query['kind'] = kind;
    if (search != null && search.isNotEmpty) query['search'] = search;
    if (page != null) query['page'] = page.toString();
    if (pageSize != null) query['page_size'] = pageSize.toString();

    return _apiClient.get<InventoryOverviewResponseDTO>(
      '/api/inventory/overview/',
      query: query.isEmpty ? null : query,
      parse: (json) =>
          InventoryOverviewResponseDTO.fromJson(json as Map<String, dynamic>),
    );
  }
}
