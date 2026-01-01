import 'dart:ui' as ui;
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import '../../../../core/di/injection_container.dart';
import '../../../../core/shared_widgets/toast.dart';
import '../../../auth/presentation/cubit/auth_cubit.dart';
import '../../../auth/presentation/cubit/auth_state.dart';
import '../../../cart/presentation/cubit/cart_cubit.dart';
import '../../../cart/presentation/cubit/cart_state.dart';
import '../../../coupons/presentation/cubit/coupon_cubit.dart';
import '../../../orders/presentation/cubit/orders_cubit.dart';
import '../../../orders/presentation/cubit/orders_state.dart';
import '../../../shipping/presentation/cubit/shipping_cubit.dart';
import '../../../payment/presentation/cubit/payment_cubit.dart';
import '../../domain/checkout_validator.dart';
import '../utils/order_state_handler.dart';
import '../widgets/checkout_form_content.dart';
import '../../../payment/presentation/widgets/payment_webview.dart';
import '../../../payment/data/services/paymob_service.dart';
import '../../../payment/domain/entities/payment_result.dart';
import '../../../payment/domain/entities/payment_method.dart';

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

      // Prefill default address if available
      final defaultAddress = authState.user.defaultAddress;
      if (defaultAddress != null) {
        _addressController.text = defaultAddress.displayAddress;
      }
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
      {double couponDiscount = 0,
      String? couponId,
      String? couponCode,
      String? governorateName}) {
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
        couponCode: couponCode,
        governorateName: governorateName);
  }

  void _submitOrder(double shippingCost, String governorateId,
      {double couponDiscount = 0,
      String? couponId,
      String? couponCode,
      String? governorateName}) {
    final authState = context.read<AuthCubit>().state;
    if (authState is! AuthAuthenticated) return;

    // Combine governorate name with address
    final address = _addressController.text.trim();
    final fullAddress =
        governorateName != null ? '$governorateName - $address' : address;

    context.read<OrdersCubit>().createMultiVendorOrder(
          authState.user.id,
          deliveryAddress: fullAddress,
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
        BlocProvider(create: (context) => sl<ShippingCubit>()),
        BlocProvider(create: (context) => sl<CouponCubit>()),
        BlocProvider(create: (context) => sl<PaymentCubit>()),
      ],
      child: _CheckoutPageContent(
        formKey: _formKey,
        addressController: _addressController,
        nameController: _nameController,
        phoneController: _phoneController,
        notesController: _notesController,
        locale: locale,
        isRtl: isRtl,
        onPlaceOrder: _placeOrder,
      ),
    );
  }
}

class _CheckoutPageContent extends StatefulWidget {
  final GlobalKey<FormState> formKey;
  final TextEditingController addressController;
  final TextEditingController nameController;
  final TextEditingController phoneController;
  final TextEditingController notesController;
  final String locale;
  final bool isRtl;
  final void Function(double, String?, Map<String, double>?, CartLoaded,
      {double couponDiscount,
      String? couponId,
      String? couponCode,
      String? governorateName}) onPlaceOrder;

  const _CheckoutPageContent({
    required this.formKey,
    required this.addressController,
    required this.nameController,
    required this.phoneController,
    required this.notesController,
    required this.locale,
    required this.isRtl,
    required this.onPlaceOrder,
  });

  @override
  State<_CheckoutPageContent> createState() => _CheckoutPageContentState();
}

class _CheckoutPageContentState extends State<_CheckoutPageContent> {
  static const _stateHandler = OrderStateHandler();

  // Payment state
  bool _showPaymentWebView = false;
  String? _paymentUrl;

