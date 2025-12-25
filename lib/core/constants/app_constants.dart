/// Application-wide constants
class AppConstants {
  AppConstants._();

  // App Info
  static const String appName = 'متجري';
  static const String appNameEn = 'My Store';
  static const String appVersion = '1.0.0';

  // API & Network
  static const int connectionTimeout = 30000;
  static const int receiveTimeout = 30000;

  // Pagination
  static const int defaultPageSize = 20;
  static const int productsPageSize = 20;
  static const int ordersPageSize = 15;
  static const int reviewsPageSize = 10;

  // Cache
  static const int cacheMaxAge = 7; // days
  static const int imageCacheMaxAge = 30; // days

  // Validation
  static const int minPasswordLength = 6;
  static const int minNameLength = 2;
  static const int maxNameLength = 50;
  static const int phoneLength = 11;

  // UI
  static const double defaultPadding = 16.0;
  static const double smallPadding = 8.0;
  static const double largePadding = 24.0;
  static const double defaultBorderRadius = 12.0;
  static const double smallBorderRadius = 8.0;
  static const double largeBorderRadius = 16.0;

  // Animation
  static const int defaultAnimationDuration = 300; // milliseconds
  static const int shortAnimationDuration = 150;
  static const int longAnimationDuration = 500;

  // Storage Keys
  static const String onboardingCompletedKey = 'onboarding_completed';
  static const String authTokenKey = 'auth_token';
  static const String userIdKey = 'user_id';
  static const String languageKey = 'language';
  static const String themeKey = 'theme';

  // Image
  static const int maxImageSize = 5 * 1024 * 1024; // 5MB
  static const int imageQuality = 85;
  static const double productImageAspectRatio = 1.0;
  static const double bannerImageAspectRatio = 16 / 9;
}
