import 'dart:ui' as ui;
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_slidable/flutter_slidable.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/theme/app_text_style.dart';
import '../../domain/entities/cart_item_entity.dart';
import '../cubit/cart_cubit.dart';
import 'cart_item/cart_item_image.dart';
import 'cart_item/cart_item_quantity_control.dart';
import 'cart_item/cart_item_badge.dart';

class CartItemCard extends StatefulWidget {
  final CartItemEntity cartItem;

  const CartItemCard({super.key, required this.cartItem});

  @override
  State<CartItemCard> createState() => _CartItemCardState();
}

class _CartItemCardState extends State<CartItemCard> {
  late int _localQuantity;
  bool _isUpdating = false;

  @override
  void initState() {
    super.initState();
    _localQuantity = widget.cartItem.quantity;
  }

  @override
  void didUpdateWidget(CartItemCard oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (!_isUpdating && widget.cartItem.quantity != _localQuantity) {
      _localQuantity = widget.cartItem.quantity;
    }
  }

  void _handleIncrease() {
    setState(() {
      _localQuantity++;
      _isUpdating = true;
    });

    context
        .read<CartCubit>()
        .updateQuantity(widget.cartItem.id, _localQuantity)
        .then((_) {
      if (mounted) setState(() => _isUpdating = false);
    });
  }

  void _handleDecrease() {
    if (_localQuantity <= 1) {
      context.read<CartCubit>().removeFromCart(widget.cartItem.id);
      return;
    }

    setState(() {
      _localQuantity--;
      _isUpdating = true;
    });

    context
        .read<CartCubit>()
        .updateQuantity(widget.cartItem.id, _localQuantity)
        .then((_) {
      if (mounted) setState(() => _isUpdating = false);
    });
  }

  void _handleRemove() {
    context.read<CartCubit>().removeFromCart(widget.cartItem.id);
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final screenWidth = MediaQuery.of(context).size.width;
    final screenHeight = MediaQuery.of(context).size.height;
    final imageSize = screenHeight * 0.08;
    final fontSize = screenWidth * 0.04;
    final isRtl = context.locale.languageCode == 'ar';

    final product = widget.cartItem.product;
    final productName = product?.name ?? 'منتج';
    final productPrice = product?.effectivePrice ?? 0;
    final productImage = product?.mainImage ?? '';
    final totalPrice = productPrice * _localQuantity;
    final hasDiscount = product?.hasDiscount ?? false;
    final isFlashSale = product?.isFlashSaleActive ?? false;
    final discountPercent = product?.discountPercentage ?? 0;
    final isInactive = product != null && !product.isActive;

    return Slidable(
      key: ValueKey(widget.cartItem.id),
      endActionPane: ActionPane(
        motion: const ScrollMotion(),
        children: [
          SlidableAction(
            onPressed: (context) => _handleRemove(),
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
          if (product != null) context.push('/product/${product.id}');
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
                      CartItemImage(imageUrl: productImage, size: imageSize),
                      SizedBox(width: screenWidth * 0.03),
                      Expanded(
                        child: _buildProductInfo(
                          productName: productName,
                          productPrice: productPrice,
                          totalPrice: totalPrice,
                          hasDiscount: hasDiscount,
                          isFlashSale: isFlashSale,
                          originalPrice: product?.price ?? 0,
                          fontSize: fontSize,
                          theme: theme,
                        ),
                      ),
                      SizedBox(width: screenWidth * 0.03),
                      CartItemQuantityControl(
                        quantity: _localQuantity,
                        fontSize: fontSize,
                        onIncrease: _handleIncrease,
                        onDecrease: _handleDecrease,
                      ),
                    ],
                  ),
                ),
              ),
            ),
            _buildBadge(
              isFlashSale: isFlashSale,
              isInactive: isInactive,
              hasDiscount: hasDiscount,
              discountPercent: discountPercent,
              isRtl: isRtl,
              topOffset: screenHeight * 0.01,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildProductInfo({
    required String productName,
    required double productPrice,
    required double totalPrice,
    required bool hasDiscount,
    required bool isFlashSale,
    required double originalPrice,
    required double fontSize,
    required ThemeData theme,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisAlignment: MainAxisAlignment.spaceAround,
      children: [
        Text(
          productName,
          style: AppTextStyle.bold_18_medium_brown.copyWith(fontSize: fontSize),
          maxLines: 2,
          overflow: TextOverflow.ellipsis,
        ),
        const SizedBox(height: 4),
        if (hasDiscount || isFlashSale)
          Row(
            children: [
              Text(
                '${originalPrice.toStringAsFixed(0)} ',
                style: TextStyle(
                  fontSize: fontSize * 0.75,
                  color: Colors.grey,
                  decoration: TextDecoration.lineThrough,
                ),
              ),
              Text(
                '${productPrice.toStringAsFixed(2)} ${'egp'.tr()}',
                style: AppTextStyle.normal_16_brownLight.copyWith(
                  fontSize: fontSize * 0.8,
                  color: theme.colorScheme.primary,
                ),
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
          style: AppTextStyle.semiBold_16_dark_brown.copyWith(
            fontSize: fontSize * 0.8,
            color: theme.colorScheme.onSurface,
          ),
        ),
      ],
    );
  }

  Widget _buildBadge({
    required bool isFlashSale,
    required bool isInactive,
    required bool hasDiscount,
    required int discountPercent,
    required bool isRtl,
    required double topOffset,
  }) {
    if (isFlashSale) {
      return CartItemBadge(
        type: CartItemBadgeType.flashSale,
        isRtl: isRtl,
        topOffset: topOffset,
      );
    } else if (isInactive) {
      return CartItemBadge(
        type: CartItemBadgeType.inactive,
        isRtl: isRtl,
        topOffset: topOffset,
      );
    } else if (hasDiscount) {
      return CartItemBadge(
        type: CartItemBadgeType.discount,
        isRtl: isRtl,
        topOffset: topOffset,
        discountPercent: discountPercent,
      );
    }
    return const SizedBox.shrink();
  }
}
