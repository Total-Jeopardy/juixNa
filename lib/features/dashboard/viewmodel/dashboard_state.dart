import 'package:juix_na/features/dashboard/model/dashboard_models.dart';

/// State for dashboard screen.
/// Contains KPIs, charts, alerts, filters, and loading/error states.
class DashboardState {
  final DashboardKPIs? kpis;
  final InventoryClerkKPIs? inventoryClerkKpis;
  final List<ProductSales> productSalesChart;
  final List<SalesTrendPoint> salesTrendChart;
  final List<ExpenseCategory>? expenseChart;
  final List<ChannelSales>? channelChart;
  final List<InventoryValuePoint>? inventoryValueChart;
  final List<DashboardAlert> alerts;
  final PeriodFilter selectedPeriod;
  final DateTime? startDate; // For CUSTOM period
  final DateTime? endDate; // For CUSTOM period
  final int? selectedLocationId;
  final bool isLoading;
  final bool isLoadingKPIs;
  final bool isLoadingCharts;
  final bool isLoadingAlerts;
  final String? error;
  final DateTime? lastSyncTime;

  const DashboardState({
    this.kpis,
    this.inventoryClerkKpis,
    this.productSalesChart = const [],
    this.salesTrendChart = const [],
    this.expenseChart,
    this.channelChart,
    this.inventoryValueChart,
    this.alerts = const [],
    this.selectedPeriod = PeriodFilter.week,
    this.startDate,
    this.endDate,
    this.selectedLocationId,
    this.isLoading = false,
    this.isLoadingKPIs = false,
    this.isLoadingCharts = false,
    this.isLoadingAlerts = false,
    this.error,
    this.lastSyncTime,
  });

  /// Create a copy with updated fields.
  DashboardState copyWith({
    DashboardKPIs? kpis,
    InventoryClerkKPIs? inventoryClerkKpis,
    List<ProductSales>? productSalesChart,
    List<SalesTrendPoint>? salesTrendChart,
    List<ExpenseCategory>? expenseChart,
    List<ChannelSales>? channelChart,
    List<InventoryValuePoint>? inventoryValueChart,
    List<DashboardAlert>? alerts,
    PeriodFilter? selectedPeriod,
    DateTime? startDate,
    DateTime? endDate,
    int? selectedLocationId,
    bool? isLoading,
    bool? isLoadingKPIs,
    bool? isLoadingCharts,
    bool? isLoadingAlerts,
    String? error,
    DateTime? lastSyncTime,
    bool clearKPIs = false,
    bool clearInventoryClerkKPIs = false,
    bool clearProductSalesChart = false,
    bool clearSalesTrendChart = false,
    bool clearExpenseChart = false,
    bool clearChannelChart = false,
    bool clearInventoryValueChart = false,
    bool clearAlerts = false,
    bool clearError = false,
    bool clearSelectedLocation = false,
    bool clearCustomDateRange = false,
  }) {
    return DashboardState(
      kpis: clearKPIs ? null : (kpis ?? this.kpis),
      inventoryClerkKpis: clearInventoryClerkKPIs
          ? null
          : (inventoryClerkKpis ?? this.inventoryClerkKpis),
      productSalesChart: clearProductSalesChart
          ? const []
          : (productSalesChart ?? this.productSalesChart),
      salesTrendChart: clearSalesTrendChart
          ? const []
          : (salesTrendChart ?? this.salesTrendChart),
      expenseChart: clearExpenseChart
          ? null
          : (expenseChart ?? this.expenseChart),
      channelChart: clearChannelChart
          ? null
          : (channelChart ?? this.channelChart),
      inventoryValueChart: clearInventoryValueChart
          ? null
          : (inventoryValueChart ?? this.inventoryValueChart),
      alerts: clearAlerts ? const [] : (alerts ?? this.alerts),
      selectedPeriod: selectedPeriod ?? this.selectedPeriod,
      startDate: clearCustomDateRange ? null : (startDate ?? this.startDate),
      endDate: clearCustomDateRange ? null : (endDate ?? this.endDate),
      selectedLocationId: clearSelectedLocation
          ? null
          : (selectedLocationId ?? this.selectedLocationId),
      isLoading: isLoading ?? this.isLoading,
      isLoadingKPIs: isLoadingKPIs ?? this.isLoadingKPIs,
      isLoadingCharts: isLoadingCharts ?? this.isLoadingCharts,
      isLoadingAlerts: isLoadingAlerts ?? this.isLoadingAlerts,
      error: clearError ? null : (error ?? this.error),
      lastSyncTime: lastSyncTime ?? this.lastSyncTime,
    );
  }

  /// Create loading state.
  factory DashboardState.loading() {
    return const DashboardState(isLoading: true);
  }

  /// Create error state.
  factory DashboardState.error(String error) {
    return DashboardState(error: error, isLoading: false);
  }

  /// Create initial/empty state.
  factory DashboardState.initial() {
    return const DashboardState();
  }

  /// Check if state has data loaded.
  bool get hasData =>
      kpis != null ||
      productSalesChart.isNotEmpty ||
      salesTrendChart.isNotEmpty ||
      alerts.isNotEmpty;

  /// Check if state is in error state.
  bool get hasError => error != null && error!.isNotEmpty;

  /// Check if any loading operation is in progress.
  bool get isAnyLoading =>
      isLoading || isLoadingKPIs || isLoadingCharts || isLoadingAlerts;

  /// Check if period is CUSTOM (requires startDate and endDate).
  bool get isCustomPeriod => selectedPeriod == PeriodFilter.custom;

  @override
  String toString() {
    return 'DashboardState('
        'kpis: ${kpis != null}, '
        'productSalesChart: ${productSalesChart.length}, '
        'salesTrendChart: ${salesTrendChart.length}, '
        'alerts: ${alerts.length}, '
        'selectedPeriod: ${selectedPeriod.value}, '
        'selectedLocationId: $selectedLocationId, '
        'isLoading: $isLoading, '
        'isLoadingKPIs: $isLoadingKPIs, '
        'isLoadingCharts: $isLoadingCharts, '
        'isLoadingAlerts: $isLoadingAlerts, '
        'error: $error'
        ')';
  }
}
