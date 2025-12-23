import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../../core/services/app_logger.dart';
import '../../../../core/services/image_upload_service.dart';
import '../../data/repositories/category_repository_impl.dart';
import '../../data/models/category_model.dart';
import '../../domain/repositories/category_repository.dart';
import 'categories_state.dart';

/// Cubit for managing categories state
class CategoriesCubit extends Cubit<CategoriesState> {
  final CategoryRepository _repository;
  final ImageUploadService _imageUploadService;
  bool _isLoading = false;

  CategoriesCubit(this._repository,
      {required ImageUploadService imageUploadService})
      : _imageUploadService = imageUploadService,
        super(const CategoriesInitial());

  /// Set the locale for fetching categories
  void setLocale(String locale) {
    if (_repository is CategoryRepositoryImpl) {
      _repository.setLocale(locale);
    }
  }

  /// Get category raw data for editing (with bilingual fields)
  Future<Map<String, dynamic>?> getCategoryRawData(String categoryId) async {
    try {
      final result = await _repository.getCategoryRawById(categoryId);
      return result.fold(
        (failure) => null,
        (data) => data,
      );
    } catch (e) {
      return null;
    }
  }

  /// Load all categories
  Future<void> loadCategories({bool forceReload = false}) async {
    // Prevent duplicate loading
    if (_isLoading) return;

    // Skip if already loaded and not forcing reload
    if (!forceReload && state is CategoriesLoaded) return;

    _isLoading = true;
    emit(const CategoriesLoading());

    final result = await _repository.getCategories();

    _isLoading = false;
    result.fold(
      (failure) => emit(CategoriesError(failure.message)),
      (categories) => emit(CategoriesLoaded(categories)),
    );
  }

  /// Create a new category
  Future<bool> createCategory(Map<String, dynamic> categoryData) async {
    try {
      AppLogger.i('═══════════════════════════════════════');
      AppLogger.i('🆕 CREATE CATEGORY STARTED');
      AppLogger.i('═══════════════════════════════════════');

      String? imageUrl;
      final newImage = categoryData['new_image'] as PickedImageData?;

      AppLogger.d('Input Data:', {
        'name_ar': categoryData['name_ar'],
        'name_en': categoryData['name_en'],
        'description': categoryData['description'],
        'is_active': categoryData['is_active'],
        'has_new_image': newImage != null,
        'image_size': newImage?.bytes.length ?? 0,
      });

      // Step 1: Upload image first if provided
      if (newImage != null) {
        AppLogger.step(1, 'Uploading image to storage...', {
          'file_name': newImage.name,
          'file_size': '${newImage.bytes.length} bytes',
        });

        imageUrl = await _imageUploadService.uploadCategoryImage(newImage);

        if (imageUrl == null) {
          AppLogger.e('❌ Image upload FAILED! Aborting category creation.');
          return false;
        }
        AppLogger.success('Image uploaded', {'url': imageUrl});
      } else {
        AppLogger.i('ℹ️ No image to upload, skipping Step 1');
      }

      // Step 2: Save category to database with image URL
      AppLogger.step(2, 'Saving category to database...', {
        'name_ar': categoryData['name_ar'],
        'name_en': categoryData['name_en'],
        'image_url': imageUrl,
      });

      final category = CategoryModel(
        id: '',
        name: categoryData['name_ar'] ?? '',
        description: categoryData['description'],
        imageUrl: imageUrl,
        isActive: categoryData['is_active'] ?? true,
        sortOrder: 0,
      );

      final result = await _repository.createCategory(
        category,
        nameAr: categoryData['name_ar'],
        nameEn: categoryData['name_en'],
      );

      return result.fold(
        (failure) {
          AppLogger.e('❌ Database insert FAILED', failure.message);
          emit(CategoriesError(failure.message));
          return false;
        },
        (_) {
          AppLogger.success('Category created successfully!');
          AppLogger.i('═══════════════════════════════════════');
          loadCategories();
          return true;
        },
      );
    } catch (e, stackTrace) {
      AppLogger.e('❌ Exception in createCategory', e, stackTrace);
      emit(CategoriesError(e.toString()));
      return false;
    }
  }

