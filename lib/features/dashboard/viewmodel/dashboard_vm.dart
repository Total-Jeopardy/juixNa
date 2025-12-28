import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:juix_na/bootstrap.dart';
import 'package:juix_na/core/auth/auth_error_handler.dart';
import 'package:juix_na/core/network/api_result.dart';
import 'package:juix_na/features/dashboard/data/dashboard_api.dart';
import 'package:juix_na/features/dashboard/data/dashboard_repository.dart';
import 'package:juix_na/features/dashboard/model/dashboard_models.dart';
import 'package:juix_na/features/dashboard/viewmodel/dashboard_state.dart';

/// Dashboard ViewModel using Riverpod AsyncNotifier.
/// Manages dashboard state: KPIs, charts, alerts, filters, period selection.
class DashboardViewModel extends AsyncNotifier<DashboardState> {
  DashboardRepository? _repository;

  /// Request tokens to track in-flight requests and ignore stale responses.
  /// Separate tokens per operation type prevent false positives when operations run concurrently.
  String? _fullDataRequestToken;
  String? _kpiRequestToken;
  String? _chartsRequestToken;
  String? _alertsRequestToken;

  /// Get DashboardRepository from ref (dependency injection).
  DashboardRepository get _dashboardRepository {
    _repository ??= ref.read(dashboardRepositoryProvider);
    return _repository!;
  }

  /// Generate request token from current filter state.
  String _generateRequestToken({
    required PeriodFilter period,
    int? locationId,
    DateTime? startDate,
    DateTime? endDate,
  }) {
    final location = locationId?.toString() ?? 'all';
    final start = startDate?.toIso8601String() ?? '';
    final end = endDate?.toIso8601String() ?? '';
    return '${period.value}_${location}_${start}_${end}';
  }

  @override
  Future<DashboardState> build() async {
    // On initialization, load dashboard data with default period (WEEK)
    return await _loadInitialData();
  }

  /// Load initial dashboard data (all data: KPIs + charts + alerts).
  /// Preserves existing data if one call fails.
  Future<DashboardState> _loadInitialData() async {
    final currentState = state.value ?? DashboardState.initial();
    try {
      final result = await _dashboardRepository.getDashboardData(
        period: currentState.selectedPeriod,
        locationId: currentState.selectedLocationId,
      );

      // Handle 401 errors (auto-logout)
      await AuthErrorHandler.handleUnauthorized(ref, result);

      if (result.isSuccess) {
        final success = result as ApiSuccess<DashboardData>;
        final dashboardData = success.data;

        return DashboardState(
          kpis: dashboardData.kpis,
          inventoryClerkKpis: dashboardData.inventoryClerkKpis,
          productSalesChart: dashboardData.topProducts,
          salesTrendChart: dashboardData.salesTrend,
          expenseChart: dashboardData.expenses,
          channelChart: dashboardData.channels,
          inventoryValueChart: dashboardData.inventoryValue,
          alerts: dashboardData.alerts,
          selectedPeriod: currentState.selectedPeriod,
          selectedLocationId: currentState.selectedLocationId,
          isLoading: false,
          isLoadingKPIs: false,
          isLoadingCharts: false,
          isLoadingAlerts: false,
          lastSyncTime: DateTime.now(),
        );
      } else {
        final failure = result as ApiFailure<DashboardData>;
        return currentState.copyWith(
          error: failure.error.message,
          isLoading: false,
        );
      }
    } catch (e) {
      // On exception, preserve existing data
      return currentState.copyWith(
        error: 'Failed to load dashboard data: ${e.toString()}',
        isLoading: false,
      );
    }
  }

