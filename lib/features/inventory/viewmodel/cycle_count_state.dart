import 'package:juix_na/features/inventory/model/inventory_models.dart';

/// Cycle count state for the cycle count screen.
/// Manages form data, system quantity, counted quantity, and variance.
class CycleCountState {
  // Form fields
  final DateTime date;
  final InventoryItem? selectedItem;
  final int? selectedLocationId;
  final double? systemQuantity; // What the system thinks is there
  final double? countedQuantity; // What was physically counted
  final String? note;

  // Available options (for pickers)
  final List<InventoryItem> availableItems;
  final List<Location> availableLocations;

  // Loading states
  final bool isLoadingItems;
  final bool isLoadingLocations;
  final bool isLoadingSystemQuantity;
  final bool isSubmitting;

  // Validation/error states
  final String? error;
  final Map<String, String> fieldErrors; // Field-specific errors

  CycleCountState({
    DateTime? date,
    this.selectedItem,
    this.selectedLocationId,
    this.systemQuantity,
    this.countedQuantity,
    this.note,
    this.availableItems = const [],
    this.availableLocations = const [],
    this.isLoadingItems = false,
    this.isLoadingLocations = false,
    this.isLoadingSystemQuantity = false,
    this.isSubmitting = false,
    this.error,
    this.fieldErrors = const {},
  }) : date = date ?? DateTime.now();

  /// Create a copy with updated fields.
  CycleCountState copyWith({
    DateTime? date,
    InventoryItem? selectedItem,
    int? selectedLocationId,
    double? systemQuantity,
    double? countedQuantity,
    String? note,
    List<InventoryItem>? availableItems,
    List<Location>? availableLocations,
    bool? isLoadingItems,
    bool? isLoadingLocations,
    bool? isLoadingSystemQuantity,
    bool? isSubmitting,
    String? error,
    Map<String, String>? fieldErrors,
    bool clearSelectedItem = false,
    bool clearSelectedLocation = false,
    bool clearSystemQuantity = false,
    bool clearCountedQuantity = false,
    bool clearError = false,
    bool clearFieldErrors = false,
  }) {
    return CycleCountState(
      date: date ?? this.date,
      selectedItem: clearSelectedItem
          ? null
          : (selectedItem ?? this.selectedItem),
      selectedLocationId: clearSelectedLocation
          ? null
          : (selectedLocationId ?? this.selectedLocationId),
      systemQuantity: clearSystemQuantity
          ? null
          : (systemQuantity ?? this.systemQuantity),
      countedQuantity: clearCountedQuantity
          ? null
          : (countedQuantity ?? this.countedQuantity),
      note: note ?? this.note,
      availableItems: availableItems ?? this.availableItems,
      availableLocations: availableLocations ?? this.availableLocations,
      isLoadingItems: isLoadingItems ?? this.isLoadingItems,
      isLoadingLocations: isLoadingLocations ?? this.isLoadingLocations,
      isLoadingSystemQuantity:
          isLoadingSystemQuantity ?? this.isLoadingSystemQuantity,
      isSubmitting: isSubmitting ?? this.isSubmitting,
      error: clearError ? null : (error ?? this.error),
      fieldErrors: clearFieldErrors
          ? {}
          : (fieldErrors ?? this.fieldErrors),
    );
  }

  /// Create initial/empty state.
  factory CycleCountState.initial() {
    return CycleCountState();
  }

  /// Calculate variance (counted - system).
  /// Returns null if either quantity is not set.
  double? get variance {
    if (systemQuantity == null || countedQuantity == null) return null;
    return countedQuantity! - systemQuantity!;
  }

  /// Check if there is a variance (difference between counted and system).
  bool get hasVariance {
    final v = variance;
    return v != null && v != 0.0;
  }

  /// Check if variance is positive (counted > system = stock gain).
  bool get isPositiveVariance {
    final v = variance;
    return v != null && v > 0;
  }

  /// Check if variance is negative (counted < system = stock loss).
  bool get isNegativeVariance {
    final v = variance;
    return v != null && v < 0;
  }

  /// Get absolute variance (for display).
  double? get absoluteVariance {
    final v = variance;
    return v != null ? v.abs() : null;
  }

  /// Check if form is valid for submission.
  bool get isValid {
    return selectedItem != null &&
        selectedLocationId != null &&
        systemQuantity != null &&
        countedQuantity != null &&
        fieldErrors.isEmpty;
  }

  /// Check if any loading operation is in progress.
  bool get isAnyLoading =>
      isLoadingItems ||
      isLoadingLocations ||
      isLoadingSystemQuantity ||
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
    return 'CycleCountState('
        'selectedItem: ${selectedItem?.name ?? 'none'}, '
        'selectedLocationId: $selectedLocationId, '
        'systemQuantity: $systemQuantity, '
        'countedQuantity: $countedQuantity, '
        'variance: $variance, '
        'isValid: $isValid, '
        'isSubmitting: $isSubmitting'
        ')';
  }
}

/// Extension to get first element or null from list.
extension LocationListExtension on List<Location> {
  Location? get firstOrNull => isEmpty ? null : first;
}

