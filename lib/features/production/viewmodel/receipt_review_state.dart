import 'package:juix_na/features/production/model/production_models.dart';

/// State for the Receipt Review screen.
class ReceiptReviewState {
  final PurchaseReceipt? receipt;
  final Map<int, double> receivingQuantities; // itemId → receiving quantity
  final bool isLoading;
  final bool isSubmitting;
  final String? error;

  const ReceiptReviewState({
    this.receipt,
    required this.receivingQuantities,
    required this.isLoading,
    required this.isSubmitting,
    this.error,
  });

  /// Initial state.
  factory ReceiptReviewState.initial() {
    return const ReceiptReviewState(
      receipt: null,
      receivingQuantities: {},
      isLoading: false,
      isSubmitting: false,
      error: null,
    );
  }

  /// Check if receipt can be approved.
  bool canApprove() {
    return receipt != null && receipt!.canApprove();
  }

  /// Update receiving quantity for a specific item.
  ReceiptReviewState updateReceivingQuantity(int itemId, double quantity) {
    final newQuantities = Map<int, double>.from(receivingQuantities);
    newQuantities[itemId] = quantity;
    return copyWith(receivingQuantities: newQuantities);
  }

  /// Initialize receiving quantities from receipt items (if not already set).
  ReceiptReviewState initializeReceivingQuantities() {
    if (receipt == null || receivingQuantities.isNotEmpty) return this;
    final newQuantities = <int, double>{};
    for (final item in receipt!.items) {
      newQuantities[item.itemId] = item.quantity;
    }
    return copyWith(receivingQuantities: newQuantities);
  }

  /// Check if state has receipt data.
  bool get hasData => receipt != null;

  /// Check if state has an error.
  bool get hasError => error != null && error!.isNotEmpty;

  /// Create a copy with updated values.
  ReceiptReviewState copyWith({
    PurchaseReceipt? receipt,
    Map<int, double>? receivingQuantities,
    bool? isLoading,
    bool? isSubmitting,
    String? error,
    bool clearError = false,
  }) {
    return ReceiptReviewState(
      receipt: receipt ?? this.receipt,
      receivingQuantities: receivingQuantities ?? this.receivingQuantities,
      isLoading: isLoading ?? this.isLoading,
      isSubmitting: isSubmitting ?? this.isSubmitting,
      error: clearError ? null : (error ?? this.error),
    );
  }
}
