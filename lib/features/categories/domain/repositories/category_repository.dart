import 'package:dartz/dartz.dart';
import '../../../../core/errors/failures.dart';
import '../entities/category_entity.dart';

/// Abstract repository interface for categories
abstract class CategoryRepository {
  /// Get all active categories
  Future<Either<Failure, List<CategoryEntity>>> getCategories();

  /// Get category by ID
  Future<Either<Failure, CategoryEntity>> getCategoryById(String id);

  /// Get category raw data by ID (for editing with bilingual support)
  Future<Either<Failure, Map<String, dynamic>>> getCategoryRawById(String id);

  /// Create a new category
  Future<Either<Failure, void>> createCategory(CategoryEntity category,
      {String? nameAr, String? nameEn});

  /// Update an existing category
  Future<Either<Failure, void>> updateCategory(CategoryEntity category,
      {String? nameAr, String? nameEn});

  /// Delete a category
  Future<Either<Failure, void>> deleteCategory(String id);

  /// Get product count by category
  Future<Either<Failure, int>> getProductCountByCategory(String categoryId);
}
