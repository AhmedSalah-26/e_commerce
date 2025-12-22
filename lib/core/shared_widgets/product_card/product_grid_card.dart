import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';

import '../../../features/products/domain/entities/product_entity.dart';
import '../../../features/products/presentation/pages/product_screen.dart';
import '../../theme/app_colors.dart';
import 'product_image_section.dart';
import 'product_info_section.dart';

/// Main ProductGridCard - delegates to smaller widgets
class ProductGridCard extends StatelessWidget {
  final ProductEntity product;

  const ProductGridCard({super.key, required this.product});

  @override
  Widget build(BuildContext context) {
    final isArabic = context.locale.languageCode == 'ar';

    return GestureDetector(
      onTap: () => _navigateToProduct(context),
      child: Container(
        decoration: _cardDecoration,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Expanded(child: ProductImageSection(product: product)),
            ProductInfoSection(product: product, isArabic: isArabic),
          ],
        ),
      ),
    );
  }

  void _navigateToProduct(BuildContext context) {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (_) => ProductScreen(product: product)),
    );
  }

  static final _cardDecoration = BoxDecoration(
    borderRadius: BorderRadius.circular(8),
    color: Colors.white,
    border: Border.all(color: AppColours.greyLight.withValues(alpha: 0.3)),
    boxShadow: [
      BoxShadow(
        color: Colors.black.withValues(alpha: 0.05),
        spreadRadius: 0,
        blurRadius: 4,
        offset: const Offset(0, 2),
      ),
    ],
  );
}
