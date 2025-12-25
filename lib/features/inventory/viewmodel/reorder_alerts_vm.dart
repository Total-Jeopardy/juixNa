import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:juix_na/core/network/api_result.dart';
import 'package:juix_na/features/inventory/data/inventory_repository.dart';
import 'package:juix_na/features/inventory/model/inventory_models.dart';
import 'package:juix_na/features/inventory/viewmodel/inventory_overview_vm.dart';
import 'package:juix_na/features/inventory/viewmodel/reorder_alerts_state.dart';

/// Reorder Alerts ViewModel using Riverpod AsyncNotifier.
/// Manages reorder alerts (items below reorder level or out of stock).
class ReorderAlertsViewModel extends AsyncNotifier<ReorderAlertsState> {
  InventoryRepository? _repository;

  /// Get InventoryRepository from ref (dependency injection).
  InventoryRepository get _inventoryRepository {
    _repository ??= ref.read(inventoryRepositoryProvider);
    return _repository!;
  }

  @override
  Future<ReorderAlertsState> build() async {
    // On initialization, load reorder alerts
    return await loadReorderAlerts();
  }

  /// Load reorder alerts from inventory overview.
  /// Uses the overview endpoint which includes low_stock_items and out_of_stock_items.
  /// 
  /// - If [locationId] is null: loads alerts for all locations (global view)
  /// - If [locationId] is set: loads alerts for that specific location only
  /// 
  /// Preserves existing state on error.
  /// 
  /// Note: For v1, overlapping calls may overwrite each other. Future enhancement:
  /// consider adding a request token/guard to ignore stale responses.
  Future<ReorderAlertsState> loadReorderAlerts({int? locationId}) async {
    final currentState = state.value ?? ReorderAlertsState.initial();
    state = AsyncValue.data(currentState.copyWith(isLoading: true));

    try {
      final result = await _inventoryRepository.getInventoryOverview(
        locationId: locationId,
      );

      if (result.isSuccess) {
        final success = result as ApiSuccess<InventoryOverview>;
        final overview = success.data;

        // Convert items with is_low_stock flag to reorder alerts
        final alerts = <ReorderAlert>[];

        for (final item in overview.items) {
          if (item.isLowStock == true) {
            // Determine severity based on stock level
            final currentStock = item.currentStock ?? item.totalQuantity ?? 0.0;
            final severity = currentStock <= 0
                ? ReorderAlertSeverity.critical
                : ReorderAlertSeverity.low;

            // Get location name if available
            String? locationName;
            if (item.locations != null && item.locations!.isNotEmpty) {
              locationName = item.locations!.first.locationName;
            }

            // Calculate suggested reorder quantity (if reorder level is known)
            // For now, we'll use a simple heuristic: suggest 2x reorder level
            // In a real system, this might come from the backend
            double? suggestedReorderQuantity;
            // Note: reorder level is not in the current API response
            // This would need to be added to the API or calculated client-side

            alerts.add(
              ReorderAlert(
                item: item,
                currentStock: currentStock,
                severity: severity,
                locationName: locationName,
                suggestedReorderQuantity: suggestedReorderQuantity,
              ),
            );
          }
        }

        // Also check KPIs for out of stock items count
        // If we have out_of_stock_items count but no items with is_low_stock,
        // we might need to fetch items with zero stock separately
        // For now, we rely on is_low_stock flag from items

        state = AsyncValue.data(
          ReorderAlertsState(
            alerts: alerts,
            selectedLocationId: locationId,
            isLoading: false,
          ),
        );
      } else {
        final failure = result as ApiFailure<InventoryOverview>;
        // Preserve existing alerts on error
        state = AsyncValue.data(
          currentState.copyWith(
            error: failure.error.message,
            isLoading: false,
          ),
        );
      }
    } catch (e) {
      // Preserve existing alerts on exception
      state = AsyncValue.data(
        currentState.copyWith(
          error: 'Failed to load reorder alerts: ${e.toString()}',
          isLoading: false,
        ),
      );
    }

    return state.value ?? ReorderAlertsState.initial();
  }

  /// Filter alerts by location.
  /// 
  /// - If [locationId] is null: shows alerts for all locations (global view)
  /// - If [locationId] is set: shows alerts for that specific location only
  /// 
  /// Note: When filtering by location, only alerts for that location are shown.
  /// Critical alerts from other locations are not included in the filtered view.
  /// To see all alerts including critical ones from all locations, use null (all locations).
  Future<void> filterByLocation(int? locationId) async {
    await loadReorderAlerts(locationId: locationId);
  }

  /// Clear location filter (show all locations).
  /// Equivalent to calling filterByLocation(null).
  Future<void> clearLocationFilter() async {
    await loadReorderAlerts(locationId: null);
  }

  /// Dismiss an alert (removes it from the list).
  /// 
  /// Note: This is a local operation. In a real system, you might want to
  /// mark it as dismissed on the backend to prevent it from showing again.
  /// 
  /// When dismissing in a location-filtered view, the alert is removed from
  /// the current filtered list. If viewing all locations, the alert is removed
  /// from the global list. To see the alert again, refresh the alerts.
  void dismissAlert(ReorderAlert alert) {
    final currentState = state.value ?? ReorderAlertsState.initial();
    final updatedAlerts = currentState.alerts
        .where((a) => a.item.id != alert.item.id)
        .toList();

    state = AsyncValue.data(
      currentState.copyWith(alerts: updatedAlerts),
    );
  }

  /// Dismiss multiple alerts.
  void dismissAlerts(List<ReorderAlert> alertsToDismiss) {
    final currentState = state.value ?? ReorderAlertsState.initial();
    final alertIds = alertsToDismiss.map((a) => a.item.id).toSet();
    final updatedAlerts = currentState.alerts
        .where((a) => !alertIds.contains(a.item.id))
        .toList();

    state = AsyncValue.data(
      currentState.copyWith(alerts: updatedAlerts),
    );
  }

  /// Clear error state.
  void clearError() {
    final currentState = state.value ?? ReorderAlertsState.initial();
    state = AsyncValue.data(
      currentState.copyWith(clearError: true),
    );
  }

  /// Refresh alerts (reload from API).
  Future<void> refresh() async {
    final currentState = state.value ?? ReorderAlertsState.initial();
    await loadReorderAlerts(locationId: currentState.selectedLocationId);
  }
}

/// Riverpod provider for ReorderAlertsViewModel.
final reorderAlertsProvider =
    AsyncNotifierProvider<ReorderAlertsViewModel, ReorderAlertsState>(
  () {
    return ReorderAlertsViewModel();
  },
);

/// Derived provider for critical alerts (for easy access).
final criticalAlertsProvider = Provider<List<ReorderAlert>>((ref) {
  final state = ref.watch(reorderAlertsProvider);
  return state.value?.criticalAlerts ?? [];
});

/// Derived provider for out of stock alerts (for easy access).
final outOfStockAlertsProvider = Provider<List<ReorderAlert>>((ref) {
  final state = ref.watch(reorderAlertsProvider);
  return state.value?.outOfStockAlerts ?? [];
});

/// Derived provider for total alert count (for easy access).
final reorderAlertsCountProvider = Provider<int>((ref) {
  final state = ref.watch(reorderAlertsProvider);
  return state.value?.totalCount ?? 0;
});

