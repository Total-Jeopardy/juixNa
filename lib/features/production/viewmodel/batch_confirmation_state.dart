import 'package:juix_na/features/production/model/production_models.dart';

/// State for the Confirm Inputs screen.
class BatchConfirmationState {
  final ProductionBatch? batch;
  final List<BatchInput> ingredients;
  final List<BatchPackaging> packaging;
  final Map<int, double>?
  adjustedInputs; // inputId → adjusted quantity (if user adjusts)
  final bool isLoading;
  final String? error;

  const BatchConfirmationState({
    this.batch,
    required this.ingredients,
    required this.packaging,
    this.adjustedInputs,
    required this.isLoading,
    this.error,
  });

  /// Initial state.
  factory BatchConfirmationState.initial() {
    return const BatchConfirmationState(
      batch: null,
      ingredients: [],
      packaging: [],
      adjustedInputs: null,
      isLoading: false,
      error: null,
    );
  }

  /// Check if there are any shortages.
  bool hasShortages() {
    final inputsData = BatchInputsData(
      ingredients: ingredients,
      packaging: packaging,
    );
    return inputsData.hasShortages();
  }

  /// Check if production can be started (no shortages).
  bool canStartProduction() {
    return !hasShortages();
  }

  /// Update adjusted input quantity.
  BatchConfirmationState updateAdjustedInput(int inputId, double quantity) {
    final newAdjustedInputs = Map<int, double>.from(adjustedInputs ?? {});
    newAdjustedInputs[inputId] = quantity;
    return copyWith(adjustedInputs: newAdjustedInputs);
  }

  /// Toggle adjust inputs mode (enable/disable).
  BatchConfirmationState toggleAdjustInputs() {
    if (adjustedInputs == null) {
      // Enable: initialize with current required quantities
      final newAdjustedInputs = <int, double>{};
      for (final ing in ingredients) {
        newAdjustedInputs[ing.inputId] = ing.requiredQuantity;
      }
      for (final pkg in packaging) {
        newAdjustedInputs[pkg.packagingId] = pkg.requiredQuantity;
      }
      return copyWith(adjustedInputs: newAdjustedInputs);
    } else {
      // Disable: clear adjusted inputs
      return copyWith(adjustedInputs: null);
    }
  }

  /// Check if state has batch data.
  bool get hasData => batch != null;

  /// Check if state has an error.
  bool get hasError => error != null && error!.isNotEmpty;

  /// Create a copy with updated values.
  BatchConfirmationState copyWith({
    ProductionBatch? batch,
    List<BatchInput>? ingredients,
    List<BatchPackaging>? packaging,
    Map<int, double>? adjustedInputs,
    bool? isLoading,
    String? error,
    bool clearError = false,
  }) {
    return BatchConfirmationState(
      batch: batch ?? this.batch,
      ingredients: ingredients ?? this.ingredients,
      packaging: packaging ?? this.packaging,
      adjustedInputs: adjustedInputs ?? this.adjustedInputs,
      isLoading: isLoading ?? this.isLoading,
      error: clearError ? null : (error ?? this.error),
    );
  }
}
