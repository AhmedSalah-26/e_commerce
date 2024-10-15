import 'package:e_commerce/feature/cart_screen/data/models/cart_model.dart';
import 'package:flutter/material.dart';
import 'package:flutter_slidable/flutter_slidable.dart';

import '../../../../Core/Theme/app_colors.dart';
import '../../../../Core/Theme/app_text_style.dart';
import '../../../home_screen/data/models/ProductModel.dart';
import '../../../home_screen/ui/home_screen.dart';

// Example list of cart items

// ProductCard widget
class ProductCardCart extends StatelessWidget {
  final CartModel product;
  final VoidCallback onIncreaseQuantity;
  final VoidCallback onDecreaseQuantity;
  final VoidCallback onRemove;

  const ProductCardCart({
    required this.product,
    required this.onIncreaseQuantity,
    required this.onDecreaseQuantity,
    required this.onRemove, required cartQuantity,
  });

  @override
  Widget build(BuildContext context) {
    double screenWidth = MediaQuery.of(context).size.width;
    double screenHeight = MediaQuery.of(context).size.height;
    double cardWidth = screenWidth * 0.9; // Card width 90% of screen width
    double cardHeight = screenHeight * 0.2; // Card height 20% of screen height
    double imageSize = cardHeight * 0.4; // Image size 40% of card height
    double fontSize = screenWidth * 0.04; // Font size 4% of screen width

    double totalPrice = product.productModel.price * product.cartQuantity;

    return Slidable(
      key: ValueKey('${product.productModel.productName}_${product.toString()}'),
      endActionPane: ActionPane(
        motion: ScrollMotion(),
        children: [
          GestureDetector(
            onTap: onRemove,
            child: Padding(
              padding: const EdgeInsets.all(8.0),
              child: Container(
                width: cardWidth * 0.3, // 30% of card width
                height: cardHeight * 0.5, // 50% of card height
                decoration: BoxDecoration(
                  color: AppColours.white,
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: <Widget>[
                    Icon(
                      Icons.delete,
                      color: Colors.red,
                      size: fontSize * 1.2, // Adjust icon size
                    ),
                    Text(
                      "Delete",
                      style: AppTextStyle.bold_14_medium_brown.copyWith(fontSize: fontSize * 0.8),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
      child: Container(
        margin: EdgeInsets.symmetric(vertical: screenHeight * 0.02),
        width: cardWidth,
        decoration: BoxDecoration(
          boxShadow: [
            BoxShadow(
              color: Colors.grey.withOpacity(0.2),
              spreadRadius: 1,
              blurRadius: 2,
              offset: Offset(0, 1),
            ),
          ],
          borderRadius: BorderRadius.circular(10),
          border: Border.all(color: AppColours.greyLighter),
          color: Colors.white,
        ),
        child: Padding(
          padding: EdgeInsets.all(screenWidth * 0.03), // Padding 3% of screen width
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              // Quantity control (left)
              Container(
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(10),
                  color: AppColours.greyLight,
                ),
                child: Column(
                  children: [
                    IconButton(
                      icon: Icon(Icons.add, color: Colors.green, size: fontSize * 1.2),
                      onPressed: onIncreaseQuantity,
                    ),
                    Text(
                      '${product.cartQuantity}',
                      style: AppTextStyle.bold_18_medium_brown.copyWith(fontSize: fontSize),
                    ),
                    IconButton(
                      icon: Icon(Icons.remove, color: Colors.red, size: fontSize * 1.2),
                      onPressed: onDecreaseQuantity,
                    ),
                  ],
                ),
              ),
              SizedBox(width: screenWidth * 0.04),
              Expanded(
                child: Container(
                  height: cardHeight * 0.6, // 60% of card height
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.end,
                    mainAxisAlignment: MainAxisAlignment.spaceAround,
                    children: [
                      // Product name
                      Text(
                        product.productModel.productName,
                        style: AppTextStyle.bold_18_medium_brown.copyWith(fontSize: fontSize),
                      ),
                      // Unit price
                      Text(
                        'سعر القطعة: EGP ${product.productModel.price.toStringAsFixed(2)}',
                        style: AppTextStyle.normal_16_brownLight.copyWith(fontSize: fontSize * 0.8),
                      ),
                      // Total price
                      Text(
                        'السعر الكلي: EGP ${totalPrice.toStringAsFixed(2)}',
                        style: AppTextStyle.semiBold_16_dark_brown.copyWith(fontSize: fontSize * 0.8),
                      ),
                    ],
                  ),
                ),
              ),
              SizedBox(width: screenWidth * 0.02),
              // Image container (middle)
              Container(
                width: imageSize,
                height: imageSize,
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(8),
                  child: Image.asset(
                    product.productModel.imagePath[0],
                    fit: BoxFit.cover,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
