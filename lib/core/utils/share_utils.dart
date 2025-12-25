import 'package:flutter/services.dart';
import '../../features/products/domain/entities/product_entity.dart';

/// Utility class for sharing content
class ShareUtils {
  static const String _scheme = 'tamorzahra';

  /// Generate deep link for a product
  static String getProductLink(String productId) {
    return '$_scheme://product/$productId';
  }

  /// Generate deep link for a store
  static String getStoreLink(String merchantId, {String? storeName}) {
    final base = '$_scheme://store/$merchantId';
    if (storeName != null) {
      return '$base?name=${Uri.encodeComponent(storeName)}';
    }
    return base;
  }

  /// Generate deep link for category
  static String getCategoryLink(String categoryId) {
    return '$_scheme://category/$categoryId';
  }

  /// Generate shareable text for a product
  static String getProductShareText(ProductEntity product, String locale) {
    final link = getProductLink(product.id);

    if (locale == 'ar') {
      return 'شوف المنتج ده: ${product.name}\n$link';
    } else {
      return 'Check out this product: ${product.name}\n$link';
    }
  }

  /// Copy link to clipboard
  static Future<void> copyToClipboard(String text) async {
    await Clipboard.setData(ClipboardData(text: text));
  }
}