  /// Load all dashboard data (KPIs + charts + alerts).
  /// Uses request token to prevent stale responses: if filters change while
  /// a request is in-flight, the stale response will be ignored.
  /// Preserves existing data on error.
  Future<void> loadDashboardData() async {
    final currentState = state.value ?? DashboardState.initial();

    // Generate request token for current filter state
    final requestToken = _generateRequestToken(
      period: currentState.selectedPeriod,
      locationId: currentState.selectedLocationId,
      startDate: currentState.startDate,
      endDate: currentState.endDate,
    );
    _fullDataRequestToken = requestToken;

    state = AsyncValue.data(currentState.copyWith(isLoading: true));

    try {
      final result = await _dashboardRepository.getDashboardData(
        period: currentState.selectedPeriod,
        startDate: currentState.startDate,
        endDate: currentState.endDate,
        locationId: currentState.selectedLocationId,
      );

      // Handle 401 errors (auto-logout)
      await AuthErrorHandler.handleUnauthorized(ref, result);

      // Check if this response is still valid (filters haven't changed)
      if (_fullDataRequestToken != requestToken) {
        // Request is stale - filters changed while request was in-flight
        // Reset loading flags to prevent UI from getting stuck
        final latest = state.value ?? DashboardState.initial();
        state = AsyncValue.data(
          latest.copyWith(
            isLoading: false,
            isLoadingKPIs: false,
            isLoadingCharts: false,
            isLoadingAlerts: false,
          ),
        );
        return;
      }

      if (result.isSuccess) {
        final success = result as ApiSuccess<DashboardData>;
        final dashboardData = success.data;

        state = AsyncValue.data(
          currentState.copyWith(
            kpis: dashboardData.kpis,
            inventoryClerkKpis: dashboardData.inventoryClerkKpis,
            productSalesChart: dashboardData.topProducts,
            salesTrendChart: dashboardData.salesTrend,
            expenseChart: dashboardData.expenses,
            channelChart: dashboardData.channels,
            inventoryValueChart: dashboardData.inventoryValue,
            alerts: dashboardData.alerts,
            isLoading: false,
            isLoadingKPIs: false,
            isLoadingCharts: false,
            isLoadingAlerts: false,
            lastSyncTime: DateTime.now(),
            clearError: true,
          ),
        );
      } else {
        final failure = result as ApiFailure<DashboardData>;
        state = AsyncValue.data(
          currentState.copyWith(error: failure.error.message, isLoading: false),
        );
      }
    } catch (e) {
      state = AsyncValue.data(
        currentState.copyWith(
          error: 'Failed to load dashboard data: ${e.toString()}',
          isLoading: false,
        ),
      );
    }
  }

  /// Load only KPI cards.
  /// Uses request token to prevent stale responses.
  /// Preserves existing KPIs on error.
  Future<void> loadKPIs() async {
    final currentState = state.value ?? DashboardState.initial();

    // Generate request token for current filter state
    final requestToken = _generateRequestToken(
      period: currentState.selectedPeriod,
      locationId: currentState.selectedLocationId,
      startDate: currentState.startDate,
      endDate: currentState.endDate,
    );
    _kpiRequestToken = requestToken;

    state = AsyncValue.data(currentState.copyWith(isLoadingKPIs: true));

    try {
      final result = await _dashboardRepository.getKPIs(
        period: currentState.selectedPeriod,
        startDate: currentState.startDate,
        endDate: currentState.endDate,
        locationId: currentState.selectedLocationId,
      );

      // Handle 401 errors (auto-logout)
      await AuthErrorHandler.handleUnauthorized(ref, result);

      // Check if this response is still valid (filters haven't changed)
      if (_kpiRequestToken != requestToken) {
        // Request is stale - filters changed while request was in-flight
        // Reset loading flag to prevent UI from getting stuck
        final latest = state.value ?? DashboardState.initial();
        state = AsyncValue.data(latest.copyWith(isLoadingKPIs: false));
        return;
      }

      if (result.isSuccess) {
        final success = result as ApiSuccess<DashboardKPIs>;
        state = AsyncValue.data(
          currentState.copyWith(
            kpis: success.data,
            isLoadingKPIs: false,
            lastSyncTime: DateTime.now(),
            clearError: true,
          ),
        );
      } else {
        final failure = result as ApiFailure<DashboardKPIs>;
        state = AsyncValue.data(
          currentState.copyWith(
            error: failure.error.message,
            isLoadingKPIs: false,
          ),
        );
      }
    } catch (e) {
      state = AsyncValue.data(
        currentState.copyWith(
          error: 'Failed to load KPIs: ${e.toString()}',
          isLoadingKPIs: false,
        ),
      );
    }
  }

