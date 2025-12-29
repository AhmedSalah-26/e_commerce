import 'package:dartz/dartz.dart';
import '../../../../core/errors/exceptions.dart';
import '../../../../core/errors/failures.dart';
import '../../domain/entities/category_entity.dart';
import '../../domain/repositories/category_repository.dart';
import '../datasources/category_remote_datasource.dart';
import '../models/category_model.dart';

/// Implementation of CategoryRepository
class CategoryRepositoryImpl implements CategoryRepository {
  final CategoryRemoteDataSource _remoteDataSource;
  String _locale = 'ar';

  CategoryRepositoryImpl(this._remoteDataSource);

  /// Set the current locale for fetching categories
  void setLocale(String locale) {
    _locale = locale;
  }

  @override
  Future<Either<Failure, List<CategoryEntity>>> getCategories() async {
    try {
      final categories = await _remoteDataSource.getCategories(locale: _locale);
      return Right(categories);
    } on ServerException catch (e) {
      return Left(ServerFailure(e.message, code: e.code));
    } catch (e) {
      return Left(ServerFailure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, List<CategoryEntity>>> getAllCategories() async {
    try {
      final categories =
          await _remoteDataSource.getAllCategories(locale: _locale);
      return Right(categories);
    } on ServerException catch (e) {
      return Left(ServerFailure(e.message, code: e.code));
    } catch (e) {
      return Left(ServerFailure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, CategoryEntity>> getCategoryById(String id) async {
    try {
      final category =
          await _remoteDataSource.getCategoryById(id, locale: _locale);
      return Right(category);
    } on ServerException catch (e) {
      return Left(ServerFailure(e.message, code: e.code));
    } catch (e) {
      return Left(ServerFailure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, Map<String, dynamic>>> getCategoryRawById(
      String id) async {
    try {
      final category = await _remoteDataSource.getCategoryRawById(id);
      return Right(category);
    } on ServerException catch (e) {
      return Left(ServerFailure(e.message, code: e.code));
    } catch (e) {
      return Left(ServerFailure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, void>> createCategory(CategoryEntity category,
      {String? nameAr, String? nameEn}) async {
    try {
      final categoryModel = CategoryModel(
        id: category.id,
        name: category.name,
        imageUrl: category.imageUrl,
        description: category.description,
        isActive: category.isActive,
        sortOrder: category.sortOrder,
      );
      await _remoteDataSource.createCategory(categoryModel,
          nameAr: nameAr, nameEn: nameEn);
      return const Right(null);
    } on ServerException catch (e) {
      return Left(ServerFailure(e.message, code: e.code));
    } catch (e) {
      return Left(ServerFailure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, void>> updateCategory(CategoryEntity category,
      {String? nameAr, String? nameEn}) async {
    try {
      final categoryModel = CategoryModel(
        id: category.id,
        name: category.name,
        imageUrl: category.imageUrl,
        description: category.description,
        isActive: category.isActive,
        sortOrder: category.sortOrder,
      );
      await _remoteDataSource.updateCategory(categoryModel,
          nameAr: nameAr, nameEn: nameEn);
      return const Right(null);
    } on ServerException catch (e) {
      return Left(ServerFailure(e.message, code: e.code));
    } catch (e) {
      return Left(ServerFailure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, void>> deleteCategory(String id) async {
    try {
      await _remoteDataSource.deleteCategory(id);
      return const Right(null);
    } on ServerException catch (e) {
      return Left(ServerFailure(e.message, code: e.code));
    } catch (e) {
      return Left(ServerFailure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, int>> getProductCountByCategory(
      String categoryId) async {
    try {
      final count =
          await _remoteDataSource.getProductCountByCategory(categoryId);
      return Right(count);
    } on ServerException catch (e) {
      return Left(ServerFailure(e.message, code: e.code));
    } catch (e) {
      return Left(ServerFailure(e.toString()));
    }
  }
}
