import 'package:supabase_flutter/supabase_flutter.dart';
import '../../../../../core/errors/exceptions.dart';
import '../../models/product_model.dart';

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
  }) async {
    try {
      final from = page * limit;
      final to = from + limit - 1;

      var queryBuilder = client
          .from('products')
          .select()
          .eq('is_active', true)
          .or('name_ar.ilike.%$query%,name_en.ilike.%$query%');

      if (categoryId != null) {
        queryBuilder = queryBuilder.eq('category_id', categoryId);
      }

      if (minPrice != null) {
        queryBuilder = queryBuilder.gte('price', minPrice);
      }

      if (maxPrice != null) {
        queryBuilder = queryBuilder.lte('price', maxPrice);
      }

      final response = await queryBuilder
          .order('created_at', ascending: false)
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

      final response = await client
          .from('products')
          .select()
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
      final from = page * limit;
      final to = from + limit - 1;

      // Use raw SQL to sort by discount percentage on server
      final response = await client
          .from('products')
          .select()
          .eq('is_active', true)
          .not('discount_price', 'is', null)
          .gt('price', 0)
          .order('discount_price', ascending: true)
          .range(from, to);

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
