import 'package:flutter/material.dart';
import 'package:e_commerce/Core/Sharedwidgets/product_grid_card.dart';

class GridProductsUi extends StatelessWidget {
  final List products;

  const GridProductsUi({super.key, required this.products});

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        // Determine the number of columns based on the screen width
        int crossAxisCount;
        double aspectRatio;

        if (constraints.maxWidth > 1200) {
          // Large screens (e.g., tablets or desktops)
          crossAxisCount = 4;
          aspectRatio = 0.6;
        } else if (constraints.maxWidth > 800) {
          // Medium screens (e.g., large phones)
          crossAxisCount = 3;
          aspectRatio = 0.65;
        } else {
          // Small screens (e.g., regular phones)
          crossAxisCount = 2;
          aspectRatio = 0.50;
        }

        return GridView.builder(
          physics: NeverScrollableScrollPhysics(),
          shrinkWrap: true,
          gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: crossAxisCount,
            crossAxisSpacing: 15.0,
            mainAxisSpacing: 15.0,
            childAspectRatio: aspectRatio,
          ),
          itemCount: products.length,
          itemBuilder: (BuildContext context, int index) {
            return ProductGridCard(
              product: products[index],
            );
          },
        );
      },
    );
  }
}
