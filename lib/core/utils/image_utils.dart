/// Utility class for image manipulation
class ImageUtils {
  ImageUtils._();

  /// Default dimensions for product images
  static const int defaultWidth = 400;
  static const int defaultHeight = 400;

  /// Resize image URL to fixed dimensions
  /// Supports: Unsplash, Cloudinary, Supabase Storage, and generic URLs
  static String resizeImageUrl(
    String imageUrl, {
    int width = defaultWidth,
    int height = defaultHeight,
  }) {
    if (imageUrl.isEmpty) return imageUrl;

    // Unsplash images
    if (imageUrl.contains('unsplash.com')) {
      return _resizeUnsplash(imageUrl, width, height);
    }

    // Cloudinary images
    if (imageUrl.contains('cloudinary.com')) {
      return _resizeCloudinary(imageUrl, width, height);
    }

    // Supabase Storage images
    if (imageUrl.contains('supabase')) {
      return _resizeSupabase(imageUrl, width, height);
    }

    // Return original URL for unsupported services
    return imageUrl;
  }

  /// Resize Unsplash image
  static String _resizeUnsplash(String url, int width, int height) {
    // Remove existing size params
    final uri = Uri.parse(url);
    final params = Map<String, String>.from(uri.queryParameters);

    // Set new dimensions
    params['w'] = width.toString();
    params['h'] = height.toString();
    params['fit'] = 'crop';
    params['crop'] = 'center';

    return uri.replace(queryParameters: params).toString();
  }

  /// Resize Cloudinary image
  static String _resizeCloudinary(String url, int width, int height) {
    // Cloudinary transformation format: /c_fill,w_400,h_400/
    final transformation = 'c_fill,w_$width,h_$height';

    // Check if URL already has transformations
    if (url.contains('/upload/')) {
      return url.replaceFirst('/upload/', '/upload/$transformation/');
    }

    return url;
  }

  /// Resize Supabase Storage image (if using image transformation)
  static String _resizeSupabase(String url, int width, int height) {
    final uri = Uri.parse(url);
    final params = Map<String, String>.from(uri.queryParameters);

    params['width'] = width.toString();
    params['height'] = height.toString();
    params['resize'] = 'cover';

    return uri.replace(queryParameters: params).toString();
  }
}
