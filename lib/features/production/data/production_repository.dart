import 'package:juix_na/core/network/api_result.dart';
import 'package:juix_na/features/production/data/production_api.dart';
import 'package:juix_na/features/production/model/production_dtos.dart';
import 'package:juix_na/features/production/model/production_models.dart';

/// Repository for production operations.
/// Wraps ProductionApi and transforms DTOs to domain models.
class ProductionRepository {
  final ProductionApi _productionApi;

  ProductionRepository({required ProductionApi productionApi})
    : _productionApi = productionApi;

  /// Create a purchase entry.
  ///
  /// Returns ApiResult<PurchaseReceipt>:
  /// - Success: PurchaseReceipt domain model
  /// - Failure: ApiError from API call
  Future<ApiResult<PurchaseReceipt>> createPurchaseEntry({
    required PurchaseEntry entry,
  }) async {
    // Convert domain model to DTO
    final request = PurchaseEntryRequestDTO(
      supplierId: entry.supplierId,
      date: entry.date.toIso8601String().split('T').first, // ISO date string
      refInvoice: entry.refInvoice,
      items: entry.items
          .map(
            (item) => PurchaseItemDTO(
              itemId: item.itemId,
              itemName: item.itemName,
              quantity: item.quantity.toString(),
              unit: item.unit,
              unitCost: item.unitCost.toString(),
              subtotal: item.subtotal.toString(),
            ),
          )
          .toList(),
      markAsReceived: entry.markAsReceived,
    );

    final result = await _productionApi.createPurchaseEntry(request: request);

    if (result.isSuccess) {
      final success = result as ApiSuccess<PurchaseReceiptDTO>;
      final receipt = PurchaseReceipt.fromDTO(success.data);
      return ApiSuccess(receipt);
    } else {
      final failure = result as ApiFailure<PurchaseReceiptDTO>;
      return ApiFailure<PurchaseReceipt>(
        failure.error,
        statusCode: failure.statusCode,
      );
    }
  }

  /// Get purchase receipts (pending/approved/rejected).
  ///
  /// Returns ApiResult<List<PurchaseReceipt>>:
  /// - Success: List of PurchaseReceipt domain models
  /// - Failure: ApiError from API call
  Future<ApiResult<List<PurchaseReceipt>>> getPurchaseReceipts({
    ReceiptStatus? status,
    int? locationId,
  }) async {
    final result = await _productionApi.getPurchaseReceipts(
      status: status?.value,
      locationId: locationId,
    );

    if (result.isSuccess) {
      final success = result as ApiSuccess<List<PurchaseReceiptDTO>>;
      final receipts = success.data
          .map((dto) => PurchaseReceipt.fromDTO(dto))
          .toList();
      return ApiSuccess(receipts);
    } else {
      final failure = result as ApiFailure<List<PurchaseReceiptDTO>>;
      return ApiFailure<List<PurchaseReceipt>>(
        failure.error,
        statusCode: failure.statusCode,
      );
    }
  }

  /// Get a specific purchase receipt by ID.
  ///
  /// Returns ApiResult<PurchaseReceipt>:
  /// - Success: PurchaseReceipt domain model
  /// - Failure: ApiError from API call
  Future<ApiResult<PurchaseReceipt>> getPurchaseReceipt({
    required int id,
  }) async {
    final result = await _productionApi.getPurchaseReceipt(id: id);

    if (result.isSuccess) {
      final success = result as ApiSuccess<PurchaseReceiptDTO>;
      final receipt = PurchaseReceipt.fromDTO(success.data);
      return ApiSuccess(receipt);
    } else {
      final failure = result as ApiFailure<PurchaseReceiptDTO>;
      return ApiFailure<PurchaseReceipt>(
        failure.error,
        statusCode: failure.statusCode,
      );
    }
  }

