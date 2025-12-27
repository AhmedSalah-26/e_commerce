import 'dart:async';
import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';
import '../../features/products/domain/entities/product_entity.dart';

/// Utility class for sharing content
class ShareUtils {
  static const String _domain = 'zaharadates.chottu.link';

  /// Generate deep link for a product - using query parameter format
  /// Example: https://zaharadates.chottu.link/product?id=123
  static Future<String> getProductLink(
    String productId, {
    String? productName,
    String? imageUrl,
  }) async {
    // Use URL with query parameter for product ID
    final link = 'https://$_domain/product?id=$productId';
    debugPrint('✅ Product Link: $link');
    return link;
  }

  /// Generate deep link for a store - using direct URL format
  static Future<String> getStoreLink(
    String merchantId, {
    String? storeName,
    String? imageUrl,
  }) async {
    // Use direct URL with merchant ID
    final link = 'https://$_domain/store/$merchantId';
    debugPrint('✅ Store Link: $link');
    return link;
  }

  /// Simple sync method for quick link generation
  /// Example: https://zaharadates.chottu.link/product?id=123
  static String getProductLinkSync(String productId) {
    return 'https://$_domain/product?id=$productId';
  }

  /// Simple sync method for store link
  static String getStoreLinkSync(String merchantId) {
    return 'https://$_domain/store/$merchantId';
  }

  /// Generate shareable text for a product (async version)
  static Future<String> getProductShareTextAsync(
    ProductEntity product,
    String locale,
  ) async {
    final link = await getProductLink(
      product.id,
      productName: product.name,
      imageUrl: product.mainImage,
    );

    if (locale == 'ar') {
      return 'شوف المنتج ده: ${product.name}\n$link';
    } else {
      return 'Check out this product: ${product.name}\n$link';
    }
  }

  /// Generate shareable text for a product (sync fallback)
  static String getProductShareText(ProductEntity product, String locale) {
    final link = getProductLinkSync(product.id);

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
