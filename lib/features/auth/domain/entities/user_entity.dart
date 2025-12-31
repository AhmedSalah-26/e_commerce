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

/// Address model for user addresses
/// id format: "governorate_id:detailed_address"
class UserAddress {
  final String id; // governorate_id:detailed_address
  final String title;
  final bool isDefault;

  const UserAddress({
    required this.id,
    required this.title,
    this.isDefault = false,
  });

  /// Extract governorate ID from the id
  String? get governorateId {
    final parts = id.split(':');
    return parts.isNotEmpty ? parts[0] : null;
  }

  /// Extract detailed address from the id
  String get detailedAddress {
    final colonIndex = id.indexOf(':');
    return colonIndex != -1 ? id.substring(colonIndex + 1) : id;
  }

  /// Get full display address (without governorate ID prefix)
  String get displayAddress => detailedAddress;

  Map<String, dynamic> toJson() => {
        'id': id,
        'title': title,
        'is_default': isDefault,
      };

  factory UserAddress.fromJson(Map<String, dynamic> json) => UserAddress(
        id: json['id'] as String,
        title: json['title'] as String,
        isDefault: json['is_default'] as bool? ?? false,
      );

  UserAddress copyWith({
    String? id,
    String? title,
    bool? isDefault,
  }) =>
      UserAddress(
        id: id ?? this.id,
        title: title ?? this.title,
        isDefault: isDefault ?? this.isDefault,
      );

  /// Create address with governorate ID and detailed address
  factory UserAddress.create({
    required String governorateId,
    required String detailedAddress,
    required String title,
    bool isDefault = false,
  }) =>
      UserAddress(
        id: '$governorateId:$detailedAddress',
        title: title,
        isDefault: isDefault,
      );
}

/// User entity representing the domain model
class UserEntity extends Equatable {
  final String id;
  final String email;
  final UserRole role;
  final String? name;
  final String? phone;
  final String? avatarUrl;
  final DateTime? createdAt;
  final bool isActive;
  final DateTime? bannedUntil;
  final String? banReason;
  final List<UserAddress> addresses;

  const UserEntity({
    required this.id,
    required this.email,
    required this.role,
    this.name,
    this.phone,
    this.avatarUrl,
    this.createdAt,
    this.isActive = true,
    this.bannedUntil,
    this.banReason,
    this.addresses = const [],
  });

  /// Get default address
  UserAddress? get defaultAddress => addresses.isEmpty
      ? null
      : addresses.firstWhere(
          (a) => a.isDefault,
          orElse: () => addresses.first,
        );

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
        createdAt,
        isActive,
        bannedUntil,
        banReason,
        addresses,
      ];
}
