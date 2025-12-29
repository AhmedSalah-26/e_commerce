import 'package:supabase_flutter/supabase_flutter.dart';
import '../../../../../core/errors/exceptions.dart';

mixin AdminOrdersMixin {
  SupabaseClient get client;

  Future<List<Map<String, dynamic>>> getAllOrdersImpl({
    String? status,
    String? priority,
    String? search,
    int page = 0,
    int pageSize = 20,
  }) async {
    try {
      var query = client.from('orders').select('''
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
        // UUID لا يدعم ilike مباشرة
        final isUuidSearch = RegExp(
          r'^[0-9a-fA-F]{8}-?[0-9a-fA-F]{4}-?[0-9a-fA-F]{4}-?[0-9a-fA-F]{4}-?[0-9a-fA-F]{12}$',
        ).hasMatch(search.replaceAll('-', '').length >= 32 ? search : '');

        if (isUuidSearch) {
          query = query.or(
              'customer_name.ilike.%$search%,customer_phone.ilike.%$search%,id.eq.$search');
        } else {
          query = query.or(
              'customer_name.ilike.%$search%,customer_phone.ilike.%$search%');
        }
      }

      final response = await query
          .order('created_at', ascending: false)
          .range(page * pageSize, (page + 1) * pageSize - 1);

      return List<Map<String, dynamic>>.from(response);
    } catch (e) {
      throw ServerException('Failed to get orders: $e');
    }
  }

  Future<void> updateOrderStatusImpl(String orderId, String status) async {
    try {
      final updates = <String, dynamic>{'status': status};

      if (status == 'closed') {
        updates['closed_at'] = DateTime.now().toIso8601String();
      } else if (status == 'delivered') {
        updates['delivered_at'] = DateTime.now().toIso8601String();
      }

      await client.from('orders').update(updates).eq('id', orderId);
    } catch (e) {
      throw ServerException('Failed to update order status: $e');
    }
  }

  Future<void> updateOrderPriorityImpl(String orderId, String priority) async {
    try {
      await client
          .from('orders')
          .update({'priority': priority}).eq('id', orderId);
    } catch (e) {
      throw ServerException('Failed to update order priority: $e');
    }
  }

  Future<void> updateOrderDetailsImpl(
      String orderId, Map<String, dynamic> data) async {
    try {
      await client.from('orders').update(data).eq('id', orderId);
    } catch (e) {
      throw ServerException('Failed to update order details: $e');
    }
  }

  Future<Map<String, dynamic>> getOrderDetailsImpl(String orderId) async {
    try {
      final response = await client.from('orders').select('''
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
}
