import 'package:supabase_flutter/supabase_flutter.dart';
import '../../../../../core/errors/exceptions.dart';
import '../../../domain/entities/order_entity.dart';

/// Mixin for updating orders
mixin OrderUpdateMixin {
  SupabaseClient get client;

  Future<void> updateOrderStatus(String orderId, OrderStatus status) async {
    try {
      await client
          .from('orders')
          .update({'status': status.name}).eq('id', orderId);
    } catch (e) {
      throw ServerException('فشل في تحديث حالة الطلب: ${e.toString()}');
    }
  }
}
