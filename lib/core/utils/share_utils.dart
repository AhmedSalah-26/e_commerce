import 'package:chottu_link/chottu_link.dart';
import 'package:chottu_link/dynamic_link/cl_dynamic_link_behaviour.dart';
import 'package:chottu_link/dynamic_link/cl_dynamic_link_parameters.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';
import '../../features/products/domain/entities/product_entity.dart';

/// Utility class for sharing content
class ShareUtils {
  static const String _domain = 'zaharadates.chottu.link';
  static const String _fallbackUrl = 'https://ahmedmohamedsalah.com';

  /// Generate deep link for a product using ChottuLink
  static Future<String?> getProductLink(
    String productId, {
    String? productName,
    String? imageUrl,
  }) async {
    String? generatedLink;

    final parameters = CLDynamicLinkParameters(
      link: Uri.parse('$_fallbackUrl/product/$productId'),
      domain: _domain,
      androidBehaviour: CLDynamicLinkBehaviour.app,
      iosBehaviour: CLDynamicLinkBehaviour.app,
      linkName: productName ?? 'Product $productId',
      selectedPath: 'product/$productId',
      socialTitle: productName,
      socialImageUrl: imageUrl,
      utmSource: 'app',
      utmMedium: 'share',
      utmCampaign: 'product_share',
    );

    ChottuLink.createDynamicLink(
      parameters: parameters,
      onSuccess: (link) {
        generatedLink = link;
        debugPrint('✅ Product Link: $link');
      },
      onError: (error) {
        debugPrint('❌ Error creating product link: ${error.description}');
      },
    );

    // Wait a bit for the async callback
    await Future.delayed(const Duration(milliseconds: 500));
    return generatedLink ?? 'https://$_domain/product/$productId';
  }

  /// Generate deep link for a store using ChottuLink
  static Future<String?> getStoreLink(
    String merchantId, {
    String? storeName,
    String? imageUrl,
  }) async {
    String? generatedLink;

    final parameters = CLDynamicLinkParameters(
      link: Uri.parse('$_fallbackUrl/store/$merchantId'),
      domain: _domain,
      androidBehaviour: CLDynamicLinkBehaviour.app,
      iosBehaviour: CLDynamicLinkBehaviour.app,
      linkName: storeName ?? 'Store $merchantId',
      selectedPath: 'store/$merchantId',
      socialTitle: storeName,
      socialImageUrl: imageUrl,
      utmSource: 'app',
      utmMedium: 'share',
      utmCampaign: 'store_share',
    );

    ChottuLink.createDynamicLink(
      parameters: parameters,
      onSuccess: (link) {
        generatedLink = link;
        debugPrint('✅ Store Link: $link');
      },
      onError: (error) {
        debugPrint('❌ Error creating store link: ${error.description}');
      },
    );

    await Future.delayed(const Duration(milliseconds: 500));
    return generatedLink ?? 'https://$_domain/store/$merchantId';
  }

  /// Simple sync method for quick link generation (fallback)
  static String getProductLinkSync(String productId) {
    return 'https://$_domain/product/$productId';
  }

  /// Simple sync method for store link (fallback)
  static String getStoreLinkSync(String merchantId) {
    return 'https://$_domain/store/$merchantId';
  }

  /// Generate shareable text for a product
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
