/// Domain models for production module.
/// These are clean, type-safe models used throughout the app.
/// Convert from DTOs using factory constructors.

import 'package:juix_na/features/production/model/production_dtos.dart';

// Re-export DTOs for convenience
export 'package:juix_na/features/production/model/production_dtos.dart';

/// Batch status enum.
enum BatchStatus {
  draft,
  pending,
  inProgress,
  completed,
  cancelled;

  String get value {
    switch (this) {
      case BatchStatus.draft:
        return 'DRAFT';
      case BatchStatus.pending:
        return 'PENDING';
      case BatchStatus.inProgress:
        return 'IN_PROGRESS';
      case BatchStatus.completed:
        return 'COMPLETED';
      case BatchStatus.cancelled:
        return 'CANCELLED';
    }
  }

  static BatchStatus? fromString(String? value) {
    if (value == null) return null;
    for (final status in BatchStatus.values) {
      if (status.value == value.toUpperCase()) {
        return status;
      }
    }
    return null;
  }

  static BatchStatus fromDTO(BatchStatusDTO dto) {
    switch (dto) {
      case BatchStatusDTO.draft:
        return BatchStatus.draft;
      case BatchStatusDTO.pending:
        return BatchStatus.pending;
      case BatchStatusDTO.inProgress:
        return BatchStatus.inProgress;
      case BatchStatusDTO.completed:
        return BatchStatus.completed;
      case BatchStatusDTO.cancelled:
        return BatchStatus.cancelled;
    }
  }
}

/// Receipt status enum.
enum ReceiptStatus {
  pending,
  approved,
  rejected;

  String get value {
    switch (this) {
      case ReceiptStatus.pending:
        return 'PENDING';
      case ReceiptStatus.approved:
        return 'APPROVED';
      case ReceiptStatus.rejected:
        return 'REJECTED';
    }
  }

  static ReceiptStatus? fromString(String? value) {
    if (value == null) return null;
    for (final status in ReceiptStatus.values) {
      if (status.value == value.toUpperCase()) {
        return status;
      }
    }
    return null;
  }

  static ReceiptStatus fromDTO(ReceiptStatusDTO dto) {
    switch (dto) {
      case ReceiptStatusDTO.pending:
        return ReceiptStatus.pending;
      case ReceiptStatusDTO.approved:
        return ReceiptStatus.approved;
      case ReceiptStatusDTO.rejected:
        return ReceiptStatus.rejected;
    }
  }

  /// Get color for status badge (for UI).
  /// Returns a string identifier that UI components can map to actual Color values.
  /// Possible values: 'orange', 'green', 'gray'
  String getStatusColor() {
    switch (this) {
      case ReceiptStatus.pending:
        return 'orange';
      case ReceiptStatus.approved:
        return 'green';
      case ReceiptStatus.rejected:
        return 'gray';
    }
  }
}

/// Stock adjustment type enum.
enum StockAdjustmentType {
  wastage,
  correction,
  other;

  String get value {
    switch (this) {
      case StockAdjustmentType.wastage:
        return 'WASTAGE';
      case StockAdjustmentType.correction:
        return 'CORRECTION';
      case StockAdjustmentType.other:
        return 'OTHER';
    }
  }

  static StockAdjustmentType? fromString(String? value) {
    if (value == null) return null;
    for (final type in StockAdjustmentType.values) {
      if (type.value == value.toUpperCase()) {
        return type;
      }
    }
    return null;
  }

  static StockAdjustmentType fromDTO(StockAdjustmentTypeDTO dto) {
    switch (dto) {
      case StockAdjustmentTypeDTO.wastage:
        return StockAdjustmentType.wastage;
      case StockAdjustmentTypeDTO.correction:
        return StockAdjustmentType.correction;
      case StockAdjustmentTypeDTO.other:
        return StockAdjustmentType.other;
    }
  }
}

/// Batch input status enum (for stock availability).
enum BatchInputStatus {
  ok,
  low,
  short;

  String get value {
    switch (this) {
      case BatchInputStatus.ok:
        return 'OK';
      case BatchInputStatus.low:
        return 'LOW';
      case BatchInputStatus.short:
        return 'SHORT';
    }
  }

  static BatchInputStatus? fromString(String? value) {
    if (value == null) return null;
    final upperValue = value.toUpperCase();
    if (upperValue == 'OK') return BatchInputStatus.ok;
    if (upperValue == 'LOW') return BatchInputStatus.low;
    if (upperValue == 'SHORT') return BatchInputStatus.short;
    return null;
  }

