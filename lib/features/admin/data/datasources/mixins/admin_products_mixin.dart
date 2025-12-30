import 'package:supabase_flutter/supabase_flutter.dart';
import '../../../../../core/errors/exceptions.dart';

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
        // Check if search is UUID format
        final isUuidSearch = RegExp(
          r'^[0-9a-fA-F]{8}-?[0-9a-fA-F]{4}-?[0-9a-fA-F]{4}-?[0-9a-fA-F]{4}-?[0-9a-fA-F]{12}$',
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
    try {
      final adminId = client.auth.currentUser?.id;
      await client.from('products').update({
        'is_suspended': true,
        'suspension_reason': reason,
        'suspended_at': DateTime.now().toIso8601String(),
        'suspended_by': adminId,
      }).eq('id', productId);
    } catch (e) {
      throw ServerException('Failed to suspend product: $e');
    }
  }

  Future<void> unsuspendProductImpl(String productId) async {
    try {
      await client.from('products').update({
        'is_suspended': false,
        'suspension_reason': null,
        'suspended_at': null,
        'suspended_by': null,
      }).eq('id', productId);
    } catch (e) {
      throw ServerException('Failed to unsuspend product: $e');
    }
  }
}
