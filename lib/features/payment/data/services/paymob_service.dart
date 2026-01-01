import 'package:flutter/material.dart';
import 'package:flutter_paymob/flutter_paymob.dart';
import '../../domain/entities/payment_result.dart';

/// Paymob payment service
///
/// Initialize in main.dart before runApp:
/// ```dart
/// await PaymobService.initialize(
///   apiKey: 'YOUR_API_KEY',
///   integrationId: YOUR_CARD_INTEGRATION_ID,
///   walletIntegrationId: YOUR_WALLET_INTEGRATION_ID,
///   iFrameId: YOUR_IFRAME_ID,
/// );
/// ```
class PaymobService {
  PaymobService._();
  static final PaymobService instance = PaymobService._();

  static bool _isInitialized = false;

  /// Initialize Paymob SDK
  static Future<void> initialize({
    required String apiKey,
    required int integrationId,
    required int walletIntegrationId,
    required int iFrameId,
  }) async {
    await FlutterPaymob.instance.initialize(
      apiKey: apiKey,
      integrationID: integrationId,
      walletIntegrationId: walletIntegrationId,
      iFrameID: iFrameId,
    );
    _isInitialized = true;
  }

  /// Check if Paymob is initialized
  static bool get isInitialized => _isInitialized;

  /// Pay with credit/debit card
  Future<PaymentResult> payWithCard({
    required BuildContext context,
    required double amount,
    String currency = 'EGP',
    String? title,
    Color? appBarColor,
  }) async {
    if (!_isInitialized) {
      return PaymentResult.failure(message: 'Paymob not initialized');
    }

    PaymentResult? result;

    await FlutterPaymob.instance.payWithCard(
      context: context,
      currency: currency,
      amount: amount,
      title: title != null ? Text(title) : null,
      appBarColor: appBarColor,
      onPayment: (response) {
        if (response.success) {
          result = PaymentResult.success(
            transactionId: response.transactionID ?? '',
            message: response.message,
            responseCode: response.responseCode,
          );
        } else {
          result = PaymentResult.failure(
            message: response.message,
            responseCode: response.responseCode,
          );
        }
      },
    );

    return result ?? PaymentResult.cancelled();
  }

  /// Pay with mobile wallet (Vodafone Cash, etc.)
  Future<PaymentResult> payWithWallet({
    required BuildContext context,
    required double amount,
    required String phoneNumber,
    String currency = 'EGP',
    String? title,
    Color? appBarColor,
  }) async {
    if (!_isInitialized) {
      return PaymentResult.failure(message: 'Paymob not initialized');
    }

    PaymentResult? result;

    await FlutterPaymob.instance.payWithWallet(
      context: context,
      currency: currency,
      amount: amount,
      number: phoneNumber,
      title: title != null ? Text(title) : null,
      appBarColor: appBarColor,
      onPayment: (response) {
        if (response.success) {
          result = PaymentResult.success(
            transactionId: response.transactionID ?? '',
            message: response.message,
            responseCode: response.responseCode,
          );
        } else {
          result = PaymentResult.failure(
            message: response.message,
            responseCode: response.responseCode,
          );
        }
      },
    );

    return result ?? PaymentResult.cancelled();
  }
}
