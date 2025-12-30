import 'package:equatable/equatable.dart';

/// User roles in the system
enum UserRole {
  admin,
  merchant,
  customer;

  static UserRole fromString(String value) {
    return UserRole.values.firstWhere(
      (e) => e.name == value.toLowerCase(),
      orElse: () => UserRole.customer,
    );
  }
}

/// User entity representing the domain model
class UserEntity extends Equatable {
  final String id;
  final String email;
  final UserRole role;
  final String? name;
  final String? phone;
  final String? avatarUrl;
  final String? governorateId;
  final DateTime? createdAt;
  final bool isActive;
  final DateTime? bannedUntil;
  final String? banReason;

  const UserEntity({
    required this.id,
    required this.email,
    required this.role,
    this.name,
    this.phone,
    this.avatarUrl,
    this.governorateId,
    this.createdAt,
    this.isActive = true,
    this.bannedUntil,
    this.banReason,
  });

  bool get isMerchant => role == UserRole.merchant;
  bool get isCustomer => role == UserRole.customer;
  bool get isAdmin => role == UserRole.admin;

  /// Check if user is currently banned
  bool get isBanned {
    if (bannedUntil == null) return false;
    // If bannedUntil is far in the future (permanent ban)
    if (bannedUntil!.year > 2100) return true;
    // Check if ban is still active
    return DateTime.now().isBefore(bannedUntil!);
  }

  @override
  List<Object?> get props => [
        id,
        email,
        role,
        name,
        phone,
        avatarUrl,
        governorateId,
        createdAt,
        isActive,
        bannedUntil,
        banReason
      ];
}
