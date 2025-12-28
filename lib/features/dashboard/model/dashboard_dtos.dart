/// Data Transfer Objects for dashboard API requests and responses.
/// These match the backend API contract exactly.

/// Period filter enum for API requests.
enum PeriodFilterDTO {
  today('TODAY'),
  week('WEEK'),
  month('MONTH'),
  custom('CUSTOM');

  final String value;
  const PeriodFilterDTO(this.value);

  static PeriodFilterDTO? fromString(String? value) {
    if (value == null) return null;
    for (final period in PeriodFilterDTO.values) {
      if (period.value.toUpperCase() == value.toUpperCase()) {
        return period;
      }
    }
    return null;
  }
}

/// KPI DTO for dashboard KPIs.
class KPIDTO {
  final String totalSales;
  final String totalExpenses;
  final String? totalProfit; // Optional, may be calculated
  final String? salesTrend; // e.g., "+15%" or "-2%"
  final String? expensesTrend; // e.g., "+2%"
  final String? profitTrend; // e.g., "+10%"

  const KPIDTO({
    required this.totalSales,
    required this.totalExpenses,
    this.totalProfit,
    this.salesTrend,
    this.expensesTrend,
    this.profitTrend,
  });

  factory KPIDTO.fromJson(Map<String, dynamic> json) {
    return KPIDTO(
      totalSales: json['total_sales'] as String,
      totalExpenses: json['total_expenses'] as String,
      totalProfit: json['total_profit'] as String?,
      salesTrend: json['sales_trend'] as String?,
      expensesTrend: json['expenses_trend'] as String?,
      profitTrend: json['profit_trend'] as String?,
    );
  }

  Map<String, dynamic> toJson() => {
    'total_sales': totalSales,
    'total_expenses': totalExpenses,
    'total_profit': totalProfit,
    'sales_trend': salesTrend,
    'expenses_trend': expensesTrend,
    'profit_trend': profitTrend,
  };
}

/// Inventory Clerk KPI DTO (role-specific).
class InventoryClerkKPIDTO {
  final int lowStockCount;
  final int outOfStockCount;

  const InventoryClerkKPIDTO({
    required this.lowStockCount,
    required this.outOfStockCount,
  });

  factory InventoryClerkKPIDTO.fromJson(Map<String, dynamic> json) {
    return InventoryClerkKPIDTO(
      lowStockCount: json['low_stock_count'] as int,
      outOfStockCount: json['out_of_stock_count'] as int,
    );
  }

  Map<String, dynamic> toJson() => {
    'low_stock_count': lowStockCount,
    'out_of_stock_count': outOfStockCount,
  };
}

/// Product sales DTO (for donut chart / top products).
class ProductSalesDTO {
  final int productId;
  final String productName;
  final String totalSales;
  final String quantitySold;
  final double percentage; // 0.0 to 100.0

  const ProductSalesDTO({
    required this.productId,
    required this.productName,
    required this.totalSales,
    required this.quantitySold,
    required this.percentage,
  });

  factory ProductSalesDTO.fromJson(Map<String, dynamic> json) {
    return ProductSalesDTO(
      productId: json['product_id'] as int,
      productName: json['product_name'] as String,
      totalSales: json['total_sales'] as String,
      quantitySold: json['quantity_sold'] as String,
      percentage: (json['percentage'] as num).toDouble(),
    );
  }

  Map<String, dynamic> toJson() => {
    'product_id': productId,
    'product_name': productName,
    'total_sales': totalSales,
    'quantity_sold': quantitySold,
    'percentage': percentage,
  };
}

/// Sales trend point DTO (for 7-day bar chart).
class SalesTrendPointDTO {
  final String date; // ISO date string
  final String salesAmount;
  final String quantity;
  final String dayLabel; // e.g., "Mon", "Tue"

  const SalesTrendPointDTO({
    required this.date,
    required this.salesAmount,
    required this.quantity,
    required this.dayLabel,
  });

  factory SalesTrendPointDTO.fromJson(Map<String, dynamic> json) {
    return SalesTrendPointDTO(
      date: json['date'] as String,
      salesAmount: json['sales_amount'] as String,
      quantity: json['quantity'] as String,
      dayLabel: json['day_label'] as String,
    );
  }

