import 'package:supabase_flutter/supabase_flutter.dart';
import '../../../../../core/errors/exceptions.dart';

mixin AdminReportsMixin {
  SupabaseClient get client;

  Future<List<Map<String, dynamic>>> getTopSellingMerchantsImpl(
      {int limit = 20}) async {
    try {
      final orders = await client
          .from('orders')
          .select(
              'id, total, status, order_items(product_id, products(merchant_id))')
          .eq('status', 'delivered');

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

      final merchantIds = merchantStats.keys.toList();
      if (merchantIds.isEmpty) return [];

      final profiles = await client
          .from('profiles')
          .select('id, name, email')
          .inFilter('id', merchantIds);

      final result = <Map<String, dynamic>>[];
      for (final profile in profiles) {
        final stats = merchantStats[profile['id']];
        if (stats != null) {
          result.add({...profile, ...stats});
        }
      }

      result.sort((a, b) =>
          (b['total_sales'] as double).compareTo(a['total_sales'] as double));

      return result.take(limit).toList();
    } catch (e) {
      throw ServerException('Failed to get top selling merchants: $e');
    }
  }

  Future<List<Map<String, dynamic>>> getTopOrderingCustomersImpl(
      {int limit = 20}) async {
    try {
      final orders =
          await client.from('orders').select('user_id, total, status');

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

      final customerIds = customerStats.keys.toList();
      if (customerIds.isEmpty) return [];

      final profiles = await client
          .from('profiles')
          .select('id, name, email, phone')
          .inFilter('id', customerIds);

      final result = <Map<String, dynamic>>[];
      for (final profile in profiles) {
        final stats = customerStats[profile['id']];
        if (stats != null) {
          result.add({...profile, ...stats});
        }
      }

      result.sort((a, b) =>
          (b['order_count'] as int).compareTo(a['order_count'] as int));

      return result.take(limit).toList();
    } catch (e) {
      throw ServerException('Failed to get top ordering customers: $e');
    }
  }

  Future<List<Map<String, dynamic>>> getMerchantsCancellationStatsImpl(
      {int limit = 20}) async {
    try {
      final orders =
          await client.from('orders').select('id, status, merchant_id');

      final Map<String, Map<String, dynamic>> merchantStats = {};
      final Set<String> processedOrders = {};

      for (final order in orders) {
        final merchantId = order['merchant_id']?.toString();
        final orderId = order['id']?.toString() ?? '';
        final status = order['status'];

        if (merchantId != null && merchantId.isNotEmpty) {
          final key = '$merchantId-$orderId';
          if (processedOrders.contains(key)) continue;
          processedOrders.add(key);

          if (!merchantStats.containsKey(merchantId)) {
            merchantStats[merchantId] = {
              'merchant_id': merchantId,
              'total_orders': 0,
              'cancelled_orders': 0,
              'delivered_orders': 0,
            };
          }
          merchantStats[merchantId]!['total_orders']++;
          if (status == 'cancelled') {
            merchantStats[merchantId]!['cancelled_orders']++;
          } else if (status == 'delivered') {
            merchantStats[merchantId]!['delivered_orders']++;
          }
        }
      }

      final merchantIds = merchantStats.keys.toList();
      if (merchantIds.isEmpty) return [];

      final profiles = await client
          .from('profiles')
          .select('id, name, email, phone')
          .inFilter('id', merchantIds);

      final result = <Map<String, dynamic>>[];
      for (final profile in profiles) {
        final stats = merchantStats[profile['id']];
        if (stats != null) {
          final cancelled = stats['cancelled_orders'] as int;
          final delivered = stats['delivered_orders'] as int;
          final total = stats['total_orders'] as int;
          result.add({
            ...profile,
            ...stats,
            'cancellation_rate': total > 0
                ? (cancelled / total * 100).toStringAsFixed(1)
                : '0.0',
            'difference': cancelled - delivered,
            'is_problematic': cancelled > delivered && cancelled > 0,
          });
        }
      }

      result.sort((a, b) => (b['cancelled_orders'] as int)
          .compareTo(a['cancelled_orders'] as int));

      return result.take(limit).toList();
    } catch (e) {
      throw ServerException('Failed to get merchants cancellation stats: $e');
    }
  }
}
