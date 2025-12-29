import 'package:supabase_flutter/supabase_flutter.dart';
import '../../../../core/errors/exceptions.dart';
import '../../../../core/services/app_logger.dart';
import '../models/category_model.dart';

/// Abstract interface for category remote data source
abstract class CategoryRemoteDataSource {
  Future<List<CategoryModel>> getCategories({String locale = 'ar'});
  Future<List<CategoryModel>> getAllCategories({String locale = 'ar'});
  Future<CategoryModel> getCategoryById(String id, {String locale = 'ar'});
  Future<Map<String, dynamic>> getCategoryRawById(String id);
  Future<void> createCategory(CategoryModel category,
      {String? nameAr, String? nameEn});
  Future<void> updateCategory(CategoryModel category,
      {String? nameAr, String? nameEn});
  Future<void> deleteCategory(String id);
  Future<int> getProductCountByCategory(String categoryId);
}

/// Implementation of category remote data source using Supabase
class CategoryRemoteDataSourceImpl implements CategoryRemoteDataSource {
  final SupabaseClient _client;

  CategoryRemoteDataSourceImpl(this._client);

  @override
  Future<List<CategoryModel>> getCategories({String locale = 'ar'}) async {
    try {
      final response = await _client
          .from('categories')
          .select()
          .eq('is_active', true)
          .order('sort_order', ascending: true);

      return (response as List)
          .map((json) => CategoryModel.fromJson(json, locale: locale))
          .toList();
    } catch (e) {
      throw ServerException('فشل في جلب التصنيفات: ${e.toString()}');
    }
  }

  @override
  Future<List<CategoryModel>> getAllCategories({String locale = 'ar'}) async {
    try {
      final response = await _client
          .from('categories')
          .select()
          .order('sort_order', ascending: true);

      return (response as List)
          .map((json) => CategoryModel.fromJson(json, locale: locale))
          .toList();
    } catch (e) {
      throw ServerException('فشل في جلب التصنيفات: ${e.toString()}');
    }
  }

  @override
  Future<CategoryModel> getCategoryById(String id,
      {String locale = 'ar'}) async {
    try {
      final response =
          await _client.from('categories').select().eq('id', id).single();

      return CategoryModel.fromJson(response, locale: locale);
    } catch (e) {
      throw ServerException('فشل في جلب التصنيف: ${e.toString()}');
    }
  }

  @override
  Future<Map<String, dynamic>> getCategoryRawById(String id) async {
    try {
      final response =
          await _client.from('categories').select().eq('id', id).single();
      return response;
    } catch (e) {
      throw ServerException('فشل في جلب التصنيف: ${e.toString()}');
    }
  }

  @override
  Future<void> createCategory(CategoryModel category,
      {String? nameAr, String? nameEn}) async {
    try {
      final json = <String, dynamic>{
        'name_ar': nameAr ?? category.name,
        'name_en': nameEn ?? category.name,
        'description': category.description,
        'is_active': category.isActive,
        'sort_order': category.sortOrder,
        'image_url': category.imageUrl,
      };

      AppLogger.i('═══════════════════════════════════════');
      AppLogger.i('💾 DATABASE INSERT - categories');
      AppLogger.i('═══════════════════════════════════════');
      AppLogger.d('Insert Data:', json);

      await _client.from('categories').insert(json);

      AppLogger.success('DATABASE INSERT SUCCESSFUL!');
      AppLogger.i('═══════════════════════════════════════');
    } catch (e, stackTrace) {
      AppLogger.e('❌ DATABASE INSERT FAILED!', e, stackTrace);
      throw ServerException('فشل في إنشاء التصنيف: ${e.toString()}');
    }
  }

  @override
  Future<void> updateCategory(CategoryModel category,
      {String? nameAr, String? nameEn}) async {
    try {
      final json = <String, dynamic>{};
      if (nameAr != null) json['name_ar'] = nameAr;
      if (nameEn != null) json['name_en'] = nameEn;
      if (category.description != null) {
        json['description'] = category.description;
      }
      json['is_active'] = category.isActive;
      json['image_url'] = category.imageUrl;

      AppLogger.i('═══════════════════════════════════════');
      AppLogger.i('💾 DATABASE UPDATE - categories');
      AppLogger.i('═══════════════════════════════════════');
      AppLogger.d('Category ID:', category.id);
      AppLogger.d('Update Data:', json);

      await _client.from('categories').update(json).eq('id', category.id);

      AppLogger.success('DATABASE UPDATE SUCCESSFUL!');
      AppLogger.i('═══════════════════════════════════════');
    } catch (e, stackTrace) {
      AppLogger.e('❌ DATABASE UPDATE FAILED!', e, stackTrace);
      throw ServerException('فشل في تحديث التصنيف: ${e.toString()}');
    }
  }

  @override
  Future<void> deleteCategory(String id) async {
    try {
      // Check if category has products first
      final productCount = await getProductCountByCategory(id);
      if (productCount > 0) {
        throw const ServerException('لا يمكن حذف تصنيف يحتوي على منتجات');
      }

      AppLogger.i('🗑️ DATABASE DELETE - categories (id: $id)');
      await _client.from('categories').delete().eq('id', id);
      AppLogger.success('DATABASE DELETE SUCCESSFUL!');
    } catch (e) {
      if (e is ServerException) rethrow;
      throw ServerException('فشل في حذف التصنيف: ${e.toString()}');
    }
  }

  @override
  Future<int> getProductCountByCategory(String categoryId) async {
    try {
      final response = await _client
          .from('products')
          .select()
          .eq('category_id', categoryId)
          .count();

      return response.count;
    } catch (e) {
      throw ServerException('فشل في حساب المنتجات: ${e.toString()}');
    }
  }
}
