import 'dart:io';
import 'package:flutter/material.dart';

class StoreLogoPicker extends StatelessWidget {
  final File? selectedImage;
  final String? logoUrl;
  final VoidCallback onTap;
  final bool isRtl;

  const StoreLogoPicker({
    super.key,
    required this.selectedImage,
    required this.logoUrl,
    required this.onTap,
    required this.isRtl,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Column(
      children: [
        GestureDetector(
          onTap: onTap,
          child: Stack(
            children: [
              Container(
                width: 100,
                height: 100,
                decoration: BoxDecoration(
                  color: theme.colorScheme.primary.withValues(alpha: 0.1),
                  shape: BoxShape.circle,
                  border:
                      Border.all(color: theme.colorScheme.primary, width: 2),
                  image: selectedImage != null
                      ? DecorationImage(
                          image: FileImage(selectedImage!),
                          fit: BoxFit.cover,
                        )
                      : logoUrl != null
                          ? DecorationImage(
                              image: NetworkImage(logoUrl!),
                              fit: BoxFit.cover,
                            )
                          : null,
                ),
                child: selectedImage == null && logoUrl == null
                    ? Icon(
                        Icons.store,
                        size: 48,
                        color: theme.colorScheme.primary,
                      )
                    : null,
              ),
              Positioned(
                bottom: 0,
                right: 0,
                child: Container(
                  padding: const EdgeInsets.all(6),
                  decoration: BoxDecoration(
                    color: theme.colorScheme.primary,
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(
                    Icons.camera_alt,
                    size: 18,
                    color: Colors.white,
                  ),
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 8),
        Text(
          isRtl ? 'اضغط لتغيير الصورة' : 'Tap to change logo',
          style: theme.textTheme.bodySmall?.copyWith(
            color: theme.colorScheme.onSurface.withValues(alpha: 0.6),
          ),
        ),
      ],
    );
  }
}