  /// Review a purchase receipt (approve or reject).
  ///
  /// Returns ApiResult<PurchaseReceipt>:
  /// - Success: PurchaseReceipt domain model with updated status
  /// - Failure: ApiError from API call
  Future<ApiResult<PurchaseReceipt>> reviewReceipt({
    required int id,
    required String action, // 'approve' or 'reject'
    Map<int, double>? receivingQuantities, // itemId -> quantity
  }) async {
    final request = ReviewReceiptRequestDTO(
      action: action,
      receivingQuantities: receivingQuantities?.map(
        (key, value) => MapEntry(key, value.toString()),
      ),
    );

    final result = await _productionApi.reviewReceipt(id: id, request: request);

    if (result.isSuccess) {
      final success = result as ApiSuccess<PurchaseReceiptDTO>;
      final receipt = PurchaseReceipt.fromDTO(success.data);
      return ApiSuccess(receipt);
    } else {
      final failure = result as ApiFailure<PurchaseReceiptDTO>;
      return ApiFailure<PurchaseReceipt>(
        failure.error,
        statusCode: failure.statusCode,
      );
    }
  }

  /// Create a production batch.
  ///
  /// Returns ApiResult<ProductionBatch>:
  /// - Success: ProductionBatch domain model
  /// - Failure: ApiError from API call
  Future<ApiResult<ProductionBatch>> createBatch({
    required int productId,
    required DateTime productionDate,
    required int locationId,
    required double plannedOutput,
    String? notes,
  }) async {
    final request = CreateBatchRequestDTO(
      productId: productId,
      productionDate: productionDate.toIso8601String().split('T').first,
      locationId: locationId,
      plannedOutput: plannedOutput.toString(),
      notes: notes,
    );

    final result = await _productionApi.createBatch(request: request);

    if (result.isSuccess) {
      final success = result as ApiSuccess<ProductionBatchDTO>;
      final batch = ProductionBatch.fromDTO(success.data);
      return ApiSuccess(batch);
    } else {
      final failure = result as ApiFailure<ProductionBatchDTO>;
      return ApiFailure<ProductionBatch>(
        failure.error,
        statusCode: failure.statusCode,
      );
    }
  }

  /// Get a specific production batch by ID.
  ///
  /// Returns ApiResult<ProductionBatch>:
  /// - Success: ProductionBatch domain model
  /// - Failure: ApiError from API call
  Future<ApiResult<ProductionBatch>> getBatch({required int id}) async {
    final result = await _productionApi.getBatch(id: id);

    if (result.isSuccess) {
      final success = result as ApiSuccess<ProductionBatchDTO>;
      final batch = ProductionBatch.fromDTO(success.data);
      return ApiSuccess(batch);
    } else {
      final failure = result as ApiFailure<ProductionBatchDTO>;
      return ApiFailure<ProductionBatch>(
        failure.error,
        statusCode: failure.statusCode,
      );
    }
  }

  /// Get production batches with optional filters.
  ///
  /// Returns ApiResult<List<ProductionBatch>>:
  /// - Success: List of ProductionBatch domain models
  /// - Failure: ApiError from API call
  Future<ApiResult<List<ProductionBatch>>> getBatches({
    BatchStatus? status,
    int? locationId,
    DateTime? dateFrom,
    DateTime? dateTo,
  }) async {
    final result = await _productionApi.getBatches(
      status: status?.value,
      locationId: locationId,
      dateFrom: dateFrom?.toIso8601String().split('T').first,
      dateTo: dateTo?.toIso8601String().split('T').first,
    );

    if (result.isSuccess) {
      final success = result as ApiSuccess<List<ProductionBatchDTO>>;
      final batches = success.data
          .map((dto) => ProductionBatch.fromDTO(dto))
          .toList();
      return ApiSuccess(batches);
    } else {
      final failure = result as ApiFailure<List<ProductionBatchDTO>>;
      return ApiFailure<List<ProductionBatch>>(
        failure.error,
        statusCode: failure.statusCode,
      );
    }
  }

  /// Confirm batch inputs (check stock availability and optionally adjust quantities).
  ///
  /// Returns ApiResult<BatchInputsData>:
  /// - Success: BatchInputsData domain model with ingredients and packaging availability (with adjusted quantities if provided)
  /// - Failure: ApiError from API call
  /// Note: This endpoint returns the inputs data after confirmation. If backend returns the updated batch instead, update return type to ProductionBatch.
  Future<ApiResult<BatchInputsData>> confirmBatchInputs({
    required int batchId,
    Map<int, double>? adjustedInputs, // inputId -> adjusted quantity
  }) async {
    final request = ConfirmBatchInputsRequestDTO(
      adjustedInputs: adjustedInputs?.map(
        (key, value) => MapEntry(key, value.toString()),
      ),
    );

    final result = await _productionApi.confirmBatchInputs(
      id: batchId,
      request: request,
    );

    if (result.isSuccess) {
      final success = result as ApiSuccess<BatchInputsResponseDTO>;
      final inputsData = BatchInputsData.fromDTO(success.data);
      return ApiSuccess(inputsData);
    } else {
      final failure = result as ApiFailure<BatchInputsResponseDTO>;
      return ApiFailure<BatchInputsData>(
        failure.error,
        statusCode: failure.statusCode,
      );
    }
  }

