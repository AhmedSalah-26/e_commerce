import 'package:flutter/cupertino.dart';
import '../../../../Core/Sharedwidgets/Product_list_Card.dart';

class ProductListUi extends StatelessWidget {
  final List products;

  const ProductListUi({super.key, required this.products});

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 340,
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        itemCount: products.length,
        itemBuilder: (BuildContext context, int index) {
          return ProductListCard(
            product: products[index],
          );
        },
      ),
    );
  }
}
