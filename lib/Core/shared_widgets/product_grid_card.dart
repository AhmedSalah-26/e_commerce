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
import 'toast.dart';

class ProductGridCard extends StatelessWidget {
  final ProductEntity product;

  const ProductGridCard({super.key, required this.product});

  @override
  Widget build(BuildContext context) {
    final isArabic = context.locale.languageCode == 'ar';

    return GestureDetector(
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(
              builder: (context) => ProductScreen(product: product)),
        );
      },
      child: ClipRRect(
        borderRadius: BorderRadius.circular(12),
        child: Container(
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(12),
            color: Colors.white,
            boxShadow: [
              BoxShadow(
                color: AppColours.greyLight.withValues(alpha: 0.2),
                spreadRadius: 1,
                blurRadius: 4,
                offset: const Offset(0, 2),
              ),
            ],
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Image Section - takes flexible space
              Expanded(
                flex: 3,
                child: Stack(
                  clipBehavior: Clip.hardEdge,
                  children: [
                    Container(
                      width: double.infinity,
                      decoration: const BoxDecoration(
                        borderRadius: BorderRadius.only(
                          topLeft: Radius.circular(12),
                          topRight: Radius.circular(12),
                        ),
                        color: AppColours.brownLight,
                      ),
                      child: ClipRRect(
                        borderRadius: const BorderRadius.only(
                          topLeft: Radius.circular(12),
                          topRight: Radius.circular(12),
                        ),
                        child: _buildProductImage(product.mainImage),
                      ),
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
                    // Discount or Out of Stock badge
                    if (product.isOutOfStock)
                      Positioned(
                        top: 8,
                        right: 8,
                        child: Container(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 6, vertical: 3),
                          decoration: BoxDecoration(
                            color: Colors.red,
                            borderRadius: BorderRadius.circular(6),
                          ),
                          child: Text('out_of_stock'.tr(),
                              style: const TextStyle(
                                  color: Colors.white, fontSize: 9)),
                        ),
                      )
                    else if (product.hasDiscount)
                      Positioned(
                        top: 8,
                        right: 8,
                        child: Container(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 6, vertical: 3),
                          decoration: BoxDecoration(
                            color: Colors.green,
                            borderRadius: BorderRadius.circular(6),
                          ),
                          child: Text(
                            '${product.discountPercentage}%-',
                            style: const TextStyle(
                                color: Colors.white, fontSize: 9),
                          ),
                        ),
                      ),
                  ],
                ),
              ),
              // Product Info
              Expanded(
                flex: 2,
                child: Directionality(
                  textDirection:
                      isArabic ? ui.TextDirection.rtl : ui.TextDirection.ltr,
                  child: Padding(
                    padding: const EdgeInsets.fromLTRB(8, 6, 8, 4),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          product.name,
                          style: AppTextStyle.normal_12_black.copyWith(
                            fontWeight: FontWeight.bold,
                            fontSize: 13,
                          ),
                          overflow: TextOverflow.ellipsis,
                          maxLines: 1,
                        ),
                        const SizedBox(height: 2),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                const Icon(Icons.star,
                                    color: Colors.amber, size: 12),
                                const SizedBox(width: 2),
                                Text(
                                  "(${product.rating.toStringAsFixed(1)})",
                                  style: const TextStyle(fontSize: 10),
                                ),
                              ],
                            ),
                            Column(
                              crossAxisAlignment: CrossAxisAlignment.end,
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                if (product.hasDiscount)
                                  AutoSizeText(
                                    "${product.price.toStringAsFixed(0)} ${'egp'.tr()}",
                                    style: const TextStyle(
                                      fontSize: 10,
                                      color: Colors.grey,
                                      decoration: TextDecoration.lineThrough,
                                    ),
                                    minFontSize: 8,
                                    maxLines: 1,
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                AutoSizeText(
                                  "${product.effectivePrice.toStringAsFixed(0)} ${'egp'.tr()}",
                                  style: const TextStyle(
                                    fontSize: 13,
                                    fontWeight: FontWeight.bold,
                                    color: AppColours.brownMedium,
                                  ),
                                  minFontSize: 11,
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                ),
                              ],
                            ),
                          ],
                        ),
                        const Spacer(),
                        // Add to Cart Button
                        SizedBox(
                          width: double.infinity,
                          height: 26,
                          child: ElevatedButton(
                            onPressed: product.isOutOfStock
                                ? null
                                : () => _addToCart(context),
                            style: ElevatedButton.styleFrom(
                              backgroundColor: product.isOutOfStock
                                  ? Colors.grey
                                  : AppColours.brownLight,
                              padding: EdgeInsets.zero,
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(6),
                              ),
                            ),
                            child: Text(
                              product.isOutOfStock
                                  ? 'out_of_stock'.tr()
                                  : 'add_to_cart'.tr(),
                              style: const TextStyle(
                                color: Colors.white,
                                fontSize: 10,
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildProductImage(String imageUrl) {
    if (imageUrl.isEmpty) {
      return const Center(
        child: Icon(Icons.image_not_supported, size: 50, color: Colors.white),
      );
    }

    if (imageUrl.startsWith('http')) {
      return Image.network(
        imageUrl,
        fit: BoxFit.cover,
        width: double.infinity,
        height: double.infinity,
        errorBuilder: (context, error, stackTrace) {
          return const Center(
            child:
                Icon(Icons.image_not_supported, size: 50, color: Colors.white),
          );
        },
        loadingBuilder: (context, child, loadingProgress) {
          if (loadingProgress == null) return child;
          return const Center(
            child: CircularProgressIndicator(
              color: Colors.white,
              strokeWidth: 2,
            ),
          );
        },
      );
    }

    // Local asset
    return Image.asset(
      imageUrl,
      fit: BoxFit.cover,
      width: double.infinity,
      height: double.infinity,
      errorBuilder: (context, error, stackTrace) {
        return const Center(
          child: Icon(Icons.image_not_supported, size: 50, color: Colors.white),
        );
      },
    );
  }

  void _addToCart(BuildContext context) {
    final authState = context.read<AuthCubit>().state;
    if (authState is AuthAuthenticated) {
      context.read<CartCubit>().setUserId(authState.user.id);
      context.read<CartCubit>().addToCart(product.id);
      Tost.showCustomToast(context, 'added_to_cart'.tr(),
          backgroundColor: Colors.green);
    } else {
      Tost.showCustomToast(context, 'login_required'.tr(),
          backgroundColor: Colors.orange);
    }
  }

  void _toggleFavorite(BuildContext context) {
    final authState = context.read<AuthCubit>().state;
    if (authState is AuthAuthenticated) {
      final favoritesCubit = context.read<FavoritesCubit>();
      favoritesCubit.setUserId(authState.user.id);
      final isFav = favoritesCubit.isFavorite(product.id);
      favoritesCubit.toggleFavorite(product.id);

      if (isFav) {
        Tost.showCustomToast(context, 'removed_from_favorites'.tr(),
            backgroundColor: Colors.grey);
      } else {
        Tost.showCustomToast(context, 'added_to_favorites'.tr(),
            backgroundColor: Colors.red);
      }
    } else {
      Tost.showCustomToast(context, 'login_required'.tr(),
          backgroundColor: Colors.orange);
    }
  }
}
