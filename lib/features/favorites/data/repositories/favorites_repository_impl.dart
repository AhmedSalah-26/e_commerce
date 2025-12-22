import 'package:dartz/dartz.dart';
import '../../../../core/errors/failures.dart';
import '../../domain/entities/favorite_entity.dart';
import '../../domain/repositories/favorites_repository.dart';
import '../datasources/favorites_remote_datasource.dart';

class FavoritesRepositoryImpl implements FavoritesRepository {
  final FavoritesRemoteDataSource _remoteDataSource;

  FavoritesRepositoryImpl(this._remoteDataSource);

  @override
  void setLocale(String locale) {
    if (_remoteDataSource is FavoritesRemoteDataSourceImpl) {
      (_remoteDataSource).setLocale(locale);
    }
  }

  @override
  Future<Either<Failure, List<FavoriteEntity>>> getFavorites(String userId,
      {String? locale, int page = 0, int limit = 10}) async {
    try {
      final favorites = await _remoteDataSource.getFavorites(userId,
          locale: locale, page: page, limit: limit);
      return Right(favorites);
    } catch (e) {
      return Left(ServerFailure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, void>> addToFavorites(
      String userId, String productId) async {
    try {
      await _remoteDataSource.addToFavorites(userId, productId);
      return const Right(null);
    } catch (e) {
      return Left(ServerFailure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, void>> removeFromFavorites(String favoriteId) async {
    try {
      await _remoteDataSource.removeFromFavorites(favoriteId);
      return const Right(null);
    } catch (e) {
      return Left(ServerFailure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, bool>> isFavorite(
      String userId, String productId) async {
    try {
      final result = await _remoteDataSource.isFavorite(userId, productId);
      return Right(result);
    } catch (e) {
      return Left(ServerFailure(e.toString()));
    }
  }
}
