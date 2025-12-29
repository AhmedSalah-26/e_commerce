import 'package:flutter_bloc/flutter_bloc.dart';
import '../../domain/repositories/admin_repository.dart';
import 'admin_state.dart';

class AdminCubit extends Cubit<AdminState> {
  final AdminRepository _repository;

  AdminCubit(this._repository) : super(const AdminInitial());

  /// Load dashboard data
  Future<void> loadDashboard() async {
    emit(const AdminLoading());

    final statsResult = await _repository.getStats();

    await statsResult.fold(
      (failure) async => emit(AdminError(failure.message)),
      (stats) async {
        final ordersResult = await _repository.getRecentOrders();
        final productsResult = await _repository.getTopProducts();

        emit(AdminLoaded(
          stats: stats,
          recentOrders: ordersResult.fold((f) => [], (orders) => orders),
          topProducts: productsResult.fold((f) => [], (products) => products),
        ));
      },
    );
  }

  /// Load users
  Future<void> loadUsers({String? role, String? search}) async {
    emit(const AdminUsersLoading());

    final result = await _repository.getUsers(role: role, search: search);

    result.fold(
      (failure) => emit(AdminError(failure.message)),
      (users) => emit(AdminUsersLoaded(users, currentRole: role)),
    );
  }

  /// Toggle user status
  Future<bool> toggleUserStatus(String userId, bool isActive) async {
    final result = await _repository.toggleUserStatus(userId, isActive);
    return result.isRight();
  }

  /// Check if user is admin
  Future<bool> isAdmin(String userId) async {
    return await _repository.isAdmin(userId);
  }
}
