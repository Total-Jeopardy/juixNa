import 'package:juix_na/features/inventory/model/inventory_models.dart';

/// Stock transfer state for the stock transfer screen.
/// Manages form data for transferring stock between locations.
class StockTransferState {
  // Form fields
  final DateTime date;
  final InventoryItem? selectedItem;
  final int? fromLocationId;
  final int? toLocationId;
  final double quantity;
  final String? reference;
  final String? note;

  // Available options (for pickers)
  final List<InventoryItem> availableItems;
  final List<Location> availableLocations;

  // Available stock (for validation)
  final double? availableStock; // Current stock at from-location

  // Loading states
  final bool isLoadingItems;
  final bool isLoadingLocations;
  final bool isLoadingAvailableStock;
  final bool isSubmitting;

  // Validation/error states
  final String? error;
  final Map<String, String> fieldErrors; // Field-specific errors

  StockTransferState({
    DateTime? date,
    this.selectedItem,
    this.fromLocationId,
    this.toLocationId,
    this.quantity = 0.0,
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
  StockTransferState copyWith({
    DateTime? date,
    InventoryItem? selectedItem,
    int? fromLocationId,
    int? toLocationId,
    double? quantity,
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
    bool clearFromLocation = false,
    bool clearToLocation = false,
    bool clearAvailableStock = false,
    bool clearError = false,
    bool clearFieldErrors = false,
  }) {
    return StockTransferState(
      date: date ?? this.date,
      selectedItem: clearSelectedItem
          ? null
          : (selectedItem ?? this.selectedItem),
      fromLocationId: clearFromLocation
          ? null
          : (fromLocationId ?? this.fromLocationId),
      toLocationId: clearToLocation
          ? null
          : (toLocationId ?? this.toLocationId),
      quantity: quantity ?? this.quantity,
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
  factory StockTransferState.initial() {
    return StockTransferState();
  }

  /// Check if form is valid for submission.
  bool get isValid {
    return selectedItem != null &&
        fromLocationId != null &&
        toLocationId != null &&
        fromLocationId != toLocationId && // Must be different locations
        quantity > 0 &&
        fieldErrors.isEmpty &&
        (availableStock == null || quantity <= availableStock!);
  }

  /// Check if quantity exceeds available stock.
  bool get quantityExceedsAvailable {
    if (availableStock == null) return false;
    return quantity > availableStock!;
  }

  /// Check if from and to locations are the same (invalid).
  bool get hasSameLocations {
    if (fromLocationId == null || toLocationId == null) return false;
    return fromLocationId == toLocationId;
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

  /// Get validation error for location fields.
  String? get locationError {
    if (hasSameLocations) {
      return 'From and to locations must be different';
    }
    return null;
  }

  /// Check if any loading operation is in progress.
  bool get isAnyLoading =>
      isLoadingItems ||
      isLoadingLocations ||
      isLoadingAvailableStock ||
      isSubmitting;

  /// Get from location (if any).
  Location? get fromLocation {
    if (fromLocationId == null) return null;
    return availableLocations.firstWhere(
      (loc) => loc.id == fromLocationId,
      orElse: () => availableLocations.firstOrNull ?? Location(
        id: -1,
        name: '',
        isActive: false,
        createdAt: DateTime(1970),
        updatedAt: DateTime(1970),
      ),
    );
  }

  /// Get to location (if any).
  Location? get toLocation {
    if (toLocationId == null) return null;
    return availableLocations.firstWhere(
      (loc) => loc.id == toLocationId,
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
    return 'StockTransferState('
        'selectedItem: ${selectedItem?.name ?? 'none'}, '
        'fromLocationId: $fromLocationId, '
        'toLocationId: $toLocationId, '
        'quantity: $quantity, '
        'isValid: $isValid, '
        'isSubmitting: $isSubmitting'
        ')';
  }
}

/// Extension to get first element or null from list.
extension LocationListExtension on List<Location> {
  Location? get firstOrNull => isEmpty ? null : first;
}

