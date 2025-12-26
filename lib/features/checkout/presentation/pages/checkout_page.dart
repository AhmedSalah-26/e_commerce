import 'dart:ui' as ui;
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import '../../../../core/di/injection_container.dart';
import '../../../../core/shared_widgets/toast.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_text_style.dart';
import '../../../auth/presentation/cubit/auth_cubit.dart';
import '../../../auth/presentation/cubit/auth_state.dart';
import '../../../cart/presentation/cubit/cart_state.dart';
import '../../../coupons/presentation/cubit/coupon_cubit.dart';
import '../../../orders/presentation/cubit/orders_cubit.dart';
import '../../../orders/presentation/cubit/orders_state.dart';
import '../../../shipping/presentation/cubit/shipping_cubit.dart';
import '../../domain/checkout_validator.dart';
import '../utils/order_state_handler.dart';
import '../widgets/checkout_form_content.dart';

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
      Map<String, double>? merchantShippingPrices, CartLoaded cartState,
      {double couponDiscount = 0, String? couponId, String? couponCode}) {
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

    _submitOrder(shippingCost, governorateId!,
        couponDiscount: couponDiscount,
        couponId: couponId,
        couponCode: couponCode);
  }

  void _submitOrder(double shippingCost, String governorateId,
      {double couponDiscount = 0, String? couponId, String? couponCode}) {
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
          couponId: couponId,
          couponCode: couponCode,
          couponDiscount: couponDiscount,
        );
  }

  @override
  Widget build(BuildContext context) {
    final isRtl = context.locale.languageCode == 'ar';
    final locale = context.locale.languageCode;

    // Check if user is authenticated
    final authState = context.read<AuthCubit>().state;
    if (authState is! AuthAuthenticated) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        context.go('/login');
      });
      return const Scaffold(
        body: Center(child: CircularProgressIndicator()),
      );
    }

    return MultiBlocProvider(
      providers: [
        BlocProvider(
            create: (context) => sl<ShippingCubit>()..loadGovernorates()),
        BlocProvider(create: (context) => sl<CouponCubit>()),
      ],
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
            body: CheckoutBody(
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
