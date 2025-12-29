import 'package:supabase_flutter/supabase_flutter.dart';
import '../../../../core/errors/exceptions.dart';
import '../models/admin_stats_model.dart';

/// Admin remote datasource
abstract class AdminRemoteDatasource {
  Future<AdminStatsModel> getStats();
  Future<List<Map<String, dynamic>>> getRecentOrders({int limit = 10});
  Future<List<Map<String, dynamic>>> getTopProducts({int limit = 5});
  Future<List<Map<String, dynamic>>> getUsers({
    String? role,
    String? search,
    int page = 0,
    int pageSize = 20,
  });
  Future<void> toggleUserStatus(String userId, bool isActive);
  Future<bool> isAdmin(String userId);
}

class AdminRemoteDatasourceImpl implements AdminRemoteDatasource {
  final SupabaseClient _client;

  AdminRemoteDatasourceImpl(this._client);

  @override
  Future<AdminStatsModel> getStats() async {
    try {
      final today = DateTime.now();
      final startOfDay = DateTime(today.year, today.month, today.day);

      // Get counts in parallel
      final results = await Future.wait([
        _client
            .from('profiles')
            .select()
            .eq('is_merchant', false)
            .eq('is_admin', false)
            .count(),
        _client.from('profiles').select().eq('is_merchant', true).count(),
        _client.from('products').select().count(),
        _client.from('products').select().eq('is_active', true).count(),
        _client.from('orders').select().count(),
        _client.from('orders').select().eq('status', 'pending').count(),
        _client
            .from('orders')
            .select()
            .gte('created_at', startOfDay.toIso8601String())
            .count(),
      ]);

      // Get revenue
      final revenueResult = await _client
          .from('orders')
          .select('total')
          .eq('status', 'delivered');

      final todayRevenueResult = await _client
          .from('orders')
          .select('total')
          .eq('status', 'delivered')
          .gte('created_at', startOfDay.toIso8601String());

      double totalRevenue = 0;
      for (final row in revenueResult) {
        totalRevenue += (row['total'] ?? 0).toDouble();
      }

      double todayRevenue = 0;
      for (final row in todayRevenueResult) {
        todayRevenue += (row['total'] ?? 0).toDouble();
      }

      return AdminStatsModel(
        totalCustomers: results[0].count,
        totalMerchants: results[1].count,
        totalProducts: results[2].count,
        activeProducts: results[3].count,
        totalOrders: results[4].count,
        pendingOrders: results[5].count,
        todayOrders: results[6].count,
        totalRevenue: totalRevenue,
        todayRevenue: todayRevenue,
      );
    } catch (e) {
      throw ServerException('Failed to get stats: $e');
    }
  }

  @override
  Future<List<Map<String, dynamic>>> getRecentOrders({int limit = 10}) async {
    try {
      final response = await _client
          .from('orders')
          .select('*, profiles!orders_customer_id_fkey(full_name)')
          .order('created_at', ascending: false)
          .limit(limit);
      return List<Map<String, dynamic>>.from(response);
    } catch (e) {
      throw ServerException('Failed to get recent orders: $e');
    }
  }

  @override
  Future<List<Map<String, dynamic>>> getTopProducts({int limit = 5}) async {
    try {
      // Get products with order count
      final response = await _client
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

  @override
  Future<List<Map<String, dynamic>>> getUsers({
    String? role,
    String? search,
    int page = 0,
    int pageSize = 20,
  }) async {
    try {
      var query = _client.from('profiles').select();

      if (role == 'customer') {
        query = query.eq('is_merchant', false).eq('is_admin', false);
      } else if (role == 'merchant') {
        query = query.eq('is_merchant', true);
      } else if (role == 'admin') {
        query = query.eq('is_admin', true);
      }

      if (search != null && search.isNotEmpty) {
        query = query.or('full_name.ilike.%$search%,email.ilike.%$search%');
      }

      final response = await query
          .order('created_at', ascending: false)
          .range(page * pageSize, (page + 1) * pageSize - 1);

      return List<Map<String, dynamic>>.from(response);
    } catch (e) {
      throw ServerException('Failed to get users: $e');
    }
  }

  @override
  Future<void> toggleUserStatus(String userId, bool isActive) async {
    try {
      await _client
          .from('profiles')
          .update({'is_active': isActive}).eq('id', userId);
    } catch (e) {
      throw ServerException('Failed to toggle user status: $e');
    }
  }

  @override
  Future<bool> isAdmin(String userId) async {
    try {
      final response = await _client
          .from('profiles')
          .select('is_admin')
          .eq('id', userId)
          .single();
      return response['is_admin'] ?? false;
    } catch (e) {
      return false;
    }
  }
}
