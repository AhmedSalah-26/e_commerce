import 'dart:ui' as ui;
import 'package:auto_size_text/auto_size_text.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:fan_carousel_image_slider/fan_carousel_image_slider.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_rating_bar/flutter_rating_bar.dart';

import '../../../../core/di/injection_container.dart';
import '../../../../core/shared_widgets/custom_button.dart';
import '../../../../core/shared_widgets/toast.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_text_style.dart';
import '../../domain/entities/product_entity.dart';
import '../../../cart/presentation/cubit/cart_cubit.dart';
import '../../../cart/presentation/cubit/cart_state.dart';
import '../../../cart/presentation/pages/cart_screen.dart';
import '../../../auth/presentation/cubit/auth_cubit.dart';
import '../../../auth/presentation/cubit/auth_state.dart';
import '../../../reviews/presentation/cubit/reviews_cubit.dart';
import '../../../reviews/presentation/widgets/reviews_section.dart';

class ProductScreen extends StatefulWidget {
  final ProductEntity product;

  const ProductScreen({super.key, required this.product});

  @override
  State<ProductScreen> createState() => _ProductScreenState();
}

class _ProductScreenState extends State<ProductScreen> {
  int _quantity = 1;

  @override
  Widget build(BuildContext context) {
    double totalPrice = _quantity * widget.product.effectivePrice;
    double screenWidth = MediaQuery.of(context).size.width;
    final isArabic = context.locale.languageCode == 'ar';

    return BlocProvider(
      create: (context) => sl<ReviewsCubit>(),
      child: Scaffold(
        backgroundColor: AppColours.white,
        appBar: AppBar(
          backgroundColor: AppColours.white,
          elevation: 0,
          leading: IconButton(
            icon:
                const Icon(Icons.arrow_back_ios, color: AppColours.brownMedium),
            onPressed: () => Navigator.pop(context),
          ),
          actions: [
            BlocBuilder<CartCubit, CartState>(
              builder: (context, cartState) {
                final cartItemCount = cartState is CartLoaded
                    ? cartState.items
                        .fold<int>(0, (sum, item) => sum + item.quantity)
                    : 0;

                return Padding(
                  padding: const EdgeInsets.only(left: 8),
                  child: IconButton(
                    onPressed: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                            builder: (context) => const CartScreen()),
                      );
                    },
                    icon: Stack(
                      clipBehavior: Clip.none,
                      children: [
                        const Icon(Icons.shopping_cart_outlined,
                            color: AppColours.brownMedium),
                        if (cartItemCount > 0)
                          Positioned(
                            right: -8,
                            top: -4,
                            child: Container(
                              padding: const EdgeInsets.all(4),
                              decoration: const BoxDecoration(
                                color: Colors.red,
                                shape: BoxShape.circle,
                              ),
                              constraints: const BoxConstraints(
                                  minWidth: 18, minHeight: 18),
                              child: Text(
                                cartItemCount > 99 ? '99+' : '$cartItemCount',
                                style: const TextStyle(
                                  color: Colors.white,
                                  fontSize: 10,
                                  fontWeight: FontWeight.bold,
                                ),
                                textAlign: TextAlign.center,
                              ),
                            ),
                          ),
                      ],
                    ),
                  ),
                );
              },
            ),
          ],
        ),
        body: Stack(
          children: <Widget>[
            Padding(
              padding: EdgeInsets.all(screenWidth * 0.04),
              child: ListView(
                children: [
                  // Image Slider
                  if (widget.product.images.isNotEmpty)
                    FanCarouselImageSlider.sliderType1(
                      autoPlayInterval: const Duration(seconds: 3),
                      isClickable: true,
                      imagesLink: widget.product.images,
                      imageFitMode: BoxFit.cover,
                      isAssets: !widget.product.images.first.startsWith('http'),
                      expandImageHeight: screenWidth * 0.7,
                      initalPageIndex: 0,
                      autoPlay: widget.product.images.length > 1,
                      indicatorActiveColor: AppColours.brownLight,
                      sliderHeight: screenWidth * 0.5,
                      sliderWidth: screenWidth,
                      expandedImageFitMode: BoxFit.contain,
                      showIndicator: widget.product.images.length > 1,
                    )
                  else
                    Container(
                      height: screenWidth * 0.5,
                      decoration: BoxDecoration(
                        color: AppColours.greyLight,
                        borderRadius: BorderRadius.circular(15),
                      ),
                      child: const Center(
                        child: Icon(Icons.image_not_supported,
                            size: 80, color: Colors.grey),
                      ),
                    ),
                  SizedBox(height: screenWidth * 0.05),
                  // Price and Name
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            if (widget.product.hasDiscount)
                              AutoSizeText(
                                "${widget.product.price.toStringAsFixed(2)} EGP",
                                style: TextStyle(
                                  fontSize: screenWidth * 0.03,
                                  color: Colors.grey,
                                  decoration: TextDecoration.lineThrough,
                                ),
                              ),
                            AutoSizeText(
                              "${widget.product.effectivePrice.toStringAsFixed(2)} EGP",
                              style: AppTextStyle.bold_18_medium_brown
                                  .copyWith(fontSize: screenWidth * 0.04),
                            ),
                          ],
                        ),
                      ),
                      Expanded(
                        flex: 2,
                        child: AutoSizeText(
                          textDirection: isArabic
                              ? ui.TextDirection.rtl
                              : ui.TextDirection.ltr,
                          textAlign:
                              isArabic ? TextAlign.right : TextAlign.left,
                          widget.product.name,
                          style: AppTextStyle.semiBold_20_dark_brown
                              .copyWith(fontSize: screenWidth * 0.04),
                          maxLines: 2,
                        ),
                      ),
                    ],
                  ),
                  SizedBox(height: screenWidth * 0.02),
                  // Rating
                  Row(
                    mainAxisAlignment: MainAxisAlignment.start,
                    children: [
                      RatingBarIndicator(
                        rating: widget.product.rating,
                        direction: Axis.horizontal,
                        itemCount: 5,
                        itemSize: screenWidth * 0.05,
                        itemPadding: EdgeInsets.symmetric(
                            horizontal: screenWidth * 0.02),
                        itemBuilder: (context, _) =>
                            const Icon(Icons.star, color: Colors.amber),
                      ),
                      SizedBox(width: screenWidth * 0.02),
                      Text(
                        "(${widget.product.rating.toStringAsFixed(1)})",
                        style: AppTextStyle.normal_16_brownLight
                            .copyWith(fontSize: screenWidth * 0.04),
                      ),
                    ],
                  ),
                  SizedBox(height: screenWidth * 0.02),
                  // Stock Status
                  Row(
                    mainAxisAlignment: MainAxisAlignment.end,
                    children: [
                      Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 12, vertical: 4),
                        decoration: BoxDecoration(
                          color: widget.product.isOutOfStock
                              ? Colors.red.shade100
                              : Colors.green.shade100,
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Text(
                          widget.product.isOutOfStock
                              ? 'out_of_stock'.tr()
                              : '${'in_stock'.tr()} (${widget.product.stock})',
                          style: TextStyle(
                            color: widget.product.isOutOfStock
                                ? Colors.red
                                : Colors.green,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ],
                  ),
                  SizedBox(height: screenWidth * 0.02),
                  // Description
                  Row(
                    mainAxisAlignment: MainAxisAlignment.end,
                    children: [
                      Expanded(
                        child: AutoSizeText(
                          widget.product.description,
                          style: AppTextStyle.normal_12_black
                              .copyWith(fontSize: screenWidth * 0.04),
                          textAlign:
                              isArabic ? TextAlign.right : TextAlign.left,
                          maxLines: 6,
                        ),
                      ),
                    ],
                  ),
                  SizedBox(height: screenWidth * 0.05),
                  // Quantity Selector
                  if (!widget.product.isOutOfStock)
                    Row(
                      mainAxisAlignment: MainAxisAlignment.end,
                      children: [
                        Container(
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(8),
                            border: Border.all(color: AppColours.brownLight),
                          ),
                          child: Row(
                            children: [
                              IconButton(
                                icon: const Icon(Icons.remove),
                                onPressed: () {
                                  setState(() {
                                    if (_quantity > 1) _quantity--;
                                  });
                                },
                              ),
                              Text(
                                '$_quantity',
                                style: AppTextStyle.normal_16_brownLight
                                    .copyWith(fontSize: screenWidth * 0.05),
                              ),
                              IconButton(
                                icon: const Icon(Icons.add),
                                onPressed: () {
                                  setState(() {
                                    if (_quantity < widget.product.stock)
                                      _quantity++;
                                  });
                                },
                              ),
                            ],
                          ),
                        ),
                        SizedBox(width: screenWidth * 0.04),
                        AutoSizeText(
                          '${'quantity'.tr()}:',
                          style: AppTextStyle.normal_16_brownLight
                              .copyWith(fontSize: screenWidth * 0.05),
                        ),
                      ],
                    ),
                  SizedBox(height: screenWidth * 0.05),
                  // Total Price
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      AutoSizeText(
                        "${totalPrice.toStringAsFixed(2)} EGP",
                        style: AppTextStyle.bold_18_medium_brown
                            .copyWith(fontSize: screenWidth * 0.04),
                      ),
                      AutoSizeText(
                        '${'total'.tr()}:',
                        style: AppTextStyle.bold_18_medium_brown
                            .copyWith(fontSize: screenWidth * 0.04),
                      ),
                    ],
                  ),
                  SizedBox(height: screenWidth * 0.05),
                  // Reviews Section
                  ReviewsSection(productId: widget.product.id),
                  SizedBox(height: screenWidth * 0.2),
                ],
              ),
            ),
            // Add to Cart Button
            Positioned(
              bottom: 16,
              left: 16,
              right: 16,
              child: CustomButton(
                color: widget.product.isOutOfStock
                    ? Colors.grey
                    : AppColours.brownLight,
                onPressed: widget.product.isOutOfStock
                    ? () {
                        Tost.showCustomToast(
                          context,
                          'out_of_stock'.tr(),
                          backgroundColor: Colors.red,
                          textColor: Colors.white,
                        );
                      }
                    : () => _addToCart(context),
                label: widget.product.isOutOfStock
                    ? 'out_of_stock'.tr()
                    : 'add_to_cart'.tr(),
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _addToCart(BuildContext context) {
    final authState = context.read<AuthCubit>().state;
    if (authState is AuthAuthenticated) {
      context.read<CartCubit>().setUserId(authState.user.id);
      context
          .read<CartCubit>()
          .addToCart(widget.product.id, quantity: _quantity);
      Tost.showCustomToast(
        context,
        'added_to_cart'.tr(),
        backgroundColor: Colors.green,
        textColor: Colors.white,
      );
    } else {
      Tost.showCustomToast(
        context,
        'login_required'.tr(),
        backgroundColor: Colors.orange,
        textColor: Colors.white,
      );
    }
  }
}
