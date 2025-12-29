import '../../domain/entities/admin_stats_entity.dart';

/// Admin stats model
class AdminStatsModel extends AdminStatsEntity {
  const AdminStatsModel({
    super.totalCustomers,
    super.totalMerchants,
    super.totalProducts,
    super.activeProducts,
    super.totalOrders,
    super.pendingOrders,
    super.todayOrders,
    super.totalRevenue,
    super.todayRevenue,
  });

  factory AdminStatsModel.fromMap(Map<String, dynamic> map) {
    return AdminStatsModel(
      totalCustomers: map['total_customers'] ?? 0,
      totalMerchants: map['total_merchants'] ?? 0,
      totalProducts: map['total_products'] ?? 0,
      activeProducts: map['active_products'] ?? 0,
      totalOrders: map['total_orders'] ?? 0,
      pendingOrders: map['pending_orders'] ?? 0,
      todayOrders: map['today_orders'] ?? 0,
      totalRevenue: (map['total_revenue'] ?? 0).toDouble(),
      todayRevenue: (map['today_revenue'] ?? 0).toDouble(),
    );
  }
}
