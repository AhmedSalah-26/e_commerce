import 'package:supabase_flutter/supabase_flutter.dart';
import '../../../../../core/errors/exceptions.dart';
import '../../models/admin_stats_model.dart';

mixin AdminStatsMixin {
  SupabaseClient get client;

  Future<AdminStatsModel> getStatsImpl({
    DateTime? fromDate,
    DateTime? toDate,
  }) async {
    try {
      // Optimized: Single RPC call instead of 9 queries
      final response = await client.rpc('get_admin_stats', params: {
        'p_from_date': fromDate?.toIso8601String(),
        'p_to_date': toDate != null
            ? DateTime(toDate.year, toDate.month, toDate.day, 23, 59, 59)
                .toIso8601String()
            : null,
      });

      final data = response as Map<String, dynamic>;

      return AdminStatsModel(
        totalCustomers: data['total_customers'] ?? 0,
        totalMerchants: data['total_merchants'] ?? 0,
        totalProducts: data['total_products'] ?? 0,
        activeProducts: data['active_products'] ?? 0,
        totalOrders: data['total_orders'] ?? 0,
        pendingOrders: data['pending_orders'] ?? 0,
        todayOrders: data['today_orders'] ?? 0,
        totalRevenue: (data['total_revenue'] ?? 0).toDouble(),
        todayRevenue: (data['today_revenue'] ?? 0).toDouble(),
      );
    } catch (e) {
      throw ServerException('Failed to get stats: $e');
    }
  }

  Future<List<Map<String, dynamic>>> getRecentOrdersImpl(
      {int limit = 10}) async {
    try {
      final response = await client
          .from('orders')
          .select('*, profiles!orders_user_id_fkey(name, email)')
          .order('created_at', ascending: false)
          .limit(limit);
      return List<Map<String, dynamic>>.from(response);
    } catch (e) {
      throw ServerException('Failed to get recent orders: $e');
    }
  }

  Future<List<Map<String, dynamic>>> getTopProductsImpl({int limit = 5}) async {
    try {
      final response = await client
          .from('products')
          .select('*, categories(name_ar, name_en)')
          .eq('is_active', true)
          .order('created_at', ascending: false)
          .limit(limit);
      return List<Map<String, dynamic>>.from(response);
    } catch (e) {
      throw ServerException('Failed to get top products: $e');
    }
  }
}
