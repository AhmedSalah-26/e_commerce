import 'package:flutter/material.dart';

import '../../../../core/shared_widgets/product_grid_card.dart';
import '../../../products/domain/entities/product_entity.dart';

class ProductsGrid extends StatelessWidget {
  final List<ProductEntity> products;

  const ProductsGrid({super.key, required this.products});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: GridView.builder(
        physics: const NeverScrollableScrollPhysics(),
        shrinkWrap: true,
        gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: 2,
          crossAxisSpacing: 12,
          mainAxisSpacing: 12,
          childAspectRatio: 0.55,
        ),
        itemCount: products.length,
        itemBuilder: (BuildContext context, int index) {
          return ProductGridCard(product: products[index]);
        },
      ),
    );
  }
}