  /// Get color for status badge (for UI).
  /// Returns a string identifier that UI components can map to actual Color values.
  /// Possible values: 'green', 'orange', 'red'
  String getStatusColor() {
    switch (this) {
      case BatchInputStatus.ok:
        return 'green';
      case BatchInputStatus.low:
        return 'orange';
      case BatchInputStatus.short:
        return 'red';
    }
  }
}

/// Purchase item model (for purchase entry).
class PurchaseItem {
  final int itemId;
  final String itemName;
  final double quantity;
  final String unit;
  final double unitCost;
  final double subtotal;

  const PurchaseItem({
    required this.itemId,
    required this.itemName,
    required this.quantity,
    required this.unit,
    required this.unitCost,
    required this.subtotal,
  });

  factory PurchaseItem.fromDTO(PurchaseItemDTO dto) {
    return PurchaseItem(
      itemId: dto.itemId,
      itemName: dto.itemName,
      quantity: double.tryParse(dto.quantity) ?? 0.0,
      unit: dto.unit,
      unitCost: double.tryParse(dto.unitCost) ?? 0.0,
      subtotal: double.tryParse(dto.subtotal) ?? 0.0,
    );
  }

  /// Calculate subtotal from quantity and unit cost.
  static double calculateSubtotal(double quantity, double unitCost) {
    return quantity * unitCost;
  }

  /// Create a copy with updated values.
  PurchaseItem copyWith({
    int? itemId,
    String? itemName,
    double? quantity,
    String? unit,
    double? unitCost,
    double? subtotal,
  }) {
    final newQuantity = quantity ?? this.quantity;
    final newUnitCost = unitCost ?? this.unitCost;
    final newSubtotal = subtotal ?? calculateSubtotal(newQuantity, newUnitCost);

    return PurchaseItem(
      itemId: itemId ?? this.itemId,
      itemName: itemName ?? this.itemName,
      quantity: newQuantity,
      unit: unit ?? this.unit,
      unitCost: newUnitCost,
      subtotal: newSubtotal,
    );
  }

  @override
  String toString() =>
      'PurchaseItem(itemId: $itemId, name: $itemName, qty: $quantity, subtotal: $subtotal)';
}

/// Purchase entry model (for creating purchase).
class PurchaseEntry {
  final int supplierId;
  final DateTime date;
  final String? refInvoice;
  final List<PurchaseItem> items;
  final bool markAsReceived;

  const PurchaseEntry({
    required this.supplierId,
    required this.date,
    this.refInvoice,
    required this.items,
    required this.markAsReceived,
  });

  /// Calculate total cost from all items.
  double calculateTotal() {
    return items.fold(0.0, (sum, item) => sum + item.subtotal);
  }

  /// Calculate total quantity.
  double calculateTotalQuantity() {
    return items.fold(0.0, (sum, item) => sum + item.quantity);
  }

  /// Get total items count.
  int getTotalItemsCount() {
    return items.length;
  }

  /// Check if purchase entry is valid.
  /// Note: This only validates required fields (supplier and items).
  /// Date validation should be handled by the ViewModel/form validation.
  bool isValid() {
    return supplierId > 0 && items.isNotEmpty;
  }

  @override
  String toString() =>
      'PurchaseEntry(supplierId: $supplierId, items: ${items.length}, total: ${calculateTotal()})';
}

/// Receipt item model (for purchase receipt).
class ReceiptItem {
  final int itemId;
  final String itemName;
  final double quantity;
  final String unit;
  final double unitCost;
  final double subtotal;
  final double? receivingQuantity;

  const ReceiptItem({
    required this.itemId,
    required this.itemName,
    required this.quantity,
    required this.unit,
    required this.unitCost,
    required this.subtotal,
    this.receivingQuantity,
  });

  factory ReceiptItem.fromDTO(ReceiptItemDTO dto) {
    return ReceiptItem(
      itemId: dto.itemId,
      itemName: dto.itemName,
      quantity: double.tryParse(dto.quantity) ?? 0.0,
      unit: dto.unit,
      unitCost: double.tryParse(dto.unitCost) ?? 0.0,
      subtotal: double.tryParse(dto.subtotal) ?? 0.0,
      receivingQuantity: dto.receivingQuantity != null
          ? double.tryParse(dto.receivingQuantity!)
          : null,
    );
  }

