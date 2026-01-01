import 'package:equatable/equatable.dart';
import '../../domain/entities/payment_method.dart';
import '../../domain/entities/payment_result.dart';

abstract class PaymentState extends Equatable {
  const PaymentState();

  @override
  List<Object?> get props => [];
}

class PaymentInitial extends PaymentState {
  final PaymentMethodType selectedMethod;

  const PaymentInitial({
    this.selectedMethod = PaymentMethodType.cashOnDelivery,
  });

  @override
  List<Object?> get props => [selectedMethod];
}

class PaymentMethodSelected extends PaymentState {
  final PaymentMethodType method;

  const PaymentMethodSelected(this.method);

  @override
  List<Object?> get props => [method];
}

class PaymentProcessing extends PaymentState {
  const PaymentProcessing();
}

class PaymentSuccess extends PaymentState {
  final PaymentResult result;

  const PaymentSuccess(this.result);

  @override
  List<Object?> get props => [result];
}

class PaymentFailure extends PaymentState {
  final String message;

  const PaymentFailure(this.message);

  @override
  List<Object?> get props => [message];
}

class PaymentCancelled extends PaymentState {
  const PaymentCancelled();
}
