import 'package:dartz/dartz.dart';
import '../errors/exceptions.dart';
import '../errors/failures.dart';

/// Extension to convert Future to Either for repository pattern
/// Reduces boilerplate try-catch in repository implementations
extension RepositoryHelper<T> on Future<T> {
  /// Converts a Future to Either<Failure, T>
  /// Handles ServerException and general exceptions
  Future<Either<Failure, T>> toEither() async {
    try {
      return Right(await this);
    } on ServerException catch (e) {
      return Left(ServerFailure(e.message, code: e.code));
    } on AuthException catch (e) {
      return Left(AuthFailure(e.message, code: e.code));
    } on CacheException catch (e) {
      return Left(CacheFailure(e.message, code: e.code));
    } catch (e) {
      return Left(ServerFailure(e.toString()));
    }
  }

  /// Converts a Future to Either with custom failure mapper
  Future<Either<Failure, T>> toEitherWith(
    Failure Function(Object error) onError,
  ) async {
    try {
      return Right(await this);
    } catch (e) {
      return Left(onError(e));
    }
  }
}

/// Extension for void futures
extension VoidRepositoryHelper on Future<void> {
  /// Converts a void Future to Either<Failure, void>
  Future<Either<Failure, void>> toEitherVoid() async {
    try {
      await this;
      return const Right(null);
    } on ServerException catch (e) {
      return Left(ServerFailure(e.message, code: e.code));
    } on AuthException catch (e) {
      return Left(AuthFailure(e.message, code: e.code));
    } on CacheException catch (e) {
      return Left(CacheFailure(e.message, code: e.code));
    } catch (e) {
      return Left(ServerFailure(e.toString()));
    }
  }
}
