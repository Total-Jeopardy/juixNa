import 'package:juix_na/features/production/model/production_models.dart';

/// State for the Purchase Receipts screen.
class PurchaseReceiptsState {
  final List<PurchaseReceipt> receipts;
  final ReceiptStatus? selectedStatus;
  final bool isLoading;
  final String? error;

  const PurchaseReceiptsState({
    required this.receipts,
    this.selectedStatus,
    required this.isLoading,
    this.error,
  });

  /// Initial state.
  factory PurchaseReceiptsState.initial() {
    return const PurchaseReceiptsState(
      receipts: [],
      selectedStatus: null,
      isLoading: false,
      error: null,
    );
  }

  /// Get filtered receipts based on selected status.
  List<PurchaseReceipt> get filteredReceipts {
    if (selectedStatus == null) return receipts;
    return receipts
        .where((receipt) => receipt.status == selectedStatus)
        .toList();
  }

  /// Check if state has receipt data.
  bool get hasData => receipts.isNotEmpty;

  /// Check if state has an error.
  bool get hasError => error != null && error!.isNotEmpty;

  /// Create a copy with updated values.
  PurchaseReceiptsState copyWith({
    List<PurchaseReceipt>? receipts,
    ReceiptStatus? selectedStatus,
    bool? isLoading,
    String? error,
    bool clearError = false,
  }) {
    return PurchaseReceiptsState(
      receipts: receipts ?? this.receipts,
      selectedStatus: selectedStatus ?? this.selectedStatus,
      isLoading: isLoading ?? this.isLoading,
      error: clearError ? null : (error ?? this.error),
    );
  }
}
