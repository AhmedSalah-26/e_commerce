import 'dart:async';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../domain/entities/user_entity.dart';
import '../../domain/repositories/auth_repository.dart';
import '../../domain/usecases/get_current_user_usecase.dart';
import '../../domain/usecases/sign_in_usecase.dart';
import '../../domain/usecases/sign_out_usecase.dart';
import '../../domain/usecases/sign_up_usecase.dart';
import 'auth_state.dart';

/// Cubit for managing authentication state
class AuthCubit extends Cubit<AuthState> {
  final SignInUseCase _signInUseCase;
  final SignUpUseCase _signUpUseCase;
  final SignOutUseCase _signOutUseCase;
  final GetCurrentUserUseCase _getCurrentUserUseCase;
  final AuthRepository _repository;

  AuthCubit({
    required SignInUseCase signInUseCase,
    required SignUpUseCase signUpUseCase,
    required SignOutUseCase signOutUseCase,
    required GetCurrentUserUseCase getCurrentUserUseCase,
    required AuthRepository repository,
  })  : _signInUseCase = signInUseCase,
        _signUpUseCase = signUpUseCase,
        _signOutUseCase = signOutUseCase,
        _getCurrentUserUseCase = getCurrentUserUseCase,
        _repository = repository,
        super(const AuthInitial());

  /// Check if user is already authenticated
  Future<void> checkAuthStatus() async {
    emit(const AuthLoading());

    final result = await _getCurrentUserUseCase();

    result.fold(
      (failure) => emit(const AuthUnauthenticated()),
      (user) {
        if (user != null) {
          emit(AuthAuthenticated(user));
        } else {
          emit(const AuthUnauthenticated());
        }
      },
    );
  }

  /// Sign in with email and password
  Future<void> signIn(String email, String password) async {
    emit(const AuthLoading());

    final result = await _signInUseCase(email, password);

    result.fold(
      (failure) => emit(AuthError(failure.message)),
      (user) => emit(AuthAuthenticated(user)),
    );
  }

  /// Sign up with email, password, role and profile data
  Future<void> signUp({
    required String email,
    required String password,
    required UserRole role,
    required String name,
    String? phone,
    String? avatarUrl,
  }) async {
    emit(const AuthLoading());

    final result = await _signUpUseCase(
      email: email,
      password: password,
      role: role,
      name: name,
      phone: phone,
      avatarUrl: avatarUrl,
    );

    result.fold(
      (failure) => emit(AuthError(failure.message)),
      (user) => emit(AuthAuthenticated(user)),
    );
  }

  /// Sign out current user
  Future<void> signOut() async {
    emit(const AuthLoading());

    final result = await _signOutUseCase();

    result.fold(
      (failure) => emit(AuthError(failure.message)),
      (_) => emit(const AuthUnauthenticated()),
    );
  }

  /// Get current user if authenticated
  UserEntity? get currentUser {
    final currentState = state;
    if (currentState is AuthAuthenticated) {
      return currentState.user;
    }
    return null;
  }

  /// Check if current user is merchant
  bool get isMerchant => currentUser?.isMerchant ?? false;

  /// Check if current user is customer
  bool get isCustomer => currentUser?.isCustomer ?? false;

  /// Update user profile
  Future<bool> updateProfile({
    String? name,
    String? phone,
    String? avatarUrl,
    List<UserAddress>? addresses,
  }) async {
    final user = currentUser;
    if (user == null) return false;

    final result = await _repository.updateProfile(
      userId: user.id,
      name: name,
      phone: phone,
      avatarUrl: avatarUrl,
      addresses: addresses,
    );

    return result.fold(
      (failure) => false,
      (updatedUser) {
        emit(AuthAuthenticated(updatedUser));
        return true;
      },
    );
  }

  /// Add new address
  Future<bool> addAddress(UserAddress address) async {
    final user = currentUser;
    if (user == null) return false;

    final newAddresses = List<UserAddress>.from(user.addresses);

    // If this is the first address or marked as default, set it as default
    if (newAddresses.isEmpty || address.isDefault) {
      // Remove default from other addresses
      for (int i = 0; i < newAddresses.length; i++) {
        if (newAddresses[i].isDefault) {
          newAddresses[i] = newAddresses[i].copyWith(isDefault: false);
        }
      }
      newAddresses.add(address.copyWith(isDefault: true));
    } else {
      newAddresses.add(address);
    }

    return updateProfile(addresses: newAddresses);
  }

  /// Update existing address
  Future<bool> updateAddress(UserAddress address) async {
    final user = currentUser;
    if (user == null) return false;

    final newAddresses = List<UserAddress>.from(user.addresses);
    final index = newAddresses.indexWhere((a) => a.id == address.id);
    if (index == -1) return false;

    // If setting as default, remove default from others
    if (address.isDefault) {
      for (int i = 0; i < newAddresses.length; i++) {
        if (newAddresses[i].isDefault && newAddresses[i].id != address.id) {
          newAddresses[i] = newAddresses[i].copyWith(isDefault: false);
        }
      }
    }

    newAddresses[index] = address;
    return updateProfile(addresses: newAddresses);
  }

  /// Delete address
  Future<bool> deleteAddress(String addressId) async {
    final user = currentUser;
    if (user == null) return false;

    final newAddresses =
        user.addresses.where((a) => a.id != addressId).toList();

    // If deleted address was default, set first one as default
    if (newAddresses.isNotEmpty && !newAddresses.any((a) => a.isDefault)) {
      newAddresses[0] = newAddresses[0].copyWith(isDefault: true);
    }

    return updateProfile(addresses: newAddresses);
  }

  /// Set address as default
  Future<bool> setDefaultAddress(String addressId) async {
    final user = currentUser;
    if (user == null) return false;

    final newAddresses = user.addresses.map((a) {
      return a.copyWith(isDefault: a.id == addressId);
    }).toList();

    return updateProfile(addresses: newAddresses);
  }
}
