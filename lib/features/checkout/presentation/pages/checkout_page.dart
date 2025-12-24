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
import '../../../auth/presentation/cubit/auth_cubit.dart';
import '../../../auth/presentation/cubit/auth_state.dart';
import '../../../cart/presentation/cubit/cart_cubit.dart';
import '../../../cart/presentation/cubit/cart_state.dart';
import '../../../orders/presentation/cubit/orders_cubit.dart';
import '../../../orders/presentation/cubit/orders_state.dart';
import '../../../shipping/domain/entities/governorate_entity.dart';
import '../../../shipping/presentation/cubit/shipping_cubit.dart';
import '../../domain/checkout_validator.dart';
import '../utils/order_state_handler.dart';
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

  static const _validator = CheckoutValidator();
  static const _stateHandler = OrderStateHandler();

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
    if (!_formKey.currentState!.validate()) return;

    final validation = _validator.validate(
      governorateId: governorateId,
      merchantShippingPrices: merchantShippingPrices,
      cartState: cartState,
    );

    if (!validation.isValid) {
      Tost.showCustomToast(
        context,
        validation.errorKey!.tr(),
        backgroundColor: validation.errorKey == 'select_governorate'
            ? Colors.orange
            : Colors.red,
        textColor: Colors.white,
      );
      return;
    }

    _submitOrder(shippingCost, governorateId!);
  }

  void _submitOrder(double shippingCost, String governorateId) {
    final authState = context.read<AuthCubit>().state;
    if (authState is! AuthAuthenticated) return;

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

  @override
  Widget build(BuildContext context) {
    final isRtl = context.locale.languageCode == 'ar';
    final locale = context.locale.languageCode;

    return BlocProvider(
      create: (context) => sl<ShippingCubit>()..loadGovernorates(),
      child: Directionality(
        textDirection: isRtl ? ui.TextDirection.rtl : ui.TextDirection.ltr,
        child: BlocListener<OrdersCubit, OrdersState>(
          listener: (context, state) =>
              _stateHandler.handleState(context, state),
          child: Scaffold(
            backgroundColor: Colors.white,
            appBar: AppBar(
              backgroundColor: Colors.white,
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
            body: _CheckoutBody(
              formKey: _formKey,
              addressController: _addressController,
              nameController: _nameController,
              phoneController: _phoneController,
              notesController: _notesController,
              locale: locale,
              onPlaceOrder: _placeOrder,
            ),
          ),
        ),
      ),
    );
  }
}

/// Optimized checkout body with selective rebuilds
class _CheckoutBody extends StatelessWidget {
  final GlobalKey<FormState> formKey;
  final TextEditingController addressController;
  final TextEditingController nameController;
  final TextEditingController phoneController;
  final TextEditingController notesController;
  final String locale;
  final void Function(double, String?, Map<String, double>?, CartLoaded)
      onPlaceOrder;

  const _CheckoutBody({
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

        return _CheckoutForm(
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
class _CheckoutForm extends StatelessWidget {
  final GlobalKey<FormState> formKey;
  final TextEditingController addressController;
  final TextEditingController nameController;
  final TextEditingController phoneController;
  final TextEditingController notesController;
  final String locale;
  final CartLoaded cartState;
  final void Function(double, String?, Map<String, double>?, CartLoaded)
      onPlaceOrder;

  const _CheckoutForm({
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
                const SizedBox(height: 24),
                OrderSummaryCard(
                  cartState: cartState,
                  shippingPrice: shippingPrice,
                  merchantShippingPrices: merchantShippingPrices,
                ),
                const SizedBox(height: 32),
                _PlaceOrderButton(
                  shippingPrice: shippingPrice,
                  totalShippingPrice: totalShippingPrice,
                  selectedGovernorate: selectedGovernorate,
                  merchantShippingPrices: merchantShippingPrices,
                  cartState: cartState,
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

/// Optimized place order button - only rebuilds when order state changes
class _PlaceOrderButton extends StatelessWidget {
  final double shippingPrice;
  final double totalShippingPrice;
  final GovernorateEntity? selectedGovernorate;
  final Map<String, double> merchantShippingPrices;
  final CartLoaded cartState;
  final void Function(double, String?, Map<String, double>?, CartLoaded)
      onPlaceOrder;

  const _PlaceOrderButton({
    required this.shippingPrice,
    required this.totalShippingPrice,
    required this.selectedGovernorate,
    required this.merchantShippingPrices,
    required this.cartState,
    required this.onPlaceOrder,
  });

  @override
  Widget build(BuildContext context) {
    return BlocSelector<OrdersCubit, OrdersState, bool>(
      selector: (state) => state is OrderCreating,
      builder: (context, isLoading) {
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
                    ),
            label: isLoading ? 'loading'.tr() : 'place_order'.tr(),
            color: AppColours.brownLight,
          ),
        );
      },
    );
  }
}
