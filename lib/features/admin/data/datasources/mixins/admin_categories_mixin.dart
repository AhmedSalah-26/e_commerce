import 'package:supabase_flutter/supabase_flutter.dart';
import '../../../../../core/errors/exceptions.dart';

mixin AdminCategoriesMixin {
  SupabaseClient get client;

  Future<List<Map<String, dynamic>>> getAllCategoriesImpl(
      {bool? isActive}) async {
    try {
      var query = client.from('categories').select();

      if (isActive != null) {
        query = query.eq('is_active', isActive);
      }

      final response = await query.order('sort_order', ascending: true);
      return List<Map<String, dynamic>>.from(response);
    } catch (e) {
      throw ServerException('Failed to get categories: $e');
    }
  }

  Future<void> toggleCategoryStatusImpl(
      String categoryId, bool isActive) async {
    try {
      await client
          .from('categories')
          .update({'is_active': isActive}).eq('id', categoryId);
    } catch (e) {
      throw ServerException('Failed to toggle category status: $e');
    }
  }
}
