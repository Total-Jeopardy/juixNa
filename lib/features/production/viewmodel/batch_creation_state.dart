/// State for the New Batch screen.
class BatchCreationState {
  final int? productId;
  final DateTime productionDate;
  final int? locationId;
  final double plannedOutput;
  final String? notes;
  final bool isLoading;
  final String? error;

  const BatchCreationState({
    this.productId,
    required this.productionDate,
    this.locationId,
    required this.plannedOutput,
    this.notes,
    required this.isLoading,
    this.error,
  });

  /// Initial state.
  factory BatchCreationState.initial() {
    return BatchCreationState(
      productId: null,
      productionDate: DateTime.now(),
      locationId: null,
      plannedOutput: 0.0,
      notes: null,
      isLoading: false,
      error: null,
    );
  }

  /// Check if the form is valid.
  /// Validates that product, location, and plannedOutput are set and positive.
  /// Guards against NaN values in plannedOutput.
  bool isValid() {
    return productId != null &&
        productId! > 0 &&
        locationId != null &&
        locationId! > 0 &&
        !plannedOutput.isNaN &&
        plannedOutput > 0;
  }

  /// Check if state has an error.
  bool get hasError => error != null && error!.isNotEmpty;

  /// Create a copy with updated values.
  BatchCreationState copyWith({
    int? productId,
    DateTime? productionDate,
    int? locationId,
    double? plannedOutput,
    String? notes,
    bool? isLoading,
    String? error,
    bool clearError = false,
  }) {
    return BatchCreationState(
      productId: productId ?? this.productId,
      productionDate: productionDate ?? this.productionDate,
      locationId: locationId ?? this.locationId,
      plannedOutput: plannedOutput ?? this.plannedOutput,
      notes: notes ?? this.notes,
      isLoading: isLoading ?? this.isLoading,
      error: clearError ? null : (error ?? this.error),
    );
  }

  /// Reset state to initial values.
  BatchCreationState reset() {
    return BatchCreationState.initial();
  }
}
