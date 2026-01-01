import 'dart:convert';
import 'package:http/http.dart' as http;

/// Paymob payment service
class PaymobService {
  PaymobService._();
  static final PaymobService instance = PaymobService._();

  static bool _isInitialized = false;
  static String _apiKey = '';
  static int _integrationId = 0;
  static int _iFrameId = 0;

  /// Initialize Paymob SDK
  static Future<void> initialize({
    required String apiKey,
    required int integrationId,
    required int iFrameId,
  }) async {
    _apiKey = apiKey;
    _integrationId = integrationId;
    _iFrameId = iFrameId;
    _isInitialized = true;
  }

  /// Check if Paymob is initialized
  static bool get isInitialized => _isInitialized;

  /// Get payment URL for card payment
  Future<String?> getPaymentUrl({
    required double amount,
    required String orderId,
    String currency = 'EGP',
    String? customerName,
    String? customerPhone,
    String? customerEmail,
  }) async {
    if (!_isInitialized) return null;

    try {
      // Step 1: Get auth token
      final authToken = await _getAuthToken();
      if (authToken == null) return null;

      // Step 2: Create order with our order ID as merchant_order_id
      final amountCents = (amount * 100).toInt();
      final paymobOrderId = await _createOrder(
        authToken,
        amountCents,
        currency,
        merchantOrderId: orderId,
      );
      if (paymobOrderId == null) return null;

      // Step 3: Get payment key
      final paymentKey = await _getPaymentKey(
        authToken: authToken,
        orderId: paymobOrderId,
        amountCents: amountCents,
        currency: currency,
        customerName: customerName,
        customerPhone: customerPhone,
        customerEmail: customerEmail,
      );
      if (paymentKey == null) return null;

      // Return iFrame URL
      return 'https://accept.paymob.com/api/acceptance/iframes/$_iFrameId?payment_token=$paymentKey';
    } catch (_) {
      return null;
    }
  }

  Future<String?> _getAuthToken() async {
    try {
      final response = await http.post(
        Uri.parse('https://accept.paymob.com/api/auth/tokens'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({'api_key': _apiKey}),
      );

      if (response.statusCode == 201) {
        final data = jsonDecode(response.body);
        return data['token'];
      }
    } catch (_) {}
    return null;
  }

  Future<int?> _createOrder(
    String authToken,
    int amountCents,
    String currency, {
    String? merchantOrderId,
  }) async {
    try {
      final response = await http.post(
        Uri.parse('https://accept.paymob.com/api/ecommerce/orders'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({
          'auth_token': authToken,
          'delivery_needed': false,
          'amount_cents': amountCents.toString(),
          'currency': currency,
          'merchant_order_id': merchantOrderId,
          'items': [],
        }),
      );

      if (response.statusCode == 201) {
        final data = jsonDecode(response.body);
        return data['id'];
      }
    } catch (_) {}
    return null;
  }

  Future<String?> _getPaymentKey({
    required String authToken,
    required int orderId,
    required int amountCents,
    required String currency,
    String? customerName,
    String? customerPhone,
    String? customerEmail,
  }) async {
    try {
      final nameParts = (customerName ?? 'Customer').split(' ');
      final firstName = nameParts.first;
      final lastName =
          nameParts.length > 1 ? nameParts.sublist(1).join(' ') : 'Name';

      final response = await http.post(
        Uri.parse('https://accept.paymob.com/api/acceptance/payment_keys'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({
          'auth_token': authToken,
          'amount_cents': amountCents.toString(),
          'expiration': 3600,
          'order_id': orderId.toString(),
          'billing_data': {
            'apartment': 'NA',
            'email': customerEmail ?? 'customer@example.com',
            'floor': 'NA',
            'first_name': firstName,
            'street': 'NA',
            'building': 'NA',
            'phone_number': customerPhone ?? '+201000000000',
            'shipping_method': 'NA',
            'postal_code': 'NA',
            'city': 'NA',
            'country': 'EG',
            'last_name': lastName,
            'state': 'NA',
          },
          'currency': currency,
          'integration_id': _integrationId,
        }),
      );

      if (response.statusCode == 201) {
        final data = jsonDecode(response.body);
        return data['token'];
      }
    } catch (_) {}
    return null;
  }
}
