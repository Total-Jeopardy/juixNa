import 'package:juix_na/core/network/api_client.dart';
import 'package:juix_na/core/network/api_result.dart';
import 'package:juix_na/features/dashboard/model/dashboard_dtos.dart';

/// API client for dashboard endpoints.
/// Uses the shared ApiClient for HTTP requests.
class DashboardApi {
  final ApiClient _apiClient;

  DashboardApi({required ApiClient apiClient}) : _apiClient = apiClient;

  /// Get full dashboard data (KPIs + charts + alerts).
  ///
  /// Endpoint: GET /api/dashboard/
  /// Query params: period, start_date, end_date, location_id (all optional)
  ///
  /// Returns ApiResult<DashboardResponseDTO>:
  /// - Success: DashboardResponseDTO with all dashboard data
  /// - Failure: ApiError with message and type
  Future<ApiResult<DashboardResponseDTO>> getDashboardData({
    String? period, // TODAY, WEEK, MONTH, CUSTOM
    String? startDate, // ISO date string (for CUSTOM period)
    String? endDate, // ISO date string (for CUSTOM period)
    int? locationId,
  }) async {
    final query = <String, dynamic>{};
    if (period != null) query['period'] = period;
    if (startDate != null) query['start_date'] = startDate;
    if (endDate != null) query['end_date'] = endDate;
    if (locationId != null) query['location_id'] = locationId.toString();

    return _apiClient.get<DashboardResponseDTO>(
      '/api/dashboard/',
      query: query.isEmpty ? null : query,
      parse: (json) =>
          DashboardResponseDTO.fromJson(json as Map<String, dynamic>),
    );
  }

  /// Get KPI data only.
  ///
  /// Endpoint: GET /api/dashboard/kpis/
  /// Query params: period, start_date, end_date, location_id (all optional)
  ///
  /// Returns ApiResult<KPIDTO>:
  /// - Success: KPIDTO with KPI values
  /// - Failure: ApiError with message and type
  Future<ApiResult<KPIDTO>> getKPIs({
    String? period,
    String? startDate,
    String? endDate,
    int? locationId,
  }) async {
    final query = <String, dynamic>{};
    if (period != null) query['period'] = period;
    if (startDate != null) query['start_date'] = startDate;
    if (endDate != null) query['end_date'] = endDate;
    if (locationId != null) query['location_id'] = locationId.toString();

    return _apiClient.get<KPIDTO>(
      '/api/dashboard/kpis/',
      query: query.isEmpty ? null : query,
      parse: (json) => KPIDTO.fromJson(json as Map<String, dynamic>),
    );
  }

  /// Get product sales chart data (for donut chart).
  ///
  /// Endpoint: GET /api/dashboard/charts/top-products/
  /// Query params: period, start_date, end_date, location_id, limit (all optional)
  ///
  /// Returns ApiResult<List<ProductSalesDTO>>:
  /// - Success: List of ProductSalesDTO
  /// - Failure: ApiError with message and type
  /// Note: Endpoint name should be verified with backend team
  Future<ApiResult<List<ProductSalesDTO>>> getProductSalesChart({
    String? period,
    String? startDate,
    String? endDate,
    int? locationId,
    int? limit, // Limit number of products (e.g., top 3)
  }) async {
    final query = <String, dynamic>{};
    if (period != null) query['period'] = period;
    if (startDate != null) query['start_date'] = startDate;
    if (endDate != null) query['end_date'] = endDate;
    if (locationId != null) query['location_id'] = locationId.toString();
    if (limit != null) query['limit'] = limit.toString();

    return _apiClient.get<List<ProductSalesDTO>>(
      '/api/dashboard/charts/top-products/',
      query: query.isEmpty ? null : query,
      parse: (json) {
        final list = json as List<dynamic>;
        return list
            .map((e) => ProductSalesDTO.fromJson(e as Map<String, dynamic>))
            .toList();
      },
    );
  }

  /// Get sales trend chart data (for 7-day bar chart).
  ///
  /// Endpoint: GET /api/dashboard/charts/sales-trend/
  /// Query params: period, start_date, end_date, location_id, group_by (all optional)
  ///
  /// Returns ApiResult<List<SalesTrendPointDTO>>:
  /// - Success: List of SalesTrendPointDTO (typically 7 points for Mon-Sun)
  /// - Failure: ApiError with message and type
  Future<ApiResult<List<SalesTrendPointDTO>>> getSalesTrendChart({
    String? period,
    String? startDate,
    String? endDate,
    int? locationId,
    String? groupBy, // e.g., "day", "week", "month"
  }) async {
    final query = <String, dynamic>{};
    if (period != null) query['period'] = period;
    if (startDate != null) query['start_date'] = startDate;
    if (endDate != null) query['end_date'] = endDate;
    if (locationId != null) query['location_id'] = locationId.toString();
    if (groupBy != null) query['group_by'] = groupBy;

    return _apiClient.get<List<SalesTrendPointDTO>>(
      '/api/dashboard/charts/sales-trend/',
      query: query.isEmpty ? null : query,
      parse: (json) {
        final list = json as List<dynamic>;
        return list
            .map((e) => SalesTrendPointDTO.fromJson(e as Map<String, dynamic>))
            .toList();
      },
    );
  }

