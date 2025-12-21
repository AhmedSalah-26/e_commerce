import '../../domain/entities/favorite_entity.dart';
import '../../../products/data/models/product_model.dart';

class FavoriteModel extends FavoriteEntity {
  const FavoriteModel({
    required super.id,
    required super.userId,
    required super.productId,
    super.product,
    super.createdAt,
  });

  factory FavoriteModel.fromJson(Map<String, dynamic> json,
      {String locale = 'ar'}) {
    return FavoriteModel(
      id: json['id'] as String,
      userId: json['user_id'] as String,
      productId: json['product_id'] as String,
      product: json['products'] != null
          ? ProductModel.fromJson(json['products'] as Map<String, dynamic>,
              locale: locale)
          : null,
      createdAt: json['created_at'] != null
          ? DateTime.parse(json['created_at'] as String)
          : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'user_id': userId,
      'product_id': productId,
    };
  }
}
