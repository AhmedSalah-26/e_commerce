import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../cart/presentation/cubit/cart_cubit.dart';
import '../../../cart/presentation/cubit/cart_state.dart';
import '../../../shipping/domain/entities/governorate_entity.dart';
import '../../../shipping/presentation/cubit/shipping_cubit.dart';
import 'checkout_coupon_section.dart';
import 'checkout_form_fields.dart';
import 'governorate_dropdown.dart';
import 'order_summary_card.dart';
import 'payment_method_card.dart';
import 'place_order_button.dart';

/// Checkout body with cart state handling
class CheckoutBody extends StatelessWidget {
  final GlobalKey<FormState> formKey;
  final TextEditingController addressController;
  final TextEditingController nameController;
  final TextEditingController phoneController;
  final TextEditingController notesController;
  final String locale;
  final void Function(double, String?, Map<String, double>?, CartLoaded,
      {double couponDiscount,
      String? couponId,
      String? couponCode,
      String? governorateName}) onPlaceOrder;

  const CheckoutBody({
    super.key,
    required this.formKey,
    required this.addressController,
    required this.nameController,
    required this.phoneController,
    required this.notesController,
    required this.locale,
    required this.onPlaceOrder,
  });

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<CartCubit, CartState>(
      buildWhen: (prev, curr) =>
          prev.runtimeType != curr.runtimeType ||
          (prev is CartLoaded &&
              curr is CartLoaded &&
              prev.items != curr.items),
      builder: (context, cartState) {
        if (cartState is! CartLoaded || cartState.isEmpty) {
          return Center(child: Text('cart_empty'.tr()));
        }

        return CheckoutFormContent(
          formKey: formKey,
          addressController: addressController,
          nameController: nameController,
          phoneController: phoneController,
          notesController: notesController,
          locale: locale,
          cartState: cartState,
          onPlaceOrder: onPlaceOrder,
        );
      },
    );
  }
}

/// Form content with shipping state
class CheckoutFormContent extends StatelessWidget {
  final GlobalKey<FormState> formKey;
  final TextEditingController addressController;
  final TextEditingController nameController;
  final TextEditingController phoneController;
  final TextEditingController notesController;
  final String locale;
  final CartLoaded cartState;
  final void Function(double, String?, Map<String, double>?, CartLoaded,
      {double couponDiscount,
      String? couponId,
      String? couponCode,
      String? governorateName}) onPlaceOrder;

  const CheckoutFormContent({
    super.key,
    required this.formKey,
    required this.addressController,
    required this.nameController,
    required this.phoneController,
    required this.notesController,
    required this.locale,
    required this.cartState,
    required this.onPlaceOrder,
  });

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<ShippingCubit, ShippingState>(
      builder: (context, shippingState) {
        final governorates = shippingState is GovernoratesLoaded
            ? shippingState.governorates
            : <GovernorateEntity>[];
        final selectedGovernorate = shippingState is GovernoratesLoaded
            ? shippingState.selectedGovernorate
            : null;
        final shippingPrice = shippingState is GovernoratesLoaded
            ? shippingState.shippingPrice
            : 0.0;
        final merchantShippingPrices = shippingState is GovernoratesLoaded
            ? shippingState.merchantShippingPrices
            : <String, double>{};
        final totalShippingPrice = shippingState is GovernoratesLoaded
            ? shippingState.totalShippingPrice
            : 0.0;
        final merchantsShippingData = shippingState is GovernoratesLoaded
            ? shippingState.merchantsShippingData
            : <String, Map<String, double>>{};

        // Get merchant IDs and names from cart
        final merchantsInfo = <String, String>{};
        for (final item in cartState.items) {
          if (item.product?.merchantId != null) {
            merchantsInfo[item.product!.merchantId!] =
                item.product!.storeName ?? '';
          }
        }

        return SingleChildScrollView(
          padding: const EdgeInsets.all(16),
          child: Form(
            key: formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                GovernorateDropdown(
                  governorates: governorates,
                  selected: selectedGovernorate,
                  locale: locale,
                  cartState: cartState,
                  merchantsShippingData: merchantsShippingData,
                  merchantsInfo: merchantsInfo,
                ),
                const SizedBox(height: 16),
                CheckoutFormFields(
                  addressController: addressController,
                  nameController: nameController,
                  phoneController: phoneController,
                  notesController: notesController,
                ),
                const SizedBox(height: 24),
                const PaymentMethodCard(),
                const SizedBox(height: 16),
                CheckoutCouponSection(
                  orderAmount: cartState.total,
                  productIds:
                      cartState.items.map((item) => item.productId).toList(),
                ),
                const SizedBox(height: 24),
                OrderSummaryCard(
                  cartState: cartState,
                  shippingPrice: shippingPrice,
                  merchantShippingPrices: merchantShippingPrices,
                ),
                const SizedBox(height: 32),
                PlaceOrderButton(
                  shippingPrice: shippingPrice,
                  totalShippingPrice: totalShippingPrice,
                  selectedGovernorate: selectedGovernorate,
                  merchantShippingPrices: merchantShippingPrices,
                  cartState: cartState,
                  locale: locale,
                  onPlaceOrder: onPlaceOrder,
                ),
                const SizedBox(height: 16),
              ],
            ),
          ),
        );
      },
    );
  }
}
