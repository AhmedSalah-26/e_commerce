import 'package:cached_network_image/cached_network_image.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../features/auth/presentation/cubit/auth_cubit.dart';
import '../../../features/auth/presentation/cubit/auth_state.dart';
import '../../../features/favorites/presentation/cubit/favorites_cubit.dart';
import '../../../features/favorites/presentation/cubit/favorites_state.dart';
import '../../../features/products/domain/entities/product_entity.dart';
import '../../theme/app_colors.dart';
import '../toast.dart';

/// Image section with discount badge and favorite button
class ProductImageSection extends StatelessWidget {
  final ProductEntity product;

  const ProductImageSection({super.key, required this.product});

  @override
  Widget build(BuildContext context) {
    return Stack(
      clipBehavior: Clip.none,
      children: [
        _buildImageContainer(),
        if (product.hasDiscount && !product.isOutOfStock)
          _DiscountBadge(percentage: product.discountPercentage),
        Positioned(
          bottom: 8,
          right: 8,
          child: _FavoriteButton(productId: product.id),
        ),
      ],
    );
  }

  Widget _buildImageContainer() {
    return Container(
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
        child: _ProductImage(imageUrl: product.mainImage),
      ),
    );
  }
}

/// Optimized product image with caching - uses cover fit for better performance
class _ProductImage extends StatelessWidget {
  final String imageUrl;
  static const int _cacheSize = 300;

  const _ProductImage({required this.imageUrl});

  @override
  Widget build(BuildContext context) {
    if (imageUrl.isEmpty) return const _ImagePlaceholder();

    if (imageUrl.startsWith('http')) {
      return CachedNetworkImage(
        imageUrl: imageUrl,
        width: double.infinity,
        height: double.infinity,
        memCacheWidth: _cacheSize,
        memCacheHeight: _cacheSize,
        maxWidthDiskCache: _cacheSize * 2,
        maxHeightDiskCache: _cacheSize * 2,
        placeholder: (_, __) => const _ImageLoading(),
        errorWidget: (_, __, ___) => const _ImagePlaceholder(),
        fadeInDuration: Duration.zero,
        fadeOutDuration: Duration.zero,
        fit: BoxFit.cover,
      );
    }

    return Image.asset(
      imageUrl,
      fit: BoxFit.cover,
      width: double.infinity,
      height: double.infinity,
      cacheWidth: _cacheSize,
      cacheHeight: _cacheSize,
      errorBuilder: (_, __, ___) => const _ImagePlaceholder(),
    );
  }
}

class _ImagePlaceholder extends StatelessWidget {
  const _ImagePlaceholder();

  @override
  Widget build(BuildContext context) {
    return const Center(
      child: Icon(Icons.image_not_supported, size: 50, color: Colors.grey),
    );
  }
}

class _ImageLoading extends StatelessWidget {
  const _ImageLoading();

  @override
  Widget build(BuildContext context) {
    return const Center(
      child: CircularProgressIndicator(
        color: AppColours.brownLight,
        strokeWidth: 2,
      ),
    );
  }
}

/// Discount badge widget
class _DiscountBadge extends StatelessWidget {
  final int percentage;

  const _DiscountBadge({required this.percentage});

  @override
  Widget build(BuildContext context) {
    return Positioned(
      top: 8,
      left: 8,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
        decoration: BoxDecoration(
          color: AppColours.brownLight,
          borderRadius: BorderRadius.circular(4),
        ),
        child: Text(
          '-$percentage%',
          style: const TextStyle(
            color: Colors.white,
            fontSize: 12,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
    );
  }
}

/// Favorite button with BlocSelector for optimized rebuilds
class _FavoriteButton extends StatelessWidget {
  final String productId;

  const _FavoriteButton({required this.productId});

  @override
  Widget build(BuildContext context) {
    return BlocSelector<FavoritesCubit, FavoritesState, bool>(
      selector: (state) =>
          state is FavoritesLoaded && state.isFavorite(productId),
      builder: (context, isFavorite) {
        return GestureDetector(
          onTap: () => _toggleFavorite(context, isFavorite),
          child: Container(
            width: 28,
            height: 28,
            decoration: const BoxDecoration(
              color: AppColours.jumiaDark,
              shape: BoxShape.circle,
            ),
            child: Icon(
              isFavorite ? Icons.favorite : Icons.favorite_border,
              color: AppColours.brownLight,
              size: 14,
            ),
          ),
        );
      },
    );
  }

  void _toggleFavorite(BuildContext context, bool isFavorite) {
    final authState = context.read<AuthCubit>().state;
    if (authState is! AuthAuthenticated) {
      Tost.showCustomToast(context, 'login_required'.tr(),
          backgroundColor: Colors.orange);
      return;
    }

    final cubit = context.read<FavoritesCubit>();
    cubit.setUserId(authState.user.id);
    cubit.toggleFavorite(productId);

    Tost.showCustomToast(
      context,
      isFavorite ? 'removed_from_favorites'.tr() : 'added_to_favorites'.tr(),
      backgroundColor: isFavorite ? Colors.grey : Colors.red,
    );
  }
}
