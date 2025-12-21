import 'package:flutter/material.dart';
import 'package:flutter_slidable/flutter_slidable.dart';

import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_text_style.dart';
import '../../domain/entities/cart_item_entity.dart';

class CartItemCard extends StatelessWidget {
  final CartItemEntity cartItem;
  final VoidCallback onIncreaseQuantity;
  final VoidCallback onDecreaseQuantity;
  final VoidCallback onRemove;

  const CartItemCard({
    super.key,
    required this.cartItem,
    required this.onIncreaseQuantity,
    required this.onDecreaseQuantity,
    required this.onRemove,
  });

  @override
  Widget build(BuildContext context) {
    double screenWidth = MediaQuery.of(context).size.width;
    double screenHeight = MediaQuery.of(context).size.height;
    double imageSize = screenHeight * 0.08;
    double fontSize = screenWidth * 0.04;

    final product = cartItem.product;
    final productName = product?.name ?? 'منتج';
    final productPrice = product?.effectivePrice ?? 0;
    final productImage = product?.mainImage ?? '';
    double totalPrice = productPrice * cartItem.quantity;

    return Slidable(
      key: ValueKey(cartItem.id),
      endActionPane: ActionPane(
        motion: const ScrollMotion(),
        children: [
          SlidableAction(
            onPressed: (context) => onRemove(),
            backgroundColor: Colors.red,
            foregroundColor: Colors.white,
            icon: Icons.delete,
            label: 'حذف',
            borderRadius: BorderRadius.circular(10),
          ),
        ],
      ),
      child: Container(
        margin: EdgeInsets.symmetric(vertical: screenHeight * 0.01),
        decoration: BoxDecoration(
          boxShadow: [
            BoxShadow(
              color: Colors.grey.withValues(alpha: 0.2),
              spreadRadius: 1,
              blurRadius: 2,
              offset: const Offset(0, 1),
            ),
          ],
          borderRadius: BorderRadius.circular(10),
          border: Border.all(color: AppColours.greyLighter),
          color: Colors.white,
        ),
        child: Padding(
          padding: EdgeInsets.all(screenWidth * 0.03),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              // Quantity control
              Container(
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(10),
                  color: AppColours.greyLight,
                ),
                child: Column(
                  children: [
                    IconButton(
                      icon: Icon(Icons.add,
                          color: Colors.green, size: fontSize * 1.2),
                      onPressed: onIncreaseQuantity,
                    ),
                    Text(
                      '${cartItem.quantity}',
                      style: AppTextStyle.bold_18_medium_brown
                          .copyWith(fontSize: fontSize),
                    ),
                    IconButton(
                      icon: Icon(Icons.remove,
                          color: Colors.red, size: fontSize * 1.2),
                      onPressed: onDecreaseQuantity,
                    ),
                  ],
                ),
              ),
              SizedBox(width: screenWidth * 0.04),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  mainAxisAlignment: MainAxisAlignment.spaceAround,
                  children: [
                    Text(
                      productName,
                      style: AppTextStyle.bold_18_medium_brown
                          .copyWith(fontSize: fontSize),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                      textAlign: TextAlign.right,
                    ),
                    const SizedBox(height: 4),
                    Text(
                      'سعر القطعة: EGP ${productPrice.toStringAsFixed(2)}',
                      style: AppTextStyle.normal_16_brownLight
                          .copyWith(fontSize: fontSize * 0.8),
                    ),
                    Text(
                      'السعر الكلي: EGP ${totalPrice.toStringAsFixed(2)}',
                      style: AppTextStyle.semiBold_16_dark_brown
                          .copyWith(fontSize: fontSize * 0.8),
                    ),
                  ],
                ),
              ),
              SizedBox(width: screenWidth * 0.02),
              // Image
              SizedBox(
                width: imageSize,
                height: imageSize,
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(8),
                  child: productImage.isNotEmpty
                      ? (productImage.startsWith('http')
                          ? Image.network(
                              productImage,
                              fit: BoxFit.cover,
                              errorBuilder: (context, error, stackTrace) {
                                return _buildPlaceholder();
                              },
                            )
                          : Image.asset(
                              productImage,
                              fit: BoxFit.cover,
                              errorBuilder: (context, error, stackTrace) {
                                return _buildPlaceholder();
                              },
                            ))
                      : _buildPlaceholder(),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildPlaceholder() {
    return Container(
      color: AppColours.greyLight,
      child: const Icon(Icons.image_not_supported, color: Colors.grey),
    );
  }
}
