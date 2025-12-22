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
  final String? merchantId;
  // Store info
  final String? storeName;
  final String? storePhone;
  final String? storeAddress;
  // Flash sale info
  final bool isFlashSale;
  final DateTime? flashSaleStart;
  final DateTime? flashSaleEnd;

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
    this.merchantId,
    this.storeName,
    this.storePhone,
    this.storeAddress,
    this.isFlashSale = false,
    this.flashSaleStart,
    this.flashSaleEnd,
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

  /// Check if store info is available
  bool get hasStoreInfo => storeName != null && storeName!.isNotEmpty;

  /// Check if flash sale is currently active
  bool get isFlashSaleActive {
    if (!isFlashSale) return false;
    if (flashSaleStart == null || flashSaleEnd == null) return false;
    final now = DateTime.now();
    return now.isAfter(flashSaleStart!) && now.isBefore(flashSaleEnd!);
  }

  /// Get remaining time for flash sale
  Duration? get flashSaleRemainingTime {
    if (!isFlashSaleActive) return null;
    return flashSaleEnd!.difference(DateTime.now());
  }

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
        merchantId,
        storeName,
        storePhone,
        storeAddress,
        isFlashSale,
        flashSaleStart,
        flashSaleEnd,
      ];
}
