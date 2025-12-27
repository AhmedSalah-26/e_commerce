import 'package:cached_network_image/cached_network_image.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../features/auth/presentation/cubit/auth_cubit.dart';
import '../../../features/auth/presentation/cubit/auth_state.dart';
import '../../../features/favorites/presentation/cubit/favorites_cubit.dart';
import '../../../features/favorites/presentation/cubit/favorites_state.dart';
import '../../../features/products/domain/entities/product_entity.dart';
import '../toast.dart';

/// Image section with favorite button (badges handled by parent)
class ProductImageSection extends StatelessWidget {
  final ProductEntity product;

  const ProductImageSection({super.key, required this.product});

  @override
  Widget build(BuildContext context) {
    return Stack(
      clipBehavior: Clip.none,
      children: [
        _buildImageContainer(context),
        Positioned(
          bottom: 8,
          right: 8,
          child: _FavoriteButton(productId: product.id),
        ),
      ],
    );
  }

  Widget _buildImageContainer(BuildContext context) {
    final theme = Theme.of(context);
    return Container(
      width: double.infinity,
      decoration: BoxDecoration(
        borderRadius: const BorderRadius.only(
          topLeft: Radius.circular(8),
          topRight: Radius.circular(8),
        ),
        color: theme.colorScheme.surface,
      ),
      child: AspectRatio(
        aspectRatio: 1.0,
        child: ClipRRect(
          borderRadius: const BorderRadius.only(
            topLeft: Radius.circular(8),
            topRight: Radius.circular(8),
          ),
          child: _ProductImage(imageUrl: product.mainImage),
        ),
      ),
    );
  }
}

/// Optimized product image with caching - uses contain fit for better display
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
        placeholder: (_, __) => const _ImagePlaceholder(),
        errorWidget: (_, __, ___) => const _ImagePlaceholder(),
        fadeInDuration: Duration.zero,
        fadeOutDuration: Duration.zero,
        fit: BoxFit.contain,
        // Prevent layout issues with broken images
        errorListener: (_) {},
      );
    }

    return Image.asset(
      imageUrl,
      fit: BoxFit.contain,
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
    final theme = Theme.of(context);
    return Container(
      width: double.infinity,
      height: double.infinity,
      color: theme.colorScheme.surfaceContainerHighest.withValues(alpha: 0.3),
      child: Center(
        child: Icon(
          Icons.image_outlined,
          size: 40,
          color: theme.colorScheme.onSurface.withValues(alpha: 0.3),
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
    final theme = Theme.of(context);
    return BlocSelector<FavoritesCubit, FavoritesState, bool>(
      selector: (state) =>
          state is FavoritesLoaded && state.isFavorite(productId),
      builder: (context, isFavorite) {
        return GestureDetector(
          onTap: () => _toggleFavorite(context, isFavorite),
          child: Container(
            width: 32,
            height: 32,
            decoration: BoxDecoration(
              color: theme.colorScheme.surfaceContainerHighest,
              shape: BoxShape.circle,
            ),
            child: Icon(
              isFavorite ? Icons.favorite : Icons.favorite_border,
              color: theme.colorScheme.primary,
              size: 18,
            ),
          ),
        );
      },
    );
  }

  Future<void> _toggleFavorite(BuildContext context, bool isFavorite) async {
    final authState = context.read<AuthCubit>().state;
    if (authState is! AuthAuthenticated) {
      Tost.showCustomToast(context, 'login_required'.tr(),
          backgroundColor: Colors.orange);
      return;
    }

    final cubit = context.read<FavoritesCubit>();
    cubit.setUserId(authState.user.id);

    // Await the result first
    final willBeRemoved = isFavorite;
    final success = await cubit.toggleFavorite(productId);

    if (!context.mounted) return;

    // Show appropriate toast based on result
    if (success) {
      Tost.showCustomToast(
        context,
        willBeRemoved
            ? 'removed_from_favorites'.tr()
            : 'added_to_favorites'.tr(),
        backgroundColor: willBeRemoved ? Colors.grey : Colors.red,
      );
    } else {
      Tost.showCustomToast(
        context,
        'error_favorite_failed'.tr(),
        backgroundColor: Colors.red,
      );
    }
  }
}
