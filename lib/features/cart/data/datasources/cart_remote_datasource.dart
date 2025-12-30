import 'package:supabase_flutter/supabase_flutter.dart';
import '../../../../core/errors/exceptions.dart';
import '../../../../core/services/logger_service.dart';
import '../models/cart_item_model.dart';

/// Abstract interface for cart remote data source
abstract class CartRemoteDataSource {
  Future<List<CartItemModel>> getCartItems(String userId,
      {String locale = 'ar'});
  Future<void> addToCart(String userId, String productId, int quantity);
  Future<void> updateQuantity(String cartItemId, int quantity);
  Future<void> removeFromCart(String cartItemId);
  Future<void> clearCart(String userId);
  Stream<List<CartItemModel>> watchCartItems(String userId,
      {String locale = 'ar'});
}

/// Implementation of cart remote data source using Supabase
class CartRemoteDataSourceImpl implements CartRemoteDataSource {
  final SupabaseClient _client;

  CartRemoteDataSourceImpl(this._client);

  @override
  Future<List<CartItemModel>> getCartItems(String userId,
      {String locale = 'ar'}) async {
    logger.d('🛒 Getting cart items for user: $userId');
    try {
      // Get cart items with products
      final response = await _client.from('cart_items').select('''
            *, 
            products(*)
          ''').eq('user_id', userId).order('created_at', ascending: false);

      logger.d('✅ Got ${(response as List).length} cart items');

      if (response.isEmpty) return [];

      // Get unique merchant IDs
      final merchantIds = <String>{};
      for (final item in response) {
        final product = item['products'];
        if (product != null && product['merchant_id'] != null) {
          merchantIds.add(product['merchant_id'] as String);
        }
      }

      // Fetch store info for all merchants
      Map<String, Map<String, dynamic>> storesMap = {};
      if (merchantIds.isNotEmpty) {
        final storesResponse = await _client
            .from('stores')
            .select('merchant_id, name, phone, description, address, logo_url')
            .inFilter('merchant_id', merchantIds.toList());

        for (final store in storesResponse) {
          storesMap[store['merchant_id'] as String] = store;
        }
      }

      // Merge store info into products
      return response.map((json) {
        final product = json['products'] as Map<String, dynamic>?;
        if (product != null && product['merchant_id'] != null) {
          final storeInfo = storesMap[product['merchant_id']];
          if (storeInfo != null) {
            json['products'] = {...product, 'stores': storeInfo};
          }
        }
        return CartItemModel.fromJson(json, locale: locale);
      }).toList();
    } catch (e, stackTrace) {
      logger.e('❌ Error getting cart items', error: e, stackTrace: stackTrace);
      throw ServerException('فشل في جلب السلة: ${e.toString()}');
    }
  }

  @override
  Future<void> addToCart(String userId, String productId, int quantity) async {
    logger.i(
        '🛒 Adding to cart: userId=$userId, productId=$productId, qty=$quantity');
    try {
      // Check if product is active
      final product = await _client
          .from('products')
          .select('is_active, stock')
          .eq('id', productId)
          .maybeSingle();

      if (product == null) {
        throw const ServerException('المنتج غير موجود');
      }

      if (product['is_active'] != true) {
        throw const ServerException('هذا المنتج غير متوفر حالياً');
      }

      if ((product['stock'] as int? ?? 0) <= 0) {
        throw const ServerException('المنتج غير متوفر في المخزون');
      }

      // Check if item already exists in cart
      final existing = await _client
          .from('cart_items')
          .select()
          .eq('user_id', userId)
          .eq('product_id', productId)
          .maybeSingle();

      if (existing != null) {
        // Update quantity
        final newQuantity = (existing['quantity'] as int) + quantity;
        logger.d('Updating existing cart item, new quantity: $newQuantity');
        await _client
            .from('cart_items')
            .update({'quantity': newQuantity}).eq('id', existing['id']);
      } else {
        // Insert new item
        logger.d('Inserting new cart item');
        await _client.from('cart_items').insert({
          'user_id': userId,
          'product_id': productId,
          'quantity': quantity,
        });
      }
      logger.i('✅ Added to cart successfully');
    } catch (e, stackTrace) {
      logger.e('❌ Error adding to cart', error: e, stackTrace: stackTrace);
      if (e is ServerException) rethrow;
      throw ServerException('فشل في إضافة المنتج للسلة: ${e.toString()}');
    }
  }

  @override
  Future<void> updateQuantity(String cartItemId, int quantity) async {
    try {
      if (quantity <= 0) {
        await removeFromCart(cartItemId);
      } else {
        await _client
            .from('cart_items')
            .update({'quantity': quantity}).eq('id', cartItemId);
      }
    } catch (e) {
      throw ServerException('فشل في تحديث الكمية: ${e.toString()}');
    }
  }

  @override
  Future<void> removeFromCart(String cartItemId) async {
    try {
      await _client.from('cart_items').delete().eq('id', cartItemId);
    } catch (e) {
      throw ServerException('فشل في حذف المنتج من السلة: ${e.toString()}');
    }
  }

  @override
  Future<void> clearCart(String userId) async {
    try {
      await _client.from('cart_items').delete().eq('user_id', userId);
    } catch (e) {
      throw ServerException('فشل في تفريغ السلة: ${e.toString()}');
    }
  }

  @override
  Stream<List<CartItemModel>> watchCartItems(String userId,
      {String locale = 'ar'}) {
    return _client
        .from('cart_items')
        .stream(primaryKey: ['id'])
        .eq('user_id', userId)
        .order('created_at', ascending: false)
        .asyncMap((data) async {
          if (data.isEmpty) return <CartItemModel>[];

          // Batch fetch all products
          final productIds =
              data.map((item) => item['product_id'] as String).toSet().toList();

          final productsResponse = await _client
              .from('products')
              .select('*')
              .inFilter('id', productIds);

          // Get unique merchant IDs
          final merchantIds = <String>{};
          for (final product in productsResponse) {
            if (product['merchant_id'] != null) {
              merchantIds.add(product['merchant_id'] as String);
            }
          }

          // Fetch store info for all merchants
          Map<String, Map<String, dynamic>> storesMap = {};
          if (merchantIds.isNotEmpty) {
            final storesResponse = await _client
                .from('stores')
                .select(
                    'merchant_id, name, phone, description, address, logo_url')
                .inFilter('merchant_id', merchantIds.toList());

            for (final store in storesResponse) {
              storesMap[store['merchant_id'] as String] = store;
            }
          }

          // Create lookup map for O(1) access with store info
          final productsMap = <String, Map<String, dynamic>>{};
          for (final p in productsResponse) {
            final merchantId = p['merchant_id'] as String?;
            if (merchantId != null && storesMap.containsKey(merchantId)) {
              productsMap[p['id'] as String] = {
                ...p,
                'stores': storesMap[merchantId]
              };
            } else {
              productsMap[p['id'] as String] = p;
            }
          }

          return data.map((item) {
            final product = productsMap[item['product_id']];
            return CartItemModel.fromJson({
              ...item,
              'products': product,
            }, locale: locale);
          }).toList();
        });
  }
}
