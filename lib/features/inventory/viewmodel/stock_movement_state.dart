import 'package:juix_na/features/inventory/model/inventory_models.dart';

/// Stock movement type (for UI).
enum StockMovementType {
  stockIn,
  stockOut,
}

/// Stock movement state for the stock movement screen.
/// Manages form data, available products, locations, and validation.
class StockMovementState {
  // Form fields
  final StockMovementType movementType;
  final DateTime date;
  final InventoryItem? selectedItem;
  final int? selectedLocationId;
  final double quantity;
  final String reason; // BREAKAGE, SALE, etc.
  final String? reference;
  final String? note;

  // Available options (for pickers)
  final List<InventoryItem> availableItems;
  final List<Location> availableLocations;

  // Available stock (for validation)
  final double? availableStock; // Current stock at selected location

  // Loading states
  final bool isLoadingItems;
  final bool isLoadingLocations;
  final bool isLoadingAvailableStock;
  final bool isSubmitting;

  // Validation/error states
  final String? error;
  final Map<String, String> fieldErrors; // Field-specific errors

  StockMovementState({
    this.movementType = StockMovementType.stockOut,
    DateTime? date,
    this.selectedItem,
    this.selectedLocationId,
    this.quantity = 0.0,
    this.reason = '',
    this.reference,
    this.note,
    this.availableItems = const [],
    this.availableLocations = const [],
    this.availableStock,
    this.isLoadingItems = false,
    this.isLoadingLocations = false,
    this.isLoadingAvailableStock = false,
    this.isSubmitting = false,
    this.error,
    this.fieldErrors = const {},
  }) : date = date ?? DateTime.now();

  /// Create a copy with updated fields.
  StockMovementState copyWith({
    StockMovementType? movementType,
    DateTime? date,
    InventoryItem? selectedItem,
    int? selectedLocationId,
    double? quantity,
    String? reason,
    String? reference,
    String? note,
    List<InventoryItem>? availableItems,
    List<Location>? availableLocations,
    double? availableStock,
    bool? isLoadingItems,
    bool? isLoadingLocations,
    bool? isLoadingAvailableStock,
    bool? isSubmitting,
    String? error,
    Map<String, String>? fieldErrors,
    bool clearSelectedItem = false,
    bool clearSelectedLocation = false,
    bool clearAvailableStock = false,
    bool clearError = false,
    bool clearFieldErrors = false,
  }) {
    return StockMovementState(
      movementType: movementType ?? this.movementType,
      date: date ?? this.date,
      selectedItem: clearSelectedItem
          ? null
          : (selectedItem ?? this.selectedItem),
      selectedLocationId: clearSelectedLocation
          ? null
          : (selectedLocationId ?? this.selectedLocationId),
      quantity: quantity ?? this.quantity,
      reason: reason ?? this.reason,
      reference: reference ?? this.reference,
      note: note ?? this.note,
      availableItems: availableItems ?? this.availableItems,
      availableLocations: availableLocations ?? this.availableLocations,
      availableStock: clearAvailableStock
          ? null
          : (availableStock ?? this.availableStock),
      isLoadingItems: isLoadingItems ?? this.isLoadingItems,
      isLoadingLocations: isLoadingLocations ?? this.isLoadingLocations,
      isLoadingAvailableStock:
          isLoadingAvailableStock ?? this.isLoadingAvailableStock,
      isSubmitting: isSubmitting ?? this.isSubmitting,
      error: clearError ? null : (error ?? this.error),
      fieldErrors: clearFieldErrors
          ? {}
          : (fieldErrors ?? this.fieldErrors),
    );
  }

  /// Create initial/empty state.
  factory StockMovementState.initial() {
    return StockMovementState();
  }

  /// Check if form is valid for submission.
  bool get isValid {
    return selectedItem != null &&
        selectedLocationId != null &&
        quantity > 0 &&
        reason.isNotEmpty &&
        fieldErrors.isEmpty &&
        (movementType == StockMovementType.stockIn ||
            (availableStock != null && quantity <= availableStock!));
  }

  /// Check if quantity exceeds available stock (for stock-out).
  bool get quantityExceedsAvailable {
    if (movementType == StockMovementType.stockIn) return false;
    if (availableStock == null) return false;
    return quantity > availableStock!;
  }

  /// Get validation error for quantity field.
  String? get quantityError {
    if (quantity <= 0) {
      return 'Quantity must be greater than 0';
    }
    if (quantityExceedsAvailable) {
      return 'Quantity exceeds available stock (${availableStock?.toStringAsFixed(2) ?? 'N/A'})';
    }
    return null;
  }

  /// Check if any loading operation is in progress.
  bool get isAnyLoading =>
      isLoadingItems ||
      isLoadingLocations ||
      isLoadingAvailableStock ||
      isSubmitting;

  /// Get selected location (if any).
  Location? get selectedLocation {
    if (selectedLocationId == null) return null;
    return availableLocations.firstWhere(
      (loc) => loc.id == selectedLocationId,
      orElse: () => availableLocations.firstOrNull ?? Location(
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
    return 'StockMovementState('
        'movementType: $movementType, '
        'selectedItem: ${selectedItem?.name ?? 'none'}, '
        'selectedLocationId: $selectedLocationId, '
        'quantity: $quantity, '
        'reason: $reason, '
        'isValid: $isValid, '
        'isSubmitting: $isSubmitting'
        ')';
  }
}

/// Extension to get first element or null from list.
extension LocationListExtension on List<Location> {
  Location? get firstOrNull => isEmpty ? null : first;
}

/// Extension to get first element or null from list (generic).
extension ListExtension<T> on List<T> {
  T? get firstOrNull => isEmpty ? null : first;
}

