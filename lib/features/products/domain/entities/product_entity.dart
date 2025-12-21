import 'package:equatable/equatable.dart';

/// Product entity representing the domain model
class ProductEntity extends Equatable {
  final String id;
  final String name;
  final String description;
  final double price;
  final double? discountPrice;
  final List<String> images;
  final String? categoryId;
  final int stock;
  final double rating;
  final int ratingCount;
  final bool isActive;
  final bool isFeatured;
  final DateTime? createdAt;

  const ProductEntity({
    required this.id,
    required this.name,
    required this.description,
    required this.price,
    this.discountPrice,
    required this.images,
    this.categoryId,
    required this.stock,
    required this.rating,
    this.ratingCount = 0,
    this.isActive = true,
    this.isFeatured = false,
    this.createdAt,
  });

  /// Check if product is out of stock
  bool get isOutOfStock => stock <= 0;

  /// Get effective price (discount or regular)
  double get effectivePrice => discountPrice ?? price;

  /// Check if product has discount
  bool get hasDiscount => discountPrice != null && discountPrice! < price;

  /// Get discount percentage
  int get discountPercentage {
    if (!hasDiscount) return 0;
    return (((price - discountPrice!) / price) * 100).round();
  }

  /// Get first image or placeholder
  String get mainImage => images.isNotEmpty ? images.first : '';

  @override
  List<Object?> get props => [
        id,
        name,
        description,
        price,
        discountPrice,
        images,
        categoryId,
        stock,
        rating,
        ratingCount,
        isActive,
        isFeatured,
        createdAt,
      ];
}
