import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../../../Core/Theme/app_colors.dart';

class ProductScreenAppBar extends StatelessWidget {
  const ProductScreenAppBar({super.key});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 12.0),
      child: Row(mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          IconButton(onPressed: () {
            Navigator.pop(context);
          }, icon: Icon(Icons.arrow_back_ios)),
          Container(
            width: 60,
            height: 50,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(12),
              color: Colors.grey[200],
            ),
            child: IconButton(
              onPressed: () {
                context.push('/CartScreen');
              },
              icon: const Icon(
                Icons.shopping_cart,
                size: 25,
                color: AppColours.primaryColor,
              ),
            ),
          ),
        ],
      ),
    );  }


}
