/// Data Transfer Objects for production API requests and responses.
/// These match the backend API contract exactly.

/// Batch status enum for DTOs.
enum BatchStatusDTO {
  draft('DRAFT'),
  pending('PENDING'),
  inProgress('IN_PROGRESS'),
  completed('COMPLETED'),
  cancelled('CANCELLED');

  final String value;
  const BatchStatusDTO(this.value);

  static BatchStatusDTO? fromString(String? value) {
    if (value == null) return null;
    for (final status in BatchStatusDTO.values) {
      if (status.value == value.toUpperCase()) {
        return status;
      }
    }
    return null;
  }
}

/// Receipt status enum for DTOs.
enum ReceiptStatusDTO {
  pending('PENDING'),
  approved('APPROVED'),
  rejected('REJECTED');

  final String value;
  const ReceiptStatusDTO(this.value);

  static ReceiptStatusDTO? fromString(String? value) {
    if (value == null) return null;
    for (final status in ReceiptStatusDTO.values) {
      if (status.value == value.toUpperCase()) {
        return status;
      }
    }
    return null;
  }
}

/// Stock adjustment type enum for DTOs.
enum StockAdjustmentTypeDTO {
  wastage('WASTAGE'),
  correction('CORRECTION'),
  other('OTHER');

  final String value;
  const StockAdjustmentTypeDTO(this.value);

  static StockAdjustmentTypeDTO? fromString(String? value) {
    if (value == null) return null;
    for (final type in StockAdjustmentTypeDTO.values) {
      if (type.value == value.toUpperCase()) {
        return type;
      }
    }
    return null;
  }
}

/// Purchase item DTO (for purchase entry).
class PurchaseItemDTO {
  final int itemId;
  final String itemName;
  final String quantity;
  final String unit;
  final String unitCost;
  final String subtotal;

  const PurchaseItemDTO({
    required this.itemId,
    required this.itemName,
    required this.quantity,
    required this.unit,
    required this.unitCost,
    required this.subtotal,
  });

  factory PurchaseItemDTO.fromJson(Map<String, dynamic> json) {
    return PurchaseItemDTO(
      itemId: json['item_id'] as int,
      itemName: json['item_name'] as String,
      quantity: json['quantity'] as String,
      unit: json['unit'] as String,
      unitCost: json['unit_cost'] as String,
      subtotal: json['subtotal'] as String,
    );
  }

  Map<String, dynamic> toJson() => {
    'item_id': itemId,
    'item_name': itemName,
    'quantity': quantity,
    'unit': unit,
    'unit_cost': unitCost,
    'subtotal': subtotal,
  };
}

/// Purchase entry request DTO.
class PurchaseEntryRequestDTO {
  final int supplierId;
  final String date;
  final String? refInvoice;
  final List<PurchaseItemDTO> items;
  final bool markAsReceived;

  const PurchaseEntryRequestDTO({
    required this.supplierId,
    required this.date,
    this.refInvoice,
    required this.items,
    required this.markAsReceived,
  });

  Map<String, dynamic> toJson() => {
    'supplier_id': supplierId,
    'date': date,
    if (refInvoice != null) 'ref_invoice': refInvoice,
    'items': items.map((item) => item.toJson()).toList(),
    'mark_as_received': markAsReceived,
  };
}

/// Receipt item DTO (for purchase receipt).
class ReceiptItemDTO {
  final int itemId;
  final String itemName;
  final String quantity;
  final String unit;
  final String unitCost;
  final String subtotal;
  final String? receivingQuantity;

  const ReceiptItemDTO({
    required this.itemId,
    required this.itemName,
    required this.quantity,
    required this.unit,
    required this.unitCost,
    required this.subtotal,
    this.receivingQuantity,
  });

  factory ReceiptItemDTO.fromJson(Map<String, dynamic> json) {
    return ReceiptItemDTO(
      itemId: json['item_id'] as int,
      itemName: json['item_name'] as String,
      quantity: json['quantity'] as String,
      unit: json['unit'] as String,
      unitCost: json['unit_cost'] as String,
      subtotal: json['subtotal'] as String,
      receivingQuantity: json['receiving_quantity'] as String?,
    );
  }

  Map<String, dynamic> toJson() => {
    'item_id': itemId,
    'item_name': itemName,
    'quantity': quantity,
    'unit': unit,
    'unit_cost': unitCost,
    'subtotal': subtotal,
    if (receivingQuantity != null) 'receiving_quantity': receivingQuantity,
  };
}

/// Purchase receipt DTO.
class PurchaseReceiptDTO {
  final int id;
  final String supplier;
  final String reference;
  final String date;
  final String createdBy;
  final String status;
  final List<ReceiptItemDTO> items;
  final String totalCost;
  final String createdAt;
  final String? updatedAt;

