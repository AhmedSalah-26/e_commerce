import 'package:flutter/material.dart';
import 'package:cached_network_image/cached_network_image.dart';

class ProductInventoryImage extends StatelessWidget {
  final String? image;

  const ProductInventoryImage({
    super.key,
    required this.image,
  });

  @override
  Widget build(BuildContext context) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(8),
      child: image != null
          ? CachedNetworkImage(
              imageUrl: image!,
              width: 60,
              height: 60,
              fit: BoxFit.cover,
              placeholder: (_, __) => Container(
                width: 60,
                height: 60,
                color: Colors.grey[200],
                child: const Icon(Icons.image, color: Colors.grey),
              ),
              errorWidget: (_, __, ___) => Container(
                width: 60,
                height: 60,
                color: Colors.grey[200],
                child: const Icon(Icons.broken_image, color: Colors.grey),
              ),
            )
          : Container(
              width: 60,
              height: 60,
              color: Colors.grey[200],
              child: const Icon(Icons.inventory_2, color: Colors.grey),
            ),
    );
  }
}
