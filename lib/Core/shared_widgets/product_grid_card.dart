import 'dart:ui' as ui;
import 'package:auto_size_text/auto_size_text.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../features/products/domain/entities/product_entity.dart';
import '../../features/products/presentation/pages/product_screen.dart';
import '../../features/cart/presentation/cubit/cart_cubit.dart';
import '../../features/favorites/presentation/cubit/favorites_cubit.dart';
import '../../features/favorites/presentation/cubit/favorites_state.dart';
import '../../features/auth/presentation/cubit/auth_cubit.dart';
import '../../features/auth/presentation/cubit/auth_state.dart';
import '../theme/app_colors.dart';
import '../theme/app_text_style.dart';
import 'custom_button.dart';
import 'toast.dart';

class ProductGridCard extends StatelessWidget {
  final ProductEntity product;

  const ProductGridCard({super.key, required this.product});

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final screenHeight = MediaQuery.of(context).size.height;
    final isArabic = context.locale.languageCode == 'ar';

    return GestureDetector(
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(
              builder: (context) => ProductScreen(product: product)),
        );
      },
      child: Container(
        width: screenWidth * 0.45,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(15),
          color: Colors.white,
          boxShadow: [
            BoxShadow(
              color: AppColours.greyLight.withValues(alpha: 0.3),
              spreadRadius: 2,
              blurRadius: 5,
              offset: const Offset(0, 3),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Stack(
              children: [
                Container(
                  height: screenHeight * 0.2,
                  decoration: BoxDecoration(
                    image: product.mainImage.isNotEmpty
                        ? DecorationImage(
                            image: _getImageProvider(product.mainImage),
                            fit: BoxFit.cover,
                          )
                        : null,
                    borderRadius: const BorderRadius.only(
                      topLeft: Radius.circular(15),
                      topRight: Radius.circular(15),
                    ),
                    color: AppColours.brownLight,
                  ),
                  child: product.mainImage.isEmpty
                      ? const Center(
                          child: Icon(Icons.image_not_supported,
                              size: 50, color: Colors.white),
                        )
                      : null,
                ),
                // Favorite button
                Positioned(
                  top: 8,
                  left: 8,
                  child: BlocBuilder<FavoritesCubit, FavoritesState>(
                    builder: (context, state) {
                      final isFav = state is FavoritesLoaded &&
                          state.isFavorite(product.id);
                      return GestureDetector(
                        onTap: () => _toggleFavorite(context),
                        child: Container(
                          padding: const EdgeInsets.all(6),
                          decoration: BoxDecoration(
                            color: Colors.white.withValues(alpha: 0.9),
                            shape: BoxShape.circle,
                          ),
                          child: Icon(
                            isFav ? Icons.favorite : Icons.favorite_border,
                            color: Colors.red,
                            size: 20,
                          ),
                        ),
                      );
                    },
                  ),
                ),
                if (product.isOutOfStock)
                  Positioned(
                    top: 8,
                    right: 8,
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 8, vertical: 4),
                      decoration: BoxDecoration(
                        color: Colors.red,
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Text('out_of_stock'.tr(),
                          style: const TextStyle(
                              color: Colors.white, fontSize: 12)),
                    ),
                  ),
                if (product.hasDiscount && !product.isOutOfStock)
                  Positioned(
                    top: 8,
                    right: 8,
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 8, vertical: 4),
                      decoration: BoxDecoration(
                        color: Colors.green,
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Text(
                        '${product.discountPercentage}%-',
                        style:
                            const TextStyle(color: Colors.white, fontSize: 12),
                      ),
                    ),
                  ),
              ],
            ),
            const SizedBox(height: 8),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 8.0),
              child: AutoSizeText(
                product.name,
                textDirection:
                    isArabic ? ui.TextDirection.rtl : ui.TextDirection.ltr,
                style: AppTextStyle.normal_12_black.copyWith(
                  fontWeight: FontWeight.bold,
                  fontSize: screenWidth * 0.04,
                ),
                minFontSize: 10,
                overflow: TextOverflow.ellipsis,
                maxLines: 1,
                textAlign: isArabic ? TextAlign.right : TextAlign.left,
              ),
            ),
            const SizedBox(height: 4),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 8.0),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceAround,
                children: [
                  Icon(Icons.star,
                      color: Colors.amber, size: screenWidth * 0.05),
                  Text(
                    "(${product.rating.toStringAsFixed(1)})",
                    style: AppTextStyle.normal_12_black
                        .copyWith(fontSize: screenWidth * 0.035),
                  ),
                  const SizedBox(width: 8),
                  Column(
                    children: [
                      if (product.hasDiscount)
                        Text(
                          "${product.price.toStringAsFixed(2)} EGP",
                          style: TextStyle(
                            fontSize: screenWidth * 0.03,
                            color: Colors.grey,
                            decoration: TextDecoration.lineThrough,
                          ),
                        ),
                      Text(
                        "${product.effectivePrice.toStringAsFixed(2)} EGP",
                        style: AppTextStyle.semiBold_16_dark_brown.copyWith(
                          fontSize: screenWidth * 0.04,
                          color: AppColours.brownMedium,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
            SizedBox(height: screenHeight * 0.015),
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: Center(
                child: SizedBox(
                  width: screenWidth * 0.35,
                  child: CustomButton(
                    color: product.isOutOfStock
                        ? Colors.grey
                        : AppColours.brownLight,
                    onPressed: product.isOutOfStock
                        ? () => Tost.showCustomToast('out_of_stock'.tr(),
                            backgroundColor: Colors.red)
                        : () => _addToCart(context),
                    label: product.isOutOfStock
                        ? 'out_of_stock'.tr()
                        : 'add_to_cart'.tr(),
                    labelSize: screenWidth * 0.04,
                  ),
                ),
              ),
            ),
            SizedBox(height: screenHeight * 0.015),
          ],
        ),
      ),
    );
  }

  ImageProvider _getImageProvider(String imageUrl) {
    if (imageUrl.startsWith('http')) {
      return NetworkImage(imageUrl);
    }
    return AssetImage(imageUrl);
  }

  void _addToCart(BuildContext context) {
    final authState = context.read<AuthCubit>().state;
    if (authState is AuthAuthenticated) {
      // Set user ID first, then add to cart
      context.read<CartCubit>().setUserId(authState.user.id);
      context.read<CartCubit>().addToCart(product.id);
      Tost.showCustomToast('added_to_cart'.tr(), backgroundColor: Colors.green);
    } else {
      Tost.showCustomToast('login_required'.tr(),
          backgroundColor: Colors.orange);
    }
  }

  void _toggleFavorite(BuildContext context) {
    final authState = context.read<AuthCubit>().state;
    if (authState is AuthAuthenticated) {
      final favoritesCubit = context.read<FavoritesCubit>();

      // Set user ID first
      favoritesCubit.setUserId(authState.user.id);

      final isFav = favoritesCubit.isFavorite(product.id);

      favoritesCubit.toggleFavorite(product.id);

      if (isFav) {
        Tost.showCustomToast('removed_from_favorites'.tr(),
            backgroundColor: Colors.grey);
      } else {
        Tost.showCustomToast('added_to_favorites'.tr(),
            backgroundColor: Colors.red);
      }
    } else {
      Tost.showCustomToast('login_required'.tr(),
          backgroundColor: Colors.orange);
    }
  }
}