  /// Check if receiving quantity differs from purchased quantity.
  bool hasQuantityDifference() {
    if (receivingQuantity == null) return false;
    return (receivingQuantity! - quantity).abs() > 0.001;
  }

  @override
  String toString() =>
      'ReceiptItem(itemId: $itemId, name: $itemName, qty: $quantity, receivingQty: $receivingQuantity)';
}

/// Purchase receipt model.
class PurchaseReceipt {
  final int id;
  final String supplier;
  final String reference;
  final DateTime date;
  final String createdBy;
  final ReceiptStatus status;
  final List<ReceiptItem> items;
  final double totalCost;
  final DateTime createdAt;
  final DateTime? updatedAt;

  const PurchaseReceipt({
    required this.id,
    required this.supplier,
    required this.reference,
    required this.date,
    required this.createdBy,
    required this.status,
    required this.items,
    required this.totalCost,
    required this.createdAt,
    this.updatedAt,
  });

  factory PurchaseReceipt.fromDTO(PurchaseReceiptDTO dto) {
    return PurchaseReceipt(
      id: dto.id,
      supplier: dto.supplier,
      reference: dto.reference,
      date: DateTime.parse(dto.date),
      createdBy: dto.createdBy,
      status: ReceiptStatus.fromString(dto.status) ?? ReceiptStatus.pending,
      items: dto.items.map((item) => ReceiptItem.fromDTO(item)).toList(),
      totalCost: double.tryParse(dto.totalCost) ?? 0.0,
      createdAt: DateTime.parse(dto.createdAt),
      updatedAt: dto.updatedAt != null ? DateTime.parse(dto.updatedAt!) : null,
    );
  }

  /// Get summary string (e.g., "3 items - 650 units").
  String getSummary() {
    final itemsCount = items.length;
    final totalQuantity = items.fold(0.0, (sum, item) => sum + item.quantity);
    return '$itemsCount items - ${totalQuantity.toStringAsFixed(0)} units';
  }

  /// Check if receipt can be approved.
  bool canApprove() {
    return status == ReceiptStatus.pending;
  }

  /// Check if receipt can be rejected.
  bool canReject() {
    return status == ReceiptStatus.pending;
  }

  @override
  String toString() =>
      'PurchaseReceipt(id: $id, supplier: $supplier, status: ${status.value}, total: $totalCost)';
}

/// Batch input model (ingredient or packaging with stock availability).
class BatchInput {
  final int inputId;
  final String inputName;
  final String? lotNumber;
  final DateTime? expiryDate;
  final double requiredQuantity;
  final double availableQuantity;
  final String unit;
  final BatchInputStatus status;

  const BatchInput({
    required this.inputId,
    required this.inputName,
    this.lotNumber,
    this.expiryDate,
    required this.requiredQuantity,
    required this.availableQuantity,
    required this.unit,
    required this.status,
  });

  factory BatchInput.fromDTO(BatchInputDTO dto) {
    return BatchInput(
      inputId: dto.inputId,
      inputName: dto.inputName,
      lotNumber: dto.lotNumber,
      expiryDate: dto.expiryDate != null
          ? DateTime.tryParse(dto.expiryDate!)
          : null,
      requiredQuantity: double.tryParse(dto.requiredQuantity) ?? 0.0,
      availableQuantity: double.tryParse(dto.availableQuantity) ?? 0.0,
      unit: dto.unit,
      status: BatchInputStatus.fromString(dto.status) ?? BatchInputStatus.ok,
    );
  }

  /// Check if input has shortage.
  bool hasShortage() {
    return status == BatchInputStatus.short;
  }

  /// Check if input is low.
  bool isLow() {
    return status == BatchInputStatus.low;
  }

  /// Get lot info string (e.g., "Lot #3821 - Exp: 12/24").
  String? getLotInfo() {
    if (lotNumber == null && expiryDate == null) return null;
    final lotPart = lotNumber != null ? 'Lot #$lotNumber' : '';
    final expPart = expiryDate != null
        ? 'Exp: ${expiryDate!.month.toString().padLeft(2, '0')}/${expiryDate!.year.toString().substring(2)}'
        : '';
    if (lotPart.isEmpty && expPart.isEmpty) return null;
    if (lotPart.isEmpty) return expPart;
    if (expPart.isEmpty) return lotPart;
    return '$lotPart - $expPart';
  }

  @override
  String toString() =>
      'BatchInput(inputId: $inputId, name: $inputName, required: $requiredQuantity, available: $availableQuantity, status: ${status.value})';
}

