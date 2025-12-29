/// Admin dashboard statistics entity
class AdminStatsEntity {
  final int totalCustomers;
  final int totalMerchants;
  final int totalProducts;
  final int activeProducts;
  final int totalOrders;
  final int pendingOrders;
  final int todayOrders;
  final double totalRevenue;
  final double todayRevenue;

  const AdminStatsEntity({
    this.totalCustomers = 0,
    this.totalMerchants = 0,
    this.totalProducts = 0,
    this.activeProducts = 0,
    this.totalOrders = 0,
    this.pendingOrders = 0,
    this.todayOrders = 0,
    this.totalRevenue = 0,
    this.todayRevenue = 0,
  });
}
