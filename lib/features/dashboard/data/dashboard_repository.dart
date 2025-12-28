import 'package:juix_na/core/network/api_result.dart';
import 'package:juix_na/features/dashboard/data/dashboard_api.dart';
import 'package:juix_na/features/dashboard/model/dashboard_dtos.dart';
import 'package:juix_na/features/dashboard/model/dashboard_models.dart';

/// Repository for dashboard operations.
/// Wraps DashboardApi and transforms DTOs to domain models.
class DashboardRepository {
  final DashboardApi _dashboardApi;

  DashboardRepository({required DashboardApi dashboardApi})
    : _dashboardApi = dashboardApi;

  /// Get full dashboard data (KPIs + charts + alerts).
  ///
  /// Returns ApiResult<DashboardData>:
  /// - Success: DashboardData with all dashboard data (domain models)
  /// - Failure: ApiError from API call
  /// Note: Dates are formatted as YYYY-MM-DD (date-only). If backend expects
  /// full timestamps for custom ranges, this formatting should be updated.
  Future<ApiResult<DashboardData>> getDashboardData({
    PeriodFilter? period,
    DateTime? startDate,
    DateTime? endDate,
    int? locationId,
  }) async {
    final result = await _dashboardApi.getDashboardData(
      period: period?.value,
      startDate: startDate?.toIso8601String().split('T').first,
      endDate: endDate?.toIso8601String().split('T').first,
      locationId: locationId,
    );

    if (result.isSuccess) {
      final success = result as ApiSuccess<DashboardResponseDTO>;
      final dashboardData = DashboardData.fromDTO(success.data);
      return ApiSuccess(dashboardData);
    } else {
      final failure = result as ApiFailure<DashboardResponseDTO>;
      return ApiFailure<DashboardData>(
        failure.error,
        statusCode: failure.statusCode,
      );
    }
  }

  /// Get KPI data only.
  ///
  /// Returns ApiResult<DashboardKPIs>:
  /// - Success: DashboardKPIs (domain model)
  /// - Failure: ApiError from API call
  /// Note: Dates are formatted as YYYY-MM-DD (date-only). Verify with backend if full timestamps are expected.
  Future<ApiResult<DashboardKPIs>> getKPIs({
    PeriodFilter? period,
    DateTime? startDate,
    DateTime? endDate,
    int? locationId,
  }) async {
    final result = await _dashboardApi.getKPIs(
      period: period?.value,
      startDate: startDate?.toIso8601String().split('T').first,
      endDate: endDate?.toIso8601String().split('T').first,
      locationId: locationId,
    );

    if (result.isSuccess) {
      final success = result as ApiSuccess<KPIDTO>;
      final kpis = DashboardKPIs.fromDTO(success.data);
      return ApiSuccess(kpis);
    } else {
      final failure = result as ApiFailure<KPIDTO>;
      return ApiFailure<DashboardKPIs>(
        failure.error,
        statusCode: failure.statusCode,
      );
    }
  }

  /// Get product sales chart data (for donut chart).
  ///
  /// Returns ApiResult<List<ProductSales>>:
  /// - Success: List of ProductSales (domain models)
  /// - Failure: ApiError from API call
  Future<ApiResult<List<ProductSales>>> getProductSalesChart({
    PeriodFilter? period,
    DateTime? startDate,
    DateTime? endDate,
    int? locationId,
    int? limit,
  }) async {
    final result = await _dashboardApi.getProductSalesChart(
      period: period?.value,
      startDate: startDate?.toIso8601String().split('T').first,
      endDate: endDate?.toIso8601String().split('T').first,
      locationId: locationId,
      limit: limit,
    );

    if (result.isSuccess) {
      final success = result as ApiSuccess<List<ProductSalesDTO>>;
      final productSales = success.data
          .map((dto) => ProductSales.fromDTO(dto))
          .toList();
      return ApiSuccess(productSales);
    } else {
      final failure = result as ApiFailure<List<ProductSalesDTO>>;
      return ApiFailure<List<ProductSales>>(
        failure.error,
        statusCode: failure.statusCode,
      );
    }
  }

  /// Get sales trend chart data (for 7-day bar chart).
  ///
  /// Returns ApiResult<List<SalesTrendPoint>>:
  /// - Success: List of SalesTrendPoint (domain models)
  /// - Failure: ApiError from API call
  Future<ApiResult<List<SalesTrendPoint>>> getSalesTrendChart({
    PeriodFilter? period,
    DateTime? startDate,
    DateTime? endDate,
    int? locationId,
    String? groupBy,
  }) async {
    final result = await _dashboardApi.getSalesTrendChart(
      period: period?.value,
      startDate: startDate?.toIso8601String().split('T').first,
      endDate: endDate?.toIso8601String().split('T').first,
      locationId: locationId,
      groupBy: groupBy,
    );

    if (result.isSuccess) {
      final success = result as ApiSuccess<List<SalesTrendPointDTO>>;
      final salesTrend = success.data
          .map((dto) => SalesTrendPoint.fromDTO(dto))
          .toList();
      return ApiSuccess(salesTrend);
    } else {
      final failure = result as ApiFailure<List<SalesTrendPointDTO>>;
      return ApiFailure<List<SalesTrendPoint>>(
        failure.error,
        statusCode: failure.statusCode,
      );
    }
  }

