import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../feature/home_screen/data/models/ProductModel.dart';
import '../../feature/product_screen/ui/product_screen.dart';
import '../../feature/home_screen/ui/home_screen.dart';
import '../Theme/app_colors.dart';
import '../Theme/app_text_style.dart';

class ProductListCard extends StatefulWidget {
  final ProductModel product;

  const ProductListCard({
    Key? key,
    required this.product,
  }) : super(key: key);

  @override
  State<ProductListCard> createState() => _ProductListCardState();
}

class _ProductListCardState extends State<ProductListCard> {
  bool isSelected = false;

  @override
  Widget build(BuildContext context) {
    // Get screen width and height using MediaQuery
    final screenWidth = MediaQuery.of(context).size.width;
    final screenHeight = MediaQuery.of(context).size.height;

    return MaterialButton(
      onPressed: () {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => ProductScreen(
              productModel: widget.product,
            ),
          ),
        );
      },
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            height: screenHeight * 0.3, // Adjust image height to 30% of screen height
            width: screenWidth * 0.45, // Adjust width to 45% of screen width
            decoration: BoxDecoration(
              image: DecorationImage(
                image: AssetImage(widget.product.imagePath[0]),
                fit: BoxFit.cover,
              ),
              borderRadius: BorderRadius.circular(25),
            ),
            child: Align(
              alignment: Alignment.topRight,
              child: Padding(
                padding: const EdgeInsets.all(8.0),
                child: CircleAvatar(
                  backgroundColor: Colors.white,
                  child: IconButton(
                    onPressed: () {
                      setState(() {
                        isSelected = !isSelected;
                      });
                      // Call the callback or handle favorite logic here
                    },
                    icon: Icon(
                      isSelected ? Icons.favorite : Icons.favorite_border,
                      color: AppColours.brownLight,
                    ),
                  ),
                ),
              ),
            ),
          ),
          SizedBox(height: screenHeight * 0.02), // Add responsive spacing
          Text(
            widget.product.productName,
            style: AppTextStyle.semiBold_20_dark_brown.copyWith(
              color: AppColours.black,
              fontSize: screenWidth * 0.05, // Adjust text size based on screen width
            ),
          ),
          SizedBox(height: screenHeight * 0.01), // Add responsive spacing
          Row(
            children: [
              Icon(
                Icons.star,
                color: Colors.amber,
                size: screenWidth * 0.05, // Adjust star icon size based on screen width
              ),
              Text(
                "(${widget.product.rating})",
                style: AppTextStyle.normal_12_black.copyWith(
                  fontSize: screenWidth * 0.04, // Adjust text size based on screen width
                ),
              ),
              const SizedBox(width: 8),
              Text(
                "\$${widget.product.price.toStringAsFixed(2)}",
                style: AppTextStyle.semiBold_20_dark_brown.copyWith(
                  color: AppColours.brownMedium,
                  fontSize: screenWidth * 0.05, // Adjust text size based on screen width
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
