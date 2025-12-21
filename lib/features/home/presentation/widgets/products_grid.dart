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
        double aspectRatio;

        if (constraints.maxWidth > 1200) {
          crossAxisCount = 4;
          aspectRatio = 0.6;
        } else if (constraints.maxWidth > 800) {
          crossAxisCount = 3;
          aspectRatio = 0.65;
        } else {
          crossAxisCount = 2;
          aspectRatio = 0.50;
        }

        return GridView.builder(
          physics: const NeverScrollableScrollPhysics(),
          shrinkWrap: true,
          gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: crossAxisCount,
            crossAxisSpacing: 15.0,
            mainAxisSpacing: 15.0,
            childAspectRatio: aspectRatio,
          ),
          itemCount: products.length,
          itemBuilder: (BuildContext context, int index) {
            return ProductGridCard(product: products[index]);
          },
        );
      },
    );
  }
}
