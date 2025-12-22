import 'package:supabase_flutter/supabase_flutter.dart';
import '../../../../../core/errors/exceptions.dart';
import '../../../../../core/services/app_logger.dart';
import '../../models/product_model.dart';

mixin ProductMutationMixin {
  SupabaseClient get client;

  Future<void> createProduct(ProductModel product, {String? merchantId}) async {
    try {
      final json = product.toInsertJson();
      if (merchantId != null) {
        json['merchant_id'] = merchantId;
      }
      json['name_ar'] = product.name;
      json['name_en'] = product.name;
      json['description_ar'] = product.description;
      json['description_en'] = product.description;

      AppLogger.i('═══════════════════════════════════════');
      AppLogger.i('💾 DATABASE INSERT - products');
      AppLogger.i('═══════════════════════════════════════');
      AppLogger.d('Insert Data:', json);

      await client.from('products').insert(json);

      AppLogger.success('DATABASE INSERT SUCCESSFUL!');
      AppLogger.i('═══════════════════════════════════════');
    } catch (e, stackTrace) {
      AppLogger.e('❌ DATABASE INSERT FAILED!', e, stackTrace);
      throw ServerException('فشل في إنشاء المنتج: ${e.toString()}');
    }
  }

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

      await client.from('products').update(json).eq('id', product.id);

      AppLogger.success('DATABASE UPDATE SUCCESSFUL!');
      AppLogger.i('═══════════════════════════════════════');
    } catch (e, stackTrace) {
      AppLogger.e('❌ DATABASE UPDATE FAILED!', e, stackTrace);
      throw ServerException('فشل في تحديث المنتج: ${e.toString()}');
    }
  }

  Future<void> updateProductData(
      String productId, Map<String, dynamic> data) async {
    try {
      AppLogger.i('═══════════════════════════════════════');
      AppLogger.i('💾 DATABASE UPDATE (RAW) - products');
      AppLogger.i('═══════════════════════════════════════');
      AppLogger.d('Product ID:', productId);
      AppLogger.d('Update Data:', data);

      await client.from('products').update(data).eq('id', productId);

      AppLogger.success('DATABASE UPDATE SUCCESSFUL!');
      AppLogger.i('═══════════════════════════════════════');
    } catch (e, stackTrace) {
      AppLogger.e('❌ DATABASE UPDATE FAILED!', e, stackTrace);
      throw ServerException('فشل في تحديث المنتج: ${e.toString()}');
    }
  }

  Future<void> deleteProduct(String id) async {
    try {
      await client.from('products').update({
        'is_active': false,
        'is_featured': false,
      }).eq('id', id);
    } catch (e) {
      throw ServerException('فشل في حذف المنتج: ${e.toString()}');
    }
  }

  Future<void> updateStock(String productId, int newStock) async {
    try {
      await client
          .from('products')
          .update({'stock': newStock}).eq('id', productId);
    } catch (e) {
      throw ServerException('فشل في تحديث المخزون: ${e.toString()}');
    }
  }
}