  Map<String, dynamic> toJson() => {
    'date': date,
    'sales_amount': salesAmount,
    'quantity': quantity,
    'day_label': dayLabel,
  };
}

/// Expense category DTO (for expense pie chart - GAP: Add later).
class ExpenseCategoryDTO {
  final String category;
  final String amount;
  final double percentage; // 0.0 to 100.0

  const ExpenseCategoryDTO({
    required this.category,
    required this.amount,
    required this.percentage,
  });

  factory ExpenseCategoryDTO.fromJson(Map<String, dynamic> json) {
    return ExpenseCategoryDTO(
      category: json['category'] as String,
      amount: json['amount'] as String,
      percentage: (json['percentage'] as num).toDouble(),
    );
  }

  Map<String, dynamic> toJson() => {
    'category': category,
    'amount': amount,
    'percentage': percentage,
  };
}

/// Channel sales DTO (for channel chart - GAP: Add later).
class ChannelSalesDTO {
  final String channelName;
  final String revenue;
  final double percentage; // 0.0 to 100.0

  const ChannelSalesDTO({
    required this.channelName,
    required this.revenue,
    required this.percentage,
  });

  factory ChannelSalesDTO.fromJson(Map<String, dynamic> json) {
    return ChannelSalesDTO(
      channelName: json['channel_name'] as String,
      revenue: json['revenue'] as String,
      percentage: (json['percentage'] as num).toDouble(),
    );
  }

  Map<String, dynamic> toJson() => {
    'channel_name': channelName,
    'revenue': revenue,
    'percentage': percentage,
  };
}

/// Inventory value point DTO (for inventory value chart - GAP: Add later).
class InventoryValuePointDTO {
  final String date; // ISO date string
  final String totalValue;

  const InventoryValuePointDTO({required this.date, required this.totalValue});

  factory InventoryValuePointDTO.fromJson(Map<String, dynamic> json) {
    return InventoryValuePointDTO(
      date: json['date'] as String,
      totalValue: json['total_value'] as String,
    );
  }

  Map<String, dynamic> toJson() => {'date': date, 'total_value': totalValue};
}

/// Alert type enum.
enum AlertTypeDTO {
  lowStock('LOW_STOCK'),
  paymentDue('PAYMENT_DUE'),
  upcomingBatch('UPCOMING_BATCH'),
  promotionExpiry('PROMOTION_EXPIRY');

  final String value;
  const AlertTypeDTO(this.value);

  static AlertTypeDTO? fromString(String? value) {
    if (value == null) return null;
    for (final type in AlertTypeDTO.values) {
      if (type.value.toUpperCase() == value.toUpperCase()) {
        return type;
      }
    }
    return null;
  }
}

/// Alert severity enum.
enum AlertSeverityDTO {
  low('LOW'),
  medium('MEDIUM'),
  high('HIGH'),
  critical('CRITICAL');

  final String value;
  const AlertSeverityDTO(this.value);

  static AlertSeverityDTO? fromString(String? value) {
    if (value == null) return null;
    for (final severity in AlertSeverityDTO.values) {
      if (severity.value.toUpperCase() == value.toUpperCase()) {
        return severity;
      }
    }
    return null;
  }
}

/// Dashboard alert DTO.
class DashboardAlertDTO {
  final int id;
  final String type; // LOW_STOCK, PAYMENT_DUE, UPCOMING_BATCH, PROMOTION_EXPIRY
  final String title;
  final String message;
  final int? itemId; // For LOW_STOCK, UPCOMING_BATCH
  final String severity; // LOW, MEDIUM, HIGH, CRITICAL
  final String? actionUrl; // Optional deep link
  final String timestamp; // ISO datetime string

  const DashboardAlertDTO({
    required this.id,
    required this.type,
    required this.title,
    required this.message,
    this.itemId,
    required this.severity,
    this.actionUrl,
    required this.timestamp,
  });

  factory DashboardAlertDTO.fromJson(Map<String, dynamic> json) {
    return DashboardAlertDTO(
      id: json['id'] as int,
      type: json['type'] as String,
      title: json['title'] as String,
      message: json['message'] as String,
      itemId: json['item_id'] as int?,
      severity: json['severity'] as String,
      actionUrl: json['action_url'] as String?,
      timestamp: json['timestamp'] as String,
    );
  }

