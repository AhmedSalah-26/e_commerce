import 'dart:ui' as ui;
import 'package:auto_size_text/auto_size_text.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_rating_bar/flutter_rating_bar.dart';

import '../../../features/products/domain/entities/product_entity.dart';
import 'product_cart_button.dart';

class ProductInfoSection extends StatelessWidget {
  final ProductEntity product;
  final bool isArabic;
  final bool compact;

  const ProductInfoSection({
    super.key,
    required this.product,
    required this.isArabic,
    this.compact = false,
  });

  @override
  Widget build(BuildContext context) {
    if (compact) {
      return _CompactInfoSection(product: product, isArabic: isArabic);
    }

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

class _CompactInfoSection extends StatelessWidget {
  final ProductEntity product;
  final bool isArabic;

  const _CompactInfoSection({required this.product, required this.isArabic});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Directionality(
      textDirection: isArabic ? ui.TextDirection.rtl : ui.TextDirection.ltr,
      child: Padding(
        padding: const EdgeInsets.all(6),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: [
            SizedBox(
              height: 24,
              child: AutoSizeText(
                product.name,
                style: TextStyle(
                  fontSize: 10,
                  color: theme.colorScheme.onSurface,
                  height: 1.2,
                ),
                maxLines: 2,
                minFontSize: 8,
                overflow: TextOverflow.ellipsis,
              ),
            ),
            const SizedBox(height: 3),
            AutoSizeText(
              "${product.effectivePrice.toStringAsFixed(0)} ${'egp'.tr()}",
              style: TextStyle(
                fontSize: 11,
                fontWeight: FontWeight.bold,
                color: theme.colorScheme.onSurface,
              ),
              maxLines: 1,
              minFontSize: 9,
            ),
            if (product.hasDiscount)
              AutoSizeText(
                "${product.price.toStringAsFixed(0)} ${'egp'.tr()}",
                style: TextStyle(
                  fontSize: 9,
                  color: theme.colorScheme.onSurface.withValues(alpha: 0.5),
                  decoration: TextDecoration.lineThrough,
                ),
                maxLines: 1,
                minFontSize: 7,
              ),
            const SizedBox(height: 2),
            Row(
              children: [
                const Icon(Icons.star, color: Colors.amber, size: 10),
                const SizedBox(width: 2),
                Text(
                  '${product.rating.toStringAsFixed(1)} (${product.ratingCount})',
                  style: TextStyle(
                    fontSize: 8,
                    color: theme.colorScheme.onSurface.withValues(alpha: 0.6),
                  ),
                ),
              ],
            ),
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
    final theme = Theme.of(context);

    return SizedBox(
      height: 36,
      child: AutoSizeText(
        name,
        style: TextStyle(
          fontSize: 13,
          color: theme.colorScheme.onSurface,
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
    final theme = Theme.of(context);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      children: [
        AutoSizeText(
          "${product.effectivePrice.toStringAsFixed(2)} ${'egp'.tr()}",
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.bold,
            color: theme.colorScheme.onSurface,
          ),
          maxLines: 1,
          minFontSize: 12,
        ),
        if (product.hasDiscount)
          AutoSizeText(
            "${product.price.toStringAsFixed(2)} ${'egp'.tr()}",
            style: TextStyle(
              fontSize: 12,
              color: theme.colorScheme.onSurface.withValues(alpha: 0.5),
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
    final theme = Theme.of(context);

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
          style: TextStyle(
            fontSize: 11,
            color: theme.colorScheme.onSurface.withValues(alpha: 0.5),
          ),
        ),
      ],
    );
  }
}
