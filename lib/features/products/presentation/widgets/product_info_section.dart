import 'dart:ui' as ui;
import 'package:auto_size_text/auto_size_text.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_rating_bar/flutter_rating_bar.dart';

import '../../../../core/theme/app_text_style.dart';
import '../../domain/entities/product_entity.dart';

class ProductInfoSection extends StatelessWidget {
  final ProductEntity product;
  final double screenWidth;
  final bool isArabic;
  final bool hidePrice;

  const ProductInfoSection({
    super.key,
    required this.product,
    required this.screenWidth,
    required this.isArabic,
    this.hidePrice = false,
  });

  @override
  Widget build(BuildContext context) {
    return Directionality(
      textDirection: isArabic ? ui.TextDirection.rtl : ui.TextDirection.ltr,
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Expanded(
            flex: 2,
            child: AutoSizeText(
              product.name,
              style: AppTextStyle.semiBold_20_dark_brown
                  .copyWith(fontSize: screenWidth * 0.04),
              minFontSize: 14,
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
            ),
          ),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                if (!hidePrice) ...[
                  if (product.hasDiscount)
                    AutoSizeText(
                      "${product.price.toStringAsFixed(2)} ${'egp'.tr()}",
                      style: TextStyle(
                        fontSize: screenWidth * 0.03,
                        color: Colors.grey,
                        decoration: TextDecoration.lineThrough,
                      ),
                      minFontSize: 10,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  AutoSizeText(
                    "${product.effectivePrice.toStringAsFixed(2)} ${'egp'.tr()}",
                    style: AppTextStyle.bold_18_medium_brown
                        .copyWith(fontSize: screenWidth * 0.04),
                    minFontSize: 14,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ],
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class ProductRatingSection extends StatelessWidget {
  final ProductEntity product;
  final double screenWidth;
  final bool isArabic;
  final Widget favoriteButton;

  const ProductRatingSection({
    super.key,
    required this.product,
    required this.screenWidth,
    required this.isArabic,
    required this.favoriteButton,
  });

  @override
  Widget build(BuildContext context) {
    return Directionality(
      textDirection: isArabic ? ui.TextDirection.rtl : ui.TextDirection.ltr,
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Row(
            children: [
              RatingBarIndicator(
                rating: product.rating,
                direction: Axis.horizontal,
                itemCount: 5,
                itemSize: screenWidth * 0.05,
                itemPadding:
                    EdgeInsets.symmetric(horizontal: screenWidth * 0.01),
                itemBuilder: (context, _) =>
                    const Icon(Icons.star, color: Colors.amber),
              ),
              SizedBox(width: screenWidth * 0.02),
              AutoSizeText(
                "(${product.rating.toStringAsFixed(1)})",
                style: AppTextStyle.normal_16_brownLight
                    .copyWith(fontSize: screenWidth * 0.04),
                minFontSize: 10,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
            ],
          ),
          favoriteButton,
        ],
      ),
    );
  }
}
