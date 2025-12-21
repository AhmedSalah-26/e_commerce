import 'package:supabase_flutter/supabase_flutter.dart';
import '../../../../core/errors/exceptions.dart';
import '../../../../core/services/app_logger.dart';
import '../models/product_model.dart';

/// Abstract interface for product remote data source
abstract class ProductRemoteDataSource {
  Future<List<ProductModel>> getProducts({
    String locale = 'ar',
    int page = 0,
    int limit = 10,
  });
  Future<List<ProductModel>> getProductsByCategory(
    String categoryId, {
    String locale = 'ar',
    int page = 0,
    int limit = 10,
  });
  Future<List<ProductModel>> searchProducts(
    String query, {
    String locale = 'ar',
    int page = 0,
    int limit = 10,
    String? categoryId,
    double? minPrice,
    double? maxPrice,
  });
  Future<List<ProductModel>> getFeaturedProducts({String locale = 'ar'});
  Future<ProductModel> getProductById(String id, {String locale = 'ar'});
  Future<Map<String, dynamic>> getProductRawById(String id);
  Future<void> createProduct(ProductModel product, {String? merchantId});
  Future<void> updateProduct(ProductModel product);
  Future<void> updateProductData(String productId, Map<String, dynamic> data);
  Future<void> deleteProduct(String id);
  Future<void> updateStock(String productId, int newStock);
  Stream<List<ProductModel>> watchProducts({String locale = 'ar'});
  Future<List<ProductModel>> getProductsByMerchant(
    String merchantId, {
    String locale = 'ar',
    int page = 0,
    int limit = 100,
  });
}

/// Implementation of product remote data source using Supabase
class ProductRemoteDataSourceImpl implements ProductRemoteDataSource {
  final SupabaseClient _client;

  ProductRemoteDataSourceImpl(this._client);

