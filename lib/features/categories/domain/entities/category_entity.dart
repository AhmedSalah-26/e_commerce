import 'package:equatable/equatable.dart';

/// Category entity representing the domain model
class CategoryEntity extends Equatable {
  final String id;
  final String name;
  final String? imageUrl;
  final String? description;
  final bool isActive;
  final int sortOrder;
  final DateTime? createdAt;

  const CategoryEntity({
    required this.id,
    required this.name,
    this.imageUrl,
    this.description,
    this.isActive = true,
    this.sortOrder = 0,
    this.createdAt,
  });

  @override
  List<Object?> get props => [
        id,
        name,
        imageUrl,
        description,
        isActive,
        sortOrder,
        createdAt,
      ];
}
