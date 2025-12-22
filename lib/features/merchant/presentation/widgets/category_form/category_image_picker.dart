import 'package:flutter/material.dart';
import '../../../../../core/theme/app_colors.dart';
import '../../../../../core/services/image_upload_service.dart';

class CategoryImagePicker extends StatelessWidget {
  final PickedImageData? selectedImage;
  final String? existingImageUrl;
  final VoidCallback onImagePicked;
  final VoidCallback onImageRemoved;
  final bool isRtl;

  const CategoryImagePicker({
    super.key,
    required this.selectedImage,
    required this.existingImageUrl,
    required this.onImagePicked,
    required this.onImageRemoved,
    required this.isRtl,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onImagePicked,
      child: Container(
        width: 120,
        height: 120,
        decoration: BoxDecoration(
          color: AppColours.greyLighter,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: AppColours.primary,
            width: 2,
          ),
        ),
        child: _buildImageContent(),
      ),
    );
  }

  Widget _buildImageContent() {
    if (selectedImage != null) {
      return Stack(
        children: [
          ClipRRect(
            borderRadius: BorderRadius.circular(10),
            child: Image.memory(
              selectedImage!.bytes,
              width: 120,
              height: 120,
              fit: BoxFit.cover,
            ),
          ),
          _buildRemoveButton(),
        ],
      );
    } else if (existingImageUrl != null) {
      return Stack(
        children: [
          ClipRRect(
            borderRadius: BorderRadius.circular(10),
            child: Image.network(
              existingImageUrl!,
              width: 120,
              height: 120,
              fit: BoxFit.cover,
            ),
          ),
          _buildRemoveButton(),
        ],
      );
    } else {
      return Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Icon(
            Icons.add_photo_alternate,
            color: AppColours.primary,
            size: 40,
          ),
          const SizedBox(height: 4),
          Text(
            isRtl ? 'إضافة صورة' : 'Add Image',
            style: const TextStyle(
              color: AppColours.primary,
              fontSize: 12,
            ),
          ),
        ],
      );
    }
  }

  Widget _buildRemoveButton() {
    return Positioned(
      top: 4,
      right: 4,
      child: GestureDetector(
        onTap: onImageRemoved,
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
    );
  }
}
