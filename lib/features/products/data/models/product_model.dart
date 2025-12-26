import '../../domain/entities/product_entity.dart';

/// Product model for data layer operations
class ProductModel extends ProductEntity {
  const ProductModel({
    required super.id,
    required super.name,
    required super.description,
    required super.price,
    super.discountPrice,
    required super.images,
    super.categoryId,
    required super.stock,
    required super.rating,
    super.ratingCount,
    super.isActive,
    super.isFeatured,
    super.createdAt,
    super.merchantId,
    super.storeName,
    super.storePhone,
    super.storeAddress,
    super.storeLogo,
    super.isFlashSale,
    super.flashSaleStart,
    super.flashSaleEnd,
  });

  /// Create ProductModel from JSON (Supabase response) with locale
  factory ProductModel.fromJson(Map<String, dynamic> json,
      {String locale = 'ar'}) {
    // Get name based on locale
    final name = locale == 'en'
        ? (json['name_en'] as String? ?? json['name_ar'] as String? ?? '')
        : (json['name_ar'] as String? ?? json['name_en'] as String? ?? '');

    // Get description based on locale
    final description = locale == 'en'
        ? (json['description_en'] as String? ??
            json['description_ar'] as String? ??
            '')
        : (json['description_ar'] as String? ??
            json['description_en'] as String? ??
            '');

    // Get store info from joined stores table or profiles table
    String? storeName;
    String? storePhone;
    String? storeAddress;
    String? storeLogo;
    if (json['stores'] != null && json['stores'] is Map) {
      storeName = json['stores']['name'] as String?;
      storePhone = json['stores']['phone'] as String?;
      storeAddress = json['stores']['address'] as String?;
      storeLogo = json['stores']['logo_url'] as String?;
    } else if (json['profiles'] != null && json['profiles'] is Map) {
      // Fallback to profiles table
      storeName = json['profiles']['name'] as String?;
      storePhone = json['profiles']['phone'] as String?;
      storeAddress = json['profiles']['address'] as String?;
    }

    return ProductModel(
      id: json['id'] as String,
      name: name,
      description: description,
      price: (json['price'] as num).toDouble(),
      discountPrice: json['discount_price'] != null
          ? (json['discount_price'] as num).toDouble()
          : null,
      images: json['images'] != null
          ? List<String>.from(json['images'] as List)
          : [],
      categoryId: json['category_id'] as String?,
      stock: json['stock'] as int? ?? 0,
      rating: (json['rating'] as num?)?.toDouble() ?? 0.0,
      ratingCount:
          json['review_count'] as int? ?? json['rating_count'] as int? ?? 0,
      isActive: json['is_active'] as bool? ?? true,
      isFeatured: json['is_featured'] as bool? ?? false,
      createdAt: json['created_at'] != null
          ? DateTime.parse(json['created_at'] as String).toLocal()
          : null,
      merchantId: json['merchant_id'] as String?,
      storeName: storeName,
      storePhone: storePhone,
      storeAddress: storeAddress,
      storeLogo: storeLogo,
      isFlashSale: json['is_flash_sale'] as bool? ?? false,
      flashSaleStart: json['flash_sale_start'] != null
          ? DateTime.parse(json['flash_sale_start'] as String).toLocal()
          : null,
      flashSaleEnd: json['flash_sale_end'] != null
          ? DateTime.parse(json['flash_sale_end'] as String).toLocal()
          : null,
    );
  }

  /// Convert ProductModel to JSON for Supabase
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name_ar': name,
      'name_en': name,
      'description_ar': description,
      'description_en': description,
      'price': price,
      'discount_price': discountPrice,
      'images': images,
      'category_id': categoryId,
      'stock': stock,
      'rating': rating,
      'rating_count': ratingCount,
      'is_active': isActive,
      'is_featured': isFeatured,
      'is_flash_sale': isFlashSale,
      'flash_sale_start': flashSaleStart?.toUtc().toIso8601String(),
      'flash_sale_end': flashSaleEnd?.toUtc().toIso8601String(),
    };
  }

  /// Convert to JSON for insert (without id)
  Map<String, dynamic> toInsertJson() {
    final json = toJson();
    json.remove('id');
    return json;
  }

  /// Create a copy with updated fields
  ProductModel copyWith({
    String? id,
    String? name,
    String? description,
    double? price,
    double? discountPrice,
    List<String>? images,
    String? categoryId,
    int? stock,
    double? rating,
    int? ratingCount,
    bool? isActive,
    bool? isFeatured,
    DateTime? createdAt,
    String? merchantId,
    String? storeName,
    String? storePhone,
    String? storeAddress,
    String? storeLogo,
    bool? isFlashSale,
    DateTime? flashSaleStart,
    DateTime? flashSaleEnd,
  }) {
    return ProductModel(
      id: id ?? this.id,
      name: name ?? this.name,
      description: description ?? this.description,
      price: price ?? this.price,
      discountPrice: discountPrice ?? this.discountPrice,
      images: images ?? this.images,
      categoryId: categoryId ?? this.categoryId,
      stock: stock ?? this.stock,
      rating: rating ?? this.rating,
      ratingCount: ratingCount ?? this.ratingCount,
      isActive: isActive ?? this.isActive,
      isFeatured: isFeatured ?? this.isFeatured,
      createdAt: createdAt ?? this.createdAt,
      merchantId: merchantId ?? this.merchantId,
      storeName: storeName ?? this.storeName,
      storePhone: storePhone ?? this.storePhone,
      storeAddress: storeAddress ?? this.storeAddress,
      storeLogo: storeLogo ?? this.storeLogo,
      isFlashSale: isFlashSale ?? this.isFlashSale,
      flashSaleStart: flashSaleStart ?? this.flashSaleStart,
      flashSaleEnd: flashSaleEnd ?? this.flashSaleEnd,
    );
  }
}
