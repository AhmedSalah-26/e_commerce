import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import '../../../domain/entities/product_entity.dart';
import '../../../../favorites/presentation/cubit/favorites_cubit.dart';
import '../../../../favorites/presentation/cubit/favorites_state.dart';

class ProductScreenAppBar extends StatelessWidget
    implements PreferredSizeWidget {
  final ProductEntity product;
  final bool isRtl;
  final VoidCallback onShare;
  final VoidCallback onReport;

  const ProductScreenAppBar({
    super.key,
    required this.product,
    required this.isRtl,
    required this.onShare,
    required this.onReport,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return AppBar(
      backgroundColor: Colors.transparent,
      elevation: 0,
      leading: IconButton(
        icon: Icon(
          isRtl ? Icons.arrow_forward_ios : Icons.arrow_back_ios,
          color: theme.colorScheme.onSurface,
        ),
        onPressed: () => context.pop(),
      ),
      actions: [
        BlocBuilder<FavoritesCubit, FavoritesState>(
          builder: (context, state) {
            final isFavorite = state is FavoritesLoaded &&
                state.favorites.any((fav) => fav.id == product.id);
            return IconButton(
              icon: Icon(
                isFavorite ? Icons.favorite : Icons.favorite_border,
                color: isFavorite ? Colors.red : theme.colorScheme.onSurface,
              ),
              onPressed: () {
                if (isFavorite) {
                  context
                      .read<FavoritesCubit>()
                      .removeFromFavorites(product.id);
                } else {
                  context.read<FavoritesCubit>().addToFavorites(product.id);
                }
              },
            );
          },
        ),
        IconButton(
          icon: Icon(Icons.share, color: theme.colorScheme.onSurface),
          onPressed: onShare,
        ),
        PopupMenuButton<String>(
          icon: Icon(Icons.more_vert, color: theme.colorScheme.onSurface),
          onSelected: (value) {
            if (value == 'report') {
              onReport();
            }
          },
          itemBuilder: (context) => [
            PopupMenuItem(
              value: 'report',
              child: Row(
                children: [
                  const Icon(Icons.flag, size: 20),
                  const SizedBox(width: 8),
                  Text(isRtl ? 'إبلاغ عن المنتج' : 'Report Product'),
                ],
              ),
            ),
          ],
        ),
      ],
    );
  }

  @override
  Size get preferredSize => const Size.fromHeight(kToolbarHeight);
}