  Map<String, dynamic> toJson() => {
    'id': id,
    'type': type,
    'title': title,
    'message': message,
    'item_id': itemId,
    'severity': severity,
    'action_url': actionUrl,
    'timestamp': timestamp,
  };
}

/// Full dashboard response DTO.
class DashboardResponseDTO {
  final KPIDTO kpis;
  final InventoryClerkKPIDTO? inventoryClerkKpis; // Optional, role-specific
  final List<ProductSalesDTO>? topProducts; // For donut chart
  final List<SalesTrendPointDTO>? salesTrend; // For 7-day bar chart
  final List<ExpenseCategoryDTO>?
  expenses; // For expense pie chart (GAP: Add later)
  final List<ChannelSalesDTO>? channels; // For channel chart (GAP: Add later)
  final List<InventoryValuePointDTO>?
  inventoryValue; // For inventory value chart (GAP: Add later)
  final List<DashboardAlertDTO> alerts;
  final String?
  period; // Period used for this data (TODAY, WEEK, MONTH, CUSTOM)

  const DashboardResponseDTO({
    required this.kpis,
    this.inventoryClerkKpis,
    this.topProducts,
    this.salesTrend,
    this.expenses,
    this.channels,
    this.inventoryValue,
    required this.alerts,
    this.period,
  });

  factory DashboardResponseDTO.fromJson(Map<String, dynamic> json) {
    // Parse top products
    final topProductsData = json['top_products'] as List<dynamic>?;
    final topProducts = topProductsData
        ?.map((e) => ProductSalesDTO.fromJson(e as Map<String, dynamic>))
        .toList();

    // Parse sales trend
    final salesTrendData = json['sales_trend'] as List<dynamic>?;
    final salesTrend = salesTrendData
        ?.map((e) => SalesTrendPointDTO.fromJson(e as Map<String, dynamic>))
        .toList();

    // Parse expenses (GAP: Add later)
    final expensesData = json['expenses'] as List<dynamic>?;
    final expenses = expensesData
        ?.map((e) => ExpenseCategoryDTO.fromJson(e as Map<String, dynamic>))
        .toList();

    // Parse channels (GAP: Add later)
    final channelsData = json['channels'] as List<dynamic>?;
    final channels = channelsData
        ?.map((e) => ChannelSalesDTO.fromJson(e as Map<String, dynamic>))
        .toList();

    // Parse inventory value (GAP: Add later)
    final inventoryValueData = json['inventory_value'] as List<dynamic>?;
    final inventoryValue = inventoryValueData
        ?.map((e) => InventoryValuePointDTO.fromJson(e as Map<String, dynamic>))
        .toList();

    // Parse alerts
    final alertsData = json['alerts'] as List<dynamic>? ?? [];
    final alerts = alertsData
        .map((e) => DashboardAlertDTO.fromJson(e as Map<String, dynamic>))
        .toList();

    // Parse inventory clerk KPIs (optional)
    InventoryClerkKPIDTO? inventoryClerkKpis;
    if (json['inventory_clerk_kpis'] != null) {
      inventoryClerkKpis = InventoryClerkKPIDTO.fromJson(
        json['inventory_clerk_kpis'] as Map<String, dynamic>,
      );
    }

    return DashboardResponseDTO(
      kpis: KPIDTO.fromJson(json['kpis'] as Map<String, dynamic>),
      inventoryClerkKpis: inventoryClerkKpis,
      topProducts: topProducts,
      salesTrend: salesTrend,
      expenses: expenses,
      channels: channels,
      inventoryValue: inventoryValue,
      alerts: alerts,
      period: json['period'] as String?,
    );
  }

  Map<String, dynamic> toJson() => {
    'kpis': kpis.toJson(),
    'inventory_clerk_kpis': inventoryClerkKpis?.toJson(),
    'top_products': topProducts?.map((e) => e.toJson()).toList(),
    'sales_trend': salesTrend?.map((e) => e.toJson()).toList(),
    'expenses': expenses?.map((e) => e.toJson()).toList(),
    'channels': channels?.map((e) => e.toJson()).toList(),
    'inventory_value': inventoryValue?.map((e) => e.toJson()).toList(),
    'alerts': alerts.map((e) => e.toJson()).toList(),
    'period': period,
  };
}
