import '../../domain/entities/category_entity.dart';

/// Category model for data layer operations
class CategoryModel extends CategoryEntity {
  const CategoryModel({
    required super.id,
    required super.name,
    super.imageUrl,
    super.description,
    super.isActive,
    super.sortOrder,
    super.createdAt,
  });

  /// Create CategoryModel from JSON (Supabase response) with locale
  factory CategoryModel.fromJson(Map<String, dynamic> json,
      {String locale = 'ar'}) {
    // Get name based on locale
    final name = locale == 'en'
        ? (json['name_en'] as String? ?? json['name_ar'] as String? ?? '')
        : (json['name_ar'] as String? ?? json['name_en'] as String? ?? '');

    return CategoryModel(
      id: json['id'] as String,
      name: name,
      imageUrl: json['image_url'] as String?,
      description: json['description'] as String?,
      isActive: json['is_active'] as bool? ?? true,
      sortOrder: json['sort_order'] as int? ?? 0,
      createdAt: json['created_at'] != null
          ? DateTime.parse(json['created_at'] as String)
          : null,
    );
  }

  /// Convert CategoryModel to JSON for Supabase
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name_ar': name, // Default to Arabic when saving
      'name_en': name,
      'image_url': imageUrl,
      'description': description,
      'is_active': isActive,
      'sort_order': sortOrder,
    };
  }

  /// Convert to JSON for insert (without id)
  Map<String, dynamic> toInsertJson() {
    final json = toJson();
    json.remove('id');
    return json;
  }

  /// Create a copy with updated fields
  CategoryModel copyWith({
    String? id,
    String? name,
    String? imageUrl,
    String? description,
    bool? isActive,
    int? sortOrder,
    DateTime? createdAt,
  }) {
    return CategoryModel(
      id: id ?? this.id,
      name: name ?? this.name,
      imageUrl: imageUrl ?? this.imageUrl,
      description: description ?? this.description,
      isActive: isActive ?? this.isActive,
      sortOrder: sortOrder ?? this.sortOrder,
      createdAt: createdAt ?? this.createdAt,
    );
  }
}
