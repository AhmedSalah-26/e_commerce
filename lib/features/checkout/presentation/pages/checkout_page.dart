import 'dart:ui' as ui;
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import '../../../../core/di/injection_container.dart';
import '../../../../core/shared_widgets/custom_button.dart';
import '../../../../core/shared_widgets/toast.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_text_style.dart';
import '../../../../core/utils/error_helper.dart';
import '../../../auth/presentation/cubit/auth_cubit.dart';
import '../../../auth/presentation/cubit/auth_state.dart';
import '../../../cart/presentation/cubit/cart_cubit.dart';
import '../../../cart/presentation/cubit/cart_state.dart';
import '../../../notifications/data/services/local_notification_service.dart';
import '../../../orders/presentation/cubit/orders_cubit.dart';
import '../../../orders/presentation/cubit/orders_state.dart';
import '../../../shipping/domain/entities/governorate_entity.dart';
import '../../../shipping/presentation/cubit/shipping_cubit.dart';
import '../widgets/checkout_form_fields.dart';
import '../widgets/governorate_dropdown.dart';
import '../widgets/payment_method_card.dart';
import '../widgets/order_summary_card.dart';

class CheckoutPage extends StatefulWidget {
  const CheckoutPage({super.key});

  @override
  State<CheckoutPage> createState() => _CheckoutPageState();
}

