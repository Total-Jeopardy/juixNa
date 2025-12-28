/// Domain models for dashboard module.
/// These are clean, type-safe models used throughout the app.
/// Convert from DTOs using factory constructors.

import 'package:juix_na/features/dashboard/model/dashboard_dtos.dart';

/// Period filter enum for dashboard.
enum PeriodFilter {
  today,
  week,
  month,
  custom;

  String get value {
    switch (this) {
      case PeriodFilter.today:
        return 'TODAY';
      case PeriodFilter.week:
        return 'WEEK';
      case PeriodFilter.month:
        return 'MONTH';
      case PeriodFilter.custom:
        return 'CUSTOM';
    }
  }

  static PeriodFilter? fromString(String? value) {
    if (value == null) return null;
    switch (value.toUpperCase()) {
      case 'TODAY':
        return PeriodFilter.today;
      case 'WEEK':
        return PeriodFilter.week;
      case 'MONTH':
        return PeriodFilter.month;
      case 'CUSTOM':
        return PeriodFilter.custom;
      default:
        return null;
    }
  }

  static PeriodFilter fromDTO(PeriodFilterDTO dto) {
    switch (dto) {
      case PeriodFilterDTO.today:
        return PeriodFilter.today;
      case PeriodFilterDTO.week:
        return PeriodFilter.week;
      case PeriodFilterDTO.month:
        return PeriodFilter.month;
      case PeriodFilterDTO.custom:
        return PeriodFilter.custom;
    }
  }
}

/// Dashboard KPIs model.
class DashboardKPIs {
  final double totalSales;
  final double totalExpenses;
  final double? totalProfit; // Optional, may be calculated
  final double? salesTrend; // e.g., 15.0 for "+15%" or -2.0 for "-2%"
  final double? expensesTrend;
  final double? profitTrend;

  const DashboardKPIs({
    required this.totalSales,
    required this.totalExpenses,
    this.totalProfit,
    this.salesTrend,
    this.expensesTrend,
    this.profitTrend,
  });

  factory DashboardKPIs.fromDTO(KPIDTO dto) {
    return DashboardKPIs(
      totalSales: double.tryParse(dto.totalSales) ?? 0.0,
      totalExpenses: double.tryParse(dto.totalExpenses) ?? 0.0,
      totalProfit: dto.totalProfit != null
          ? double.tryParse(dto.totalProfit!) ?? 0.0
          : null,
      salesTrend: _parseTrend(dto.salesTrend),
      expensesTrend: _parseTrend(dto.expensesTrend),
      profitTrend: _parseTrend(dto.profitTrend),
    );
  }

  /// Parse trend string like "+15%" or "-2%" to double.
  /// Preserves the sign (positive/negative) from the original string.
  static double? _parseTrend(String? trendStr) {
    if (trendStr == null || trendStr.isEmpty) return null;
    // Extract sign and numeric value separately
    final isNegative = trendStr.trim().startsWith('-');
    // Remove +, -, and % signs to get the numeric value
    final cleaned = trendStr.replaceAll(RegExp(r'[+\-%]'), '');
    final value = double.tryParse(cleaned);
    if (value == null) return null;
    // Return negative value if original string started with '-'
    return isNegative ? -value : value;
  }

  /// Get formatted trend string (e.g., "+15%" or "-2%").
  String? getFormattedSalesTrend() {
    if (salesTrend == null) return null;
    final sign = salesTrend! >= 0 ? '+' : '';
    return '$sign${salesTrend!.toStringAsFixed(0)}%';
  }

  String? getFormattedExpensesTrend() {
    if (expensesTrend == null) return null;
    final sign = expensesTrend! >= 0 ? '+' : '';
    return '$sign${expensesTrend!.toStringAsFixed(0)}%';
  }

  String? getFormattedProfitTrend() {
    if (profitTrend == null) return null;
    final sign = profitTrend! >= 0 ? '+' : '';
    return '$sign${profitTrend!.toStringAsFixed(0)}%';
  }

  @override
  String toString() =>
      'DashboardKPIs(sales: $totalSales, expenses: $totalExpenses, profit: $totalProfit)';
}

/// Inventory Clerk KPIs model (role-specific).
class InventoryClerkKPIs {
  final int lowStockCount;
  final int outOfStockCount;

  const InventoryClerkKPIs({
    required this.lowStockCount,
    required this.outOfStockCount,
  });

  factory InventoryClerkKPIs.fromDTO(InventoryClerkKPIDTO dto) {
    return InventoryClerkKPIs(
      lowStockCount: dto.lowStockCount,
      outOfStockCount: dto.outOfStockCount,
    );
  }

  @override
  String toString() =>
      'InventoryClerkKPIs(lowStock: $lowStockCount, outOfStock: $outOfStockCount)';
}

/// Product sales model (for donut chart).
class ProductSales {
  final int productId;
  final String productName;
  final double totalSales;
  final double quantitySold;
  final double percentage; // 0.0 to 100.0

