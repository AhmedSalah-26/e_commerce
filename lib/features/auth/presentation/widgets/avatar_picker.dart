import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:easy_localization/easy_localization.dart';

class AvatarPicker extends StatelessWidget {
  final String? currentAvatarUrl;
  final Uint8List? selectedImageBytes;
  final String? userName;
  final VoidCallback onPickImage;
  final VoidCallback? onRemoveImage;
  final bool isLoading;

  const AvatarPicker({
    super.key,
    this.currentAvatarUrl,
    this.selectedImageBytes,
    this.userName,
    required this.onPickImage,
    this.onRemoveImage,
    this.isLoading = false,
  });

  String _getInitial() {
    if (userName != null && userName!.isNotEmpty) {
      return userName![0].toUpperCase();
    }
    return '?';
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Column(
      children: [
        Stack(
          children: [
            GestureDetector(
              onTap: isLoading ? null : onPickImage,
              child: CircleAvatar(
                radius: 50,
                backgroundColor:
                    theme.colorScheme.primary.withValues(alpha: 0.1),
                backgroundImage: _getBackgroundImage(),
                child: _buildAvatarContent(theme),
              ),
            ),
            Positioned(
              bottom: 0,
              right: 0,
              child: GestureDetector(
                onTap: isLoading ? null : onPickImage,
                child: Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: theme.colorScheme.primary,
                    shape: BoxShape.circle,
                    border: Border.all(
                      color: theme.scaffoldBackgroundColor,
                      width: 2,
                    ),
                  ),
                  child: Icon(
                    Icons.camera_alt,
                    size: 18,
                    color: Colors.white,
                  ),
                ),
              ),
            ),
            if (isLoading)
              Positioned.fill(
                child: Container(
                  decoration: BoxDecoration(
                    color: Colors.black38,
                    shape: BoxShape.circle,
                  ),
                  child: const Center(
                    child: CircularProgressIndicator(
                      color: Colors.white,
                      strokeWidth: 2,
                    ),
                  ),
                ),
              ),
          ],
        ),
        const SizedBox(height: 8),
        Text(
          'tap_to_change_photo'.tr(),
          style: TextStyle(
            fontSize: 12,
            color: theme.colorScheme.onSurface.withValues(alpha: 0.6),
          ),
        ),
        if ((currentAvatarUrl != null || selectedImageBytes != null) &&
            onRemoveImage != null) ...[
          const SizedBox(height: 4),
          TextButton.icon(
            onPressed: isLoading ? null : onRemoveImage,
            icon: const Icon(Icons.delete_outline, size: 16),
            label: Text('remove_photo'.tr()),
            style: TextButton.styleFrom(
              foregroundColor: Colors.red,
              padding: const EdgeInsets.symmetric(horizontal: 8),
            ),
          ),
        ],
      ],
    );
  }

  ImageProvider? _getBackgroundImage() {
    if (selectedImageBytes != null) {
      return MemoryImage(selectedImageBytes!);
    }
    if (currentAvatarUrl != null && currentAvatarUrl!.isNotEmpty) {
      return NetworkImage(currentAvatarUrl!);
    }
    return null;
  }

  Widget? _buildAvatarContent(ThemeData theme) {
    if (selectedImageBytes != null ||
        (currentAvatarUrl != null && currentAvatarUrl!.isNotEmpty)) {
      return null;
    }
    return Text(
      _getInitial(),
      style: TextStyle(
        color: theme.colorScheme.primary,
        fontSize: 36,
        fontWeight: FontWeight.bold,
      ),
    );
  }
}