/// Batch packaging model.
class BatchPackaging {
  final int packagingId;
  final String packagingName;
  final String? sku;
  final double requiredQuantity;
  final double availableQuantity;
  final BatchInputStatus status;

  const BatchPackaging({
    required this.packagingId,
    required this.packagingName,
    this.sku,
    required this.requiredQuantity,
    required this.availableQuantity,
    required this.status,
  });

  factory BatchPackaging.fromDTO(BatchPackagingDTO dto) {
    return BatchPackaging(
      packagingId: dto.packagingId,
      packagingName: dto.packagingName,
      sku: dto.sku,
      requiredQuantity: double.tryParse(dto.requiredQuantity) ?? 0.0,
      availableQuantity: double.tryParse(dto.availableQuantity) ?? 0.0,
      status: BatchInputStatus.fromString(dto.status) ?? BatchInputStatus.ok,
    );
  }

  /// Check if packaging has shortage.
  bool hasShortage() {
    return status == BatchInputStatus.short;
  }

  /// Check if packaging is low.
  bool isLow() {
    return status == BatchInputStatus.low;
  }

  @override
  String toString() =>
      'BatchPackaging(packagingId: $packagingId, name: $packagingName, required: $requiredQuantity, available: $availableQuantity, status: ${status.value})';
}

/// Batch wastage model.
class BatchWastage {
  final double quantity;
  final StockAdjustmentType reasonCode;
  final String? reasonDescription;

  const BatchWastage({
    required this.quantity,
    required this.reasonCode,
    this.reasonDescription,
  });

  factory BatchWastage.fromDTO(BatchWastageDTO dto) {
    return BatchWastage(
      quantity: double.tryParse(dto.quantity) ?? 0.0,
      reasonCode:
          StockAdjustmentType.fromString(dto.reasonCode) ??
          StockAdjustmentType.wastage,
      reasonDescription: dto.reasonDescription,
    );
  }

  /// Get reason display string.
  String getReasonDisplay() {
    final codeStr = reasonCode.value;
    if (reasonDescription != null && reasonDescription!.isNotEmpty) {
      return '$codeStr: $reasonDescription';
    }
    return codeStr;
  }

  @override
  String toString() =>
      'BatchWastage(quantity: $quantity, reason: ${reasonCode.value})';
}

/// Production batch model.
class ProductionBatch {
  final int id;
  final int productId;
  final String productName;
  final DateTime productionDate;
  final int locationId;
  final String? locationName;
  final double plannedOutput;
  final double? actualOutput;
  final BatchStatus status;
  final String? notes;
  final String batchNumber;
  final DateTime createdAt;
  final DateTime? updatedAt;
  final DateTime? completedAt;

  const ProductionBatch({
    required this.id,
    required this.productId,
    required this.productName,
    required this.productionDate,
    required this.locationId,
    this.locationName,
    required this.plannedOutput,
    this.actualOutput,
    required this.status,
    this.notes,
    required this.batchNumber,
    required this.createdAt,
    this.updatedAt,
    this.completedAt,
  });

  factory ProductionBatch.fromDTO(ProductionBatchDTO dto) {
    return ProductionBatch(
      id: dto.id,
      productId: dto.productId,
      productName: dto.productName,
      productionDate: DateTime.parse(dto.productionDate),
      locationId: dto.locationId,
      locationName: dto.locationName,
      plannedOutput: double.tryParse(dto.plannedOutput) ?? 0.0,
      actualOutput: dto.actualOutput != null
          ? double.tryParse(dto.actualOutput!)
          : null,
      status: BatchStatus.fromString(dto.status) ?? BatchStatus.draft,
      notes: dto.notes,
      batchNumber: dto.batchNumber,
      createdAt: DateTime.parse(dto.createdAt),
      updatedAt: dto.updatedAt != null ? DateTime.parse(dto.updatedAt!) : null,
      completedAt: dto.completedAt != null
          ? DateTime.parse(dto.completedAt!)
          : null,
    );
  }

  /// Calculate variance percentage (actual vs planned).
  /// Returns null if actualOutput is null.
  double? calculateVariance() {
    if (actualOutput == null) return null;
    if (plannedOutput == 0) return null;
    return ((actualOutput! - plannedOutput) / plannedOutput) * 100;
  }

  /// Get formatted variance string (e.g., "-4%" or "+2%").
  String? getFormattedVariance() {
    final variance = calculateVariance();
    if (variance == null) return null;
    final sign = variance >= 0 ? '+' : '';
    return '$sign${variance.toStringAsFixed(1)}%';
  }

