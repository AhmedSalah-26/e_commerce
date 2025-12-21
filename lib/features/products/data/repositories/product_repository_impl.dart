import 'package:dartz/dartz.dart';
import '../../../../core/errors/exceptions.dart';
import '../../../../core/errors/failures.dart';
import '../../domain/entities/product_entity.dart';
import '../../domain/repositories/product_repository.dart';
import '../datasources/product_remote_datasource.dart';
import '../models/product_model.dart';

/// Implementation of ProductRepository
class ProductRepositoryImpl implements ProductRepository {
  final ProductRemoteDataSource _remoteDataSource;
  String _locale = 'ar';

  ProductRepositoryImpl(this._remoteDataSource);

  /// Set the current locale for fetching products
  void setLocale(String locale) {
    _locale = locale;
  }

  @override
  Future<Either<Failure, List<ProductEntity>>> getProducts({
    int page = 0,
    int limit = 10,
  }) async {
    try {
      final products = await _remoteDataSource.getProducts(
        locale: _locale,
        page: page,
        limit: limit,
      );
      return Right(products);
    } on ServerException catch (e) {
      return Left(ServerFailure(e.message, code: e.code));
    } catch (e) {
      return Left(ServerFailure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, List<ProductEntity>>> getProductsByCategory(
    String categoryId, {
    int page = 0,
    int limit = 10,
  }) async {
    try {
      final products = await _remoteDataSource.getProductsByCategory(
        categoryId,
        locale: _locale,
        page: page,
        limit: limit,
      );
      return Right(products);
    } on ServerException catch (e) {
      return Left(ServerFailure(e.message, code: e.code));
    } catch (e) {
      return Left(ServerFailure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, List<ProductEntity>>> searchProducts(
    String query, {
    int page = 0,
    int limit = 10,
    String? categoryId,
    double? minPrice,
    double? maxPrice,
  }) async {
    try {
      final products = await _remoteDataSource.searchProducts(
        query,
        locale: _locale,
        page: page,
        limit: limit,
        categoryId: categoryId,
        minPrice: minPrice,
        maxPrice: maxPrice,
      );
      return Right(products);
    } on ServerException catch (e) {
      return Left(ServerFailure(e.message, code: e.code));
    } catch (e) {
      return Left(ServerFailure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, List<ProductEntity>>> getFeaturedProducts() async {
    try {
      final products =
          await _remoteDataSource.getFeaturedProducts(locale: _locale);
      return Right(products);
    } on ServerException catch (e) {
      return Left(ServerFailure(e.message, code: e.code));
    } catch (e) {
      return Left(ServerFailure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, ProductEntity>> getProductById(String id) async {
    try {
      final product =
          await _remoteDataSource.getProductById(id, locale: _locale);
      return Right(product);
    } on ServerException catch (e) {
      return Left(ServerFailure(e.message, code: e.code));
    } catch (e) {
      return Left(ServerFailure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, Map<String, dynamic>>> getProductRawById(
      String id) async {
    try {
      final product = await _remoteDataSource.getProductRawById(id);
      return Right(product);
    } on ServerException catch (e) {
      return Left(ServerFailure(e.message, code: e.code));
    } catch (e) {
      return Left(ServerFailure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, void>> createProduct(ProductEntity product,
      {String? merchantId}) async {
    try {
      final productModel = ProductModel(
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
      await _remoteDataSource.createProduct(productModel,
          merchantId: merchantId);
      return const Right(null);
    } on ServerException catch (e) {
      return Left(ServerFailure(e.message, code: e.code));
    } catch (e) {
      return Left(ServerFailure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, void>> updateProduct(ProductEntity product) async {
    try {
      final productModel = ProductModel(
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
      await _remoteDataSource.updateProduct(productModel);
      return const Right(null);
    } on ServerException catch (e) {
      return Left(ServerFailure(e.message, code: e.code));
    } catch (e) {
      return Left(ServerFailure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, void>> deleteProduct(String id) async {
    try {
      await _remoteDataSource.deleteProduct(id);
      return const Right(null);
    } on ServerException catch (e) {
      return Left(ServerFailure(e.message, code: e.code));
    } catch (e) {
      return Left(ServerFailure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, void>> updateProductData(
      String productId, Map<String, dynamic> data) async {
    try {
      await _remoteDataSource.updateProductData(productId, data);
      return const Right(null);
    } on ServerException catch (e) {
      return Left(ServerFailure(e.message, code: e.code));
    } catch (e) {
      return Left(ServerFailure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, void>> updateStock(
      String productId, int newStock) async {
    try {
      await _remoteDataSource.updateStock(productId, newStock);
      return const Right(null);
    } on ServerException catch (e) {
      return Left(ServerFailure(e.message, code: e.code));
    } catch (e) {
      return Left(ServerFailure(e.toString()));
    }
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
  }) async {
    try {
      final products = await _remoteDataSource.getProductsByMerchant(
        merchantId,
        locale: _locale,
        page: page,
        limit: limit,
      );
      return Right(products);
    } on ServerException catch (e) {
      return Left(ServerFailure(e.message, code: e.code));
    } catch (e) {
      return Left(ServerFailure(e.toString()));
    }
  }
}
