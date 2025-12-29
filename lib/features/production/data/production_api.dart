import 'package:juix_na/core/network/api_client.dart';
import 'package:juix_na/core/network/api_result.dart';
import 'package:juix_na/features/production/model/production_dtos.dart';

/// API client for production endpoints.
/// Uses the shared ApiClient for HTTP requests.
class ProductionApi {
  final ApiClient _apiClient;

  ProductionApi({required ApiClient apiClient}) : _apiClient = apiClient;

  /// Create a purchase entry.
  ///
  /// Endpoint: POST /api/production/purchases/
  /// Request body: PurchaseEntryRequestDTO
  ///
  /// Returns ApiResult<PurchaseReceiptDTO>:
  /// - Success: PurchaseReceiptDTO with created purchase receipt
  /// - Failure: ApiError with message and type
  Future<ApiResult<PurchaseReceiptDTO>> createPurchaseEntry({
    required PurchaseEntryRequestDTO request,
  }) async {
    return _apiClient.post<PurchaseReceiptDTO>(
      '/api/production/purchases/',
      body: request.toJson(),
      parse: (json) =>
          PurchaseReceiptDTO.fromJson(json as Map<String, dynamic>),
    );
  }

  /// Get purchase receipts (pending/approved/rejected).
  ///
  /// Endpoint: GET /api/production/purchases/receipts/
  /// Query params: status, location_id (both optional)
  ///
  /// Returns ApiResult<List<PurchaseReceiptDTO>>:
  /// - Success: List of PurchaseReceiptDTO
  /// - Failure: ApiError with message and type
  Future<ApiResult<List<PurchaseReceiptDTO>>> getPurchaseReceipts({
    String? status, // PENDING, APPROVED, REJECTED
    int? locationId,
  }) async {
    final query = <String, dynamic>{};
    if (status != null) query['status'] = status;
    if (locationId != null) query['location_id'] = locationId.toString();

    return _apiClient.get<List<PurchaseReceiptDTO>>(
      '/api/production/purchases/receipts/',
      query: query.isEmpty ? null : query,
      parse: (json) {
        final list = json as List<dynamic>;
        return list
            .map((e) => PurchaseReceiptDTO.fromJson(e as Map<String, dynamic>))
            .toList();
      },
    );
  }

  /// Get a specific purchase receipt by ID.
  ///
  /// Endpoint: GET /api/production/purchases/receipts/{id}/
  /// Path param: id
  ///
  /// Returns ApiResult<PurchaseReceiptDTO>:
  /// - Success: PurchaseReceiptDTO with receipt details
  /// - Failure: ApiError with message and type
  Future<ApiResult<PurchaseReceiptDTO>> getPurchaseReceipt({
    required int id,
  }) async {
    return _apiClient.get<PurchaseReceiptDTO>(
      '/api/production/purchases/receipts/$id/',
      parse: (json) =>
          PurchaseReceiptDTO.fromJson(json as Map<String, dynamic>),
    );
  }

  /// Review a purchase receipt (approve or reject).
  ///
  /// Endpoint: POST /api/production/purchases/receipts/{id}/review/
  /// Path param: id
  /// Request body: ReviewReceiptRequestDTO
  ///
  /// Returns ApiResult<PurchaseReceiptDTO>:
  /// - Success: PurchaseReceiptDTO with updated receipt
  /// - Failure: ApiError with message and type
  Future<ApiResult<PurchaseReceiptDTO>> reviewReceipt({
    required int id,
    required ReviewReceiptRequestDTO request,
  }) async {
    return _apiClient.post<PurchaseReceiptDTO>(
      '/api/production/purchases/receipts/$id/review/',
      body: request.toJson(),
      parse: (json) =>
          PurchaseReceiptDTO.fromJson(json as Map<String, dynamic>),
    );
  }

  /// Create a production batch.
  ///
  /// Endpoint: POST /api/production/batches/
  /// Request body: CreateBatchRequestDTO
  ///
  /// Returns ApiResult<ProductionBatchDTO>:
  /// - Success: ProductionBatchDTO with created batch
  /// - Failure: ApiError with message and type
  Future<ApiResult<ProductionBatchDTO>> createBatch({
    required CreateBatchRequestDTO request,
  }) async {
    return _apiClient.post<ProductionBatchDTO>(
      '/api/production/batches/',
      body: request.toJson(),
      parse: (json) =>
          ProductionBatchDTO.fromJson(json as Map<String, dynamic>),
    );
  }

  /// Get a specific production batch by ID.
  ///
  /// Endpoint: GET /api/production/batches/{id}/
  /// Path param: id
  ///
  /// Returns ApiResult<ProductionBatchDTO>:
  /// - Success: ProductionBatchDTO with batch details
  /// - Failure: ApiError with message and type
  Future<ApiResult<ProductionBatchDTO>> getBatch({required int id}) async {
    return _apiClient.get<ProductionBatchDTO>(
      '/api/production/batches/$id/',
      parse: (json) =>
          ProductionBatchDTO.fromJson(json as Map<String, dynamic>),
    );
  }

