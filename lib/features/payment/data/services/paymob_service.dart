import 'dart:async';
import 'package:flutter/material.dart';
import 'package:paymob_payment/paymob_payment.dart';
import '../../domain/entities/payment_result.dart';

/// Paymob payment service
class PaymobService {
  PaymobService._();
  static final PaymobService instance = PaymobService._();

  static bool _isInitialized = false;

  /// Initialize Paymob SDK
  static Future<void> initialize({
    required String apiKey,
    required int integrationId,
    required int iFrameId,
  }) async {
    PaymobPayment.instance.initialize(
      apiKey: apiKey,
      integrationID: integrationId,
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
  }) async {
    if (!_isInitialized) {
      return PaymentResult.failure(message: 'Paymob not initialized');
    }

    final completer = Completer<PaymentResult>();

    try {
      // Amount in cents (e.g., 100 EGP = 10000 cents)
      final amountInCents = (amount * 100).toInt().toString();

      final response = await PaymobPayment.instance.pay(
        context: context,
        currency: currency,
        amountInCents: amountInCents,
        onPayment: (response) {
          if (!completer.isCompleted) {
            if (response.success) {
              completer.complete(PaymentResult.success(
                transactionId: response.transactionID ?? '',
                message: response.message,
                responseCode: response.responseCode,
              ));
            } else {
              completer.complete(PaymentResult.failure(
                message: response.message,
                responseCode: response.responseCode,
              ));
            }
          }
        },
      );

      // If response is returned directly (user cancelled or error)
      if (!completer.isCompleted) {
        if (response == null) {
          completer.complete(PaymentResult.cancelled());
        } else if (response.success) {
          completer.complete(PaymentResult.success(
            transactionId: response.transactionID ?? '',
            message: response.message,
            responseCode: response.responseCode,
          ));
        } else {
          completer.complete(PaymentResult.failure(
            message: response.message,
            responseCode: response.responseCode,
          ));
        }
      }
    } catch (e) {
      if (!completer.isCompleted) {
        completer.complete(PaymentResult.failure(message: e.toString()));
      }
    }

    return completer.future;
  }
}
