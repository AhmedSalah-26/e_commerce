import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../auth/presentation/cubit/auth_cubit.dart';
import '../../../auth/presentation/cubit/auth_state.dart';
import '../../../coupons/presentation/widgets/coupon_input_field.dart';

/// Coupon section widget for checkout
class CheckoutCouponSection extends StatelessWidget {
  final double orderAmount;

  const CheckoutCouponSection({super.key, required this.orderAmount});

  @override
  Widget build(BuildContext context) {
    final authState = context.read<AuthCubit>().state;
    if (authState is! AuthAuthenticated) return const SizedBox.shrink();

    return CouponInputField(
      userId: authState.user.id,
      orderAmount: orderAmount,
    );
  }
}