  /// Get production batches with optional filters.
  ///
  /// Endpoint: GET /api/production/batches/
  /// Query params: status, location_id, date_from, date_to (all optional)
  ///
  /// Returns ApiResult<List<ProductionBatchDTO>>:
  /// - Success: List of ProductionBatchDTO
  /// - Failure: ApiError with message and type
  Future<ApiResult<List<ProductionBatchDTO>>> getBatches({
    String? status, // DRAFT, PENDING, IN_PROGRESS, COMPLETED, CANCELLED
    int? locationId,
    String? dateFrom, // ISO date string
    String? dateTo, // ISO date string
  }) async {
    final query = <String, dynamic>{};
    if (status != null) query['status'] = status;
    if (locationId != null) query['location_id'] = locationId.toString();
    if (dateFrom != null) query['date_from'] = dateFrom;
    if (dateTo != null) query['date_to'] = dateTo;

    return _apiClient.get<List<ProductionBatchDTO>>(
      '/api/production/batches/',
      query: query.isEmpty ? null : query,
      parse: (json) {
        final list = json as List<dynamic>;
        return list
            .map((e) => ProductionBatchDTO.fromJson(e as Map<String, dynamic>))
            .toList();
      },
    );
  }

  /// Confirm batch inputs (check stock availability and optionally adjust quantities).
  ///
  /// Endpoint: POST /api/production/batches/{id}/confirm-inputs/
  /// Path param: id
  /// Request body: ConfirmBatchInputsRequestDTO
  ///
  /// Returns ApiResult<BatchInputsResponseDTO>:
  /// - Success: BatchInputsResponseDTO with ingredients and packaging availability
  /// - Failure: ApiError with message and type
  Future<ApiResult<BatchInputsResponseDTO>> confirmBatchInputs({
    required int id,
    required ConfirmBatchInputsRequestDTO request,
  }) async {
    return _apiClient.post<BatchInputsResponseDTO>(
      '/api/production/batches/$id/confirm-inputs/',
      body: request.toJson(),
      parse: (json) =>
          BatchInputsResponseDTO.fromJson(json as Map<String, dynamic>),
    );
  }

  /// Get batch inputs (check stock availability).
  ///
  /// Endpoint: GET /api/production/batches/{id}/inputs/
  /// Path param: id
  ///
  /// Returns ApiResult<BatchInputsResponseDTO>:
  /// - Success: BatchInputsResponseDTO with ingredients and packaging availability
  /// - Failure: ApiError with message and type
  Future<ApiResult<BatchInputsResponseDTO>> getBatchInputs({
    required int id,
  }) async {
    return _apiClient.get<BatchInputsResponseDTO>(
      '/api/production/batches/$id/inputs/',
      parse: (json) =>
          BatchInputsResponseDTO.fromJson(json as Map<String, dynamic>),
    );
  }

  /// Start production batch (move from DRAFT/PENDING to IN_PROGRESS).
  ///
  /// Endpoint: POST /api/production/batches/{id}/start/
  /// Path param: id
  ///
  /// Returns ApiResult<ProductionBatchDTO>:
  /// - Success: ProductionBatchDTO with updated batch (status: IN_PROGRESS)
  /// - Failure: ApiError with message and type
  Future<ApiResult<ProductionBatchDTO>> startBatch({required int id}) async {
    return _apiClient.post<ProductionBatchDTO>(
      '/api/production/batches/$id/start/',
      body: <String, dynamic>{}, // Empty body for start action
      parse: (json) =>
          ProductionBatchDTO.fromJson(json as Map<String, dynamic>),
    );
  }

  /// Complete production batch (record final output and wastage).
  ///
  /// Endpoint: POST /api/production/batches/{id}/complete/
  /// Path param: id
  /// Request body: CompleteBatchRequestDTO
  ///
  /// Returns ApiResult<ProductionBatchDTO>:
  /// - Success: ProductionBatchDTO with completed batch (status: COMPLETED)
  /// - Failure: ApiError with message and type
  Future<ApiResult<ProductionBatchDTO>> completeBatch({
    required int id,
    required CompleteBatchRequestDTO request,
  }) async {
    return _apiClient.post<ProductionBatchDTO>(
      '/api/production/batches/$id/complete/',
      body: request.toJson(),
      parse: (json) =>
          ProductionBatchDTO.fromJson(json as Map<String, dynamic>),
    );
  }

  /// Get recent activity feed (purchases, production, stock adjustments).
  ///
  /// Endpoint: GET /api/production/activity/
  /// Query params: limit (optional, default may vary)
  ///
  /// Returns ApiResult<List<ActivityItemDTO>>:
  /// - Success: List of ActivityItemDTO with recent activities
  /// - Failure: ApiError with message and type
  Future<ApiResult<List<ActivityItemDTO>>> getRecentActivity({
    int? limit,
  }) async {
    final query = <String, dynamic>{};
    if (limit != null) query['limit'] = limit.toString();

    return _apiClient.get<List<ActivityItemDTO>>(
      '/api/production/activity/',
      query: query.isEmpty ? null : query,
      parse: (json) {
        final list = json as List<dynamic>;
        return list
            .map((e) => ActivityItemDTO.fromJson(e as Map<String, dynamic>))
            .toList();
      },
    );
  }
}
