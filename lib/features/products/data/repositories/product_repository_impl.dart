import 'package:dartz/dartz.dart';
import '../../../../core/errors/failures.dart';
import '../../../../core/utils/repository_helper.dart';
import '../../domain/entities/product_entity.dart';
import '../../domain/repositories/product_repository.dart';
import '../datasources/product_remote_datasource.dart';
import '../models/product_model.dart';

/// Implementation of ProductRepository using RepositoryHelper
class ProductRepositoryImpl implements ProductRepository {
  final ProductRemoteDataSource _remoteDataSource;
  String _locale = 'ar';

  ProductRepositoryImpl(this._remoteDataSource);

  void setLocale(String locale) {
    _locale = locale;
  }

  @override
  Future<Either<Failure, List<ProductEntity>>> getProducts({
    int page = 0,
    int limit = 10,
  }) {
    return _remoteDataSource
        .getProducts(locale: _locale, page: page, limit: limit)
        .toEither();
  }

  @override
  Future<Either<Failure, List<ProductEntity>>> getProductsByCategory(
    String categoryId, {
    int page = 0,
    int limit = 10,
  }) {
    return _remoteDataSource
        .getProductsByCategory(categoryId,
            locale: _locale, page: page, limit: limit)
        .toEither();
  }

  @override
  Future<Either<Failure, List<ProductEntity>>> searchProducts(
    String query, {
    int page = 0,
    int limit = 10,
    String? categoryId,
    double? minPrice,
    double? maxPrice,
  }) {
    return _remoteDataSource
        .searchProducts(query,
            locale: _locale,
            page: page,
            limit: limit,
            categoryId: categoryId,
            minPrice: minPrice,
            maxPrice: maxPrice)
        .toEither();
  }

  @override
  Future<Either<Failure, List<ProductEntity>>> getFeaturedProducts() {
    return _remoteDataSource.getFeaturedProducts(locale: _locale).toEither();
  }

  @override
  Future<Either<Failure, ProductEntity>> getProductById(String id) {
    return _remoteDataSource.getProductById(id, locale: _locale).toEither();
  }

  @override
  Future<Either<Failure, Map<String, dynamic>>> getProductRawById(String id) {
    return _remoteDataSource.getProductRawById(id).toEither();
  }

  @override
  Future<Either<Failure, void>> createProduct(ProductEntity product,
      {String? merchantId}) {
    final productModel = _toModel(product);
    return _remoteDataSource
        .createProduct(productModel, merchantId: merchantId)
        .toEitherVoid();
  }

  @override
  Future<Either<Failure, void>> updateProduct(ProductEntity product) {
    final productModel = _toModel(product);
    return _remoteDataSource.updateProduct(productModel).toEitherVoid();
  }

  @override
  Future<Either<Failure, void>> deleteProduct(String id) {
    return _remoteDataSource.deleteProduct(id).toEitherVoid();
  }

  @override
  Future<Either<Failure, void>> updateProductData(
      String productId, Map<String, dynamic> data) {
    return _remoteDataSource.updateProductData(productId, data).toEitherVoid();
  }

  @override
  Future<Either<Failure, void>> updateStock(String productId, int newStock) {
    return _remoteDataSource.updateStock(productId, newStock).toEitherVoid();
  }

  @override
  Stream<List<ProductEntity>> watchProducts() {
    return _remoteDataSource.watchProducts(locale: _locale);
  }

  @override
  Future<Either<Failure, List<ProductEntity>>> getProductsByMerchant(
    String merchantId, {
    int page = 0,
    int limit = 100,
  }) {
    return _remoteDataSource
        .getProductsByMerchant(merchantId,
            locale: _locale, page: page, limit: limit)
        .toEither();
  }

  @override
  Future<Either<Failure, List<ProductEntity>>> getDiscountedProducts({
    int page = 0,
    int limit = 10,
  }) {
    return _remoteDataSource
        .getDiscountedProducts(locale: _locale, page: page, limit: limit)
        .toEither();
  }

  @override
  Future<Either<Failure, List<ProductEntity>>> getNewestProducts({
    int limit = 10,
  }) {
    return _remoteDataSource
        .getNewestProducts(locale: _locale, limit: limit)
        .toEither();
  }

  /// Convert entity to model
  ProductModel _toModel(ProductEntity product) {
    return ProductModel(
      id: product.id,
      name: product.name,
      description: product.description,
      price: product.price,
      discountPrice: product.discountPrice,
      images: product.images,
      categoryId: product.categoryId,
      stock: product.stock,
      rating: product.rating,
      ratingCount: product.ratingCount,
      isActive: product.isActive,
      isFeatured: product.isFeatured,
    );
  }
}
