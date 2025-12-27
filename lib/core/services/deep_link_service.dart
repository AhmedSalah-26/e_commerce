import 'package:flutter/foundation.dart';
import '../routing/app_router.dart';

/// Service to handle deep links
/// Supports links like:
/// - https://zaharadates.chottu.link/product?id=123
/// - https://zaharadates.chottu.link/product?id=abc
/// - https://zaharadates.chottu.link/product?id=8564767e-1566-432d-be3c-dcb486542a9a
/// - https://zaharadates.chottu.link/store?id=456
/// - tamorzahra://product/123 (legacy)
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
    debugPrint('Deep Link parsing URI: $uri');
    debugPrint('  - scheme: ${uri.scheme}');
    debugPrint('  - host: ${uri.host}');
    debugPrint('  - path: ${uri.path}');
    debugPrint('  - pathSegments: ${uri.pathSegments}');
    debugPrint('  - queryParameters: ${uri.queryParameters}');

    List<String> segments = uri.pathSegments;

    // Always check query parameters first (for ?id= format)
    final queryId = uri.queryParameters['id'];

    if (segments.isEmpty) {
      // No path segments, check if we have query params in the full path
      if (queryId != null && queryId.isNotEmpty) {
        // Determine type from path
        if (uri.path.contains('product')) {
          return '/product/$queryId';
        } else if (uri.path.contains('store')) {
          return '/store/$queryId';
        }
      }
      return '/home';
    }

    switch (segments.first) {
      case 'product':
        // Handle /product/123 format
        if (segments.length > 1) {
          return '/product/${segments[1]}';
        }
        // Handle /product?id=123 format
        if (queryId != null && queryId.isNotEmpty) {
          return '/product/$queryId';
        }
        debugPrint('Product link missing ID, redirecting to home');
        return '/home';

      case 'store':
        // Handle /store/456 or /store?id=456
        if (segments.length > 1) {
          final name = uri.queryParameters['name'];
          return '/store/${segments[1]}${name != null ? '?name=$name' : ''}';
        }
        // Check query parameter
        final storeId = uri.queryParameters['id'];
        if (storeId != null) {
          final name = uri.queryParameters['name'];
          return '/store/$storeId${name != null ? '?name=$name' : ''}';
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
        // Handle short paths like /p123 for products, /s456 for stores
        final firstSegment = segments.first;
        if (firstSegment.startsWith('p') && firstSegment.length > 1) {
          final productId = firstSegment.substring(1);
          return '/product/$productId';
        }
        if (firstSegment.startsWith('s') && firstSegment.length > 1) {
          final storeId = firstSegment.substring(1);
          return '/store/$storeId';
        }
        return '/home';
    }
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
