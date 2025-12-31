import '../../domain/entities/user_entity.dart';

/// User model for data layer operations
class UserModel extends UserEntity {
  const UserModel({
    required super.id,
    required super.email,
    required super.role,
    super.name,
    super.phone,
    super.avatarUrl,
    super.createdAt,
    super.isActive,
    super.bannedUntil,
    super.banReason,
    super.addresses,
  });

  /// Create UserModel from JSON (Supabase response)
  factory UserModel.fromJson(Map<String, dynamic> json) {
    List<UserAddress> addresses = [];
    if (json['addresses'] != null) {
      final addressList = json['addresses'];
      if (addressList is List) {
        addresses = addressList
            .map((a) => UserAddress.fromJson(a as Map<String, dynamic>))
            .toList();
      }
    }

    return UserModel(
      id: json['id'] as String,
      email: json['email'] as String,
      role: UserRole.fromString(json['role'] as String? ?? 'customer'),
      name: json['name'] as String?,
      phone: json['phone'] as String?,
      avatarUrl: json['avatar_url'] as String?,
      createdAt: json['created_at'] != null
          ? DateTime.parse(json['created_at'] as String)
          : null,
      isActive: json['is_active'] as bool? ?? true,
      bannedUntil: json['banned_until'] != null
          ? DateTime.parse(json['banned_until'] as String)
          : null,
      banReason: json['ban_reason'] as String?,
      addresses: addresses,
    );
  }

  /// Convert UserModel to JSON for Supabase
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'email': email,
      'role': role.name,
      'name': name,
      'phone': phone,
      'avatar_url': avatarUrl,
      'addresses': addresses.map((a) => a.toJson()).toList(),
    };
  }

  /// Create a copy with updated fields
  UserModel copyWith({
    String? id,
    String? email,
    UserRole? role,
    String? name,
    String? phone,
    String? avatarUrl,
    DateTime? createdAt,
    bool? isActive,
    DateTime? bannedUntil,
    String? banReason,
    List<UserAddress>? addresses,
  }) {
    return UserModel(
      id: id ?? this.id,
      email: email ?? this.email,
      role: role ?? this.role,
      name: name ?? this.name,
      phone: phone ?? this.phone,
      avatarUrl: avatarUrl ?? this.avatarUrl,
      createdAt: createdAt ?? this.createdAt,
      isActive: isActive ?? this.isActive,
      bannedUntil: bannedUntil ?? this.bannedUntil,
      banReason: banReason ?? this.banReason,
      addresses: addresses ?? this.addresses,
    );
  }
}