  /// Load all chart data.
  /// Currently loads: Product Sales and Sales Trend charts.
  /// Note: Expense, Channel, and Inventory Value charts are deferred (GAP items)
  /// and will be added when backend endpoints are ready.
  /// Uses request token to prevent stale responses.
  /// Preserves existing chart data on error.
  Future<void> loadCharts() async {
    final currentState = state.value ?? DashboardState.initial();

    // Generate request token for current filter state
    final requestToken = _generateRequestToken(
      period: currentState.selectedPeriod,
      locationId: currentState.selectedLocationId,
      startDate: currentState.startDate,
      endDate: currentState.endDate,
    );
    _chartsRequestToken = requestToken;

    state = AsyncValue.data(currentState.copyWith(isLoadingCharts: true));

    try {
      // Load all chart data in parallel for better performance
      // TODO: Add expense, channel, and inventory value charts when backend is ready
      final productSalesFuture = _dashboardRepository.getProductSalesChart(
        period: currentState.selectedPeriod,
        startDate: currentState.startDate,
        endDate: currentState.endDate,
        locationId: currentState.selectedLocationId,
        limit: 3, // Top 3 products
      );

      final salesTrendFuture = _dashboardRepository.getSalesTrendChart(
        period: currentState.selectedPeriod,
        startDate: currentState.startDate,
        endDate: currentState.endDate,
        locationId: currentState.selectedLocationId,
        groupBy: 'day',
      );

      final results = await Future.wait([productSalesFuture, salesTrendFuture]);
      final productSalesResult = results[0] as ApiResult<List<ProductSales>>;
      final salesTrendResult = results[1] as ApiResult<List<SalesTrendPoint>>;

      // Handle 401 errors (auto-logout)
      await AuthErrorHandler.handleUnauthorized(ref, productSalesResult);
      await AuthErrorHandler.handleUnauthorized(ref, salesTrendResult);

      // Check if this response is still valid (filters haven't changed)
      if (_chartsRequestToken != requestToken) {
        // Request is stale - filters changed while request was in-flight
        // Reset loading flag to prevent UI from getting stuck
        final latest = state.value ?? DashboardState.initial();
        state = AsyncValue.data(latest.copyWith(isLoadingCharts: false));
        return;
      }

      // Extract chart data (preserve existing on error)
      final productSales = productSalesResult.isSuccess
          ? (productSalesResult as ApiSuccess<List<ProductSales>>).data
          : currentState.productSalesChart;

      final salesTrend = salesTrendResult.isSuccess
          ? (salesTrendResult as ApiSuccess<List<SalesTrendPoint>>).data
          : currentState.salesTrendChart;

      state = AsyncValue.data(
        currentState.copyWith(
          productSalesChart: productSales,
          salesTrendChart: salesTrend,
          isLoadingCharts: false,
          lastSyncTime: DateTime.now(),
          clearError: true,
        ),
      );
    } catch (e) {
      state = AsyncValue.data(
        currentState.copyWith(
          error: 'Failed to load charts: ${e.toString()}',
          isLoadingCharts: false,
        ),
      );
    }
  }

  /// Load alerts/notifications.
  /// Note: Alerts are location-filtered but not period-filtered.
  /// Uses request token to prevent stale responses when location changes.
  /// Preserves existing alerts on error.
  Future<void> loadAlerts() async {
    final currentState = state.value ?? DashboardState.initial();

    // Generate request token for current location (alerts are location-only)
    final locationToken = currentState.selectedLocationId?.toString() ?? 'all';
    final requestToken = 'alerts_$locationToken';
    _alertsRequestToken = requestToken;

    state = AsyncValue.data(currentState.copyWith(isLoadingAlerts: true));

    try {
      final result = await _dashboardRepository.getAlerts(
        locationId: currentState.selectedLocationId,
      );

      // Handle 401 errors (auto-logout)
      await AuthErrorHandler.handleUnauthorized(ref, result);

      // Check if this response is still valid (location hasn't changed)
      if (_alertsRequestToken != requestToken) {
        // Request is stale - location changed while request was in-flight
        // Reset loading flag to prevent UI from getting stuck
        final latest = state.value ?? DashboardState.initial();
        state = AsyncValue.data(latest.copyWith(isLoadingAlerts: false));
        return;
      }

      if (result.isSuccess) {
        final success = result as ApiSuccess<List<DashboardAlert>>;
        state = AsyncValue.data(
          currentState.copyWith(
            alerts: success.data,
            isLoadingAlerts: false,
            lastSyncTime: DateTime.now(),
            clearError: true,
          ),
        );
      } else {
        final failure = result as ApiFailure<List<DashboardAlert>>;
        state = AsyncValue.data(
          currentState.copyWith(
            error: failure.error.message,
            isLoadingAlerts: false,
          ),
        );
      }
    } catch (e) {
      state = AsyncValue.data(
        currentState.copyWith(
          error: 'Failed to load alerts: ${e.toString()}',
          isLoadingAlerts: false,
        ),
      );
    }
  }

  /// Refresh dashboard (reload all data).
  Future<void> refreshDashboard() async {
    await loadDashboardData();
  }