  const ProductSales({
    required this.productId,
    required this.productName,
    required this.totalSales,
    required this.quantitySold,
    required this.percentage,
  });

  factory ProductSales.fromDTO(ProductSalesDTO dto) {
    return ProductSales(
      productId: dto.productId,
      productName: dto.productName,
      totalSales: double.tryParse(dto.totalSales) ?? 0.0,
      quantitySold: double.tryParse(dto.quantitySold) ?? 0.0,
      percentage: dto.percentage,
    );
  }

  @override
  String toString() =>
      'ProductSales(id: $productId, name: $productName, sales: $totalSales, %: $percentage)';
}

/// Sales trend point model (for 7-day bar chart).
class SalesTrendPoint {
  final DateTime date;
  final double salesAmount;
  final double quantity;
  final String dayLabel; // e.g., "Mon", "Tue"

  const SalesTrendPoint({
    required this.date,
    required this.salesAmount,
    required this.quantity,
    required this.dayLabel,
  });

  factory SalesTrendPoint.fromDTO(SalesTrendPointDTO dto) {
    return SalesTrendPoint(
      date: DateTime.parse(dto.date),
      salesAmount: double.tryParse(dto.salesAmount) ?? 0.0,
      quantity: double.tryParse(dto.quantity) ?? 0.0,
      dayLabel: dto.dayLabel,
    );
  }

  @override
  String toString() =>
      'SalesTrendPoint(date: $date, sales: $salesAmount, qty: $quantity)';
}

/// Expense category model (for expense pie chart - GAP: Add later).
class ExpenseCategory {
  final String category;
  final double amount;
  final double percentage; // 0.0 to 100.0

  const ExpenseCategory({
    required this.category,
    required this.amount,
    required this.percentage,
  });

  factory ExpenseCategory.fromDTO(ExpenseCategoryDTO dto) {
    return ExpenseCategory(
      category: dto.category,
      amount: double.tryParse(dto.amount) ?? 0.0,
      percentage: dto.percentage,
    );
  }

  @override
  String toString() =>
      'ExpenseCategory(category: $category, amount: $amount, %: $percentage)';
}

/// Channel sales model (for channel chart - GAP: Add later).
class ChannelSales {
  final String channelName;
  final double revenue;
  final double percentage; // 0.0 to 100.0

  const ChannelSales({
    required this.channelName,
    required this.revenue,
    required this.percentage,
  });

  factory ChannelSales.fromDTO(ChannelSalesDTO dto) {
    return ChannelSales(
      channelName: dto.channelName,
      revenue: double.tryParse(dto.revenue) ?? 0.0,
      percentage: dto.percentage,
    );
  }

  @override
  String toString() =>
      'ChannelSales(channel: $channelName, revenue: $revenue, %: $percentage)';
}

/// Inventory value point model (for inventory value chart - GAP: Add later).
class InventoryValuePoint {
  final DateTime date;
  final double totalValue;

  const InventoryValuePoint({required this.date, required this.totalValue});

  factory InventoryValuePoint.fromDTO(InventoryValuePointDTO dto) {
    return InventoryValuePoint(
      date: DateTime.parse(dto.date),
      totalValue: double.tryParse(dto.totalValue) ?? 0.0,
    );
  }

  @override
  String toString() => 'InventoryValuePoint(date: $date, value: $totalValue)';
}

/// Alert type enum.
enum AlertType {
  lowStock,
  paymentDue,
  upcomingBatch,
  promotionExpiry;

  String get value {
    switch (this) {
      case AlertType.lowStock:
        return 'LOW_STOCK';
      case AlertType.paymentDue:
        return 'PAYMENT_DUE';
      case AlertType.upcomingBatch:
        return 'UPCOMING_BATCH';
      case AlertType.promotionExpiry:
        return 'PROMOTION_EXPIRY';
    }
  }

  static AlertType? fromString(String? value) {
    if (value == null) return null;
    switch (value.toUpperCase()) {
      case 'LOW_STOCK':
        return AlertType.lowStock;
      case 'PAYMENT_DUE':
        return AlertType.paymentDue;
      case 'UPCOMING_BATCH':
        return AlertType.upcomingBatch;
      case 'PROMOTION_EXPIRY':
        return AlertType.promotionExpiry;
      default:
        return null;
    }
  }

  static AlertType fromDTO(AlertTypeDTO dto) {
    switch (dto) {
      case AlertTypeDTO.lowStock:
        return AlertType.lowStock;
      case AlertTypeDTO.paymentDue:
        return AlertType.paymentDue;
      case AlertTypeDTO.upcomingBatch:
        return AlertType.upcomingBatch;
      case AlertTypeDTO.promotionExpiry:
        return AlertType.promotionExpiry;
    }
  }
}

/// Alert severity enum.
enum AlertSeverity {
  low,
  medium,
  high,
  critical;

