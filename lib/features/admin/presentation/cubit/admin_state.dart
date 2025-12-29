import 'package:equatable/equatable.dart';
import '../../../orders/domain/entities/order_entity.dart';
import '../../../products/domain/entities/product_entity.dart';
import '../../domain/entities/admin_stats_entity.dart';

abstract class AdminState extends Equatable {
  const AdminState();
  @override
  List<Object?> get props => [];
}

class AdminInitial extends AdminState {
  const AdminInitial();
}

class AdminLoading extends AdminState {
  const AdminLoading();
}

class AdminLoaded extends AdminState {
  final AdminStatsEntity stats;
  final List<OrderEntity> recentOrders;
  final List<ProductEntity> topProducts;

  const AdminLoaded({
    required this.stats,
    this.recentOrders = const [],
    this.topProducts = const [],
  });

  @override
  List<Object?> get props => [stats, recentOrders, topProducts];
}

class AdminError extends AdminState {
  final String message;
  const AdminError(this.message);
  @override
  List<Object?> get props => [message];
}

// Users states
class AdminUsersLoading extends AdminState {
  const AdminUsersLoading();
}

class AdminUsersLoaded extends AdminState {
  final List<Map<String, dynamic>> users;
  final String? currentRole;

  const AdminUsersLoaded(this.users, {this.currentRole});

  @override
  List<Object?> get props => [users, currentRole];
}
