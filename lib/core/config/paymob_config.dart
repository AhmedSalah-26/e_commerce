/// Paymob configuration
///
/// Get your credentials from: https://accept.paymob.com/portal2/en/settings
///
/// IMPORTANT: In production, use environment variables or secure storage
/// instead of hardcoding these values.
class PaymobConfig {
  PaymobConfig._();

  // TODO: Replace with your actual Paymob credentials
  static const String apiKey = 'YOUR_PAYMOB_API_KEY';

  // Card payment integration ID
  static const int integrationId = 0; // YOUR_CARD_INTEGRATION_ID

  // Wallet payment integration ID (Vodafone Cash, etc.)
  static const int walletIntegrationId = 0; // YOUR_WALLET_INTEGRATION_ID

  // iFrame ID for card payments
  static const int iFrameId = 0; // YOUR_IFRAME_ID

  /// Check if Paymob is configured
  static bool get isConfigured =>
      apiKey != 'YOUR_PAYMOB_API_KEY' &&
      integrationId != 0 &&
      walletIntegrationId != 0 &&
      iFrameId != 0;
}
