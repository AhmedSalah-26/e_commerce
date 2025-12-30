import 'package:supabase_flutter/supabase_flutter.dart';
import '../../../../../core/errors/exceptions.dart';
import '../../models/product_model.dart';
import '../../../domain/enums/sort_option.dart';

mixin ProductQueryMixin {
  SupabaseClient get client;

  Future<List<ProductModel>> getProducts({
    String locale = 'ar',
    int page = 0,
    int limit = 10,
  }) async {
    try {
      final from = page * limit;
      final to = from + limit - 1;

      final response = await client
          .from('products')
          .select()
          .eq('is_active', true)
          .order('created_at', ascending: false)
          .range(from, to);

      return (response as List)
          .map((json) => ProductModel.fromJson(json, locale: locale))
          .toList();
    } catch (e) {
      throw ServerException('فشل في جلب المنتجات: ${e.toString()}');
    }
  }

  Future<List<ProductModel>> getProductsByCategory(
    String categoryId, {
    String locale = 'ar',
    int page = 0,
    int limit = 10,
  }) async {
    try {
      final from = page * limit;
      final to = from + limit - 1;

      final response = await client
          .from('products')
          .select()
          .eq('category_id', categoryId)
          .eq('is_active', true)
          .order('created_at', ascending: false)
          .range(from, to);

      return (response as List)
          .map((json) => ProductModel.fromJson(json, locale: locale))
          .toList();
    } catch (e) {
      throw ServerException('فشل في جلب منتجات التصنيف: ${e.toString()}');
    }
  }

  Future<List<ProductModel>> searchProducts(
    String query, {
    String locale = 'ar',
    int page = 0,
    int limit = 10,
    String? categoryId,
    double? minPrice,
    double? maxPrice,
    SortOption? sortOption,
  }) async {
    try {
      final from = page * limit;
      final to = from + limit - 1;

      var queryBuilder = client.from('products').select().eq('is_active', true);

      // Apply search filter only if query is not empty
      if (query.isNotEmpty) {
        queryBuilder =
            queryBuilder.or('name_ar.ilike.%$query%,name_en.ilike.%$query%');
      }

      if (categoryId != null) {
        queryBuilder = queryBuilder.eq('category_id', categoryId);
      }

      if (minPrice != null) {
        queryBuilder = queryBuilder.gte('price', minPrice);
      }

      if (maxPrice != null) {
        queryBuilder = queryBuilder.lte('price', maxPrice);
      }

      // Apply sorting
      final sort = sortOption ?? SortOption.newest;
      final response = await queryBuilder
          .order(sort.orderColumn, ascending: sort.isAscending)
          .range(from, to);

      return (response as List)
          .map((json) => ProductModel.fromJson(json, locale: locale))
          .toList();
    } catch (e) {
      throw ServerException('فشل في البحث: ${e.toString()}');
    }
  }

  Future<List<ProductModel>> getFeaturedProducts({String locale = 'ar'}) async {
    try {
      final response = await client
          .from('products')
          .select()
          .eq('is_featured', true)
          .eq('is_active', true)
          .order('created_at', ascending: false);

      return (response as List)
          .map((json) => ProductModel.fromJson(json, locale: locale))
          .toList();
    } catch (e) {
      throw ServerException('فشل في جلب المنتجات المميزة: ${e.toString()}');
    }
  }

  Future<List<ProductModel>> getProductsByMerchant(
    String merchantId, {
    String locale = 'ar',
    int page = 0,
    int limit = 100,
  }) async {
    try {
      final from = page * limit;
      final to = from + limit - 1;

      // Optimized: Single query with store JOIN instead of 2 queries
      final response = await client
          .from('products')
          .select(
              '*, stores:merchant_id(name, description, phone, address, logo_url)')
          .eq('merchant_id', merchantId)
          .order('created_at', ascending: false)
          .range(from, to);

      return (response as List)
          .map((json) => ProductModel.fromJson(json, locale: locale))
          .toList();
    } catch (e) {
      throw ServerException('فشل في جلب منتجات التاجر: ${e.toString()}');
    }
  }

  Future<List<ProductModel>> getDiscountedProducts({
    String locale = 'ar',
    int page = 0,
    int limit = 10,
  }) async {
    try {
      final offset = page * limit;

      // Use RPC function to get products sorted by discount percentage on server
      final response = await client.rpc(
        'get_discounted_products_sorted',
        params: {
          'p_limit': limit,
          'p_offset': offset,
        },
      );

      return (response as List)
          .map((json) => ProductModel.fromJson(json, locale: locale))
          .toList();
    } catch (e) {
      throw ServerException('فشل في جلب المنتجات المخفضة: ${e.toString()}');
    }
  }

  Future<List<ProductModel>> getNewestProducts({
    String locale = 'ar',
    int limit = 10,
  }) async {
    try {
      final response = await client
          .from('products')
          .select()
          .eq('is_active', true)
          .order('created_at', ascending: false)
          .limit(limit);

      return (response as List)
          .map((json) => ProductModel.fromJson(json, locale: locale))
          .toList();
    } catch (e) {
      throw ServerException('فشل في جلب المنتجات الجديدة: ${e.toString()}');
    }
  }
}
