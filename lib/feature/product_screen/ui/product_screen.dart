import 'package:auto_size_text/auto_size_text.dart';
import 'package:e_commerce/feature/product_screen/ui/widgets/product_screen_appbar.dart';
import 'package:fan_carousel_image_slider/fan_carousel_image_slider.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_rating_bar/flutter_rating_bar.dart';
import 'package:provider/provider.dart';

import '../../../Core/Sharedwidgets/CustomButton.dart';
import '../../../Core/Theme/app_colors.dart';
import '../../../Core/Theme/app_text_style.dart';
import '../../cart_screen/Domain/CartScreenProvider.dart';
import '../../cart_screen/data/models/cart_model.dart';
import '../../home_screen/data/models/ProductModel.dart';
import '../../home_screen/ui/home_screen.dart';

class ProductScreen extends StatefulWidget {
  final ProductModel productModel;

  const ProductScreen({super.key, required this.productModel});

  @override
  State<ProductScreen> createState() => _ProductScreenState();
}

class _ProductScreenState extends State<ProductScreen> {
  int _quantity = 1;

  @override
  Widget build(BuildContext context) {
    double totalPrice = _quantity * widget.productModel.price;
    double screenWidth = MediaQuery.of(context).size.width;
     final cartProvider = Provider.of<CartProvider>(context, listen: true);
    return Scaffold(
      backgroundColor: AppColours.white,
      body: Stack(
        children: <Widget>[
          Padding(
            padding: EdgeInsets.all(screenWidth * 0.04), // Adjust padding
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                SizedBox(height: screenWidth * 0.05),
                ProductScreenAppBar(),
                Expanded(
                  child: ListView(
                    children: [
                      // Type 1
                      FanCarouselImageSlider.sliderType1(
                        autoPlayInterval: Duration(seconds: 3),
                        isClickable: true,
                        imagesLink: widget.productModel.imagePath,
                        imageFitMode: BoxFit.cover,
                        isAssets: true,
                        expandImageHeight: screenWidth * 0.7,
                        // Responsive image height
                        initalPageIndex: 0,
                        autoPlay: true,
                        indicatorActiveColor: AppColours.brownLight,
                        sliderHeight: screenWidth * 0.5,
                        // Responsive slider height
                        sliderWidth: screenWidth,
                        // Responsive slider width
                        expandedImageFitMode: BoxFit.contain,
                        showIndicator: true,
                      ),
                      SizedBox(height: screenWidth * 0.05),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Expanded(
                            child: AutoSizeText(
                              "${widget.productModel.price.toStringAsFixed(2)} EGP",
                              style: AppTextStyle.bold_18_medium_brown.copyWith(
                                fontSize:
                                    screenWidth * 0.04, // Responsive font size
                              ),
                            ),
                          ),
                          Expanded(
                            flex: 2,
                            child: AutoSizeText(
                              textDirection: TextDirection.rtl,
                              textAlign: TextAlign.right,
                              widget.productModel.productName,
                              style:
                                  AppTextStyle.semiBold_20_dark_brown.copyWith(
                                fontSize:
                                    screenWidth * 0.04, // Responsive font size
                              ),
                              maxLines: 2,
                            ),
                          ),
                        ],
                      ),
                      SizedBox(height: screenWidth * 0.02),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.start,
                        children: [
                          RatingBar.builder(
                            initialRating: widget.productModel.rating,
                            minRating: 1,
                            direction: Axis.horizontal,
                            allowHalfRating: true,
                            itemCount: 5,
                            itemSize: screenWidth * 0.05,
                            // Responsive item size
                            itemPadding: EdgeInsets.symmetric(
                                horizontal: screenWidth * 0.02),
                            itemBuilder: (context, _) => Icon(
                              Icons.star,
                              color: Colors.amber,
                            ),
                            onRatingUpdate: (value) {},
                          ),
                          SizedBox(width: screenWidth * 0.02),
                          Text(
                            "(${widget.productModel.rating})",
                            style: AppTextStyle.normal_16_brownLight.copyWith(
                              fontSize:
                                  screenWidth * 0.04, // Responsive font size
                            ),
                          ),
                        ],
                      ),
                      SizedBox(height: screenWidth * 0.02),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.end,
                        children: [
                          Expanded(
                            child: AutoSizeText(
                              widget.productModel.description,
                              style: AppTextStyle.normal_12_black.copyWith(
                                fontSize:
                                    screenWidth * 0.04, // Responsive font size
                              ),
                              textAlign: TextAlign.right,
                              maxLines: 4,
                            ),
                          ),
                        ],
                      ),
                      SizedBox(height: screenWidth * 0.05),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.end,
                        children: [
                          Container(
                            decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(8),
                              border: Border.all(
                                color: AppColours.brownLight,
                              ),
                            ),
                            child: Row(
                              children: [
                                IconButton(
                                  icon: Icon(Icons.remove),
                                  onPressed: () {
                                    setState(() {
                                      if (_quantity > 1) {
                                        _quantity--;
                                      }
                                    });
                                  },
                                ),
                                Text(
                                  '$_quantity',
                                  style: AppTextStyle.normal_16_brownLight
                                      .copyWith(
                                    fontSize: screenWidth *
                                        0.05, // Responsive font size
                                  ),
                                ),
                                IconButton(
                                  icon: Icon(Icons.add),
                                  onPressed: () {
                                    setState(() {
                                      _quantity++;
                                    });
                                  },
                                ),
                              ],
                            ),
                          ),
                          SizedBox(width: screenWidth * 0.04),
                         AutoSizeText(
                            ':الكمية',
                            style: AppTextStyle.normal_16_brownLight.copyWith(
                              fontSize:
                                  screenWidth * 0.05, // Responsive font size
                              ),
                          ),
                        ],
                      ),
                      SizedBox(height: screenWidth * 0.05),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          AutoSizeText(
                            "${totalPrice.toStringAsFixed(2)} EGP",
                            style: AppTextStyle.bold_18_medium_brown.copyWith(
                              fontSize:
                                  screenWidth * 0.04, // Responsive font size
                            ),
                          ),
                          AutoSizeText(
                            ': السعر الكلي',
                            style: AppTextStyle.bold_18_medium_brown.copyWith(
                              fontSize:
                                  screenWidth * 0.04, // Responsive font size
                            ),
                          ),
                        ],
                      ),
                      SizedBox(height: screenWidth * 0.05),
                    ],
                  ),
                ),
              ],
            ),
          ),
          Padding(
            padding: EdgeInsets.all(screenWidth * 0.04),
            child: Align(
              alignment: Alignment.bottomCenter,
              child: SizedBox(
                width: double.infinity,
                child: CustomButton(
                  onPressed: () {
                    cartProvider.updateCart(CartModel(
                      cartQuantity: _quantity,
                      productModel: widget.productModel,
                    ));

                  },
                  label: 'اضف الى السلة',
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