class _CheckoutPageState extends State<CheckoutPage> {
  final _formKey = GlobalKey<FormState>();
  final _addressController = TextEditingController();
  final _nameController = TextEditingController();
  final _phoneController = TextEditingController();
  final _notesController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _prefillUserData();
  }

  void _prefillUserData() {
    final authState = context.read<AuthCubit>().state;
    if (authState is AuthAuthenticated) {
      _nameController.text = authState.user.name ?? '';
      _phoneController.text = authState.user.phone ?? '';
    }
  }

  @override
  void dispose() {
    _addressController.dispose();
    _nameController.dispose();
    _phoneController.dispose();
    _notesController.dispose();
    super.dispose();
  }

  void _placeOrder(double shippingCost, String? governorateId,
      Map<String, double>? merchantShippingPrices, CartLoaded cartState) {
    if (_formKey.currentState!.validate()) {
      if (governorateId == null) {
        Tost.showCustomToast(
          context,
          'select_governorate'.tr(),
          backgroundColor: Colors.orange,
          textColor: Colors.white,
        );
        return;
      }

      // Check if any merchant has unavailable shipping
      if (merchantShippingPrices != null && merchantShippingPrices.isNotEmpty) {
        final merchantIds = <String>{};
        for (final item in cartState.items) {
          final merchantId = item.product?.merchantId;
          if (merchantId != null) {
            merchantIds.add(merchantId);
          }
        }

        for (final merchantId in merchantIds) {
          if (!merchantShippingPrices.containsKey(merchantId)) {
            Tost.showCustomToast(
              context,
              'shipping_not_supported'.tr(),
              backgroundColor: Colors.red,
              textColor: Colors.white,
            );
            return;
          }
        }
      }

      final authState = context.read<AuthCubit>().state;
      if (authState is AuthAuthenticated) {
        // Use multi-vendor order to split by merchant
        context.read<OrdersCubit>().createMultiVendorOrder(
              authState.user.id,
              deliveryAddress: _addressController.text.trim(),
              customerName: _nameController.text.trim(),
              customerPhone: _phoneController.text.trim(),
              notes: _notesController.text.trim().isEmpty
                  ? null
                  : _notesController.text.trim(),
              shippingCost: shippingCost,
              governorateId: governorateId,
            );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final isRtl = context.locale.languageCode == 'ar';
    final locale = context.locale.languageCode;

    return BlocProvider(
      create: (context) => sl<ShippingCubit>()..loadGovernorates(),
      child: Directionality(
        textDirection: isRtl ? ui.TextDirection.rtl : ui.TextDirection.ltr,
        child: BlocListener<OrdersCubit, OrdersState>(
          listener: (context, state) {
            if (state is OrderCreated) {
              sl<LocalNotificationService>().createOrderStatusNotification(
                orderId: state.orderId,
                status: 'pending',
                locale: context.locale.languageCode,
              );

              Tost.showCustomToast(
                context,
                'order_placed'.tr(),
                backgroundColor: Colors.green,
                textColor: Colors.white,
              );
              final authState = context.read<AuthCubit>().state;
              if (authState is AuthAuthenticated) {
                context.read<CartCubit>().loadCart(authState.user.id);
              }
              context.go('/orders');
            } else if (state is MultiVendorOrderCreated) {
              sl<LocalNotificationService>().createOrderStatusNotification(
                orderId: state.parentOrderId,
                status: 'pending',
                locale: context.locale.languageCode,
              );

              Tost.showCustomToast(
                context,
                'order_placed'.tr(),
                backgroundColor: Colors.green,
                textColor: Colors.white,
              );
              final authState = context.read<AuthCubit>().state;
              if (authState is AuthAuthenticated) {
                context.read<CartCubit>().loadCart(authState.user.id);
              }
              context.go('/parent-order/${state.parentOrderId}');
            } else if (state is OrdersError) {
              Tost.showCustomToast(
                context,
                ErrorHelper.getUserFriendlyMessage(state.message),
                backgroundColor: Colors.red,
                textColor: Colors.white,
              );
            }
          },
          child: Scaffold(
            backgroundColor: Colors.white,
            appBar: AppBar(
              backgroundColor: Colors.white,
              elevation: 0,
              leading: IconButton(
                icon: const Icon(
                  Icons.arrow_back,
                  color: AppColours.brownMedium,
                ),
                onPressed: () => context.pop(),
              ),
              title: Text(
                'checkout_title'.tr(),
                style: AppTextStyle.semiBold_20_dark_brown.copyWith(
                  color: AppColours.brownMedium,
                ),
              ),
              centerTitle: true,
            ),
            body: BlocBuilder<CartCubit, CartState>(
              builder: (context, cartState) {
                if (cartState is! CartLoaded || cartState.isEmpty) {
                  return Center(child: Text('cart_empty'.tr()));
                }

                return BlocBuilder<ShippingCubit, ShippingState>(
                  builder: (context, shippingState) {
                    final governorates = shippingState is GovernoratesLoaded
                        ? shippingState.governorates
                        : <GovernorateEntity>[];
                    final selectedGovernorate =
                        shippingState is GovernoratesLoaded
                            ? shippingState.selectedGovernorate
                            : null;
                    final shippingPrice = shippingState is GovernoratesLoaded
                        ? shippingState.shippingPrice
                        : 0.0;
                    final merchantShippingPrices =
                        shippingState is GovernoratesLoaded
                            ? shippingState.merchantShippingPrices
                            : <String, double>{};
                    final totalShippingPrice =
                        shippingState is GovernoratesLoaded
                            ? shippingState.totalShippingPrice
                            : 0.0;

                    return SingleChildScrollView(
                      padding: const EdgeInsets.all(16),
                      child: Form(
                        key: _formKey,
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            GovernorateDropdown(
                              governorates: governorates,
                              selected: selectedGovernorate,
                              locale: locale,
                              cartState: cartState,
                            ),
                            const SizedBox(height: 16),
                            CheckoutFormFields(
                              addressController: _addressController,
                              nameController: _nameController,
                              phoneController: _phoneController,
                              notesController: _notesController,
                            ),
                            const SizedBox(height: 24),
                            const PaymentMethodCard(),
                            const SizedBox(height: 24),
                            OrderSummaryCard(
                              cartState: cartState,
                              shippingPrice: shippingPrice,
                              merchantShippingPrices: merchantShippingPrices,
                            ),
                            const SizedBox(height: 32),
                            BlocBuilder<OrdersCubit, OrdersState>(
                              builder: (context, orderState) {
                                final isLoading = orderState is OrderCreating;
                                // Use total shipping price for the order
                                final orderShippingCost = totalShippingPrice > 0
                                    ? totalShippingPrice
                                    : shippingPrice;
                                return SizedBox(
                                  width: double.infinity,
                                  child: CustomButton(
                                    onPressed: isLoading
                                        ? () {}
                                        : () => _placeOrder(
                                              orderShippingCost,
                                              selectedGovernorate?.id,
                                              merchantShippingPrices,
                                              cartState,
                                            ),
                                    label: isLoading
                                        ? 'loading'.tr()
                                        : 'place_order'.tr(),
                                    color: AppColours.brownLight,
                                  ),
                                );
                              },
                            ),
                            const SizedBox(height: 16),
                          ],
                        ),
                      ),
                    );
                  },
                );
              },
            ),
          ),
        ),
      ),
    );
  }
}
