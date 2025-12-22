import 'package:dartz/dartz.dart';

import '../../../../core/errors/failures.dart';
import '../../../products/domain/entities/product_entity.dart';
import '../../../products/domain/repositories/product_repository.dart';

class SearchService {
  final ProductRepository repository;
  static const int pageSize = 10;

  SearchService(this.repository);

  Future<Either<Failure, List<ProductEntity>>> searchProducts({
    required String query,
    required int page,
    String? categoryId,
    double? minPrice,
    double? maxPrice,
  }) async {
    if (query.isEmpty) {
      return const Right([]);
    }

    return await repository.searchProducts(
      query,
      page: page,
      limit: pageSize,
      categoryId: categoryId,
      minPrice: minPrice,
      maxPrice: maxPrice,
    );
  }
}
