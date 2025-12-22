import 'dart:ui' as ui;
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';

import '../../../features/products/domain/entities/product_entity.dart';
import '../../theme/app_colors.dart';
import 'product_cart_button.dart';

/// Product info section with name, price, rating, and cart button
class ProductInfoSection extends StatelessWidget {
  final ProductEntity product;
  final bool isArabic;

  const ProductInfoSection({
    super.key,
    required this.product,
    required this.isArabic,
  });

  @override
  Widget build(BuildContext context) {
    return Directionality(
      textDirection: isArabic ? ui.TextDirection.rtl : ui.TextDirection.ltr,
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _ProductName(name: product.name),
            const SizedBox(height: 8),
            _PriceSection(product: product),
            const SizedBox(height: 8),
            _RatingStars(rating: product.rating),
            const SizedBox(height: 12),
            ProductCartButton(product: product),
          ],
        ),
      ),
    );
  }
}

class _ProductName extends StatelessWidget {
  final String name;

  const _ProductName({required this.name});

  @override
  Widget build(BuildContext context) {
    return Text(
      name,
      style: const TextStyle(
        fontSize: 13,
        color: AppColours.jumiaDark,
        height: 1.3,
      ),
      maxLines: 2,
      overflow: TextOverflow.ellipsis,
    );
  }
}

class _PriceSection extends StatelessWidget {
  final ProductEntity product;

  const _PriceSection({required this.product});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          "${product.effectivePrice.toStringAsFixed(2)} ${'egp'.tr()}",
          style: const TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.bold,
            color: AppColours.jumiaDark,
          ),
        ),
        if (product.hasDiscount) ...[
          const SizedBox(height: 2),
          Text(
            "${product.price.toStringAsFixed(2)} ${'egp'.tr()}",
            style: const TextStyle(
              fontSize: 12,
              color: AppColours.jumiaGrey,
              decoration: TextDecoration.lineThrough,
            ),
          ),
        ],
      ],
    );
  }
}

class _RatingStars extends StatelessWidget {
  final double rating;

  const _RatingStars({required this.rating});

  @override
  Widget build(BuildContext context) {
    final floorRating = rating.floor();
    return Row(
      children: [
        for (int i = 0; i < 5; i++)
          Icon(
            i < floorRating ? Icons.star : Icons.star_border,
            color: AppColours.jumiaYellow,
            size: 14,
          ),
        const SizedBox(width: 4),
        const Text(
          "(0)",
          style: TextStyle(fontSize: 11, color: AppColours.jumiaGrey),
        ),
      ],
    );
  }
}