  // Store order data for after payment
  double? _pendingShippingCost;
  String? _pendingGovernorateId;
  Map<String, double>? _pendingMerchantShippingPrices;
  CartLoaded? _pendingCartState;
  double _pendingCouponDiscount = 0;
  String? _pendingCouponId;
  String? _pendingCouponCode;
  String? _pendingGovernorateName;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _loadShippingData();
    });
  }

  void _loadShippingData() {
    final cartState = context.read<CartCubit>().state;
    debugPrint('🛒 CheckoutPage: Cart state type: ${cartState.runtimeType}');

    if (cartState is CartLoaded) {
      final merchantIds = <String>{};
      for (final item in cartState.items) {
        if (item.product?.merchantId != null) {
          merchantIds.add(item.product!.merchantId!);
        }
      }
      debugPrint(
          '🛒 CheckoutPage: Found ${merchantIds.length} merchants: $merchantIds');

      context
          .read<ShippingCubit>()
          .loadGovernoratesWithAvailability(merchantIds.toList());
    } else {
      debugPrint('⚠️ CheckoutPage: Cart not loaded, loading governorates only');
      context.read<ShippingCubit>().loadGovernorates();
    }
  }

  Future<void> _handlePlaceOrder(
    double shippingCost,
    String? governorateId,
    Map<String, double>? merchantShippingPrices,
    CartLoaded cartState, {
    double couponDiscount = 0,
    String? couponId,
    String? couponCode,
    String? governorateName,
  }) async {
    final paymentCubit = context.read<PaymentCubit>();
    final selectedMethod = paymentCubit.selectedMethod;

    // If cash on delivery, place order directly
    if (selectedMethod == PaymentMethodType.cashOnDelivery) {
      widget.onPlaceOrder(
        shippingCost,
        governorateId,
        merchantShippingPrices,
        cartState,
        couponDiscount: couponDiscount,
        couponId: couponId,
        couponCode: couponCode,
        governorateName: governorateName,
      );
      return;
    }

    // For card payment, get payment URL and show webview
    final totalAmount = cartState.total + shippingCost - couponDiscount;

    final paymentUrl = await PaymobService.instance.getPaymentUrl(
      amount: totalAmount,
      customerName: widget.nameController.text.trim(),
      customerPhone: widget.phoneController.text.trim(),
    );

    if (paymentUrl == null) {
      if (mounted) {
        Tost.showCustomToast(
          context,
          widget.isRtl ? 'فشل في تحميل صفحة الدفع' : 'Failed to load payment',
          backgroundColor: Colors.red,
          textColor: Colors.white,
        );
      }
      return;
    }

    // Store order data for after payment
    _pendingShippingCost = shippingCost;
    _pendingGovernorateId = governorateId;
    _pendingMerchantShippingPrices = merchantShippingPrices;
    _pendingCartState = cartState;
    _pendingCouponDiscount = couponDiscount;
    _pendingCouponId = couponId;
    _pendingCouponCode = couponCode;
    _pendingGovernorateName = governorateName;

    setState(() {
      _paymentUrl = paymentUrl;
      _showPaymentWebView = true;
    });
  }

  void _handlePaymentComplete(PaymentResult result) {
    setState(() {
      _showPaymentWebView = false;
      _paymentUrl = null;
    });

    if (result.success && _pendingCartState != null) {
      // Payment successful, place order
      widget.onPlaceOrder(
        _pendingShippingCost!,
        _pendingGovernorateId,
        _pendingMerchantShippingPrices,
        _pendingCartState!,
        couponDiscount: _pendingCouponDiscount,
        couponId: _pendingCouponId,
        couponCode: _pendingCouponCode,
        governorateName: _pendingGovernorateName,
      );
    } else if (!result.success &&
        result.message != 'Payment cancelled by user') {
      Tost.showCustomToast(
        context,
        result.message ?? (widget.isRtl ? 'فشل الدفع' : 'Payment failed'),
        backgroundColor: Colors.red,
        textColor: Colors.white,
      );
    }
  }

  void _handlePaymentCancel() {
    setState(() {
      _showPaymentWebView = false;
      _paymentUrl = null;
    });
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Directionality(
      textDirection: widget.isRtl ? ui.TextDirection.rtl : ui.TextDirection.ltr,
      child: BlocListener<OrdersCubit, OrdersState>(
        listener: (context, state) => _stateHandler.handleState(context, state),
        child: Scaffold(
          backgroundColor: theme.scaffoldBackgroundColor,
          appBar: _showPaymentWebView
              ? null
              : AppBar(
                  backgroundColor: theme.scaffoldBackgroundColor,
                  leading: IconButton(
                    icon: Icon(
                      Icons.arrow_back,
                      color: theme.colorScheme.primary,
                    ),
                    onPressed: () => context.pop(),
                  ),
                  title: Text(
                    'checkout_title'.tr(),
                    style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.w600,
                      color: theme.colorScheme.primary,
                    ),
                  ),
                  centerTitle: true,
                ),
          body: _showPaymentWebView && _paymentUrl != null
              ? PaymentWebView(
                  paymentUrl: _paymentUrl!,
                  onPaymentComplete: _handlePaymentComplete,
                  onCancel: _handlePaymentCancel,
                )
              : CheckoutBody(
                  formKey: widget.formKey,
                  addressController: widget.addressController,
                  nameController: widget.nameController,
                  phoneController: widget.phoneController,
                  notesController: widget.notesController,
                  locale: widget.locale,
                  onPlaceOrder: _handlePlaceOrder,
                ),
        ),
      ),
    );
  }
}
