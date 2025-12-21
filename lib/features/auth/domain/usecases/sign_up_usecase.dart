import 'package:dartz/dartz.dart';
import '../../../../core/errors/failures.dart';
import '../entities/user_entity.dart';
import '../repositories/auth_repository.dart';

/// Use case for signing up a new user
class SignUpUseCase {
  final AuthRepository _repository;

  SignUpUseCase(this._repository);

  Future<Either<Failure, UserEntity>> call({
    required String email,
    required String password,
    required UserRole role,
    required String name,
    String? phone,
  }) {
    return _repository.signUp(
      email: email,
      password: password,
      role: role,
      name: name,
      phone: phone,
    );
  }
}