  /// Get expense chart data (for expense pie chart - GAP: Add later).
  ///
  /// Returns ApiResult<List<ExpenseCategory>>:
  /// - Success: List of ExpenseCategory (domain models)
  /// - Failure: ApiError from API call
  Future<ApiResult<List<ExpenseCategory>>> getExpenseChart({
    PeriodFilter? period,
    DateTime? startDate,
    DateTime? endDate,
    int? locationId,
  }) async {
    final result = await _dashboardApi.getExpenseChart(
      period: period?.value,
      startDate: startDate?.toIso8601String().split('T').first,
      endDate: endDate?.toIso8601String().split('T').first,
      locationId: locationId,
    );

    if (result.isSuccess) {
      final success = result as ApiSuccess<List<ExpenseCategoryDTO>>;
      final expenses = success.data
          .map((dto) => ExpenseCategory.fromDTO(dto))
          .toList();
      return ApiSuccess(expenses);
    } else {
      final failure = result as ApiFailure<List<ExpenseCategoryDTO>>;
      return ApiFailure<List<ExpenseCategory>>(
        failure.error,
        statusCode: failure.statusCode,
      );
    }
  }

  /// Get channel sales chart data (for channel chart - GAP: Add later).
  ///
  /// Returns ApiResult<List<ChannelSales>>:
  /// - Success: List of ChannelSales (domain models)
  /// - Failure: ApiError from API call
  Future<ApiResult<List<ChannelSales>>> getChannelSalesChart({
    PeriodFilter? period,
    DateTime? startDate,
    DateTime? endDate,
  }) async {
    final result = await _dashboardApi.getChannelSalesChart(
      period: period?.value,
      startDate: startDate?.toIso8601String().split('T').first,
      endDate: endDate?.toIso8601String().split('T').first,
    );

    if (result.isSuccess) {
      final success = result as ApiSuccess<List<ChannelSalesDTO>>;
      final channels = success.data
          .map((dto) => ChannelSales.fromDTO(dto))
          .toList();
      return ApiSuccess(channels);
    } else {
      final failure = result as ApiFailure<List<ChannelSalesDTO>>;
      return ApiFailure<List<ChannelSales>>(
        failure.error,
        statusCode: failure.statusCode,
      );
    }
  }

  /// Get inventory value chart data (for inventory value chart - GAP: Add later).
  ///
  /// Returns ApiResult<List<InventoryValuePoint>>:
  /// - Success: List of InventoryValuePoint (domain models)
  /// - Failure: ApiError from API call
  Future<ApiResult<List<InventoryValuePoint>>> getInventoryValueChart({
    PeriodFilter? period,
    DateTime? startDate,
    DateTime? endDate,
    int? locationId,
  }) async {
    final result = await _dashboardApi.getInventoryValueChart(
      period: period?.value,
      startDate: startDate?.toIso8601String().split('T').first,
      endDate: endDate?.toIso8601String().split('T').first,
      locationId: locationId,
    );

    if (result.isSuccess) {
      final success = result as ApiSuccess<List<InventoryValuePointDTO>>;
      final inventoryValue = success.data
          .map((dto) => InventoryValuePoint.fromDTO(dto))
          .toList();
      return ApiSuccess(inventoryValue);
    } else {
      final failure = result as ApiFailure<List<InventoryValuePointDTO>>;
      return ApiFailure<List<InventoryValuePoint>>(
        failure.error,
        statusCode: failure.statusCode,
      );
    }
  }

  /// Get dashboard alerts/notifications.
  ///
  /// Returns ApiResult<List<DashboardAlert>>:
  /// - Success: List of DashboardAlert (domain models)
  /// - Failure: ApiError from API call
  Future<ApiResult<List<DashboardAlert>>> getAlerts({int? locationId}) async {
    final result = await _dashboardApi.getAlerts(locationId: locationId);

    if (result.isSuccess) {
      final success = result as ApiSuccess<List<DashboardAlertDTO>>;
      final alerts = success.data
          .map((dto) => DashboardAlert.fromDTO(dto))
          .toList();
      return ApiSuccess(alerts);
    } else {
      final failure = result as ApiFailure<List<DashboardAlertDTO>>;
      return ApiFailure<List<DashboardAlert>>(
        failure.error,
        statusCode: failure.statusCode,
      );
    }
  }
}
