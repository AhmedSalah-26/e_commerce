import 'dart:ui' as ui;
import 'package:auto_size_text/auto_size_text.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_rating_bar/flutter_rating_bar.dart';

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
          mainAxisSize: MainAxisSize.min,
          children: [
            _ProductName(name: product.name),
            const SizedBox(height: 8),
            _PriceSection(product: product),
            const SizedBox(height: 8),
            _RatingStars(
              rating: product.rating,
              ratingCount: product.ratingCount,
            ),
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
    return SizedBox(
      height: 36, // Fixed height for 2 lines
      child: AutoSizeText(
        name,
        style: const TextStyle(
          fontSize: 13,
          color: AppColours.jumiaDark,
          height: 1.3,
        ),
        maxLines: 2,
        minFontSize: 10,
        overflow: TextOverflow.ellipsis,
      ),
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
      mainAxisSize: MainAxisSize.min,
      children: [
        AutoSizeText(
          "${product.effectivePrice.toStringAsFixed(2)} ${'egp'.tr()}",
          style: const TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.bold,
            color: AppColours.jumiaDark,
          ),
          maxLines: 1,
          minFontSize: 12,
        ),
        if (product.hasDiscount)
          AutoSizeText(
            "${product.price.toStringAsFixed(2)} ${'egp'.tr()}",
            style: const TextStyle(
              fontSize: 12,
              color: AppColours.jumiaGrey,
              decoration: TextDecoration.lineThrough,
            ),
            maxLines: 1,
            minFontSize: 9,
          ),
      ],
    );
  }
}

class _RatingStars extends StatelessWidget {
  final double rating;
  final int ratingCount;

  const _RatingStars({required this.rating, required this.ratingCount});

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        RatingBarIndicator(
          rating: rating,
          direction: Axis.horizontal,
          itemCount: 5,
          itemSize: 14,
          itemBuilder: (context, _) => const Icon(
            Icons.star,
            color: Colors.amber,
          ),
        ),
        const SizedBox(width: 4),
        Text(
          '($ratingCount)',
          style: const TextStyle(
            fontSize: 11,
            color: AppColours.jumiaGrey,
          ),
        ),
      ],
    );
  }
}
