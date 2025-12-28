import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../../core/shared_widgets/custom_button.dart';
import '../../../cart/presentation/cubit/cart_state.dart';
import '../../../coupons/presentation/cubit/coupon_cubit.dart';
import '../../../coupons/presentation/cubit/coupon_state.dart';
import '../../../orders/presentation/cubit/orders_cubit.dart';
import '../../../orders/presentation/cubit/orders_state.dart';
import '../../../shipping/domain/entities/governorate_entity.dart';

/// Place order button with coupon support
class PlaceOrderButton extends StatelessWidget {
  final double shippingPrice;
  final double totalShippingPrice;
  final GovernorateEntity? selectedGovernorate;
  final Map<String, double> merchantShippingPrices;
  final CartLoaded cartState;
  final String locale;
  final void Function(double, String?, Map<String, double>?, CartLoaded,
      {double couponDiscount,
      String? couponId,
      String? couponCode,
      String? governorateName}) onPlaceOrder;

  const PlaceOrderButton({
    super.key,
    required this.shippingPrice,
    required this.totalShippingPrice,
    required this.selectedGovernorate,
    required this.merchantShippingPrices,
    required this.cartState,
    required this.locale,
    required this.onPlaceOrder,
  });

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<CouponCubit, CouponState>(
      builder: (context, couponState) {
        final appliedCoupon =
            couponState is CouponApplied ? couponState.result : null;
        final couponDiscount = appliedCoupon?.discountAmount ?? 0;

        return BlocSelector<OrdersCubit, OrdersState, bool>(
          selector: (state) => state is OrderCreating,
          builder: (context, isLoading) {
            final theme = Theme.of(context);
            final orderShippingCost =
                totalShippingPrice > 0 ? totalShippingPrice : shippingPrice;
            return SizedBox(
              width: double.infinity,
              child: CustomButton(
                onPressed: isLoading
                    ? () {}
                    : () => onPlaceOrder(
                          orderShippingCost,
                          selectedGovernorate?.id,
                          merchantShippingPrices,
                          cartState,
                          couponDiscount: couponDiscount,
                          couponId: appliedCoupon?.couponId,
                          couponCode: appliedCoupon?.code,
                          governorateName: selectedGovernorate?.getName(locale),
                        ),
                label: isLoading ? 'loading'.tr() : 'place_order'.tr(),
                color: theme.colorScheme.primary,
              ),
            );
          },
        );
      },
    );
  }
}
