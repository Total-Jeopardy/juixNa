import 'package:juix_na/features/inventory/model/inventory_models.dart';

/// Transfer status for display purposes.
/// Note: The API doesn't return explicit status for transfers.
/// For v1, we assume all transfers are SYNCED (they're already in the system).
enum TransferDisplayStatus {
  synced, // Successfully completed
  pending, // In progress (not applicable for v1, as API doesn't support this)
  failed, // Failed (not applicable for v1, as API doesn't support this)
}

/// Transfer History State for the Transfer History screen.
/// Manages list of stock transfers (movements with type: TRANSFER) with filtering.
class TransferHistoryState {
  final List<StockMovement> transfers; // Filtered to type: TRANSFER
  final List<Location> availableLocations; // For location filter

  // Filters
  final DateTime? fromDate;
  final DateTime? toDate;
  final int? selectedLocationId; // Source location filter
  final int? selectedItemId; // Product filter
  final TransferDisplayStatus? statusFilter; // Status filter (for future use)

  // Loading states
  final bool isLoading;
  final bool isLoadingLocations;

  // Error state
  final String? error;

  // Pagination
  final PaginationInfo? pagination;

  const TransferHistoryState({
    this.transfers = const [],
    this.availableLocations = const [],
    this.fromDate,
    this.toDate,
    this.selectedLocationId,
    this.selectedItemId,
    this.statusFilter,
    this.isLoading = false,
    this.isLoadingLocations = false,
    this.error,
    this.pagination,
  });

  /// Create a copy with updated fields.
  TransferHistoryState copyWith({
    List<StockMovement>? transfers,
    List<Location>? availableLocations,
    DateTime? fromDate,
    DateTime? toDate,
    int? selectedLocationId,
    int? selectedItemId,
    TransferDisplayStatus? statusFilter,
    bool? isLoading,
    bool? isLoadingLocations,
    String? error,
    PaginationInfo? pagination,
    bool clearFromDate = false,
    bool clearToDate = false,
    bool clearSelectedLocation = false,
    bool clearSelectedItem = false,
    bool clearStatusFilter = false,
    bool clearError = false,
    bool clearPagination = false,
  }) {
    return TransferHistoryState(
      transfers: transfers ?? this.transfers,
      availableLocations: availableLocations ?? this.availableLocations,
      fromDate: clearFromDate ? null : (fromDate ?? this.fromDate),
      toDate: clearToDate ? null : (toDate ?? this.toDate),
      selectedLocationId: clearSelectedLocation
          ? null
          : (selectedLocationId ?? this.selectedLocationId),
      selectedItemId: clearSelectedItem
          ? null
          : (selectedItemId ?? this.selectedItemId),
      statusFilter: clearStatusFilter
          ? null
          : (statusFilter ?? this.statusFilter),
      isLoading: isLoading ?? this.isLoading,
      isLoadingLocations: isLoadingLocations ?? this.isLoadingLocations,
      error: clearError ? null : (error ?? this.error),
      pagination: clearPagination ? null : (pagination ?? this.pagination),
    );
  }

  /// Create initial/empty state.
  factory TransferHistoryState.initial() {
    return const TransferHistoryState();
  }

  /// Create loading state.
  factory TransferHistoryState.loading() {
    return const TransferHistoryState(isLoading: true);
  }

  /// Create error state.
  factory TransferHistoryState.error(String error) {
    return TransferHistoryState(error: error, isLoading: false);
  }

  /// Check if state has transfers.
  bool get hasTransfers => transfers.isNotEmpty;

  /// Check if state is in error state.
  bool get hasError => error != null && error!.isNotEmpty;

  /// Get total count of transfers.
  int get totalCount => transfers.length;

  @override
  String toString() {
    return 'TransferHistoryState('
        'transfers: ${transfers.length}, '
        'isLoading: $isLoading, '
        'error: $error'
        ')';
  }
}