  /// Get batch inputs (check stock availability).
  ///
  /// Returns ApiResult<BatchInputsData>:
  /// - Success: BatchInputsData domain model with ingredients and packaging availability
  /// - Failure: ApiError from API call
  Future<ApiResult<BatchInputsData>> getBatchInputs({
    required int batchId,
  }) async {
    final result = await _productionApi.getBatchInputs(id: batchId);

    if (result.isSuccess) {
      final success = result as ApiSuccess<BatchInputsResponseDTO>;
      final inputsData = BatchInputsData.fromDTO(success.data);
      return ApiSuccess(inputsData);
    } else {
      final failure = result as ApiFailure<BatchInputsResponseDTO>;
      return ApiFailure<BatchInputsData>(
        failure.error,
        statusCode: failure.statusCode,
      );
    }
  }

  /// Start production batch (move from DRAFT/PENDING to IN_PROGRESS).
  ///
  /// Returns ApiResult<ProductionBatch>:
  /// - Success: ProductionBatch domain model with updated status
  /// - Failure: ApiError from API call
  Future<ApiResult<ProductionBatch>> startBatch({required int batchId}) async {
    final result = await _productionApi.startBatch(id: batchId);

    if (result.isSuccess) {
      final success = result as ApiSuccess<ProductionBatchDTO>;
      final batch = ProductionBatch.fromDTO(success.data);
      return ApiSuccess(batch);
    } else {
      final failure = result as ApiFailure<ProductionBatchDTO>;
      return ApiFailure<ProductionBatch>(
        failure.error,
        statusCode: failure.statusCode,
      );
    }
  }

  /// Complete production batch (record final output and wastage).
  ///
  /// Returns ApiResult<ProductionBatch>:
  /// - Success: ProductionBatch domain model with completed status
  /// - Failure: ApiError from API call
  Future<ApiResult<ProductionBatch>> completeBatch({
    required int batchId,
    required double actualOutput,
    BatchWastage? wastage,
  }) async {
    final request = CompleteBatchRequestDTO(
      actualOutput: actualOutput.toString(),
      wastage: wastage != null
          ? BatchWastageDTO(
              quantity: wastage.quantity.toString(),
              reasonCode: wastage.reasonCode.value,
              reasonDescription: wastage.reasonDescription,
            )
          : null,
    );

    final result = await _productionApi.completeBatch(
      id: batchId,
      request: request,
    );

    if (result.isSuccess) {
      final success = result as ApiSuccess<ProductionBatchDTO>;
      final batch = ProductionBatch.fromDTO(success.data);
      return ApiSuccess(batch);
    } else {
      final failure = result as ApiFailure<ProductionBatchDTO>;
      return ApiFailure<ProductionBatch>(
        failure.error,
        statusCode: failure.statusCode,
      );
    }
  }

  /// Get recent activity feed (purchases, production, stock adjustments).
  ///
  /// Returns ApiResult<List<ActivityItem>>:
  /// - Success: List of ActivityItem domain models
  /// - Failure: ApiError from API call
  Future<ApiResult<List<ActivityItem>>> getRecentActivity({int? limit}) async {
    final result = await _productionApi.getRecentActivity(limit: limit);

    if (result.isSuccess) {
      final success = result as ApiSuccess<List<ActivityItemDTO>>;
      final activities = success.data
          .map((dto) => ActivityItem.fromDTO(dto))
          .toList();
      return ApiSuccess(activities);
    } else {
      final failure = result as ApiFailure<List<ActivityItemDTO>>;
      return ApiFailure<List<ActivityItem>>(
        failure.error,
        statusCode: failure.statusCode,
      );
    }
  }
}
