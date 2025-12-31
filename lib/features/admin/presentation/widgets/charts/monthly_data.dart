class MonthlyData {
  final String month;
  final double sales;
  final int customers;
  final int orders;
  final int cancelled;

  MonthlyData({
    required this.month,
    required this.sales,
    required this.customers,
    required this.orders,
    required this.cancelled,
  });

  factory MonthlyData.fromJson(Map<String, dynamic> json) {
    return MonthlyData(
      month: json['month_name'] as String? ?? '',
      sales: (json['total_sales'] as num?)?.toDouble() ?? 0,
      customers: (json['new_customers'] as num?)?.toInt() ?? 0,
      orders: (json['total_orders'] as num?)?.toInt() ?? 0,
      cancelled: (json['cancelled_orders'] as num?)?.toInt() ?? 0,
    );
  }
}
