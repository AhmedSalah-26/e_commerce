import 'package:supabase_flutter/supabase_flutter.dart';
import '../../../../core/errors/exceptions.dart';
import '../../domain/enums/sort_option.dart';
import '../models/product_model.dart';
import 'mixins/product_query_mixin.dart';
import 'mixins/product_mutation_mixin.dart';

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
    SortOption? sortOption,
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
  Future<List<ProductModel>> getDiscountedProducts({
    String locale = 'ar',
    int page = 0,
    int limit = 10,
  });
  Future<List<ProductModel>> getNewestProducts({
    String locale = 'ar',
    int limit = 10,
  });
  Future<List<ProductModel>> getBestSellingProducts({
    String locale = 'ar',
    int page = 0,
    int limit = 10,
  });
  Future<List<ProductModel>> getTopRatedProducts({
    String locale = 'ar',
    int page = 0,
    int limit = 10,
  });
  Future<void> cleanupExpiredFlashSales();
  Future<void> cleanupExpiredFlashSaleForProduct(String productId);
}

/// Implementation of product remote data source using Supabase
class ProductRemoteDataSourceImpl
    with ProductQueryMixin, ProductMutationMixin
    implements ProductRemoteDataSource {
  @override
  final SupabaseClient client;

  ProductRemoteDataSourceImpl(this.client);

  @override
  Future<ProductModel> getProductById(String id, {String locale = 'ar'}) async {
    try {
      final response =
          await client.from('products').select().eq('id', id).single();

      // Fetch store info separately if merchant_id exists
      Map<String, dynamic>? storeInfo;
      if (response['merchant_id'] != null) {
        try {
          final storeResponse = await client
              .from('stores')
              .select('name, description, phone, address, logo_url')
              .eq('merchant_id', response['merchant_id'])
              .maybeSingle();
          storeInfo = storeResponse;
        } catch (e) {
          // Log but don't fail - store info is optional
          print('⚠️ Failed to fetch store info: $e');
        }
      }

      return ProductModel.fromJson({
        ...response,
        if (storeInfo != null) 'stores': storeInfo,
      }, locale: locale);
    } on PostgrestException catch (e) {
      print('❌ PostgrestException in getProductById: ${e.message}');
      throw ServerException('فشل في جلب المنتج: ${e.message}');
    } catch (e) {
      print('❌ Error in getProductById: $e');
      throw ServerException('فشل في جلب المنتج: ${e.toString()}');
    }
  }

  @override
  Future<Map<String, dynamic>> getProductRawById(String id) async {
    try {
      final response =
          await client.from('products').select().eq('id', id).single();
      return response;
    } catch (e) {
      throw ServerException('فشل في جلب المنتج: ${e.toString()}');
    }
  }

  @override
  Stream<List<ProductModel>> watchProducts({String locale = 'ar'}) {
    return client
        .from('products')
        .stream(primaryKey: ['id'])
        .order('created_at', ascending: false)
        .map((data) => data
            .where((json) =>
                json['is_active'] == true && json['is_suspended'] != true)
            .map((json) => ProductModel.fromJson(json, locale: locale))
            .toList());
  }

  @override
  Future<void> cleanupExpiredFlashSales() async {
    try {
      // Call the database function to cleanup expired flash sales
      await client.rpc('cleanup_expired_flash_sales');
    } catch (e) {
      // Silently fail - this is a background cleanup task
      // The trigger will handle individual products on update
    }
  }

  @override
  Future<void> cleanupExpiredFlashSaleForProduct(String productId) async {
    try {
      // Directly update the product to remove flash sale and discount
      await client.from('products').update({
        'is_flash_sale': false,
        'flash_sale_start': null,
        'flash_sale_end': null,
        'discount_price': null,
      }).eq('id', productId);
    } catch (_) {
      // Silently fail
    }
  }
}
