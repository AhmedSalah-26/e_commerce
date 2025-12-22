import 'package:dartz/dartz.dart';
import '../../../../core/errors/failures.dart';
import '../entities/favorite_entity.dart';

abstract class FavoritesRepository {
  Future<Either<Failure, List<FavoriteEntity>>> getFavorites(String userId,
      {String? locale, int page, int limit});
  Future<Either<Failure, void>> addToFavorites(String userId, String productId);
  Future<Either<Failure, void>> removeFromFavorites(String favoriteId);
  Future<Either<Failure, bool>> isFavorite(String userId, String productId);
  void setLocale(String locale);
}
