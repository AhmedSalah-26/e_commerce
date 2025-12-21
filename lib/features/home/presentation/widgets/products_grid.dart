import 'package:flutter/material.dart';

import '../../../../core/shared_widgets/product_grid_card.dart';
import '../../../products/domain/entities/product_entity.dart';

class ProductsGrid extends StatelessWidget {
  final List<ProductEntity> products;

  const ProductsGrid({super.key, required this.products});

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        int crossAxisCount;
        double childAspectRatio;

        if (constraints.maxWidth > 1200) {
          crossAxisCount = 4;
          childAspectRatio = 0.72;
        } else if (constraints.maxWidth > 800) {
          crossAxisCount = 3;
          childAspectRatio = 0.70;
        } else {
          crossAxisCount = 2;
          childAspectRatio = 0.68;
        }

        return Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16),
          child: GridView.builder(
            physics: const NeverScrollableScrollPhysics(),
            shrinkWrap: true,
            gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: crossAxisCount,
              crossAxisSpacing: 12,
              mainAxisSpacing: 12,
              childAspectRatio: childAspectRatio,
            ),
            itemCount: products.length,
            itemBuilder: (BuildContext context, int index) {
              return ProductGridCard(product: products[index]);
            },
          ),
        );
      },
    );
  }
}
