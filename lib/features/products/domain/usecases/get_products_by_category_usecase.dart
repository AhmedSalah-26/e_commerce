import 'package:dartz/dartz.dart';
import '../../../../core/errors/failures.dart';
import '../entities/product_entity.dart';
import '../repositories/product_repository.dart';

/// Use case for getting products by category
class GetProductsByCategoryUseCase {
  final ProductRepository _repository;

  GetProductsByCategoryUseCase(this._repository);

  Future<Either<Failure, List<ProductEntity>>> call(String categoryId) {
    return _repository.getProductsByCategory(categoryId);
  }
}
