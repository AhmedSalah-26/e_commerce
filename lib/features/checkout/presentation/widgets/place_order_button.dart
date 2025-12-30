import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../../core/shared_widgets/animated_order_button.dart';
import '../../../../core/shared_widgets/toast.dart';
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
  final GlobalKey<FormState> formKey;
  final TextEditingController nameController;
  final TextEditingController phoneController;
  final TextEditingController addressController;
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
    required this.formKey,
    required this.nameController,
    required this.phoneController,
    required this.addressController,
    required this.onPlaceOrder,
  });

  @override
  Widget build(BuildContext context) {
    // Check if all merchants support shipping to selected governorate
    final merchantIds = <String>{};
    for (final item in cartState.items) {
      if (item.product?.merchantId != null) {
        merchantIds.add(item.product!.merchantId!);
      }
    }

    final allMerchantsSupported = selectedGovernorate != null &&
        merchantIds.every((id) => merchantShippingPrices.containsKey(id));

    final isRtl = locale == 'ar';

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
              child: AnimatedOrderButton(
                onPressed: isLoading
                    ? null
                    : () {
                        // Check empty fields first
                        if (nameController.text.trim().isEmpty) {
                          Tost.showCustomToast(
                            context,
                            isRtl
                                ? 'يرجى إدخال الاسم'
                                : 'Please enter your name',
                            backgroundColor: Colors.red,
                            textColor: Colors.white,
                          );
                          return;
                        }

                        if (phoneController.text.trim().isEmpty) {
                          Tost.showCustomToast(
                            context,
                            isRtl
                                ? 'يرجى إدخال رقم الهاتف'
                                : 'Please enter phone number',
                            backgroundColor: Colors.red,
                            textColor: Colors.white,
                          );
                          return;
                        }

                        if (addressController.text.trim().isEmpty) {
                          Tost.showCustomToast(
                            context,
                            isRtl
                                ? 'يرجى إدخال العنوان'
                                : 'Please enter address',
                            backgroundColor: Colors.red,
                            textColor: Colors.white,
                          );
                          return;
                        }

                        // Check governorate selection
                        if (selectedGovernorate == null) {
                          Tost.showCustomToast(
                            context,
                            isRtl
                                ? 'يرجى اختيار المحافظة'
                                : 'Please select governorate',
                            backgroundColor: Colors.red,
                            textColor: Colors.white,
                          );
                          return;
                        }

                        // Check shipping support
                        if (!allMerchantsSupported) {
                          Tost.showCustomToast(
                            context,
                            isRtl
                                ? 'بعض التجار لا يدعمون التوصيل لهذه المحافظة'
                                : 'Some merchants don\'t deliver to this governorate',
                            backgroundColor: Colors.red,
                            textColor: Colors.white,
                          );
                          return;
                        }

                        // Validate form (for any other validation rules)
                        if (!formKey.currentState!.validate()) {
                          Tost.showCustomToast(
                            context,
                            isRtl
                                ? 'يرجى إكمال البيانات المطلوبة'
                                : 'Please complete required fields',
                            backgroundColor: Colors.red,
                            textColor: Colors.white,
                          );
                          return;
                        }

                        // All validations passed, place order
                        onPlaceOrder(
                          orderShippingCost,
                          selectedGovernorate!.id,
                          merchantShippingPrices,
                          cartState,
                          couponDiscount: couponDiscount,
                          couponId: appliedCoupon?.couponId,
                          couponCode: appliedCoupon?.code,
                          governorateName: selectedGovernorate!.getName(locale),
                        );
                      },
                label: 'place_order'.tr(),
                isLoading: isLoading,
                color: theme.colorScheme.primary,
              ),
            );
          },
        );
      },
    );
  }
}