  /// Check if batch can be started.
  bool canStart() {
    return status == BatchStatus.draft || status == BatchStatus.pending;
  }

  /// Check if batch can be completed.
  bool canComplete() {
    return status == BatchStatus.inProgress;
  }

  /// Check if batch is in progress.
  bool isInProgress() {
    return status == BatchStatus.inProgress;
  }

  /// Check if batch is completed.
  bool isCompleted() {
    return status == BatchStatus.completed;
  }

  @override
  String toString() =>
      'ProductionBatch(id: $id, batchNumber: $batchNumber, product: $productName, status: ${status.value}, plannedOutput: $plannedOutput)';
}

/// Activity item model (for recent activity feed).
enum ActivityType {
  purchase('PURCHASE'),
  production('PRODUCTION'),
  stockAdjustment('STOCK_ADJUSTMENT');

  final String value;
  const ActivityType(this.value);

  static ActivityType? fromString(String? value) {
    if (value == null) return null;
    for (final type in ActivityType.values) {
      if (type.value == value.toUpperCase()) {
        return type;
      }
    }
    return null;
  }
}

/// Activity item model.
class ActivityItem {
  final int id;
  final ActivityType type;
  final String itemName;
  final String? itemImage;
  final String activityType; // 'Received Supply', 'Production Batch #042', etc.
  final double quantityChange; // Parsed from "+50kg" or "-120 Btl"
  final bool isPositive; // true if positive change
  final DateTime timestamp;
  final String? reference; // Batch number, receipt reference, etc.

  const ActivityItem({
    required this.id,
    required this.type,
    required this.itemName,
    this.itemImage,
    required this.activityType,
    required this.quantityChange,
    required this.isPositive,
    required this.timestamp,
    this.reference,
  });

  factory ActivityItem.fromDTO(ActivityItemDTO dto) {
    // Parse quantity change (e.g., "+50kg" or "-120 Btl")
    final quantityStr = dto.quantityChange.trim();
    final isPositive = !quantityStr.startsWith('-');
    final cleanedQuantity = quantityStr.replaceAll(RegExp(r'[+\-]'), '').trim();
    // Extract numeric part (remove unit)
    final numericPart = cleanedQuantity.split(RegExp(r'\s+')).first;
    final quantity = double.tryParse(numericPart) ?? 0.0;

    return ActivityItem(
      id: dto.id,
      type: ActivityType.fromString(dto.type) ?? ActivityType.purchase,
      itemName: dto.itemName,
      itemImage: dto.itemImage,
      activityType: dto.activityType,
      quantityChange: quantity,
      isPositive: isPositive,
      timestamp: DateTime.parse(dto.timestamp),
      reference: dto.reference,
    );
  }

  /// Get formatted quantity change (e.g., "+50kg" or "-120 Btl").
  String getFormattedQuantityChange() {
    final sign = isPositive ? '+' : '-';
    return '$sign${quantityChange.toStringAsFixed(0)}';
  }

  @override
  String toString() =>
      'ActivityItem(id: $id, type: ${type.value}, item: $itemName, change: ${getFormattedQuantityChange()})';
}

/// Batch inputs data model (ingredients and packaging).
class BatchInputsData {
  final List<BatchInput> ingredients;
  final List<BatchPackaging> packaging;

  const BatchInputsData({required this.ingredients, required this.packaging});

  factory BatchInputsData.fromDTO(BatchInputsResponseDTO dto) {
    return BatchInputsData(
      ingredients: dto.ingredients
          .map((item) => BatchInput.fromDTO(item))
          .toList(),
      packaging: dto.packaging
          .map((item) => BatchPackaging.fromDTO(item))
          .toList(),
    );
  }

  /// Check if there are any shortages.
  bool hasShortages() {
    return ingredients.any((ing) => ing.hasShortage()) ||
        packaging.any((pkg) => pkg.hasShortage());
  }

  /// Get all inputs with shortages.
  List<BatchInput> getIngredientsWithShortage() {
    return ingredients.where((ing) => ing.hasShortage()).toList();
  }

  /// Get all packaging with shortages.
  List<BatchPackaging> getPackagingWithShortage() {
    return packaging.where((pkg) => pkg.hasShortage()).toList();
  }

  @override
  String toString() =>
      'BatchInputsData(ingredients: ${ingredients.length}, packaging: ${packaging.length})';
}
