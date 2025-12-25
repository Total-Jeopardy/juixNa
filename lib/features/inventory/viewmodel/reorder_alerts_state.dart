import 'package:juix_na/features/inventory/model/inventory_models.dart';

/// Reorder alert severity level.
enum ReorderAlertSeverity {
  critical, // Out of stock or very low
  low, // Below reorder level
}

/// Reorder alert model.
/// Represents an item that needs to be reordered.
class ReorderAlert {
  final InventoryItem item;
  final double currentStock;
  final double? reorderLevel;
  final double? suggestedReorderQuantity;
  final ReorderAlertSeverity severity;
  final String? locationName; // If location-specific

  const ReorderAlert({
    required this.item,
    required this.currentStock,
    this.reorderLevel,
    this.suggestedReorderQuantity,
    required this.severity,
    this.locationName,
  });

  /// Check if item is out of stock.
  bool get isOutOfStock => currentStock <= 0;

  /// Check if item is critically low.
  bool get isCritical => severity == ReorderAlertSeverity.critical;

  /// Get display message for the alert.
  String get message {
    if (isOutOfStock) {
      return 'Out of stock';
    }
    if (reorderLevel != null) {
      return 'Below reorder level (${reorderLevel!.toStringAsFixed(2)})';
    }
    return 'Low stock';
  }

  @override
  String toString() {
    return 'ReorderAlert(item: ${item.name}, stock: $currentStock, severity: $severity)';
  }
}

/// Reorder alerts state.
/// Manages list of items that need reordering.
class ReorderAlertsState {
  final List<ReorderAlert> alerts;
  final int? selectedLocationId; // Filter by location (optional)
  final bool isLoading;
  final String? error;

  const ReorderAlertsState({
    this.alerts = const [],
    this.selectedLocationId,
    this.isLoading = false,
    this.error,
  });

  /// Create a copy with updated fields.
  ReorderAlertsState copyWith({
    List<ReorderAlert>? alerts,
    int? selectedLocationId,
    bool? isLoading,
    String? error,
    bool clearSelectedLocation = false,
    bool clearError = false,
  }) {
    return ReorderAlertsState(
      alerts: alerts ?? this.alerts,
      selectedLocationId: clearSelectedLocation
          ? null
          : (selectedLocationId ?? this.selectedLocationId),
      isLoading: isLoading ?? this.isLoading,
      error: clearError ? null : (error ?? this.error),
    );
  }

  /// Create loading state.
  factory ReorderAlertsState.loading() {
    return const ReorderAlertsState(isLoading: true);
  }

  /// Create error state.
  factory ReorderAlertsState.error(String error) {
    return ReorderAlertsState(error: error, isLoading: false);
  }

  /// Create initial/empty state.
  factory ReorderAlertsState.initial() {
    return const ReorderAlertsState();
  }

  /// Get critical alerts (out of stock or very low).
  List<ReorderAlert> get criticalAlerts {
    return alerts.where((alert) => alert.isCritical).toList();
  }

  /// Get low stock alerts (below reorder level but not critical).
  List<ReorderAlert> get lowStockAlerts {
    return alerts.where((alert) => !alert.isCritical).toList();
  }

  /// Get out of stock alerts.
  List<ReorderAlert> get outOfStockAlerts {
    return alerts.where((alert) => alert.isOutOfStock).toList();
  }

  /// Check if state has alerts.
  bool get hasAlerts => alerts.isNotEmpty;

  /// Check if state is in error state.
  bool get hasError => error != null && error!.isNotEmpty;

  /// Get total count of alerts.
  int get totalCount => alerts.length;

  /// Get count of critical alerts.
  int get criticalCount => criticalAlerts.length;

  /// Get count of out of stock alerts.
  int get outOfStockCount => outOfStockAlerts.length;

  /// Check if viewing all locations (global view).
  /// Returns true if selectedLocationId is null.
  bool get isViewingAllLocations => selectedLocationId == null;

  /// Check if filtering by a specific location.
  bool get isFilteringByLocation => selectedLocationId != null;

  @override
  String toString() {
    return 'ReorderAlertsState('
        'alerts: ${alerts.length}, '
        'critical: $criticalCount, '
        'outOfStock: $outOfStockCount, '
        'selectedLocationId: $selectedLocationId, '
        'isLoading: $isLoading, '
        'error: $error'
        ')';
  }
}

