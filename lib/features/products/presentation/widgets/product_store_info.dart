import 'dart:ui' as ui;
import 'package:auto_size_text/auto_size_text.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_text_style.dart';
import '../../domain/entities/product_entity.dart';

class ProductStoreInfo extends StatelessWidget {
  final ProductEntity product;
  final double screenWidth;
  final bool isArabic;

  const ProductStoreInfo({
    super.key,
    required this.product,
    required this.screenWidth,
    required this.isArabic,
  });

  @override
  Widget build(BuildContext context) {
    if (!product.hasStoreInfo) return const SizedBox.shrink();

    return Directionality(
      textDirection: isArabic ? ui.TextDirection.rtl : ui.TextDirection.ltr,
      child: InkWell(
        onTap: () => _navigateToStore(context),
        borderRadius: BorderRadius.circular(6),
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
          decoration: BoxDecoration(
            color: AppColours.primary.withValues(alpha: 0.08),
            borderRadius: BorderRadius.circular(6),
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              Expanded(
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Icon(Icons.store,
                        size: 14, color: AppColours.brownMedium),
                    const SizedBox(width: 4),
                    Flexible(
                      child: AutoSizeText(
                        product.storeName!,
                        style: AppTextStyle.semiBold_16_dark_brown
                            .copyWith(fontSize: 12),
                        maxLines: 1,
                        minFontSize: 8,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                    const SizedBox(width: 4),
                    Icon(
                      Icons.arrow_forward_ios,
                      size: 10,
                      color: AppColours.brownMedium.withValues(alpha: 0.6),
                    ),
                  ],
                ),
              ),
              if (product.storeAddress != null &&
                  product.storeAddress!.isNotEmpty)
                Expanded(
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Icon(Icons.location_on,
                          size: 14, color: AppColours.brownMedium),
                      const SizedBox(width: 4),
                      Flexible(
                        child: Text(
                          product.storeAddress!,
                          style: AppTextStyle.normal_14_greyDark
                              .copyWith(fontSize: 11),
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                    ],
                  ),
                ),
              if (product.storePhone != null && product.storePhone!.isNotEmpty)
                Expanded(
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Icon(Icons.phone,
                          size: 14, color: AppColours.brownMedium),
                      const SizedBox(width: 4),
                      Flexible(
                        child: Text(
                          product.storePhone!,
                          style: AppTextStyle.normal_14_greyDark
                              .copyWith(fontSize: 11),
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                    ],
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }

  void _navigateToStore(BuildContext context) {
    if (product.merchantId == null) return;

    final storeName = Uri.encodeComponent(product.storeName ?? '');
    context.push('/store/${product.merchantId}?name=$storeName');
  }
}
