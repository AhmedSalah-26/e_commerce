import 'package:auto_size_text/auto_size_text.dart';
import 'package:e_commerce/feature/cart_screen/Domain/CartScreenProvider.dart';
import 'package:e_commerce/feature/cart_screen/data/models/cart_model.dart';
import 'package:e_commerce/feature/home_screen/Domain/home_screen_provider.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../feature/favorite_page_screen/Domain/favorite_screen_provider.dart';
import '../../feature/home_screen/data/models/ProductModel.dart';
import '../Theme/app_colors.dart';
import '../Theme/app_text_style.dart';
import 'CustomButton.dart';
import '../../feature/product_screen/ui/product_screen.dart';
import '../../feature/home_screen/ui/home_screen.dart';

class ProductGridCard extends StatefulWidget {
  final ProductModel product;

  const ProductGridCard({
    Key? key,
    required this.product,
  }) : super(key: key);

  @override
  State<ProductGridCard> createState() => _ProductGridCardState();
}

class _ProductGridCardState extends State<ProductGridCard> {

  @override
  Widget build(BuildContext context) {
    bool isfavorite = widget.product.isfavorite;

    // Get screen width and height using MediaQuery
    final screenWidth = MediaQuery.of(context).size.width;
    final screenHeight = MediaQuery.of(context).size.height;

    return MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => CartProvider()),

        ChangeNotifierProvider(create: (_) => HomeScreenProvider()),

        ChangeNotifierProvider(create: (_) => FavoriteScreenProvider()),
      ],
      child: GestureDetector(
        onTap: () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => ProductScreen(
                productModel: widget.product,
              ),
            ),
          );
        },
        child: Container(
          width: screenWidth * 0.45, // Make card width responsive (45% of screen width)
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(15),
            color: Colors.white,
            boxShadow: [
              BoxShadow(
                color: AppColours.greyLight.withOpacity(0.3),
                spreadRadius: 2,
                blurRadius: 5,
                offset: Offset(0, 3),
              ),
            ],
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              // Product Image and Favorite Button
              Stack(
                children: [
                  Container(
                    height: screenHeight * 0.2, // Make image height responsive (20% of screen height)
                    decoration: BoxDecoration(
                      image: DecorationImage(
                        image: AssetImage(widget.product.imagePath[0]),
                        fit: BoxFit.cover,
                      ),
                      borderRadius: BorderRadius.only(
                        topLeft: Radius.circular(15),
                        topRight: Radius.circular(15),
                      ),
                      color: AppColours.brownLight,
                    ),
                  ),
                  Positioned(
                    top: 8,
                    right: 8,
                    child: CircleAvatar(
                      backgroundColor: Colors.white,
                      child: IconButton(
                        onPressed: () {
                          final favoriteProvider = Provider.of<FavoriteScreenProvider>(context, listen: false);

                          setState(() {
                            if (isfavorite) {
                              widget.product.isfavorite = false;
                              favoriteProvider.removeFromFavorite(widget.product);

                            } else {
                              widget.product.isfavorite = true;
                              favoriteProvider.addToFavorite(widget.product);
                            }

                          });
                        },
                        icon: Icon(
                          isfavorite? Icons.favorite : Icons.favorite_border,
                          color: AppColours.brownMedium,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 8),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 8.0),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    AutoSizeText(
                      widget.product.productName.length > 20
                          ? widget.product.productName.substring(0, 20) + '...' // عرض أول 10 أحرف مع نقاط
                          : widget.product.productName, // عرض النص كاملاً إذا كان طوله 10 أحرف أو أقل
                      textDirection: TextDirection.rtl, // Set text direction to RTL for Arabic
                      style: AppTextStyle.normal_12_black.copyWith(
                        fontWeight: FontWeight.bold,
                        fontSize: screenWidth * 0.04, // Adjust text size based on screen width
                      ),
                      minFontSize: 10, // Minimum font size when the text is too long
                      overflow: TextOverflow.ellipsis, // Handle overflow
                      maxLines: 1, // Ensure the text stays on one line
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 4),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 8.0),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceAround,
                  children: [
                    Icon(
                      Icons.star,
                      color: Colors.amber,
                      size: screenWidth * 0.05, // Adjust star size
                    ),
                    Text(
                      "(${widget.product.rating})",
                      style: AppTextStyle.normal_12_black.copyWith(
                        fontSize: screenWidth * 0.035, // Adjust text size
                      ),
                    ),
                    const SizedBox(width: 8),
                    Text(
                      "${widget.product.price.toStringAsFixed(2)} EGP",
                      style: AppTextStyle.semiBold_16_dark_brown.copyWith(
                        fontSize: screenWidth * 0.04, // Adjust price font size
                        color: AppColours.brownMedium,
                      ),
                    ),
                  ],
                ),
              ),
              SizedBox(height: screenHeight * 0.015), // Adjust spacing based on screen height
              Padding(
                padding: const EdgeInsets.all(8.0),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceAround,
                  children: [
                    Container(
                      width: screenWidth * 0.35, // Adjust button width
                      child: CustomButton(
                        color: AppColours.brownLight,
                        onPressed: () {
                          final CartScreenProvider = Provider.of<CartProvider>(context, listen: false);

                          CartScreenProvider.updateCart(CartModel(
                            cartQuantity: 1,
                            productModel: widget.product,
                          ),
                          );
                        },
                        label: 'اضف للسلة',
                        labelSize: screenWidth * 0.04, // Adjust button label size
                      ),
                    ),
                  ],
                ),
              ),
              SizedBox(height: screenHeight * 0.015), // Adjust spacing based on screen height

            ],
          ),
        ),
      ),
    );
  }
}
