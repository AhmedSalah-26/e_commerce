import 'package:dartz/dartz.dart';
import '../../../../core/errors/failures.dart';
import '../entities/product_entity.dart';
import '../enums/sort_option.dart';

/// Abstract repository interface for products
abstract class ProductRepository {
  /// Get all active products with pagination
  Future<Either<Failure, List<ProductEntity>>> getProducts({
    int page = 0,
    int limit = 10,
  });

  /// Get products by category with pagination
  Future<Either<Failure, List<ProductEntity>>> getProductsByCategory(
    String categoryId, {
    int page = 0,
    int limit = 10,
  });

  /// Search products with pagination and filters
  Future<Either<Failure, List<ProductEntity>>> searchProducts(
    String query, {
    int page = 0,
    int limit = 10,
    String? categoryId,
    double? minPrice,
    double? maxPrice,
    SortOption? sortOption,
  });

  /// Get featured products
  Future<Either<Failure, List<ProductEntity>>> getFeaturedProducts();

  /// Get product by ID
  Future<Either<Failure, ProductEntity>> getProductById(String id);

  /// Get product raw data by ID (for editing with bilingual support)
  Future<Either<Failure, Map<String, dynamic>>> getProductRawById(String id);

  /// Create a new product
  Future<Either<Failure, void>> createProduct(ProductEntity product,
      {String? merchantId});

  /// Update an existing product
  Future<Either<Failure, void>> updateProduct(ProductEntity product);

  /// Delete a product
  Future<Either<Failure, void>> deleteProduct(String id);

  /// Update product with raw data (for bilingual support)
  Future<Either<Failure, void>> updateProductData(
      String productId, Map<String, dynamic> data);

  /// Update product stock
  Future<Either<Failure, void>> updateStock(String productId, int newStock);

  /// Watch products stream
  Stream<List<ProductEntity>> watchProducts();

  /// Get products by merchant ID
  Future<Either<Failure, List<ProductEntity>>> getProductsByMerchant(
    String merchantId, {
    int page = 0,
    int limit = 100,
  });

  /// Get products with highest discount
  Future<Either<Failure, List<ProductEntity>>> getDiscountedProducts({
    int page = 0,
    int limit = 10,
  });

  /// Get newest products
  Future<Either<Failure, List<ProductEntity>>> getNewestProducts({
    int limit = 10,
  });

  /// Get best selling products
  Future<Either<Failure, List<ProductEntity>>> getBestSellingProducts({
    int page = 0,
    int limit = 10,
  });

  /// Get top rated products
  Future<Either<Failure, List<ProductEntity>>> getTopRatedProducts({
    int page = 0,
    int limit = 10,
  });

  /// Get flash sale products (is_flash_sale = true and active)
  Future<Either<Failure, List<ProductEntity>>> getFlashSaleProducts({
    int limit = 10,
  });
}
