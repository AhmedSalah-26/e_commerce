import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';

class CartItemImage extends StatelessWidget {
  final String imageUrl;
  final double size;

  const CartItemImage({
    super.key,
    required this.imageUrl,
    required this.size,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return SizedBox(
      width: size,
      height: size,
      child: ClipRRect(
        borderRadius: BorderRadius.circular(8),
        child: imageUrl.isNotEmpty
            ? (imageUrl.startsWith('http')
                ? CachedNetworkImage(
                    imageUrl: imageUrl,
                    fit: BoxFit.cover,
                    memCacheWidth: 160,
                    placeholder: (_, __) => _buildPlaceholder(theme),
                    errorWidget: (_, __, ___) => _buildPlaceholder(theme),
                  )
                : Image.asset(
                    imageUrl,
                    fit: BoxFit.cover,
                    errorBuilder: (context, error, stackTrace) {
                      return _buildPlaceholder(theme);
                    },
                  ))
            : _buildPlaceholder(theme),
      ),
    );
  }

  Widget _buildPlaceholder(ThemeData theme) {
    return Container(
      color: theme.colorScheme.surface,
      child: const Icon(Icons.image_not_supported, color: Colors.grey),
    );
  }
}
