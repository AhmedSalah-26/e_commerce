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

  void _placeOrder(double shippingCost, String? governorateId) {
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

      final authState = context.read<AuthCubit>().state;
      if (authState is AuthAuthenticated) {
        context.read<OrdersCubit>().createOrderFromCart(
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
                icon:
                    const Icon(Icons.arrow_back, color: AppColours.brownMedium),
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

                    return SingleChildScrollView(
                      padding: const EdgeInsets.all(16),
                      child: Form(
                        key: _formKey,
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            // Governorate Selection
                            _buildSectionTitle('governorate'.tr()),
                            const SizedBox(height: 12),
                            _buildGovernorateDropdown(
                              context,
                              governorates,
                              selectedGovernorate,
                              locale,
                              cartState,
                            ),
                            const SizedBox(height: 16),

                            // Delivery Info Section
                            _buildSectionTitle('delivery_address'.tr()),
                            const SizedBox(height: 12),
                            _buildTextField(
                              controller: _addressController,
                              hint: 'delivery_address_hint'.tr(),
                              icon: Icons.location_on_outlined,
                              maxLines: 3,
                              validator: (value) {
                                if (value == null || value.isEmpty) {
                                  return 'field_required'.tr();
                                }
                                return null;
                              },
                            ),
                            const SizedBox(height: 16),
                            _buildSectionTitle('customer_name'.tr()),
                            const SizedBox(height: 12),
                            _buildTextField(
                              controller: _nameController,
                              hint: 'customer_name'.tr(),
                              icon: Icons.person_outlined,
                              validator: (value) {
                                if (value == null || value.isEmpty) {
                                  return 'field_required'.tr();
                                }
                                return null;
                              },
                            ),
                            const SizedBox(height: 16),
                            _buildSectionTitle('customer_phone'.tr()),
                            const SizedBox(height: 12),
                            _buildTextField(
                              controller: _phoneController,
                              hint: 'customer_phone'.tr(),
                              icon: Icons.phone_outlined,
                              keyboardType: TextInputType.phone,
                              textDirection: ui.TextDirection.ltr,
                              validator: (value) {
                                if (value == null || value.isEmpty) {
                                  return 'field_required'.tr();
                                }
                                return null;
                              },
                            ),
                            const SizedBox(height: 16),
                            _buildSectionTitle(
                                '${'order_notes'.tr()} (${'optional'.tr()})'),
                            const SizedBox(height: 12),
                            _buildTextField(
                              controller: _notesController,
                              hint: 'order_notes_hint'.tr(),
                              icon: Icons.note_outlined,
                              maxLines: 2,
                            ),
                            const SizedBox(height: 24),

                            // Payment Method
                            _buildSectionTitle('payment_method'.tr()),
                            const SizedBox(height: 12),
                            Container(
                              padding: const EdgeInsets.all(16),
                              decoration: BoxDecoration(
                                color: Colors.grey.shade100,
                                borderRadius: BorderRadius.circular(12),
                                border:
                                    Border.all(color: AppColours.brownLight),
                              ),
                              child: Row(
                                children: [
                                  const Icon(Icons.money,
                                      color: AppColours.brownMedium),
                                  const SizedBox(width: 12),
                                  Text(
                                    'cash_on_delivery'.tr(),
                                    style: AppTextStyle.normal_16_brownLight,
                                  ),
                                  const Spacer(),
                                  const Icon(Icons.check_circle,
                                      color: Colors.green),
                                ],
                              ),
                            ),
                            const SizedBox(height: 24),

                            // Order Summary
                            _buildSectionTitle('order_summary'.tr()),
                            const SizedBox(height: 12),
                            _buildOrderSummary(cartState, shippingPrice),
                            const SizedBox(height: 32),

                            // Place Order Button
                            BlocBuilder<OrdersCubit, OrdersState>(
                              builder: (context, orderState) {
                                final isLoading = orderState is OrderCreating;
                                return SizedBox(
                                  width: double.infinity,
                                  child: CustomButton(
                                    onPressed: isLoading
                                        ? () {}
                                        : () => _placeOrder(
                                              shippingPrice,
                                              selectedGovernorate?.id,
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

  Widget _buildGovernorateDropdown(
    BuildContext context,
    List<GovernorateEntity> governorates,
    GovernorateEntity? selected,
    String locale,
    CartLoaded cartState,
  ) {
    // Get merchant ID from first cart item
    String? merchantId;
    if (cartState.items.isNotEmpty && cartState.items.first.product != null) {
      merchantId = cartState.items.first.product!.merchantId;
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      decoration: BoxDecoration(
        color: Colors.white,
        border: Border.all(color: AppColours.brownLight, width: 1.5),
        borderRadius: BorderRadius.circular(12),
      ),
      child: DropdownButtonHideUnderline(
        child: DropdownButton<GovernorateEntity>(
          value: selected,
          hint: Text(
            'select_governorate'.tr(),
            style: const TextStyle(color: AppColours.brownMedium),
          ),
          isExpanded: true,
          icon: const Icon(Icons.keyboard_arrow_down,
              color: AppColours.brownMedium),
          dropdownColor: Colors.white,
          items: governorates.map((gov) {
            return DropdownMenuItem<GovernorateEntity>(
              value: gov,
              child: Text(
                gov.getName(locale),
                style: const TextStyle(color: AppColours.brownMedium),
              ),
            );
          }).toList(),
          onChanged: (gov) {
            if (gov != null) {
              context.read<ShippingCubit>().selectGovernorate(gov, merchantId);
            }
          },
        ),
      ),
    );
  }

  Widget _buildOrderSummary(CartLoaded cartState, double shippingPrice) {
    final total = cartState.total + shippingPrice;

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.grey.shade100,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        children: [
          ...cartState.items.map((item) => Padding(
                padding: const EdgeInsets.symmetric(vertical: 8),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Expanded(
                      child: Text(
                        '${item.product?.name ?? 'منتج'} x${item.quantity}',
                        style: const TextStyle(fontSize: 14),
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                    Text(
                      '${item.itemTotal.toStringAsFixed(2)} ${'egp'.tr()}',
                      style: const TextStyle(fontWeight: FontWeight.w500),
                    ),
                  ],
                ),
              )),
          const Divider(),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text('subtotal'.tr()),
              Text('${cartState.total.toStringAsFixed(2)} ${'egp'.tr()}'),
            ],
          ),
          const SizedBox(height: 8),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text('shipping_cost'.tr()),
              Text(
                shippingPrice > 0
                    ? '${shippingPrice.toStringAsFixed(2)} ${'egp'.tr()}'
                    : '-',
                style: TextStyle(
                  color: shippingPrice > 0 ? null : Colors.grey,
                ),
              ),
            ],
          ),
          const Divider(),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'total'.tr(),
                style: const TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
              Text(
                '${total.toStringAsFixed(2)} ${'egp'.tr()}',
                style: const TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: AppColours.brownMedium,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildSectionTitle(String title) {
    return Text(
      title,
      style: const TextStyle(
        fontSize: 18,
        fontWeight: FontWeight.bold,
        color: AppColours.brownMedium,
      ),
    );
  }

  Widget _buildTextField({
    required TextEditingController controller,
    String? hint,
    required IconData icon,
    int maxLines = 1,
    TextInputType? keyboardType,
    ui.TextDirection? textDirection,
    String? Function(String?)? validator,
  }) {
    return TextFormField(
      controller: controller,
      maxLines: maxLines,
      keyboardType: keyboardType,
      textDirection: textDirection,
      decoration: InputDecoration(
        hintText: hint,
        prefixIcon: Icon(icon, color: AppColours.brownMedium),
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: AppColours.brownLight, width: 2),
        ),
      ),
      validator: validator,
    );
  }
}
