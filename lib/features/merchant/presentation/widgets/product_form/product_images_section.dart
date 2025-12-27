import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import '../../../../../core/services/image_upload_service.dart';
import '../../../../../core/di/injection_container.dart';

class ProductImagesSection extends StatelessWidget {
  final bool isRtl;
  final List<PickedImageData> selectedImages;
  final List<String> existingImages;
  final VoidCallback onImagesChanged;

  const ProductImagesSection({
    super.key,
    required this.isRtl,
    required this.selectedImages,
    required this.existingImages,
    required this.onImagesChanged,
  });

  Future<void> _pickImages(BuildContext context) async {
    try {
      final imageService = sl<ImageUploadService>();
      final images = await imageService.pickMultipleImages();

      if (images.isNotEmpty) {
        selectedImages.addAll(images);
        onImagesChanged();
      }
    } catch (e) {
      debugPrint('Error picking images: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          isRtl ? 'صور المنتج' : 'Product Images',
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w600,
            color: theme.colorScheme.onSurface,
          ),
        ),
        const SizedBox(height: 8),
        SizedBox(
          height: 100,
          child: ListView(
            scrollDirection: Axis.horizontal,
            children: [
              _buildAddImageButton(context, theme),
              ...existingImages.map((url) => _buildImageTile(
                    theme: theme,
                    imageUrl: url,
                    onRemove: () {
                      existingImages.remove(url);
                      onImagesChanged();
                    },
                  )),
              ...selectedImages.map((imageData) => _buildImageTile(
                    theme: theme,
                    imageData: imageData,
                    onRemove: () {
                      selectedImages.remove(imageData);
                      onImagesChanged();
                    },
                  )),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildAddImageButton(BuildContext context, ThemeData theme) {
    return GestureDetector(
      onTap: () => _pickImages(context),
      child: Container(
        width: 100,
        height: 100,
        margin: const EdgeInsets.only(left: 8),
        decoration: BoxDecoration(
          color: theme.scaffoldBackgroundColor,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: theme.colorScheme.primary,
            style: BorderStyle.solid,
            width: 2,
          ),
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.add_photo_alternate,
              color: theme.colorScheme.primary,
              size: 32,
            ),
            const SizedBox(height: 4),
            Text(
              isRtl ? 'إضافة' : 'Add',
              style: TextStyle(
                color: theme.colorScheme.primary,
                fontSize: 12,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildImageTile({
    required ThemeData theme,
    PickedImageData? imageData,
    String? imageUrl,
    required VoidCallback onRemove,
  }) {
    return Container(
      width: 100,
      height: 100,
      margin: const EdgeInsets.only(left: 8),
      child: Stack(
        children: [
          ClipRRect(
            borderRadius: BorderRadius.circular(12),
            child: imageData != null
                ? Image.memory(
                    imageData.bytes,
                    width: 100,
                    height: 100,
                    fit: BoxFit.cover,
                  )
                : CachedNetworkImage(
                    imageUrl: imageUrl!,
                    width: 100,
                    height: 100,
                    fit: BoxFit.cover,
                    memCacheWidth: 200,
                    placeholder: (_, __) => Container(
                      color: theme.colorScheme.outline.withValues(alpha: 0.2),
                      child: const Center(
                        child: CircularProgressIndicator(strokeWidth: 2),
                      ),
                    ),
                    errorWidget: (_, __, ___) => Container(
                      color: theme.colorScheme.outline.withValues(alpha: 0.2),
                      child: const Icon(Icons.error),
                    ),
                  ),
          ),
          Positioned(
            top: 4,
            right: 4,
            child: GestureDetector(
              onTap: onRemove,
              child: Container(
                padding: const EdgeInsets.all(4),
                decoration: const BoxDecoration(
                  color: Colors.red,
                  shape: BoxShape.circle,
                ),
                child: const Icon(
                  Icons.close,
                  color: Colors.white,
                  size: 16,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
