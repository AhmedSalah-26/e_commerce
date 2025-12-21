import 'dart:typed_data';
import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:image_picker/image_picker.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'app_logger.dart';

class ImageUploadService {
  final SupabaseClient _client;
  final ImagePicker _picker = ImagePicker();

  ImageUploadService(this._client);

  /// Pick image (works on both web and mobile)
  Future<PickedImageData?> pickImage() async {
    try {
      AppLogger.i('📷 Picking single image...');
      final XFile? image = await _picker.pickImage(
        source: ImageSource.gallery,
        maxWidth: 1024,
        maxHeight: 1024,
        imageQuality: 80,
      );

      if (image != null) {
        final bytes = await image.readAsBytes();
        AppLogger.success('Image picked', {
          'name': image.name,
          'size': '${bytes.length} bytes',
        });
        return PickedImageData(
          bytes: bytes,
          name: image.name,
          path: kIsWeb ? null : image.path,
        );
      }
      AppLogger.w('No image selected');
      return null;
    } catch (e, stackTrace) {
      AppLogger.e('❌ Error picking image', e, stackTrace);
      return null;
    }
  }

  /// Pick multiple images (works on both web and mobile)
  Future<List<PickedImageData>> pickMultipleImages() async {
    try {
      AppLogger.i('📷 Picking multiple images...');
      final List<XFile> images = await _picker.pickMultiImage(
        maxWidth: 1024,
        maxHeight: 1024,
        imageQuality: 80,
      );

      AppLogger.d('Images selected: ${images.length}');
      final List<PickedImageData> results = [];
      for (final image in images) {
        final bytes = await image.readAsBytes();
        AppLogger.d('Loaded: ${image.name} (${bytes.length} bytes)');
        results.add(PickedImageData(
          bytes: bytes,
          name: image.name,
          path: kIsWeb ? null : image.path,
        ));
      }
      return results;
    } catch (e, stackTrace) {
      AppLogger.e('❌ Error picking images', e, stackTrace);
      return [];
    }
  }

  /// Upload image to Supabase Storage using bytes (works on web and mobile)
  Future<String?> uploadImageBytes(
      Uint8List bytes, String fileName, String bucket, String folder) async {
    try {
      AppLogger.i('═══════════════════════════════════════');
      AppLogger.i('☁️ UPLOADING IMAGE TO STORAGE');
      AppLogger.i('═══════════════════════════════════════');

      AppLogger.d('Upload Details:', {
        'file_name': fileName,
        'bucket': bucket,
        'folder': folder,
        'size': '${bytes.length} bytes',
      });

      final extension = fileName.split('.').last.toLowerCase();
      final uniqueFileName =
          '$folder/${DateTime.now().millisecondsSinceEpoch}_$fileName';

      String contentType = 'image/jpeg';
      if (extension == 'png') {
        contentType = 'image/png';
      } else if (extension == 'gif') {
        contentType = 'image/gif';
      } else if (extension == 'webp') {
        contentType = 'image/webp';
      }

      AppLogger.step(1, 'Calling Supabase Storage API...', {
        'path': uniqueFileName,
        'content_type': contentType,
      });

      final response = await _client.storage.from(bucket).uploadBinary(
            uniqueFileName,
            bytes,
            fileOptions: FileOptions(
              cacheControl: '3600',
              upsert: true,
              contentType: contentType,
            ),
          );

      AppLogger.success('Upload API Response', {'response': response});

      AppLogger.step(2, 'Getting public URL...');
      final publicUrl =
          _client.storage.from(bucket).getPublicUrl(uniqueFileName);

      AppLogger.success('IMAGE UPLOADED SUCCESSFULLY!', {'url': publicUrl});
      AppLogger.i('═══════════════════════════════════════');

      return publicUrl;
    } catch (e, stackTrace) {
      AppLogger.e('═══════════════════════════════════════');
      AppLogger.e('❌ UPLOAD FAILED!', e, stackTrace);
      AppLogger.e('═══════════════════════════════════════');
      return null;
    }
  }

  /// Upload product image
  Future<String?> uploadProductImage(PickedImageData imageData) async {
    AppLogger.i('🛍️ Uploading PRODUCT image...');
    return uploadImageBytes(
        imageData.bytes, imageData.name, 'products', 'images');
  }

  /// Upload category image
  Future<String?> uploadCategoryImage(PickedImageData imageData) async {
    AppLogger.i('📁 Uploading CATEGORY image...');
    return uploadImageBytes(
        imageData.bytes, imageData.name, 'categories', 'images');
  }

  /// Delete image from storage
  Future<bool> deleteImage(String imageUrl, String bucket) async {
    try {
      AppLogger.i('🗑️ Deleting image: $imageUrl');
      final uri = Uri.parse(imageUrl);
      final pathSegments = uri.pathSegments;
      final filePath =
          pathSegments.sublist(pathSegments.indexOf(bucket) + 1).join('/');

      await _client.storage.from(bucket).remove([filePath]);
      AppLogger.success('Image deleted');
      return true;
    } catch (e, stackTrace) {
      AppLogger.e('❌ Error deleting image', e, stackTrace);
      return false;
    }
  }
}

/// Class to hold picked image data (works on both web and mobile)
class PickedImageData {
  final Uint8List bytes;
  final String name;
  final String? path;

  PickedImageData({
    required this.bytes,
    required this.name,
    this.path,
  });
}
