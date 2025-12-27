import 'dart:ui' as ui;
import 'package:auto_size_text/auto_size_text.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';

import '../../../../core/theme/app_text_style.dart';
import '../../domain/entities/product_entity.dart';

class ProductStockStatus extends StatelessWidget {
  final ProductEntity product;
  final double screenWidth;
  final bool isArabic;

  const ProductStockStatus({
    super.key,
    required this.product,
    required this.screenWidth,
    required this.isArabic,
  });

  @override
  Widget build(BuildContext context) {
    return Directionality(
      textDirection: isArabic ? ui.TextDirection.rtl : ui.TextDirection.ltr,
      child: Row(
        mainAxisAlignment: MainAxisAlignment.start,
        children: [
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
            decoration: BoxDecoration(
              color: product.isOutOfStock
                  ? Colors.red.shade100
                  : Colors.green.shade100,
              borderRadius: BorderRadius.circular(8),
            ),
            child: Text(
              product.isOutOfStock
                  ? 'out_of_stock'.tr()
                  : '${'in_stock'.tr()} (${product.stock})',
              style: TextStyle(
                color: product.isOutOfStock ? Colors.red : Colors.green,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class ProductDescription extends StatefulWidget {
  final ProductEntity product;
  final double screenWidth;
  final bool isArabic;

  const ProductDescription({
    super.key,
    required this.product,
    required this.screenWidth,
    required this.isArabic,
  });

  @override
  State<ProductDescription> createState() => _ProductDescriptionState();
}

class _ProductDescriptionState extends State<ProductDescription> {
  bool _isExpanded = false;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Directionality(
      textDirection:
          widget.isArabic ? ui.TextDirection.rtl : ui.TextDirection.ltr,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            widget.product.description,
            style: AppTextStyle.normal_12_black.copyWith(
              fontSize: widget.screenWidth * 0.04,
              color: theme.colorScheme.onSurface,
            ),
            maxLines: _isExpanded ? null : 6,
            overflow:
                _isExpanded ? TextOverflow.visible : TextOverflow.ellipsis,
          ),
          if (widget.product.description.length > 200)
            TextButton(
              onPressed: () {
                setState(() {
                  _isExpanded = !_isExpanded;
                });
              },
              style: TextButton.styleFrom(
                padding: EdgeInsets.zero,
                minimumSize: const Size(0, 30),
                tapTargetSize: MaterialTapTargetSize.shrinkWrap,
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    _isExpanded ? 'show_less'.tr() : 'show_more'.tr(),
                    style: TextStyle(
                      color: theme.colorScheme.primary,
                      fontSize: widget.screenWidth * 0.035,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  Icon(
                    _isExpanded
                        ? Icons.keyboard_arrow_up
                        : Icons.keyboard_arrow_down,
                    color: theme.colorScheme.primary,
                    size: 20,
                  ),
                ],
              ),
            ),
        ],
      ),
    );
  }
}

class ProductQuantitySelector extends StatelessWidget {
  final int quantity;
  final int maxStock;
  final double screenWidth;
  final bool isArabic;
  final Function(int) onQuantityChanged;

  const ProductQuantitySelector({
    super.key,
    required this.quantity,
    required this.maxStock,
    required this.screenWidth,
    required this.isArabic,
    required this.onQuantityChanged,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Directionality(
      textDirection: isArabic ? ui.TextDirection.rtl : ui.TextDirection.ltr,
      child: Row(
        children: [
          AutoSizeText(
            '${'quantity'.tr()}:',
            style: AppTextStyle.normal_16_brownLight.copyWith(
              fontSize: screenWidth * 0.05,
              color: theme.colorScheme.primary,
            ),
            minFontSize: 12,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
          SizedBox(width: screenWidth * 0.04),
          Container(
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(8),
              border: Border.all(color: theme.colorScheme.primary),
            ),
            child: Row(
              children: [
                IconButton(
                  icon: Icon(Icons.remove, color: theme.colorScheme.onSurface),
                  onPressed: () {
                    if (quantity > 1) onQuantityChanged(quantity - 1);
                  },
                ),
                AutoSizeText(
                  '$quantity',
                  style: AppTextStyle.normal_16_brownLight.copyWith(
                    fontSize: screenWidth * 0.05,
                    color: theme.colorScheme.onSurface,
                  ),
                  minFontSize: 12,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                IconButton(
                  icon: Icon(Icons.add, color: theme.colorScheme.onSurface),
                  onPressed: () {
                    if (quantity < maxStock) onQuantityChanged(quantity + 1);
                  },
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class ProductTotalPrice extends StatelessWidget {
  final double totalPrice;
  final double screenWidth;
  final bool isArabic;

  const ProductTotalPrice({
    super.key,
    required this.totalPrice,
    required this.screenWidth,
    required this.isArabic,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Directionality(
      textDirection: isArabic ? ui.TextDirection.rtl : ui.TextDirection.ltr,
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          AutoSizeText(
            '${'total'.tr()}:',
            style: AppTextStyle.bold_18_medium_brown.copyWith(
              fontSize: screenWidth * 0.04,
              color: theme.colorScheme.onSurface,
            ),
            minFontSize: 14,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
          AutoSizeText(
            "${totalPrice.toStringAsFixed(2)} ${'egp'.tr()}",
            style: AppTextStyle.bold_18_medium_brown.copyWith(
              fontSize: screenWidth * 0.04,
              color: theme.colorScheme.primary,
            ),
            minFontSize: 14,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
        ],
      ),
    );
  }
}