  /// Delete a category
  Future<bool> deleteCategory(String categoryId) async {
    try {
      AppLogger.i('🗑️ DELETE CATEGORY: $categoryId');

      final result = await _repository.deleteCategory(categoryId);

      return result.fold(
        (failure) {
          AppLogger.e('❌ Delete failed', failure.message);
          emit(CategoriesError(failure.message));
          return false;
        },
        (_) {
          AppLogger.success('Category deleted');
          loadCategories();
          return true;
        },
      );
    } catch (e, stackTrace) {
      AppLogger.e('❌ Exception in deleteCategory', e, stackTrace);
      emit(CategoriesError(e.toString()));
      return false;
    }
  }

  /// Update a category
  Future<bool> updateCategory(
      String categoryId, Map<String, dynamic> categoryData) async {
    try {
      AppLogger.i('═══════════════════════════════════════');
      AppLogger.i('✏️ UPDATE CATEGORY STARTED');
      AppLogger.i('═══════════════════════════════════════');

      String? imageUrl = categoryData['image_url'];
      final newImage = categoryData['new_image'] as PickedImageData?;

      AppLogger.d('Input Data:', {
        'category_id': categoryId,
        'name_ar': categoryData['name_ar'],
        'name_en': categoryData['name_en'],
        'description': categoryData['description'],
        'is_active': categoryData['is_active'],
        'existing_image_url': imageUrl,
        'has_new_image': newImage != null,
        'new_image_size': newImage?.bytes.length ?? 0,
      });

      // Step 1: Upload new image first if provided
      if (newImage != null) {
        AppLogger.step(1, 'Uploading NEW image to storage...', {
          'file_name': newImage.name,
          'file_size': '${newImage.bytes.length} bytes',
        });

        final uploadedUrl =
            await _imageUploadService.uploadCategoryImage(newImage);

        if (uploadedUrl == null) {
          AppLogger.e('❌ Image upload FAILED! Aborting category update.');
          return false;
        }
        imageUrl = uploadedUrl;
        AppLogger.success('New image uploaded', {'url': imageUrl});
      } else {
        AppLogger.i('ℹ️ No new image, keeping existing: $imageUrl');
      }

      // Step 2: Update category in database with image URL
      AppLogger.step(2, 'Updating category in database...', {
        'category_id': categoryId,
        'name_ar': categoryData['name_ar'],
        'name_en': categoryData['name_en'],
        'image_url': imageUrl,
      });

      final category = CategoryModel(
        id: categoryId,
        name: categoryData['name_ar'] ?? '',
        description: categoryData['description'],
        imageUrl: imageUrl,
        isActive: categoryData['is_active'] ?? true,
        sortOrder: 0,
      );

      final result = await _repository.updateCategory(
        category,
        nameAr: categoryData['name_ar'],
        nameEn: categoryData['name_en'],
      );

      return result.fold(
        (failure) {
          AppLogger.e('❌ Database update FAILED', failure.message);
          emit(CategoriesError(failure.message));
          return false;
        },
        (_) {
          AppLogger.success('Category updated successfully!');
          AppLogger.i('═══════════════════════════════════════');
          loadCategories();
          return true;
        },
      );
    } catch (e, stackTrace) {
      AppLogger.e('❌ Exception in updateCategory', e, stackTrace);
      emit(CategoriesError(e.toString()));
      return false;
    }
  }

  /// Refresh categories
  Future<void> refresh() async {
    await loadCategories(forceReload: true);
  }

  /// Reset state and force reload - used when language changes
  Future<void> reset() async {
    _isLoading = false;
    emit(const CategoriesInitial());
    await loadCategories(forceReload: true);
  }
}
