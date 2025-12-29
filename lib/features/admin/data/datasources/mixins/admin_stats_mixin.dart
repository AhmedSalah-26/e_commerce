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
      final today = DateTime.now();
      final startOfDay = DateTime(today.year, today.month, today.day);

      // Base queries for counts (not affected by date filter)
      final baseResults = await Future.wait([
        client.from('profiles').select().eq('role', 'customer').count(),
        client.from('profiles').select().eq('role', 'merchant').count(),
        client.from('products').select().count(),
        client.from('products').select().eq('is_active', true).count(),
      ]);

      // Orders queries with optional date filter
      var ordersQuery = client.from('orders').select();
      var pendingQuery = client.from('orders').select().eq('status', 'pending');
      var todayQuery = client
          .from('orders')
          .select()
          .gte('created_at', startOfDay.toIso8601String());
      var revenueQuery =
          client.from('orders').select('total').eq('status', 'delivered');
      var todayRevenueQuery = client
          .from('orders')
          .select('total')
          .eq('status', 'delivered')
          .gte('created_at', startOfDay.toIso8601String());

      // Apply date filters if provided
      if (fromDate != null) {
        final fromStr = fromDate.toIso8601String();
        ordersQuery = ordersQuery.gte('created_at', fromStr);
        pendingQuery = pendingQuery.gte('created_at', fromStr);
        revenueQuery = revenueQuery.gte('created_at', fromStr);
      }
      if (toDate != null) {
        final toStr =
            DateTime(toDate.year, toDate.month, toDate.day, 23, 59, 59)
                .toIso8601String();
        ordersQuery = ordersQuery.lte('created_at', toStr);
        pendingQuery = pendingQuery.lte('created_at', toStr);
        revenueQuery = revenueQuery.lte('created_at', toStr);
      }

      final orderResults = await Future.wait([
        ordersQuery.count(),
        pendingQuery.count(),
        todayQuery.count(),
      ]);

      final revenueResult = await revenueQuery;
      final todayRevenueResult = await todayRevenueQuery;

      double totalRevenue = 0;
      for (final row in revenueResult) {
        totalRevenue += (row['total'] ?? 0).toDouble();
      }

      double todayRevenue = 0;
      for (final row in todayRevenueResult) {
        todayRevenue += (row['total'] ?? 0).toDouble();
      }

      return AdminStatsModel(
        totalCustomers: baseResults[0].count,
        totalMerchants: baseResults[1].count,
        totalProducts: baseResults[2].count,
        activeProducts: baseResults[3].count,
        totalOrders: orderResults[0].count,
        pendingOrders: orderResults[1].count,
        todayOrders: orderResults[2].count,
        totalRevenue: totalRevenue,
        todayRevenue: todayRevenue,
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
