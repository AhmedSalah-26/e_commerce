import 'package:logger/logger.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../../../../../core/errors/exceptions.dart';

final _log = Logger(
  printer: PrettyPrinter(methodCount: 0, printEmojis: false),
);

mixin AdminProductsMixin {
  SupabaseClient get client;

  Future<List<Map<String, dynamic>>> getAllProductsImpl({
    String? categoryId,
    bool? isActive,
    String? search,
    int page = 0,
    int pageSize = 20,
  }) async {
    try {
      var query = client.from('products').select('''
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
        final isUuidSearch = RegExp(
          r'^[0-9a-fA-F]{8}-?[0-9a-fA-F]{4}-?[0-9a-fA-F]{4}-?[0-9a-fA-F]{4}-?[0-9a-fA-F]{12}',
        ).hasMatch(search);

        if (isUuidSearch) {
          query = query.or(
              'name_ar.ilike.%$search%,name_en.ilike.%$search%,id.eq.$search,merchant_id.eq.$search');
        } else {
          query = query.or('name_ar.ilike.%$search%,name_en.ilike.%$search%');
        }
      }

      final response = await query
          .order('created_at', ascending: false)
          .range(page * pageSize, (page + 1) * pageSize - 1);

      return List<Map<String, dynamic>>.from(response);
    } catch (e) {
      throw ServerException('Failed to get products: $e');
    }
  }

  Future<void> toggleProductStatusImpl(String productId, bool isActive) async {
    try {
      await client
          .from('products')
          .update({'is_active': isActive}).eq('id', productId);
    } catch (e) {
      throw ServerException('Failed to toggle product status: $e');
    }
  }

  Future<void> deleteProductImpl(String productId) async {
    try {
      await client.from('products').delete().eq('id', productId);
    } catch (e) {
      throw ServerException('Failed to delete product: $e');
    }
  }

  Future<void> suspendProductImpl(String productId, String reason) async {
    final adminId = client.auth.currentUser?.id;

    print('========================================');
    print('SUSPEND REQUEST');
    print('productId: $productId');
    print('reason: $reason');
    print('adminId: $adminId');
    print('========================================');

    try {
      final result = await client
          .from('products')
          .update({
            'is_suspended': true,
            'is_active': false, // Also deactivate when suspended
            'suspension_reason': reason,
            'suspended_at': DateTime.now().toIso8601String(),
            'suspended_by': adminId,
          })
          .eq('id', productId)
          .select();

      print('SUSPEND RESPONSE: $result');

      if (result.isEmpty) {
        print(
            'SUSPEND FAILED: Empty response - product not found or RLS blocked');
      } else {
        print('SUSPEND SUCCESS: ${result[0]}');
      }
    } catch (e) {
      print('SUSPEND ERROR: $e');
      throw ServerException('Failed to suspend product: $e');
    }
  }

  Future<void> unsuspendProductImpl(String productId) async {
    _log.i('UNSUSPEND REQUEST: productId=$productId');

    try {
      final result = await client
          .from('products')
          .update({
            'is_suspended': false,
            'suspension_reason': null,
            'suspended_at': null,
            'suspended_by': null,
          })
          .eq('id', productId)
          .select();

      _log.i('UNSUSPEND RESPONSE: $result');
    } catch (e) {
      _log.e('UNSUSPEND ERROR: $e');
      throw ServerException('Failed to unsuspend product: $e');
    }
  }
}