  const PurchaseReceiptDTO({
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

  factory PurchaseReceiptDTO.fromJson(Map<String, dynamic> json) {
    final itemsData = json['items'] as List<dynamic>;
    final items = itemsData
        .map((e) => ReceiptItemDTO.fromJson(e as Map<String, dynamic>))
        .toList();

    return PurchaseReceiptDTO(
      id: json['id'] as int,
      supplier: json['supplier'] as String,
      reference: json['reference'] as String,
      date: json['date'] as String,
      createdBy: json['created_by'] as String,
      status: json['status'] as String,
      items: items,
      totalCost: json['total_cost'] as String,
      createdAt: json['created_at'] as String,
      updatedAt: json['updated_at'] as String?,
    );
  }

  Map<String, dynamic> toJson() => {
    'id': id,
    'supplier': supplier,
    'reference': reference,
    'date': date,
    'created_by': createdBy,
    'status': status,
    'items': items.map((item) => item.toJson()).toList(),
    'total_cost': totalCost,
    'created_at': createdAt,
    if (updatedAt != null) 'updated_at': updatedAt,
  };
}

/// Review receipt request DTO.
class ReviewReceiptRequestDTO {
  final String action; // 'approve' or 'reject'
  final Map<int, String>? receivingQuantities; // itemId -> quantity

  const ReviewReceiptRequestDTO({
    required this.action,
    this.receivingQuantities,
  });

  Map<String, dynamic> toJson() => {
    'action': action,
    if (receivingQuantities != null)
      'receiving_quantities': receivingQuantities!.map(
        (key, value) => MapEntry(key.toString(), value),
      ),
  };
}

/// Batch input DTO (ingredient or packaging).
class BatchInputDTO {
  final int inputId;
  final String inputName;
  final String? lotNumber;
  final String? expiryDate;
  final String requiredQuantity;
  final String availableQuantity;
  final String unit;
  final String status; // 'OK' | 'LOW' | 'SHORT'

  const BatchInputDTO({
    required this.inputId,
    required this.inputName,
    this.lotNumber,
    this.expiryDate,
    required this.requiredQuantity,
    required this.availableQuantity,
    required this.unit,
    required this.status,
  });

  factory BatchInputDTO.fromJson(Map<String, dynamic> json) {
    return BatchInputDTO(
      inputId: json['input_id'] as int,
      inputName: json['input_name'] as String,
      lotNumber: json['lot_number'] as String?,
      expiryDate: json['expiry_date'] as String?,
      requiredQuantity: json['required_quantity'] as String,
      availableQuantity: json['available_quantity'] as String,
      unit: json['unit'] as String,
      status: json['status'] as String,
    );
  }

  Map<String, dynamic> toJson() => {
    'input_id': inputId,
    'input_name': inputName,
    if (lotNumber != null) 'lot_number': lotNumber,
    if (expiryDate != null) 'expiry_date': expiryDate,
    'required_quantity': requiredQuantity,
    'available_quantity': availableQuantity,
    'unit': unit,
    'status': status,
  };
}

/// Batch packaging DTO.
class BatchPackagingDTO {
  final int packagingId;
  final String packagingName;
  final String? sku;
  final String requiredQuantity;
  final String availableQuantity;
  final String status; // 'OK' | 'LOW' | 'SHORT'

  const BatchPackagingDTO({
    required this.packagingId,
    required this.packagingName,
    this.sku,
    required this.requiredQuantity,
    required this.availableQuantity,
    required this.status,
  });

  factory BatchPackagingDTO.fromJson(Map<String, dynamic> json) {
    return BatchPackagingDTO(
      packagingId: json['packaging_id'] as int,
      packagingName: json['packaging_name'] as String,
      sku: json['sku'] as String?,
      requiredQuantity: json['required_quantity'] as String,
      availableQuantity: json['available_quantity'] as String,
      status: json['status'] as String,
    );
  }

  Map<String, dynamic> toJson() => {
    'packaging_id': packagingId,
    'packaging_name': packagingName,
    if (sku != null) 'sku': sku,
    'required_quantity': requiredQuantity,
    'available_quantity': availableQuantity,
    'status': status,
  };
}

/// Batch inputs response DTO.
class BatchInputsResponseDTO {
  final List<BatchInputDTO> ingredients;
  final List<BatchPackagingDTO> packaging;

  const BatchInputsResponseDTO({
    required this.ingredients,
    required this.packaging,
  });

  factory BatchInputsResponseDTO.fromJson(Map<String, dynamic> json) {
    final ingredientsData = json['ingredients'] as List<dynamic>? ?? [];
    final ingredients = ingredientsData
        .map((e) => BatchInputDTO.fromJson(e as Map<String, dynamic>))
        .toList();

    final packagingData = json['packaging'] as List<dynamic>? ?? [];
    final packaging = packagingData
        .map((e) => BatchPackagingDTO.fromJson(e as Map<String, dynamic>))
        .toList();

    return BatchInputsResponseDTO(
      ingredients: ingredients,
      packaging: packaging,
    );
  }
}

/// Batch wastage DTO.
class BatchWastageDTO {
  final String quantity;
  final String reasonCode;
  final String? reasonDescription;

  const BatchWastageDTO({
    required this.quantity,
    required this.reasonCode,
    this.reasonDescription,
  });

  factory BatchWastageDTO.fromJson(Map<String, dynamic> json) {
    return BatchWastageDTO(
      quantity: json['quantity'] as String,
      reasonCode: json['reason_code'] as String,
      reasonDescription: json['reason_description'] as String?,
    );
  }

  Map<String, dynamic> toJson() => {
    'quantity': quantity,
    'reason_code': reasonCode,
    if (reasonDescription != null) 'reason_description': reasonDescription,
  };
}

/// Production batch DTO.
class ProductionBatchDTO {
  final int id;
  final int productId;
  final String productName;
  final String productionDate;
  final int locationId;
  final String? locationName;
  final String plannedOutput;
  final String? actualOutput;
  final String status;
  final String? notes;
  final String batchNumber;
  final String createdAt;
  final String? updatedAt;
  final String? completedAt;

  const ProductionBatchDTO({
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

  factory ProductionBatchDTO.fromJson(Map<String, dynamic> json) {
    return ProductionBatchDTO(
      id: json['id'] as int,
      productId: json['product_id'] as int,
      productName: json['product_name'] as String,
      productionDate: json['production_date'] as String,
      locationId: json['location_id'] as int,
      locationName: json['location_name'] as String?,
      plannedOutput: json['planned_output'] as String,
      actualOutput: json['actual_output'] as String?,
      status: json['status'] as String,
      notes: json['notes'] as String?,
      batchNumber: json['batch_number'] as String,
      createdAt: json['created_at'] as String,
      updatedAt: json['updated_at'] as String?,
      completedAt: json['completed_at'] as String?,
    );
  }

  Map<String, dynamic> toJson() => {
    'id': id,
    'product_id': productId,
    'product_name': productName,
    'production_date': productionDate,
    'location_id': locationId,
    if (locationName != null) 'location_name': locationName,
    'planned_output': plannedOutput,
    if (actualOutput != null) 'actual_output': actualOutput,
    'status': status,
    if (notes != null) 'notes': notes,
    'batch_number': batchNumber,
    'created_at': createdAt,
    if (updatedAt != null) 'updated_at': updatedAt,
    if (completedAt != null) 'completed_at': completedAt,
  };
}

/// Create batch request DTO.
class CreateBatchRequestDTO {
  final int productId;
  final String productionDate;
  final int locationId;
  final String plannedOutput;
  final String? notes;

  const CreateBatchRequestDTO({
    required this.productId,
    required this.productionDate,
    required this.locationId,
    required this.plannedOutput,
    this.notes,
  });

  Map<String, dynamic> toJson() => {
    'product_id': productId,
    'production_date': productionDate,
    'location_id': locationId,
    'planned_output': plannedOutput,
    if (notes != null) 'notes': notes,
  };
}

/// Confirm batch inputs request DTO (optional adjusted inputs).
class ConfirmBatchInputsRequestDTO {
  final Map<int, String>? adjustedInputs; // inputId -> adjusted quantity

  const ConfirmBatchInputsRequestDTO({this.adjustedInputs});

  Map<String, dynamic> toJson() => {
    if (adjustedInputs != null)
      'adjusted_inputs': adjustedInputs!.map(
        (key, value) => MapEntry(key.toString(), value),
      ),
  };
}

/// Complete batch request DTO.
class CompleteBatchRequestDTO {
  final String actualOutput;
  final BatchWastageDTO? wastage;

  const CompleteBatchRequestDTO({required this.actualOutput, this.wastage});

  Map<String, dynamic> toJson() => {
    'actual_output': actualOutput,
    if (wastage != null) 'wastage': wastage!.toJson(),
  };
}

/// Activity item DTO (for recent activity feed).
class ActivityItemDTO {
  final int id;
  final String type; // 'PURCHASE' | 'PRODUCTION' | 'STOCK_ADJUSTMENT'
  final String itemName;
  final String? itemImage;
  final String activityType; // 'Received Supply', 'Production Batch', etc.
  final String quantityChange; // '+50kg', '-120 Btl', etc.
  final String timestamp;
  final String? reference; // Batch number, receipt reference, etc.

  const ActivityItemDTO({
    required this.id,
    required this.type,
    required this.itemName,
    this.itemImage,
    required this.activityType,
    required this.quantityChange,
    required this.timestamp,
    this.reference,
  });

  factory ActivityItemDTO.fromJson(Map<String, dynamic> json) {
    return ActivityItemDTO(
      id: json['id'] as int,
      type: json['type'] as String,
      itemName: json['item_name'] as String,
      itemImage: json['item_image'] as String?,
      activityType: json['activity_type'] as String,
      quantityChange: json['quantity_change'] as String,
      timestamp: json['timestamp'] as String,
      reference: json['reference'] as String?,
    );
  }

  Map<String, dynamic> toJson() => {
    'id': id,
    'type': type,
    'item_name': itemName,
    if (itemImage != null) 'item_image': itemImage,
    'activity_type': activityType,
    'quantity_change': quantityChange,
    'timestamp': timestamp,
    if (reference != null) 'reference': reference,
  };
}
