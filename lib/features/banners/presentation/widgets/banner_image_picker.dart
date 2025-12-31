import 'dart:io';
import 'package:flutter/material.dart';
import 'package:cached_network_image/cached_network_image.dart';

class BannerImagePicker extends StatelessWidget {
  final File? selectedImage;
  final String? existingImageUrl;
  final VoidCallback onTap;

  const BannerImagePicker({
    super.key,
    this.selectedImage,
    this.existingImageUrl,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return GestureDetector(
      onTap: onTap,
      child: Container(
        height: 150,
        width: double.infinity,
        decoration: BoxDecoration(
          color: theme.colorScheme.surfaceContainerHighest,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: theme.colorScheme.outline.withValues(alpha: 0.3),
          ),
        ),
        child: _buildContent(theme),
      ),
    );
  }

  Widget _buildContent(ThemeData theme) {
    if (selectedImage != null) {
      return ClipRRect(
        borderRadius: BorderRadius.circular(12),
        child: Image.file(selectedImage!, fit: BoxFit.cover),
      );
    }

    if (existingImageUrl != null && existingImageUrl!.isNotEmpty) {
      return ClipRRect(
        borderRadius: BorderRadius.circular(12),
        child: CachedNetworkImage(
          imageUrl: existingImageUrl!,
          fit: BoxFit.cover,
        ),
      );
    }

    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Icon(Icons.add_photo_alternate,
            size: 48, color: theme.colorScheme.outline),
        const SizedBox(height: 8),
        Text(
          'اضغط لاختيار صورة',
          style: TextStyle(color: theme.colorScheme.outline),
        ),
      ],
    );
  }
}
