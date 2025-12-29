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

  // Phase 2: Orders
  Future<List<Map<String, dynamic>>> getAllOrders({
    String? status,
    String? priority,
    String? search,
    int page = 0,
    int pageSize = 20,
  });
  Future<void> updateOrderStatus(String orderId, String status);
  Future<void> updateOrderPriority(String orderId, String priority);
  Future<void> updateOrderDetails(String orderId, Map<String, dynamic> data);
  Future<Map<String, dynamic>> getOrderDetails(String orderId);

  // Phase 3: Products
  Future<List<Map<String, dynamic>>> getAllProducts({
    String? categoryId,
    bool? isActive,
    String? search,
    int page = 0,
    int pageSize = 20,
  });
  Future<void> toggleProductStatus(String productId, bool isActive);
  Future<void> deleteProduct(String productId);

  // Phase 4: Categories
  Future<List<Map<String, dynamic>>> getAllCategories({bool? isActive});
  Future<void> toggleCategoryStatus(String categoryId, bool isActive);

  // Product Suspension (Admin only)
  Future<void> suspendProduct(String productId, String reason);
  Future<void> unsuspendProduct(String productId);

  // User Ban (Admin only - Supabase Auth)
  Future<Map<String, dynamic>> banUser(String userId, String duration);
  Future<Map<String, dynamic>> unbanUser(String userId);

  // Rankings & Reports
  Future<List<Map<String, dynamic>>> getTopSellingMerchants({int limit = 20});
  Future<List<Map<String, dynamic>>> getTopOrderingCustomers({int limit = 20});
  Future<List<Map<String, dynamic>>> getMerchantsCancellationStats(
      {int limit = 20});
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
        _client.from('profiles').select().eq('role', 'customer').count(),
        _client.from('profiles').select().eq('role', 'merchant').count(),
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
          .select('*, profiles!orders_user_id_fkey(name, email)')
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
        query = query.eq('role', 'customer');
      } else if (role == 'merchant') {
        query = query.eq('role', 'merchant');
      } else if (role == 'admin') {
        query = query.eq('role', 'admin');
      }

      if (search != null && search.isNotEmpty) {
        query = query.or('name.ilike.%$search%,email.ilike.%$search%');
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
          .select('role')
          .eq('id', userId)
          .single();
      return response['role'] == 'admin';
    } catch (e) {
      return false;
    }
  }

  // Phase 2: Orders
  @override
  Future<List<Map<String, dynamic>>> getAllOrders({
    String? status,
    String? priority,
    String? search,
    int page = 0,
    int pageSize = 20,
  }) async {
    try {
      var query = _client.from('orders').select('''
        *,
        profiles!orders_user_id_fkey(id, name, email, phone)
      ''');

      if (status != null && status.isNotEmpty) {
        query = query.eq('status', status);
      }

      if (priority != null && priority.isNotEmpty) {
        query = query.eq('priority', priority);
      }

      if (search != null && search.isNotEmpty) {
        // Search by name, phone, email, or order ID
        query = query.or(
            'customer_name.ilike.%$search%,customer_phone.ilike.%$search%,id.ilike.%$search%');
      }

      final response = await query
          .order('created_at', ascending: false)
          .range(page * pageSize, (page + 1) * pageSize - 1);

      return List<Map<String, dynamic>>.from(response);
    } catch (e) {
      throw ServerException('Failed to get orders: $e');
    }
  }

  @override
  Future<void> updateOrderStatus(String orderId, String status) async {
    try {
      final updates = <String, dynamic>{'status': status};

      // Set timestamps based on status
      if (status == 'closed') {
        updates['closed_at'] = DateTime.now().toIso8601String();
      } else if (status == 'delivered') {
        updates['delivered_at'] = DateTime.now().toIso8601String();
      }

      await _client.from('orders').update(updates).eq('id', orderId);
    } catch (e) {
      throw ServerException('Failed to update order status: $e');
    }
  }

  @override
  Future<void> updateOrderPriority(String orderId, String priority) async {
    try {
      await _client
          .from('orders')
          .update({'priority': priority}).eq('id', orderId);
    } catch (e) {
      throw ServerException('Failed to update order priority: $e');
    }
  }

  @override
  Future<void> updateOrderDetails(
      String orderId, Map<String, dynamic> data) async {
    try {
      await _client.from('orders').update(data).eq('id', orderId);
    } catch (e) {
      throw ServerException('Failed to update order details: $e');
    }
  }

  @override
  Future<Map<String, dynamic>> getOrderDetails(String orderId) async {
    try {
      final response = await _client.from('orders').select('''
        *,
        profiles!orders_user_id_fkey(id, name, email, phone),
        order_items(
          id, quantity, price, total,
          products(id, name, name_ar, images)
        )
      ''').eq('id', orderId).single();
      return Map<String, dynamic>.from(response);
    } catch (e) {
      throw ServerException('Failed to get order details: $e');
    }
  }

  // Phase 3: Products
  @override
  Future<List<Map<String, dynamic>>> getAllProducts({
    String? categoryId,
    bool? isActive,
    String? search,
    int page = 0,
    int pageSize = 20,
  }) async {
    try {
      var query = _client.from('products').select('''
        *,
        categories(id, name_ar, name_en),
        profiles!products_merchant_id_fkey(name, email)
      ''');

      if (categoryId != null) {
        query = query.eq('category_id', categoryId);
      }

      if (isActive != null) {
        query = query.eq('is_active', isActive);
      }

      if (search != null && search.isNotEmpty) {
        query = query.or('name.ilike.%$search%,name_ar.ilike.%$search%');
      }

      final response = await query
          .order('created_at', ascending: false)
          .range(page * pageSize, (page + 1) * pageSize - 1);

      return List<Map<String, dynamic>>.from(response);
    } catch (e) {
      throw ServerException('Failed to get products: $e');
    }
  }

  @override
  Future<void> toggleProductStatus(String productId, bool isActive) async {
    try {
      await _client
          .from('products')
          .update({'is_active': isActive}).eq('id', productId);
    } catch (e) {
      throw ServerException('Failed to toggle product status: $e');
    }
  }

  @override
  Future<void> deleteProduct(String productId) async {
    try {
      await _client.from('products').delete().eq('id', productId);
    } catch (e) {
      throw ServerException('Failed to delete product: $e');
    }
  }

  // Phase 4: Categories
  @override
  Future<List<Map<String, dynamic>>> getAllCategories({bool? isActive}) async {
    try {
      var query = _client.from('categories').select();

      if (isActive != null) {
        query = query.eq('is_active', isActive);
      }

      final response = await query.order('sort_order', ascending: true);
      return List<Map<String, dynamic>>.from(response);
    } catch (e) {
      throw ServerException('Failed to get categories: $e');
    }
  }

  @override
  Future<void> toggleCategoryStatus(String categoryId, bool isActive) async {
    try {
      await _client
          .from('categories')
          .update({'is_active': isActive}).eq('id', categoryId);
    } catch (e) {
      throw ServerException('Failed to toggle category status: $e');
    }
  }

  // Product Suspension (Admin only)
  @override
  Future<void> suspendProduct(String productId, String reason) async {
    try {
      final adminId = _client.auth.currentUser?.id;
      await _client.from('products').update({
        'is_suspended': true,
        'suspension_reason': reason,
        'suspended_at': DateTime.now().toIso8601String(),
        'suspended_by': adminId,
      }).eq('id', productId);
    } catch (e) {
      throw ServerException('Failed to suspend product: $e');
    }
  }

  @override
  Future<void> unsuspendProduct(String productId) async {
    try {
      await _client.from('products').update({
        'is_suspended': false,
        'suspension_reason': null,
        'suspended_at': null,
        'suspended_by': null,
      }).eq('id', productId);
    } catch (e) {
      throw ServerException('Failed to unsuspend product: $e');
    }
  }

  // User Ban (Admin only - Supabase Auth)
  @override
  Future<Map<String, dynamic>> banUser(String userId, String duration) async {
    try {
      final response = await _client.rpc('ban_user', params: {
        'target_user_id': userId,
        'ban_duration': duration,
      });
      return Map<String, dynamic>.from(response);
    } catch (e) {
      throw ServerException('Failed to ban user: $e');
    }
  }

  @override
  Future<Map<String, dynamic>> unbanUser(String userId) async {
    try {
      final response = await _client.rpc('ban_user', params: {
        'target_user_id': userId,
        'ban_duration': 'none',
      });
      return Map<String, dynamic>.from(response);
    } catch (e) {
      throw ServerException('Failed to unban user: $e');
    }
  }

  // Rankings & Reports
  @override
  Future<List<Map<String, dynamic>>> getTopSellingMerchants(
      {int limit = 20}) async {
    try {
      // Get orders with merchant info from products
      final orders = await _client
          .from('orders')
          .select(
              'id, total, status, order_items(product_id, products(merchant_id))')
          .eq('status', 'delivered');

      // Aggregate by merchant
      final Map<String, Map<String, dynamic>> merchantStats = {};

      for (final order in orders) {
        final items = order['order_items'] as List? ?? [];
        for (final item in items) {
          final product = item['products'];
          if (product != null) {
            final merchantId = product['merchant_id'];
            if (merchantId != null) {
              if (!merchantStats.containsKey(merchantId)) {
                merchantStats[merchantId] = {
                  'merchant_id': merchantId,
                  'total_sales': 0.0,
                  'order_count': 0,
                };
              }
              merchantStats[merchantId]!['total_sales'] +=
                  (order['total'] ?? 0).toDouble();
              merchantStats[merchantId]!['order_count']++;
            }
          }
        }
      }

      // Get merchant profiles
      final merchantIds = merchantStats.keys.toList();
      if (merchantIds.isEmpty) return [];

      final profiles = await _client
          .from('profiles')
          .select('id, name, email')
          .inFilter('id', merchantIds);

      // Merge data
      final result = <Map<String, dynamic>>[];
      for (final profile in profiles) {
        final stats = merchantStats[profile['id']];
        if (stats != null) {
          result.add({
            ...profile,
            ...stats,
          });
        }
      }

      // Sort by total sales
      result.sort((a, b) =>
          (b['total_sales'] as double).compareTo(a['total_sales'] as double));

      return result.take(limit).toList();
    } catch (e) {
      throw ServerException('Failed to get top selling merchants: $e');
    }
  }

  @override
  Future<List<Map<String, dynamic>>> getTopOrderingCustomers(
      {int limit = 20}) async {
    try {
      final orders =
          await _client.from('orders').select('user_id, total, status');

      // Aggregate by customer
      final Map<String, Map<String, dynamic>> customerStats = {};

      for (final order in orders) {
        final userId = order['user_id'];
        if (userId != null) {
          if (!customerStats.containsKey(userId)) {
            customerStats[userId] = {
              'user_id': userId,
              'total_spent': 0.0,
              'order_count': 0,
              'delivered_count': 0,
            };
          }
          customerStats[userId]!['order_count']++;
          if (order['status'] == 'delivered') {
            customerStats[userId]!['total_spent'] +=
                (order['total'] ?? 0).toDouble();
            customerStats[userId]!['delivered_count']++;
          }
        }
      }

      // Get customer profiles
      final customerIds = customerStats.keys.toList();
      if (customerIds.isEmpty) return [];

      final profiles = await _client
          .from('profiles')
          .select('id, name, email, phone')
          .inFilter('id', customerIds);

      // Merge data
      final result = <Map<String, dynamic>>[];
      for (final profile in profiles) {
        final stats = customerStats[profile['id']];
        if (stats != null) {
          result.add({
            ...profile,
            ...stats,
          });
        }
      }

      // Sort by order count
      result.sort((a, b) =>
          (b['order_count'] as int).compareTo(a['order_count'] as int));

      return result.take(limit).toList();
    } catch (e) {
      throw ServerException('Failed to get top ordering customers: $e');
    }
  }

  @override
  Future<List<Map<String, dynamic>>> getMerchantsCancellationStats(
      {int limit = 20}) async {
    try {
      // Get all orders with merchant info
      final orders = await _client
          .from('orders')
          .select('id, status, order_items(product_id, products(merchant_id))');

      // Aggregate by merchant
      final Map<String, Map<String, dynamic>> merchantStats = {};

      for (final order in orders) {
        final items = order['order_items'] as List? ?? [];
        for (final item in items) {
          final product = item['products'];
          if (product != null) {
            final merchantId = product['merchant_id'];
            if (merchantId != null) {
              if (!merchantStats.containsKey(merchantId)) {
                merchantStats[merchantId] = {
                  'merchant_id': merchantId,
                  'total_orders': 0,
                  'cancelled_orders': 0,
                  'delivered_orders': 0,
                };
              }
              merchantStats[merchantId]!['total_orders']++;
              if (order['status'] == 'cancelled') {
                merchantStats[merchantId]!['cancelled_orders']++;
              } else if (order['status'] == 'delivered') {
                merchantStats[merchantId]!['delivered_orders']++;
              }
            }
          }
        }
      }

      // Get merchant profiles
      final merchantIds = merchantStats.keys.toList();
      if (merchantIds.isEmpty) return [];

      final profiles = await _client
          .from('profiles')
          .select('id, name, email')
          .inFilter('id', merchantIds);

      // Merge data and calculate difference
      final result = <Map<String, dynamic>>[];
      for (final profile in profiles) {
        final stats = merchantStats[profile['id']];
        if (stats != null) {
          final cancelled = stats['cancelled_orders'] as int;
          final delivered = stats['delivered_orders'] as int;
          result.add({
            ...profile,
            ...stats,
            'cancellation_rate': stats['total_orders'] > 0
                ? (cancelled / stats['total_orders'] * 100).toStringAsFixed(1)
                : '0.0',
            'difference': cancelled - delivered,
            'is_problematic': cancelled > delivered,
          });
        }
      }

      // Sort by cancelled orders (descending)
      result.sort((a, b) => (b['cancelled_orders'] as int)
          .compareTo(a['cancelled_orders'] as int));

      return result.take(limit).toList();
    } catch (e) {
      throw ServerException('Failed to get merchants cancellation stats: $e');
    }
  }
}
