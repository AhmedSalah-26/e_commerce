import 'package:dartz/dartz.dart';
import '../../../../core/errors/failures.dart';
import '../entities/user_entity.dart';

/// Abstract repository interface for authentication
abstract class AuthRepository {
  /// Sign in with email and password
  Future<Either<Failure, UserEntity>> signIn(String email, String password);

  /// Sign up with email, password, role and profile data
  Future<Either<Failure, UserEntity>> signUp({
    required String email,
    required String password,
    required UserRole role,
    required String name,
    String? phone,
    String? avatarUrl,
    String? governorateId,
  });

  /// Sign out current user
  Future<Either<Failure, void>> signOut();

  /// Get current authenticated user
  Future<Either<Failure, UserEntity?>> getCurrentUser();

  /// Update user profile
  Future<Either<Failure, UserEntity>> updateProfile({
    required String userId,
    String? name,
    String? phone,
    String? avatarUrl,
    String? governorateId,
    List<UserAddress>? addresses,
  });

  /// Stream of auth state changes
  Stream<UserEntity?> get authStateChanges;
}