  /// Set period filter and reload data.
  Future<void> setPeriod(PeriodFilter period) async {
    final currentState = state.value ?? DashboardState.initial();
    state = AsyncValue.data(
      currentState.copyWith(
        selectedPeriod: period,
        clearCustomDateRange: period != PeriodFilter.custom,
      ),
    );

    // Reload data with new period
    await loadDashboardData();
  }

  /// Set custom date range and reload data.
  /// Validates that end date is not before start date.
  /// Returns error state if validation fails.
  Future<void> setCustomDateRange(DateTime start, DateTime end) async {
    final currentState = state.value ?? DashboardState.initial();

    // Validate date range
    if (end.isBefore(start)) {
      state = AsyncValue.data(
        currentState.copyWith(error: 'End date cannot be before start date'),
      );
      return;
    }

    state = AsyncValue.data(
      currentState.copyWith(
        selectedPeriod: PeriodFilter.custom,
        startDate: start,
        endDate: end,
      ),
    );

    // Reload data with custom date range
    await loadDashboardData();
  }

  /// Set location filter and reload data.
  Future<void> setLocation(int? locationId) async {
    final currentState = state.value ?? DashboardState.initial();
    state = AsyncValue.data(
      currentState.copyWith(selectedLocationId: locationId),
    );

    // Reload data for selected location
    await loadDashboardData();
  }

  /// Dismiss an alert locally (remove from state).
  void dismissAlert(DashboardAlert alert) {
    final currentState = state.value ?? DashboardState.initial();
    final updatedAlerts = currentState.alerts
        .where((a) => a.id != alert.id)
        .toList();

    state = AsyncValue.data(currentState.copyWith(alerts: updatedAlerts));
  }

  /// Dismiss all alerts locally (clear alerts list).
  void dismissAllAlerts() {
    final currentState = state.value ?? DashboardState.initial();
    state = AsyncValue.data(currentState.copyWith(clearAlerts: true));
  }

  /// Clear error state.
  void clearError() {
    final currentState = state.value ?? DashboardState.initial();
    state = AsyncValue.data(currentState.copyWith(clearError: true));
  }
}

/// Riverpod provider for DashboardApi.
final dashboardApiProvider = Provider<DashboardApi>((ref) {
  final apiClient = ref.watch(apiClientProvider);
  return DashboardApi(apiClient: apiClient);
});

/// Riverpod provider for DashboardRepository.
final dashboardRepositoryProvider = Provider<DashboardRepository>((ref) {
  final dashboardApi = ref.watch(dashboardApiProvider);
  return DashboardRepository(dashboardApi: dashboardApi);
});

/// Riverpod provider for DashboardViewModel.
final dashboardProvider =
    AsyncNotifierProvider<DashboardViewModel, DashboardState>(() {
      return DashboardViewModel();
    });

/// Derived provider for dashboard KPIs (for easy access).
final dashboardKPIsProvider = Provider<DashboardKPIs?>((ref) {
  final state = ref.watch(dashboardProvider);
  return state.value?.kpis;
});

/// Derived provider for product sales chart (for easy access).
final dashboardProductSalesChartProvider = Provider<List<ProductSales>>((ref) {
  final state = ref.watch(dashboardProvider);
  return state.value?.productSalesChart ?? [];
});

/// Derived provider for sales trend chart (for easy access).
final dashboardSalesTrendChartProvider = Provider<List<SalesTrendPoint>>((ref) {
  final state = ref.watch(dashboardProvider);
  return state.value?.salesTrendChart ?? [];
});

/// Derived provider for dashboard alerts (for easy access).
final dashboardAlertsProvider = Provider<List<DashboardAlert>>((ref) {
  final state = ref.watch(dashboardProvider);
  return state.value?.alerts ?? [];
});

/// Derived provider for expense chart (for easy access).
/// Note: Currently returns empty list as expense chart is a GAP item (deferred).
final dashboardExpenseChartProvider = Provider<List<ExpenseCategory>>((ref) {
  final state = ref.watch(dashboardProvider);
  return state.value?.expenseChart ?? [];
});

/// Derived provider for channel chart (for easy access).
/// Note: Currently returns empty list as channel chart is a GAP item (deferred).
final dashboardChannelChartProvider = Provider<List<ChannelSales>>((ref) {
  final state = ref.watch(dashboardProvider);
  return state.value?.channelChart ?? [];
});

/// Derived provider for inventory value chart (for easy access).
/// Note: Currently returns empty list as inventory value chart is a GAP item (deferred).
final dashboardInventoryValueChartProvider =
    Provider<List<InventoryValuePoint>>((ref) {
      final state = ref.watch(dashboardProvider);
      return state.value?.inventoryValueChart ?? [];
    });