  @override
  Future<List<ProductModel>> getProducts({
    String locale = 'ar',
    int page = 0,
    int limit = 10,
  }) async {
    try {
      final from = page * limit;
      final to = from + limit - 1;

      final response = await _client
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

  @override
  Future<List<ProductModel>> getProductsByCategory(
    String categoryId, {
    String locale = 'ar',
    int page = 0,
    int limit = 10,
  }) async {
    try {
      final from = page * limit;
      final to = from + limit - 1;

      final response = await _client
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

  @override
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

      // Search in both Arabic and English names
      var queryBuilder = _client
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

  @override
  Future<List<ProductModel>> getFeaturedProducts({String locale = 'ar'}) async {
    try {
      final response = await _client
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

  @override
  Future<ProductModel> getProductById(String id, {String locale = 'ar'}) async {
    try {
      // Get product first
      final response =
          await _client.from('products').select().eq('id', id).single();

      // Try to get store info separately
      Map<String, dynamic>? storeInfo;
      if (response['merchant_id'] != null) {
        try {
          final storeResponse = await _client
              .from('stores')
              .select('name, phone, address')
              .eq('merchant_id', response['merchant_id'])
              .maybeSingle();
          storeInfo = storeResponse;
        } catch (_) {}
      }

      return ProductModel.fromJson({
        ...response,
        if (storeInfo != null) 'stores': storeInfo,
      }, locale: locale);
    } catch (e) {
      throw ServerException('فشل في جلب المنتج: ${e.toString()}');
    }
  }

  @override
  Future<Map<String, dynamic>> getProductRawById(String id) async {
    try {
      final response =
          await _client.from('products').select().eq('id', id).single();
      return response;
    } catch (e) {
      throw ServerException('فشل في جلب المنتج: ${e.toString()}');
    }
  }

  @override
  Future<void> createProduct(ProductModel product, {String? merchantId}) async {
    try {
      final json = product.toInsertJson();
      if (merchantId != null) {
        json['merchant_id'] = merchantId;
      }
      // Ensure name_ar and name_en are set
      json['name_ar'] = product.name;
      json['name_en'] = product.name;
      json['description_ar'] = product.description;
      json['description_en'] = product.description;

      AppLogger.i('═══════════════════════════════════════');
      AppLogger.i('💾 DATABASE INSERT - products');
      AppLogger.i('═══════════════════════════════════════');
      AppLogger.d('Insert Data:', json);

      await _client.from('products').insert(json);

      AppLogger.success('DATABASE INSERT SUCCESSFUL!');
      AppLogger.i('═══════════════════════════════════════');
    } catch (e, stackTrace) {
      AppLogger.e('❌ DATABASE INSERT FAILED!', e, stackTrace);
      throw ServerException('فشل في إنشاء المنتج: ${e.toString()}');
    }
  }

  @override
  Future<void> updateProduct(ProductModel product) async {
    try {
      final json = <String, dynamic>{
        'name_ar': product.name,
        'name_en': product.name,
        'description_ar': product.description,
        'description_en': product.description,
        'price': product.price,
        'discount_price': product.discountPrice,
        'images': product.images,
        'category_id': product.categoryId,
        'stock': product.stock,
        'is_active': product.isActive,
        'is_featured': product.isFeatured,
      };

      AppLogger.i('═══════════════════════════════════════');
      AppLogger.i('💾 DATABASE UPDATE - products');
      AppLogger.i('═══════════════════════════════════════');
      AppLogger.d('Product ID:', product.id);
      AppLogger.d('Update Data:', json);

      await _client.from('products').update(json).eq('id', product.id);

      AppLogger.success('DATABASE UPDATE SUCCESSFUL!');
      AppLogger.i('═══════════════════════════════════════');
    } catch (e, stackTrace) {
      AppLogger.e('❌ DATABASE UPDATE FAILED!', e, stackTrace);
      throw ServerException('فشل في تحديث المنتج: ${e.toString()}');
    }
  }

  @override
  Future<void> updateProductData(
      String productId, Map<String, dynamic> data) async {
    try {
      AppLogger.i('═══════════════════════════════════════');
      AppLogger.i('💾 DATABASE UPDATE (RAW) - products');
      AppLogger.i('═══════════════════════════════════════');
      AppLogger.d('Product ID:', productId);
      AppLogger.d('Update Data:', data);

      await _client.from('products').update(data).eq('id', productId);

      AppLogger.success('DATABASE UPDATE SUCCESSFUL!');
      AppLogger.i('═══════════════════════════════════════');
    } catch (e, stackTrace) {
      AppLogger.e('❌ DATABASE UPDATE FAILED!', e, stackTrace);
      throw ServerException('فشل في تحديث المنتج: ${e.toString()}');
    }
  }

  @override
  Future<void> deleteProduct(String id) async {
    try {
      // Soft delete - set is_active to false instead of hard delete
      // This prevents foreign key constraint errors with order_items
      await _client.from('products').update({
        'is_active': false,
        'is_featured': false,
      }).eq('id', id);
    } catch (e) {
      throw ServerException('فشل في حذف المنتج: ${e.toString()}');
    }
  }

  @override
  Future<void> updateStock(String productId, int newStock) async {
    try {
      await _client
          .from('products')
          .update({'stock': newStock}).eq('id', productId);
    } catch (e) {
      throw ServerException('فشل في تحديث المخزون: ${e.toString()}');
    }
  }

  @override
  Stream<List<ProductModel>> watchProducts({String locale = 'ar'}) {
    return _client
        .from('products')
        .stream(primaryKey: ['id'])
        .eq('is_active', true)
        .order('created_at', ascending: false)
        .map((data) => data
            .map((json) => ProductModel.fromJson(json, locale: locale))
            .toList());
  }

  @override
  Future<List<ProductModel>> getProductsByMerchant(
    String merchantId, {
    String locale = 'ar',
    int page = 0,
    int limit = 100,
  }) async {
    try {
      final from = page * limit;
      final to = from + limit - 1;

      final response = await _client
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
}
