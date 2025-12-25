import 'package:flutter/foundation.dart';
import '../routing/app_router.dart';

/// Service to handle deep links
/// Supports links like:
/// - tamorzahra://product/123
/// - tamorzahra://store/456
/// - tamorzahra://category/789
/// - tamorzahra://cart
/// - tamorzahra://orders
class DeepLinkService {
  static final DeepLinkService _instance = DeepLinkService._internal();
  factory DeepLinkService() => _instance;
  DeepLinkService._internal();

  String? _pendingDeepLink;

  /// Get pending deep link (for after login)
  String? get pendingDeepLink => _pendingDeepLink;

  /// Clear pending deep link
  void clearPendingDeepLink() {
    _pendingDeepLink = null;
  }

  /// Handle incoming deep link URI
  void handleDeepLink(Uri uri) {
    debugPrint('Deep Link received: $uri');

    final path = _uriToPath(uri);
    if (path != null) {
      _navigateToPath(path);
    }
  }

  /// Convert URI to app path
  String? _uriToPath(Uri uri) {
    // Handle tamorzahra://product/123
    if (uri.scheme == 'tamorzahra') {
      final segments = uri.pathSegments;
      if (segments.isEmpty) return '/home';

      switch (segments.first) {
        case 'product':
          if (segments.length > 1) {
            return '/product/${segments[1]}';
          }
          return '/home';

        case 'store':
          if (segments.length > 1) {
            final name = uri.queryParameters['name'];
            return '/store/${segments[1]}${name != null ? '?name=$name' : ''}';
          }
          return '/home';

        case 'category':
          if (segments.length > 1) {
            return '/home'; // TODO: Add category route
          }
          return '/home';

        case 'cart':
          return '/cart';

        case 'orders':
          return '/orders';

        case 'favorites':
          return '/favorites';

        default:
          return '/home';
      }
    }

    return null;
  }

  /// Navigate to path
  void _navigateToPath(String path) {
    try {
      AppRouter.router.go(path);
    } catch (e) {
      debugPrint('Deep Link navigation error: $e');
      // Save for later if navigation fails (e.g., not logged in)
      _pendingDeepLink = path;
    }
  }

  /// Navigate to pending deep link (call after login)
  void navigateToPendingDeepLink() {
    if (_pendingDeepLink != null) {
      final path = _pendingDeepLink!;
      _pendingDeepLink = null;
      AppRouter.router.go(path);
    }
  }

  /// Check if there's a pending deep link
  bool get hasPendingDeepLink => _pendingDeepLink != null;

  /// Save deep link for after authentication
  void savePendingDeepLink(String path) {
    _pendingDeepLink = path;
  }
}
