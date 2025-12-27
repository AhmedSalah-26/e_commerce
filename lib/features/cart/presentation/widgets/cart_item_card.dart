import 'dart:ui' as ui;
import 'package:cached_network_image/cached_network_image.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_slidable/flutter_slidable.dart';
import 'package:go_router/go_router.dart';

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
    final theme = Theme.of(context);
    double screenWidth = MediaQuery.of(context).size.width;
    double screenHeight = MediaQuery.of(context).size.height;
    double imageSize = screenHeight * 0.08;
    double fontSize = screenWidth * 0.04;
    final isRtl = context.locale.languageCode == 'ar';

    final product = cartItem.product;
    final productName = product?.name ?? 'منتج';
    final productPrice = product?.effectivePrice ?? 0;
    final productImage = product?.mainImage ?? '';
    double totalPrice = productPrice * cartItem.quantity;
    final hasDiscount = product?.hasDiscount ?? false;
    final isFlashSale = product?.isFlashSaleActive ?? false;
    final discountPercent = product?.discountPercentage ?? 0;
    final isInactive = product != null && !product.isActive;

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
            label: 'delete'.tr(),
            borderRadius: BorderRadius.circular(10),
          ),
        ],
      ),
      child: GestureDetector(
        onTap: () {
          if (product != null) {
            context.push('/product/${product.id}');
          }
        },
        child: Stack(
          clipBehavior: Clip.none,
          children: [
            Container(
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
                border: Border.all(
                    color: theme.colorScheme.outline.withValues(alpha: 0.3)),
                color: theme.scaffoldBackgroundColor,
              ),
              child: Directionality(
                textDirection:
                    isRtl ? ui.TextDirection.rtl : ui.TextDirection.ltr,
                child: Padding(
                  padding: EdgeInsets.all(screenWidth * 0.03),
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      // Image
                      SizedBox(
                        width: imageSize,
                        height: imageSize,
                        child: ClipRRect(
                          borderRadius: BorderRadius.circular(8),
                          child: productImage.isNotEmpty
                              ? (productImage.startsWith('http')
                                  ? CachedNetworkImage(
                                      imageUrl: productImage,
                                      fit: BoxFit.cover,
                                      memCacheWidth: 160,
                                      placeholder: (_, __) =>
                                          _buildPlaceholder(theme),
                                      errorWidget: (_, __, ___) =>
                                          _buildPlaceholder(theme),
                                    )
                                  : Image.asset(
                                      productImage,
                                      fit: BoxFit.cover,
                                      errorBuilder:
                                          (context, error, stackTrace) {
                                        return _buildPlaceholder(theme);
                                      },
                                    ))
                              : _buildPlaceholder(theme),
                        ),
                      ),
                      SizedBox(width: screenWidth * 0.03),
                      // Product Info
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          mainAxisAlignment: MainAxisAlignment.spaceAround,
                          children: [
                            Text(
                              productName,
                              style: AppTextStyle.bold_18_medium_brown.copyWith(
                                fontSize: fontSize,
                              ),
                              maxLines: 2,
                              overflow: TextOverflow.ellipsis,
                            ),
                            const SizedBox(height: 4),
                            // Price with discount display
                            if (hasDiscount || isFlashSale)
                              Row(
                                children: [
                                  Text(
                                    '${product?.price.toStringAsFixed(0)} ',
                                    style: TextStyle(
                                      fontSize: fontSize * 0.75,
                                      color: Colors.grey,
                                      decoration: TextDecoration.lineThrough,
                                    ),
                                  ),
                                  Text(
                                    '${productPrice.toStringAsFixed(2)} ${'egp'.tr()}',
                                    style: AppTextStyle.normal_16_brownLight
                                        .copyWith(
                                            fontSize: fontSize * 0.8,
                                            color: theme.colorScheme.primary),
                                  ),
                                ],
                              )
                            else
                              Text(
                                '${'unit_price'.tr()}: ${productPrice.toStringAsFixed(2)} ${'egp'.tr()}',
                                style: AppTextStyle.normal_16_brownLight
                                    .copyWith(fontSize: fontSize * 0.8),
                              ),
                            Text(
                              '${'total_price'.tr()}: ${totalPrice.toStringAsFixed(2)} ${'egp'.tr()}',
                              style:
                                  AppTextStyle.semiBold_16_dark_brown.copyWith(
                                fontSize: fontSize * 0.8,
                                color: theme.colorScheme.onSurface,
                              ),
                            ),
                          ],
                        ),
                      ),
                      SizedBox(width: screenWidth * 0.03),
                      // Quantity control
                      Container(
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(10),
                          color: theme.colorScheme.surface,
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
                              style: AppTextStyle.bold_18_medium_brown.copyWith(
                                fontSize: fontSize,
                              ),
                            ),
                            IconButton(
                              icon: Icon(Icons.remove,
                                  color: Colors.red, size: fontSize * 1.2),
                              onPressed: onDecreaseQuantity,
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
            // Flash Sale Badge on Card
            if (isFlashSale)
              Positioned(
                top: screenHeight * 0.01,
                left: isRtl ? null : 0,
                right: isRtl ? 0 : null,
                child: Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 6, vertical: 3),
                  decoration: BoxDecoration(
                    color: Colors.red,
                    borderRadius: BorderRadius.only(
                      topLeft: isRtl ? Radius.zero : const Radius.circular(10),
                      topRight: isRtl ? const Radius.circular(10) : Radius.zero,
                      bottomLeft:
                          isRtl ? const Radius.circular(10) : Radius.zero,
                      bottomRight:
                          isRtl ? Radius.zero : const Radius.circular(10),
                    ),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const Icon(Icons.flash_on,
                          color: Colors.yellow, size: 12),
                      Text(
                        'flash_sale_badge'.tr(),
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 10,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                ),
              )
            // Inactive Product Badge
            else if (isInactive)
              Positioned(
                top: screenHeight * 0.01,
                left: isRtl ? null : 0,
                right: isRtl ? 0 : null,
                child: Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 6, vertical: 3),
                  decoration: BoxDecoration(
                    color: Colors.orange[700],
                    borderRadius: BorderRadius.only(
                      topLeft: isRtl ? Radius.zero : const Radius.circular(10),
                      topRight: isRtl ? const Radius.circular(10) : Radius.zero,
                      bottomLeft:
                          isRtl ? const Radius.circular(10) : Radius.zero,
                      bottomRight:
                          isRtl ? Radius.zero : const Radius.circular(10),
                    ),
                  ),
                  child: Text(
                    'shipping_unavailable'.tr(),
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 10,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              )
            // Discount Badge on Card (only if not flash sale)
            else if (hasDiscount)
              Positioned(
                top: screenHeight * 0.01,
                left: isRtl ? null : 0,
                right: isRtl ? 0 : null,
                child: Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 6, vertical: 3),
                  decoration: BoxDecoration(
                    color: theme.colorScheme.primary,
                    borderRadius: BorderRadius.only(
                      topLeft: isRtl ? Radius.zero : const Radius.circular(10),
                      topRight: isRtl ? const Radius.circular(10) : Radius.zero,
                      bottomLeft:
                          isRtl ? const Radius.circular(10) : Radius.zero,
                      bottomRight:
                          isRtl ? Radius.zero : const Radius.circular(10),
                    ),
                  ),
                  child: Text(
                    '-$discountPercent%',
                    textDirection: ui.TextDirection.ltr,
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 10,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildPlaceholder(ThemeData theme) {
    return Container(
      color: theme.colorScheme.surface,
      child: const Icon(Icons.image_not_supported, color: Colors.grey),
    );
  }
}
