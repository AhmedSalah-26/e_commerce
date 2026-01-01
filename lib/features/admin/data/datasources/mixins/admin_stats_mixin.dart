import 'package:supabase_flutter/supabase_flutter.dart';
import '../../../../../core/errors/exceptions.dart';
import '../../models/admin_stats_model.dart';
import '../../../presentation/widgets/admin_charts.dart';

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
      }).timeout(const Duration(seconds: 15));

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
      print('❌ Failed to get admin stats via RPC: $e');
      // Fallback to individual queries if RPC fails
      return _getStatsFallback(fromDate: fromDate, toDate: toDate);
    }
  }

  Future<AdminStatsModel> _getStatsFallback({
    DateTime? fromDate,
    DateTime? toDate,
  }) async {
    try {
      print('📊 Using fallback stats queries...');

      // Get counts in parallel with timeout
      final results = await Future.wait([
        client
            .from('profiles')
            .select('id')
            .eq('role', 'customer')
            .count(CountOption.exact),
        client
            .from('profiles')
            .select('id')
            .eq('role', 'merchant')
            .count(CountOption.exact),
        client.from('products').select('id').count(CountOption.exact),
        client
            .from('products')
            .select('id')
            .eq('is_active', true)
            .count(CountOption.exact),
      ]).timeout(const Duration(seconds: 10));

      final totalCustomers = results[0].count;
      final totalMerchants = results[1].count;
      final totalProducts = results[2].count;
      final activeProducts = results[3].count;

      // Get order stats with timeout
      var ordersQuery =
          client.from('orders').select('id, status, total, created_at');
      if (fromDate != null) {
        ordersQuery = ordersQuery.gte('created_at', fromDate.toIso8601String());
      }
      if (toDate != null) {
        ordersQuery = ordersQuery.lte('created_at', toDate.toIso8601String());
      }
      final ordersData = await ordersQuery.timeout(const Duration(seconds: 10));

      final orders = List<Map<String, dynamic>>.from(ordersData);
      final totalOrders = orders.length;
      final pendingOrders =
          orders.where((o) => o['status'] == 'pending').length;

      final now = DateTime.now();
      final startOfDay = DateTime(now.year, now.month, now.day);
      final todayOrders = orders.where((o) {
        final createdAt = DateTime.tryParse(o['created_at'] ?? '');
        return createdAt != null && createdAt.isAfter(startOfDay);
      }).length;

      final deliveredOrders = orders.where((o) => o['status'] == 'delivered');
      final totalRevenue = deliveredOrders.fold<double>(
          0, (sum, o) => sum + ((o['total'] as num?)?.toDouble() ?? 0));

      final todayDelivered = deliveredOrders.where((o) {
        final createdAt = DateTime.tryParse(o['created_at'] ?? '');
        return createdAt != null && createdAt.isAfter(startOfDay);
      });
      final todayRevenue = todayDelivered.fold<double>(
          0, (sum, o) => sum + ((o['total'] as num?)?.toDouble() ?? 0));

      print('✅ Fallback stats loaded successfully');
      return AdminStatsModel(
        totalCustomers: totalCustomers,
        totalMerchants: totalMerchants,
        totalProducts: totalProducts,
        activeProducts: activeProducts,
        totalOrders: totalOrders,
        pendingOrders: pendingOrders,
        todayOrders: todayOrders,
        totalRevenue: totalRevenue,
        todayRevenue: todayRevenue,
      );
    } catch (e) {
      print('❌ Fallback stats also failed: $e');
      // Return empty stats instead of throwing
      return AdminStatsModel(
        totalCustomers: 0,
        totalMerchants: 0,
        totalProducts: 0,
        activeProducts: 0,
        totalOrders: 0,
        pendingOrders: 0,
        todayOrders: 0,
        totalRevenue: 0,
        todayRevenue: 0,
      );
    }
  }

  Future<List<MonthlyData>> getMonthlyStatsImpl({int months = 6}) async {
    try {
      final response = await client.rpc('get_monthly_stats', params: {
        'p_months': months,
      });

      return (response as List)
          .map((json) => MonthlyData.fromJson(json as Map<String, dynamic>))
          .toList();
    } catch (e) {
      print('❌ Failed to get monthly stats: $e');
      // Return empty list on error - charts will show "no data"
      return [];
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