  /// Get expense chart data (for expense pie chart - GAP: Add later).
  ///
  /// Endpoint: GET /api/dashboard/charts/expenses/
  /// Query params: period, start_date, end_date, location_id (all optional)
  ///
  /// Returns ApiResult<List<ExpenseCategoryDTO>>:
  /// - Success: List of ExpenseCategoryDTO
  /// - Failure: ApiError with message and type
  Future<ApiResult<List<ExpenseCategoryDTO>>> getExpenseChart({
    String? period,
    String? startDate,
    String? endDate,
    int? locationId,
  }) async {
    final query = <String, dynamic>{};
    if (period != null) query['period'] = period;
    if (startDate != null) query['start_date'] = startDate;
    if (endDate != null) query['end_date'] = endDate;
    if (locationId != null) query['location_id'] = locationId.toString();

    return _apiClient.get<List<ExpenseCategoryDTO>>(
      '/api/dashboard/charts/expenses/',
      query: query.isEmpty ? null : query,
      parse: (json) {
        final list = json as List<dynamic>;
        return list
            .map((e) => ExpenseCategoryDTO.fromJson(e as Map<String, dynamic>))
            .toList();
      },
    );
  }

  /// Get channel sales chart data (for channel chart - GAP: Add later).
  ///
  /// Endpoint: GET /api/dashboard/charts/channels/
  /// Query params: period, start_date, end_date (all optional)
  ///
  /// Returns ApiResult<List<ChannelSalesDTO>>:
  /// - Success: List of ChannelSalesDTO
  /// - Failure: ApiError with message and type
  Future<ApiResult<List<ChannelSalesDTO>>> getChannelSalesChart({
    String? period,
    String? startDate,
    String? endDate,
  }) async {
    final query = <String, dynamic>{};
    if (period != null) query['period'] = period;
    if (startDate != null) query['start_date'] = startDate;
    if (endDate != null) query['end_date'] = endDate;

    return _apiClient.get<List<ChannelSalesDTO>>(
      '/api/dashboard/charts/channels/',
      query: query.isEmpty ? null : query,
      parse: (json) {
        final list = json as List<dynamic>;
        return list
            .map((e) => ChannelSalesDTO.fromJson(e as Map<String, dynamic>))
            .toList();
      },
    );
  }

  /// Get inventory value chart data (for inventory value chart - GAP: Add later).
  ///
  /// Endpoint: GET /api/dashboard/charts/inventory-value/
  /// Query params: period, start_date, end_date, location_id (all optional)
  ///
  /// Returns ApiResult<List<InventoryValuePointDTO>>:
  /// - Success: List of InventoryValuePointDTO
  /// - Failure: ApiError with message and type
  Future<ApiResult<List<InventoryValuePointDTO>>> getInventoryValueChart({
    String? period,
    String? startDate,
    String? endDate,
    int? locationId,
  }) async {
    final query = <String, dynamic>{};
    if (period != null) query['period'] = period;
    if (startDate != null) query['start_date'] = startDate;
    if (endDate != null) query['end_date'] = endDate;
    if (locationId != null) query['location_id'] = locationId.toString();

    return _apiClient.get<List<InventoryValuePointDTO>>(
      '/api/dashboard/charts/inventory-value/',
      query: query.isEmpty ? null : query,
      parse: (json) {
        final list = json as List<dynamic>;
        return list
            .map(
              (e) => InventoryValuePointDTO.fromJson(e as Map<String, dynamic>),
            )
            .toList();
      },
    );
  }

  /// Get dashboard alerts/notifications.
  ///
  /// Endpoint: GET /api/dashboard/alerts/
  /// Query params: location_id (optional)
  ///
  /// Returns ApiResult<List<DashboardAlertDTO>>:
  /// - Success: List of DashboardAlertDTO
  /// - Failure: ApiError with message and type
  Future<ApiResult<List<DashboardAlertDTO>>> getAlerts({
    int? locationId,
  }) async {
    final query = <String, dynamic>{};
    if (locationId != null) query['location_id'] = locationId.toString();

    return _apiClient.get<List<DashboardAlertDTO>>(
      '/api/dashboard/alerts/',
      query: query.isEmpty ? null : query,
      parse: (json) {
        final list = json as List<dynamic>;
        return list
            .map((e) => DashboardAlertDTO.fromJson(e as Map<String, dynamic>))
            .toList();
      },
    );
  }
}
