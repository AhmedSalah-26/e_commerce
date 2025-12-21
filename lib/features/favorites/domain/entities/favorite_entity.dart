import 'package:equatable/equatable.dart';
import '../../../products/domain/entities/product_entity.dart';

class FavoriteEntity extends Equatable {
  final String id;
  final String userId;
  final String productId;
  final ProductEntity? product;
  final DateTime? createdAt;

  const FavoriteEntity({
    required this.id,
    required this.userId,
    required this.productId,
    this.product,
    this.createdAt,
  });

  @override
  List<Object?> get props => [id, userId, productId, product, createdAt];
}
