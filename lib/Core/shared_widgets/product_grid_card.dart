import 'dart:ui' as ui;
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
      child: Container(
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(8),
          color: Colors.white,
          border:
              Border.all(color: AppColours.greyLight.withValues(alpha: 0.3)),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.05),
              spreadRadius: 0,
              blurRadius: 4,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // Image Section with badges
            Expanded(
              child: Stack(
                children: [
                  Container(
                    width: double.infinity,
                    decoration: const BoxDecoration(
                      borderRadius: BorderRadius.only(
                        topLeft: Radius.circular(8),
                        topRight: Radius.circular(8),
                      ),
                      color: Colors.white,
                    ),
                    child: ClipRRect(
                      borderRadius: const BorderRadius.only(
                        topLeft: Radius.circular(8),
                        topRight: Radius.circular(8),
                      ),
                      child: _buildProductImage(product.mainImage),
                    ),
                  ),
                  // Discount badge (top left)
                  if (product.hasDiscount && !product.isOutOfStock)
                    Positioned(
                      top: 8,
                      left: 8,
                      child: Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 8, vertical: 4),
                        decoration: BoxDecoration(
                          color: AppColours.jumiaOrange,
                          borderRadius: BorderRadius.circular(4),
                        ),
                        child: Text(
                          '-${product.discountPercentage}%',
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 12,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ),
                  // Favorite button (bottom right)
                  Positioned(
                    bottom: 8,
                    right: 8,
                    child: BlocBuilder<FavoritesCubit, FavoritesState>(
                      builder: (context, state) {
                        final isFav = state is FavoritesLoaded &&
                            state.isFavorite(product.id);
                        return GestureDetector(
                          onTap: () => _toggleFavorite(context),
                          child: Container(
                            padding: const EdgeInsets.all(8),
                            decoration: const BoxDecoration(
                              color: AppColours.jumiaDark,
                              shape: BoxShape.circle,
                            ),
                            child: Icon(
                              isFav ? Icons.favorite : Icons.favorite_border,
                              color: AppColours.jumiaOrange,
                              size: 20,
                            ),
                          ),
                        );
                      },
                    ),
                  ),
                ],
              ),
            ),
            // Product Info Section
            Directionality(
              textDirection:
                  isArabic ? ui.TextDirection.rtl : ui.TextDirection.ltr,
              child: Padding(
                padding: const EdgeInsets.all(12),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Product Name
                    Text(
                      product.name,
                      style: const TextStyle(
                        fontSize: 13,
                        color: AppColours.jumiaDark,
                        height: 1.3,
                      ),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 8),
                    // Price Section
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          "${product.effectivePrice.toStringAsFixed(2)} ${'egp'.tr()}",
                          style: const TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                            color: AppColours.jumiaDark,
                          ),
                        ),
                        if (product.hasDiscount) ...[
                          const SizedBox(height: 2),
                          Text(
                            "${product.price.toStringAsFixed(2)} ${'egp'.tr()}",
                            style: const TextStyle(
                              fontSize: 12,
                              color: AppColours.jumiaGrey,
                              decoration: TextDecoration.lineThrough,
                            ),
                          ),
                        ],
                      ],
                    ),
                    const SizedBox(height: 8),
                    // Rating
                    Row(
                      children: [
                        ...List.generate(5, (index) {
                          return Icon(
                            index < product.rating.floor()
                                ? Icons.star
                                : Icons.star_border,
                            color: AppColours.jumiaYellow,
                            size: 14,
                          );
                        }),
                        const SizedBox(width: 4),
                        Text(
                          "(0)",
                          style: const TextStyle(
                            fontSize: 11,
                            color: AppColours.jumiaGrey,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 12),
                    // Add to Cart Button
                    SizedBox(
                      width: double.infinity,
                      height: 40,
                      child: ElevatedButton(
                        onPressed: product.isOutOfStock
                            ? null
                            : () => _addToCart(context),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: product.isOutOfStock
                              ? Colors.grey
                              : AppColours.jumiaOrange,
                          padding: EdgeInsets.zero,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(6),
                          ),
                          elevation: 0,
                        ),
                        child: Text(
                          product.isOutOfStock
                              ? 'out_of_stock'.tr()
                              : 'add_to_cart'.tr(),
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 13,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
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
