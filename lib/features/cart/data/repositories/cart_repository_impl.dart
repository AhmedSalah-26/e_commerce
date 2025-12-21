import 'package:dartz/dartz.dart';
import '../../../../core/errors/exceptions.dart';
import '../../../../core/errors/failures.dart';
import '../../domain/entities/cart_item_entity.dart';
import '../../domain/repositories/cart_repository.dart';
import '../datasources/cart_remote_datasource.dart';

/// Implementation of CartRepository
class CartRepositoryImpl implements CartRepository {
  final CartRemoteDataSource _remoteDataSource;
  String _locale = 'ar';

  CartRepositoryImpl(this._remoteDataSource);

  /// Set the current locale for fetching cart items
  void setLocale(String locale) {
    _locale = locale;
  }

  @override
  Future<Either<Failure, List<CartItemEntity>>> getCartItems(
      String userId) async {
    try {
      final items =
          await _remoteDataSource.getCartItems(userId, locale: _locale);
      return Right(items);
    } on ServerException catch (e) {
      return Left(ServerFailure(e.message, code: e.code));
    } catch (e) {
      return Left(ServerFailure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, void>> addToCart(
      String userId, String productId, int quantity) async {
    try {
      await _remoteDataSource.addToCart(userId, productId, quantity);
      return const Right(null);
    } on ServerException catch (e) {
      return Left(ServerFailure(e.message, code: e.code));
    } catch (e) {
      return Left(ServerFailure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, void>> updateQuantity(
      String cartItemId, int quantity) async {
    try {
      await _remoteDataSource.updateQuantity(cartItemId, quantity);
      return const Right(null);
    } on ServerException catch (e) {
      return Left(ServerFailure(e.message, code: e.code));
    } catch (e) {
      return Left(ServerFailure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, void>> removeFromCart(String cartItemId) async {
    try {
      await _remoteDataSource.removeFromCart(cartItemId);
      return const Right(null);
    } on ServerException catch (e) {
      return Left(ServerFailure(e.message, code: e.code));
    } catch (e) {
      return Left(ServerFailure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, void>> clearCart(String userId) async {
    try {
      await _remoteDataSource.clearCart(userId);
      return const Right(null);
    } on ServerException catch (e) {
      return Left(ServerFailure(e.message, code: e.code));
    } catch (e) {
      return Left(ServerFailure(e.toString()));
    }
  }

  @override
  Stream<List<CartItemEntity>> watchCartItems(String userId) {
    return _remoteDataSource.watchCartItems(userId, locale: _locale);
  }
}
