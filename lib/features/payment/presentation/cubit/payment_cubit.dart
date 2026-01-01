import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'dart:io' show Platform;
import '../../data/services/paymob_service.dart';
import '../../domain/entities/payment_method.dart';
import 'payment_state.dart';

class PaymentCubit extends Cubit<PaymentState> {
  PaymentCubit() : super(const PaymentInitial());

  PaymentMethodType _selectedMethod = PaymentMethodType.cashOnDelivery;

  PaymentMethodType get selectedMethod => _selectedMethod;

  /// Check if online payment is supported on current platform
  static bool get isOnlinePaymentSupported {
    if (kIsWeb) return false;
    try {
      return Platform.isAndroid || Platform.isIOS;
    } catch (_) {
      return false;
    }
  }

  /// Select payment method
  void selectPaymentMethod(PaymentMethodType method) {
    _selectedMethod = method;
    emit(PaymentMethodSelected(method));
  }

  /// Process payment based on selected method
  Future<bool> processPayment({
    required BuildContext context,
    required double amount,
    String? walletPhoneNumber,
  }) async {
    switch (_selectedMethod) {
      case PaymentMethodType.cashOnDelivery:
        // No payment processing needed
        return true;

      case PaymentMethodType.card:
        if (!isOnlinePaymentSupported) {
          emit(
              const PaymentFailure('الدفع الإلكتروني غير متاح على هذه المنصة'));
          return false;
        }
        return _processCardPayment(context, amount);

      case PaymentMethodType.wallet:
        if (walletPhoneNumber == null || walletPhoneNumber.isEmpty) {
          emit(const PaymentFailure('رقم المحفظة مطلوب'));
          return false;
        }
        return _processWalletPayment(context, amount, walletPhoneNumber);
    }
  }

  Future<bool> _processCardPayment(BuildContext context, double amount) async {
    emit(const PaymentProcessing());

    final result = await PaymobService.instance.payWithCard(
      context: context,
      amount: amount,
    );

    if (result.success) {
      emit(PaymentSuccess(result));
      return true;
    } else {
      if (result.message == 'Payment cancelled by user') {
        emit(const PaymentCancelled());
      } else {
        emit(PaymentFailure(result.message ?? 'فشل الدفع'));
      }
      return false;
    }
  }

  Future<bool> _processWalletPayment(
    BuildContext context,
    double amount,
    String phoneNumber,
  ) async {
    // Wallet not supported in current package
    emit(const PaymentFailure('الدفع بالمحفظة غير متاح حالياً'));
    return false;
  }

  /// Reset to initial state
  void reset() {
    _selectedMethod = PaymentMethodType.cashOnDelivery;
    emit(const PaymentInitial());
  }
}
