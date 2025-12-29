import 'package:juix_na/features/production/model/production_models.dart';

/// State for the Complete Batch screen.
class BatchCompletionState {
  final ProductionBatch? batch;
  final double? actualOutput;
  final BatchWastage? wastage;
  final bool isLoading;
  final bool isSubmitting;
  final String? error;

  const BatchCompletionState({
    this.batch,
    this.actualOutput,
    this.wastage,
    required this.isLoading,
    required this.isSubmitting,
    this.error,
  });

  /// Initial state.
  factory BatchCompletionState.initial() {
    return const BatchCompletionState(
      batch: null,
      actualOutput: null,
      wastage: null,
      isLoading: false,
      isSubmitting: false,
      error: null,
    );
  }

  /// Calculate variance percentage (actual vs planned output).
  /// Returns null if batch/actualOutput is missing or planned output is zero.
  /// Guards against division by zero and NaN values.
  double? calculateVariance() {
    if (batch == null || actualOutput == null) return null;
    if (batch!.plannedOutput == 0) return null;
    final variance =
        ((actualOutput! - batch!.plannedOutput) / batch!.plannedOutput) * 100;
    // Guard against NaN (shouldn't happen with numeric inputs, but safety check)
    if (variance.isNaN || variance.isInfinite) return null;
    return variance;
  }

  /// Get formatted variance string (e.g., "-4%" or "+2%").
  String? getFormattedVariance() {
    final variance = calculateVariance();
    if (variance == null) return null;
    final sign = variance >= 0 ? '+' : '';
    return '$sign${variance.toStringAsFixed(1)}%';
  }

  /// Check if the form is valid for submission.
  /// Validates that batch exists, actualOutput is positive and not NaN,
  /// and wastage (if present) has valid quantity and reason.
  bool isValid() {
    if (batch == null) return false;
    if (actualOutput == null) return false;
    // Guard against NaN and non-positive values
    if (actualOutput!.isNaN || actualOutput! <= 0) return false;
    // Validate wastage if present
    if (wastage != null) {
      if (wastage!.quantity.isNaN ||
          wastage!.quantity <= 0 ||
          wastage!.reasonCode.value.isEmpty) {
        return false;
      }
    }
    return true;
  }

  /// Check if state has batch data.
  bool get hasData => batch != null;

  /// Check if state has an error.
  bool get hasError => error != null && error!.isNotEmpty;

  /// Create a copy with updated values.
  BatchCompletionState copyWith({
    ProductionBatch? batch,
    double? actualOutput,
    BatchWastage? wastage,
    bool? isLoading,
    bool? isSubmitting,
    String? error,
    bool clearError = false,
  }) {
    return BatchCompletionState(
      batch: batch ?? this.batch,
      actualOutput: actualOutput ?? this.actualOutput,
      wastage: wastage ?? this.wastage,
      isLoading: isLoading ?? this.isLoading,
      isSubmitting: isSubmitting ?? this.isSubmitting,
      error: clearError ? null : (error ?? this.error),
    );
  }
}