  String get value {
    switch (this) {
      case AlertSeverity.low:
        return 'LOW';
      case AlertSeverity.medium:
        return 'MEDIUM';
      case AlertSeverity.high:
        return 'HIGH';
      case AlertSeverity.critical:
        return 'CRITICAL';
    }
  }

  static AlertSeverity? fromString(String? value) {
    if (value == null) return null;
    switch (value.toUpperCase()) {
      case 'LOW':
        return AlertSeverity.low;
      case 'MEDIUM':
        return AlertSeverity.medium;
      case 'HIGH':
        return AlertSeverity.high;
      case 'CRITICAL':
        return AlertSeverity.critical;
      default:
        return null;
    }
  }

  static AlertSeverity fromDTO(AlertSeverityDTO dto) {
    switch (dto) {
      case AlertSeverityDTO.low:
        return AlertSeverity.low;
      case AlertSeverityDTO.medium:
        return AlertSeverity.medium;
      case AlertSeverityDTO.high:
        return AlertSeverity.high;
      case AlertSeverityDTO.critical:
        return AlertSeverity.critical;
    }
  }
}

/// Dashboard alert model.
class DashboardAlert {
  final int id;
  final AlertType type;
  final String title;
  final String message;
  final int? itemId; // For LOW_STOCK, UPCOMING_BATCH
  final AlertSeverity severity;
  final String? actionUrl; // Optional deep link
  final DateTime timestamp;

  const DashboardAlert({
    required this.id,
    required this.type,
    required this.title,
    required this.message,
    this.itemId,
    required this.severity,
    this.actionUrl,
    required this.timestamp,
  });

  factory DashboardAlert.fromDTO(DashboardAlertDTO dto) {
    // Use safe fallback for unknown types/severities to prevent crashes
    // If backend adds new alert types, they'll be handled gracefully
    final type = AlertType.fromString(dto.type) ?? AlertType.lowStock;
    final severity =
        AlertSeverity.fromString(dto.severity) ?? AlertSeverity.medium;

    return DashboardAlert(
      id: dto.id,
      type: type,
      title: dto.title,
      message: dto.message,
      itemId: dto.itemId,
      severity: severity,
      actionUrl: dto.actionUrl,
      timestamp: DateTime.parse(dto.timestamp),
    );
  }

  /// Get border color based on alert type (for UI).
  String getBorderColor() {
    switch (type) {
      case AlertType.lowStock:
        return 'red'; // Red border
      case AlertType.paymentDue:
        return 'orange'; // Orange border
      case AlertType.upcomingBatch:
        return 'blue'; // Blue border
      case AlertType.promotionExpiry:
        return 'purple'; // Purple border
    }
  }

  @override
  String toString() =>
      'DashboardAlert(id: $id, type: ${type.value}, title: $title)';
}

/// Complete dashboard data model.
class DashboardData {
  final DashboardKPIs kpis;
  final InventoryClerkKPIs? inventoryClerkKpis; // Optional, role-specific
  final List<ProductSales> topProducts; // For donut chart
  final List<SalesTrendPoint> salesTrend; // For 7-day bar chart
  final List<ExpenseCategory>?
  expenses; // For expense pie chart (GAP: Add later)
  final List<ChannelSales>? channels; // For channel chart (GAP: Add later)
  final List<InventoryValuePoint>?
  inventoryValue; // For inventory value chart (GAP: Add later)
  final List<DashboardAlert> alerts;
  final PeriodFilter? period; // Period used for this data

  const DashboardData({
    required this.kpis,
    this.inventoryClerkKpis,
    required this.topProducts,
    required this.salesTrend,
    this.expenses,
    this.channels,
    this.inventoryValue,
    required this.alerts,
    this.period,
  });

  factory DashboardData.fromDTO(DashboardResponseDTO dto) {
    return DashboardData(
      kpis: DashboardKPIs.fromDTO(dto.kpis),
      inventoryClerkKpis: dto.inventoryClerkKpis != null
          ? InventoryClerkKPIs.fromDTO(dto.inventoryClerkKpis!)
          : null,
      topProducts: (dto.topProducts ?? [])
          .map((e) => ProductSales.fromDTO(e))
          .toList(),
      salesTrend: (dto.salesTrend ?? [])
          .map((e) => SalesTrendPoint.fromDTO(e))
          .toList(),
      expenses: dto.expenses?.map((e) => ExpenseCategory.fromDTO(e)).toList(),
      channels: dto.channels?.map((e) => ChannelSales.fromDTO(e)).toList(),
      inventoryValue: dto.inventoryValue
          ?.map((e) => InventoryValuePoint.fromDTO(e))
          .toList(),
      alerts: dto.alerts.map((e) => DashboardAlert.fromDTO(e)).toList(),
      period: dto.period != null
          ? PeriodFilter.fromString(dto.period!)
          : PeriodFilter.week, // Default to WEEK
    );
  }

  @override
  String toString() =>
      'DashboardData(kpis: $kpis, topProducts: ${topProducts.length}, salesTrend: ${salesTrend.length}, alerts: ${alerts.length})';
}
