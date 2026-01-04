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
          .eq('is_suspended', false)
          .gt('stock', 0)
          .order('created_at', ascending: false)
          .range(from, to);

      return (response as List)
          .map((json) => ProductModel.fromJson(json, locale: locale))
          .toList();
    } catch (e) {
      throw const ServerException('error_loading_products');
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
          .eq('is_suspended', false)
          .gt('stock', 0)
          .order('created_at', ascending: false)
          .range(from, to);

      return (response as List)
          .map((json) => ProductModel.fromJson(json, locale: locale))
          .toList();
    } catch (e) {
      throw const ServerException('error_loading_products');
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

      var queryBuilder = client
          .from('products')
          .select()
          .eq('is_active', true)
          .eq('is_suspended', false)
          .gt('stock', 0);

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
      throw const ServerException('error_search_failed');
    }
  }

  Future<List<ProductModel>> getFeaturedProducts({String locale = 'ar'}) async {
    try {
      final response = await client
          .from('products')
          .select()
          .eq('is_featured', true)
          .eq('is_active', true)
          .eq('is_suspended', false)
          .gt('stock', 0)
          .order('created_at', ascending: false);

      return (response as List)
          .map((json) => ProductModel.fromJson(json, locale: locale))
          .toList();
    } catch (e) {
      throw const ServerException('error_loading_products');
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

      // Get products first
      final response = await client
          .from('products')
          .select()
          .eq('merchant_id', merchantId)
          .order('created_at', ascending: false)
          .range(from, to);

      // Fetch store info once for all products
      Map<String, dynamic>? storeInfo;
      try {
        final storeResponse = await client
            .from('stores')
            .select('name, description, phone, address, logo_url')
            .eq('merchant_id', merchantId)
            .maybeSingle();
        storeInfo = storeResponse;
      } catch (_) {}

      return (response as List)
          .map((json) => ProductModel.fromJson({
                ...json,
                if (storeInfo != null) 'stores': storeInfo,
              }, locale: locale))
          .toList();
    } catch (e) {
      throw const ServerException('error_loading_products');
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
      throw const ServerException('error_loading_products');
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
          .eq('is_suspended', false)
          .gt('stock', 0)
          .order('created_at', ascending: false)
          .limit(limit);

      return (response as List)
          .map((json) => ProductModel.fromJson(json, locale: locale))
          .toList();
    } catch (e) {
      throw const ServerException('error_loading_products');
    }
  }

  /// Get best selling products (sorted by rating count as proxy for popularity)
  Future<List<ProductModel>> getBestSellingProducts({
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
          .eq('is_suspended', false)
          .gt('stock', 0)
          .order('rating_count', ascending: false)
          .order('rating', ascending: false)
          .order('created_at', ascending: false)
          .range(from, to);

      return (response as List)
          .map((json) => ProductModel.fromJson(json, locale: locale))
          .toList();
    } catch (e) {
      throw const ServerException('error_loading_products');
    }
  }

  /// Get top rated products (sorted by rating)
  Future<List<ProductModel>> getTopRatedProducts({
    String locale = 'ar',
    int page = 0,
    int limit = 10,
  }) async {
    try {
      final from = page * limit;
      final to = from + limit - 1;

      final response = await client
          .from('products')
          .select('*')
          .eq('is_active', true)
          .eq('is_suspended', false)
          .gt('stock', 0)
          .gte('rating_count', 1)
          .order('rating', ascending: false)
          .range(from, to);

      return (response as List)
          .map((json) => ProductModel.fromJson(json, locale: locale))
          .toList();
    } catch (e) {
      throw const ServerException('error_loading_products');
    }
  }

  /// Get flash sale products (is_flash_sale = true and currently active)
  Future<List<ProductModel>> getFlashSaleProducts({
    String locale = 'ar',
    int limit = 10,
  }) async {
    try {
      // Get all flash sale products first
      final response = await client
          .from('products')
          .select()
          .eq('is_active', true)
          .eq('is_suspended', false)
          .eq('is_flash_sale', true)
          .gt('stock', 0)
          .limit(limit * 2); // Get more to filter

      final now = DateTime.now();

      // Filter in Dart to handle timezone correctly
      final activeFlashSale = (response as List).where((json) {
        final startStr = json['flash_sale_start'];
        final endStr = json['flash_sale_end'];
        if (startStr == null || endStr == null) return false;

        final start = DateTime.parse(startStr);
        final end = DateTime.parse(endStr);
        return now.isAfter(start) && now.isBefore(end);
      }).toList();

      // Sort by end time (soonest ending first)
      activeFlashSale.sort((a, b) {
        final endA = DateTime.parse(a['flash_sale_end']);
        final endB = DateTime.parse(b['flash_sale_end']);
        return endA.compareTo(endB);
      });

      return activeFlashSale
          .take(limit)
          .map((json) => ProductModel.fromJson(json, locale: locale))
          .toList();
    } catch (e) {
      throw const ServerException('error_loading_products');
    }
  }
}
