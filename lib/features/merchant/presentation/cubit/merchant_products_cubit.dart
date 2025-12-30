import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:equatable/equatable.dart';
import '../../../../core/services/app_logger.dart';
import '../../../../core/services/image_upload_service.dart';
import '../../../products/domain/entities/product_entity.dart';
import '../../../products/domain/repositories/product_repository.dart';
import '../../../products/data/models/product_model.dart';

// States
abstract class MerchantProductsState extends Equatable {
  const MerchantProductsState();

  @override
  List<Object?> get props => [];
}

class MerchantProductsInitial extends MerchantProductsState {}

class MerchantProductsLoading extends MerchantProductsState {}

class MerchantProductsLoaded extends MerchantProductsState {
  final List<ProductEntity> products;

  const MerchantProductsLoaded(this.products);

  @override
  List<Object?> get props => [products];
}

class MerchantProductsError extends MerchantProductsState {
  final String message;

  const MerchantProductsError(this.message);

  @override
  List<Object?> get props => [message];
}

class MerchantProductCreating extends MerchantProductsState {}

class MerchantProductCreated extends MerchantProductsState {}

class MerchantProductDeleting extends MerchantProductsState {}

class MerchantProductDeleted extends MerchantProductsState {}

// Cubit
class MerchantProductsCubit extends Cubit<MerchantProductsState> {
  final ProductRepository _productRepository;
  final ImageUploadService _imageUploadService;
  String? _currentMerchantId;

  MerchantProductsCubit(this._productRepository,
      {required ImageUploadService imageUploadService})
      : _imageUploadService = imageUploadService,
        super(MerchantProductsInitial());

  /// Get product raw data for editing (with bilingual fields)
  Future<Map<String, dynamic>?> getProductRawData(String productId) async {
    try {
      final result = await _productRepository.getProductRawById(productId);
      return result.fold(
        (failure) => null,
        (data) => data,
      );
    } catch (e) {
      return null;
    }
  }

  Future<void> loadMerchantProducts(String merchantId) async {
    _currentMerchantId = merchantId;
    emit(MerchantProductsLoading());
    try {
      final result = await _productRepository.getProductsByMerchant(merchantId);
      result.fold(
        (failure) => emit(MerchantProductsError(failure.message)),
        (products) => emit(MerchantProductsLoaded(products)),
      );
    } catch (e) {
      emit(MerchantProductsError(e.toString()));
    }
  }

  Future<bool> createProduct(
      Map<String, dynamic> productData, String merchantId) async {
    try {
      AppLogger.i('═══════════════════════════════════════');
      AppLogger.i('🆕 CREATE PRODUCT STARTED');
      AppLogger.i('═══════════════════════════════════════');

      // Upload new images first
      List<String> imageUrls = List<String>.from(productData['images'] ?? []);
      final newImages = productData['new_images'] as List<PickedImageData>?;

      AppLogger.d('Input Data:', {
        'name_ar': productData['name_ar'],
        'name_en': productData['name_en'],
        'price': productData['price'],
        'category_id': productData['category_id'],
        'existing_images': imageUrls.length,
        'new_images': newImages?.length ?? 0,
      });

      // Step 1: Upload images
      if (newImages != null && newImages.isNotEmpty) {
        AppLogger.step(1, 'Uploading ${newImages.length} images...');

        for (int i = 0; i < newImages.length; i++) {
          final imageData = newImages[i];
          AppLogger.d('Uploading image ${i + 1}/${newImages.length}', {
            'name': imageData.name,
            'size': '${imageData.bytes.length} bytes'
          });

          final url = await _imageUploadService.uploadProductImage(imageData);
          if (url != null) {
            AppLogger.success('Image ${i + 1} uploaded', {'url': url});
            imageUrls.add(url);
          } else {
            AppLogger.e('❌ Failed to upload image ${i + 1}');
            return false;
          }
        }
        AppLogger.success('All images uploaded', {'total': imageUrls.length});
      } else {
        AppLogger.i('ℹ️ No new images to upload');
      }

      // Step 2: Save product to database
      AppLogger.step(2, 'Saving product to database...', {
        'name_ar': productData['name_ar'],
        'images': imageUrls,
      });

      final product = ProductModel(
        id: '',
        name: productData['name_ar'] ?? '',
        description: productData['description_ar'] ?? '',
        price: productData['price'] ?? 0.0,
        discountPrice: productData['discount_price'],
        images: imageUrls,
        categoryId: productData['category_id'],
        stock: productData['stock'] ?? 0,
        rating: 0.0,
        ratingCount: 0,
        isActive: productData['is_active'] ?? true,
        isFeatured: productData['is_featured'] ?? false,
        isFlashSale: productData['is_flash_sale'] ?? false,
        flashSaleStart: productData['flash_sale_start'] != null
            ? DateTime.parse(productData['flash_sale_start'])
            : null,
        flashSaleEnd: productData['flash_sale_end'] != null
            ? DateTime.parse(productData['flash_sale_end'])
            : null,
      );

      final result = await _productRepository.createProduct(product,
          merchantId: merchantId);

      return result.fold(
        (failure) {
          AppLogger.e('❌ Database insert FAILED', failure.message);
          emit(MerchantProductsError(failure.message));
          return false;
        },
        (_) {
          AppLogger.success('Product created successfully!');
          AppLogger.i('═══════════════════════════════════════');
          if (_currentMerchantId != null) {
            loadMerchantProducts(_currentMerchantId!);
          }
          return true;
        },
      );
    } catch (e, stackTrace) {
      AppLogger.e('❌ Exception in createProduct', e, stackTrace);
      emit(MerchantProductsError(e.toString()));
      return false;
    }
  }

  Future<bool> deleteProduct(String productId) async {
    try {
      AppLogger.i('🗑️ DELETE PRODUCT: $productId');

      // Get product images before deletion to clean up storage
      List<String> imagesToDelete = [];
      if (state is MerchantProductsLoaded) {
        final product = (state as MerchantProductsLoaded)
            .products
            .where((p) => p.id == productId)
            .firstOrNull;
        if (product != null) {
          imagesToDelete = product.images;
        }
      }

      final result = await _productRepository.deleteProduct(productId);

      return result.fold(
        (failure) {
          AppLogger.e('❌ Delete failed', failure.message);
          emit(MerchantProductsError(failure.message));
          return false;
        },
        (_) async {
          AppLogger.success('Product deleted');

          // Delete product images from storage
          if (imagesToDelete.isNotEmpty) {
            AppLogger.i(
                '🗑️ Deleting ${imagesToDelete.length} product images from storage');
            await _imageUploadService.deleteImages(imagesToDelete, 'products');
          }

          if (state is MerchantProductsLoaded) {
            final currentProducts = (state as MerchantProductsLoaded).products;
            final updatedProducts =
                currentProducts.where((p) => p.id != productId).toList();
            emit(MerchantProductsLoaded(updatedProducts));
          }
          return true;
        },
      );
    } catch (e, stackTrace) {
      AppLogger.e('❌ Exception in deleteProduct', e, stackTrace);
      emit(MerchantProductsError(e.toString()));
      return false;
    }
  }

  Future<bool> updateProduct(
      String productId, Map<String, dynamic> productData) async {
    try {
      AppLogger.i('═══════════════════════════════════════');
      AppLogger.i('✏️ UPDATE PRODUCT STARTED');
      AppLogger.i('═══════════════════════════════════════');

      // Get existing images and new images
      List<String> imageUrls = List<String>.from(productData['images'] ?? []);
      final newImages = productData['new_images'] as List<PickedImageData>?;
      final originalImages =
          List<String>.from(productData['original_images'] ?? []);

      AppLogger.d('Input Data:', {
        'product_id': productId,
        'name_ar': productData['name_ar'],
        'name_en': productData['name_en'],
        'price': productData['price'],
        'category_id': productData['category_id'],
        'existing_images': imageUrls.length,
        'original_images': originalImages.length,
        'new_images': newImages?.length ?? 0,
      });

      // Step 0: Delete removed images from storage
      if (originalImages.isNotEmpty) {
        await _imageUploadService.deleteRemovedProductImages(
            originalImages, imageUrls);
      }

      // Step 1: Upload new images if any
      if (newImages != null && newImages.isNotEmpty) {
        AppLogger.step(1, 'Uploading ${newImages.length} new images...');

        for (int i = 0; i < newImages.length; i++) {
          final imageData = newImages[i];
          AppLogger.d('Uploading image ${i + 1}/${newImages.length}', {
            'name': imageData.name,
            'size': '${imageData.bytes.length} bytes'
          });

          final url = await _imageUploadService.uploadProductImage(imageData);
          if (url != null) {
            AppLogger.success('Image ${i + 1} uploaded', {'url': url});
            imageUrls.add(url);
          } else {
            AppLogger.e('❌ Failed to upload image ${i + 1}');
            return false;
          }
        }
        AppLogger.success(
            'All new images uploaded', {'total_images': imageUrls.length});
      } else {
        AppLogger.i(
            'ℹ️ No new images to upload, keeping existing: ${imageUrls.length}');
      }

      // Step 2: Update product in database
      AppLogger.step(2, 'Updating product in database...', {
        'product_id': productId,
        'name_ar': productData['name_ar'],
        'name_en': productData['name_en'],
        'images': imageUrls,
      });

      // Build update data with bilingual support
      final updateData = {
        'name_ar': productData['name_ar'] ?? '',
        'name_en': productData['name_en'] ?? productData['name_ar'] ?? '',
        'description_ar': productData['description_ar'] ?? '',
        'description_en': productData['description_en'] ??
            productData['description_ar'] ??
            '',
        'price': productData['price'] ?? 0.0,
        'discount_price': productData['discount_price'],
        'images': imageUrls,
        'category_id': productData['category_id'],
        'stock': productData['stock'] ?? 0,
        'is_active': productData['is_active'] ?? true,
        'is_featured': productData['is_featured'] ?? false,
        'is_flash_sale': productData['is_flash_sale'] ?? false,
        'flash_sale_start': productData['flash_sale_start'],
        'flash_sale_end': productData['flash_sale_end'],
      };

      final result =
          await _productRepository.updateProductData(productId, updateData);

      return result.fold(
        (failure) {
          AppLogger.e('❌ Database update FAILED', failure.message);
          emit(MerchantProductsError(failure.message));
          return false;
        },
        (_) {
          AppLogger.success('Product updated successfully!');
          AppLogger.i('═══════════════════════════════════════');
          if (_currentMerchantId != null) {
            loadMerchantProducts(_currentMerchantId!);
          }
          return true;
        },
      );
    } catch (e, stackTrace) {
      AppLogger.e('❌ Exception in updateProduct', e, stackTrace);
      emit(MerchantProductsError(e.toString()));
      return false;
    }
  }

  /// Toggle product active status
  Future<bool> toggleProductActive(String productId, bool isActive) async {
    try {
      AppLogger.i('🔄 TOGGLE PRODUCT ACTIVE: $productId -> $isActive');

      final result = await _productRepository.updateProductData(
        productId,
        {'is_active': isActive},
      );

      return result.fold(
        (failure) {
          AppLogger.e('❌ Toggle active failed', failure.message);
          emit(MerchantProductsError(failure.message));
          return false;
        },
        (_) {
          AppLogger.success('Product active status updated');
          if (_currentMerchantId != null) {
            loadMerchantProducts(_currentMerchantId!);
          }
          return true;
        },
      );
    } catch (e, stackTrace) {
      AppLogger.e('❌ Exception in toggleProductActive', e, stackTrace);
      emit(MerchantProductsError(e.toString()));
      return false;
    }
  }
}
