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
import '../../../orders/domain/entities/order_entity.dart';
import '../../../orders/presentation/cubit/orders_cubit.dart';
import '../../../orders/presentation/cubit/orders_state.dart';
import '../../../shipping/presentation/cubit/shipping_cubit.dart';
import '../../../payment/presentation/cubit/payment_cubit.dart';
import '../../domain/checkout_validator.dart';
import '../utils/order_state_handler.dart';
import '../widgets/checkout_form_content.dart';
import '../../../payment/presentation/widgets/payment_webview.dart';
import '../../../payment/presentation/widgets/wallet_phone_dialog.dart';
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
      String? governorateName,
      String? paymentMethod}) {
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
        governorateName: governorateName,
        paymentMethod: paymentMethod);
  }

  void _submitOrder(double shippingCost, String governorateId,
      {double couponDiscount = 0,
      String? couponId,
      String? couponCode,
      String? governorateName,
      String? paymentMethod}) {
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
          paymentMethod: paymentMethod,
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
      String? governorateName,
      String? paymentMethod}) onPlaceOrder;

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
  bool _isLoadingPayment = false;
  bool _isWalletPayment = false;

  // Store order data for card/wallet payment flow
  double? _pendingTotalAmount;
  String? _walletPhoneNumber;
  String? _pendingOrderId;

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

    // If cash on delivery, place order directly with cash_on_delivery status
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
        paymentMethod: 'cash_on_delivery',
      );
      return;
    }

    // For wallet payment: show dialog to get wallet phone number
    if (selectedMethod == PaymentMethodType.wallet) {
      final walletPhone = await WalletPhoneDialog.show(
        context,
        initialPhone: widget.phoneController.text.trim(),
      );

      if (walletPhone == null || walletPhone.isEmpty) {
        // User cancelled
        return;
      }
      _walletPhoneNumber = walletPhone;
    }

    // For card/wallet payment: store total amount for payment page
    _pendingTotalAmount = cartState.total + shippingCost - couponDiscount;

    // Create order FIRST with pending payment status
    // The order will be created, then we open payment page
    // Webhook will update payment status to paid/failed
    final paymentMethodStr =
        selectedMethod == PaymentMethodType.wallet ? 'wallet' : 'card';
    widget.onPlaceOrder(
      shippingCost,
      governorateId,
      merchantShippingPrices,
      cartState,
      couponDiscount: couponDiscount,
      couponId: couponId,
      couponCode: couponCode,
      governorateName: governorateName,
      paymentMethod: paymentMethodStr,
    );
  }

  /// Called when order is created successfully for card/wallet payment
  Future<void> _openPaymentPage(
      String orderId, PaymentMethodType paymentMethod) async {
    if (_pendingTotalAmount == null) return;

    // Store order ID for status update if payment fails
    _pendingOrderId = orderId;

    setState(() {
      _isLoadingPayment = true;
      _isWalletPayment = paymentMethod == PaymentMethodType.wallet;
    });

    String? paymentUrl;

    if (paymentMethod == PaymentMethodType.wallet &&
        _walletPhoneNumber != null) {
      // Wallet payment
      paymentUrl = await PaymobService.instance.getWalletPaymentUrl(
        amount: _pendingTotalAmount!,
        orderId: orderId,
        walletPhoneNumber: _walletPhoneNumber!,
        customerName: widget.nameController.text.trim(),
        customerEmail: null,
      );
    } else {
      // Card payment
      paymentUrl = await PaymobService.instance.getPaymentUrl(
        amount: _pendingTotalAmount!,
        orderId: orderId,
        customerName: widget.nameController.text.trim(),
        customerPhone: widget.phoneController.text.trim(),
      );
    }

    if (!mounted) return;

    if (paymentUrl == null || paymentUrl.isEmpty) {
      setState(() {
        _isLoadingPayment = false;
        _isWalletPayment = false;
      });
      Tost.showCustomToast(
        context,
        widget.isRtl ? 'فشل في تحميل صفحة الدفع' : 'Failed to load payment',
        backgroundColor: Colors.red,
        textColor: Colors.white,
      );
      return;
    }

    // Check for wallet payment error
    if (paymentUrl.startsWith('ERROR:')) {
      setState(() {
        _isLoadingPayment = false;
        _isWalletPayment = false;
      });
      final errorMessage = paymentUrl.substring(6);
      String displayMessage;
      if (errorMessage.contains('not registered')) {
        displayMessage = widget.isRtl
            ? 'رقم الهاتف غير مسجل في أي محفظة إلكترونية'
            : 'Phone number is not registered with any wallet';
      } else {
        displayMessage = errorMessage;
      }
      Tost.showCustomToast(
        context,
        displayMessage,
        backgroundColor: Colors.red,
        textColor: Colors.white,
      );
      return;
    }

    setState(() {
      _paymentUrl = paymentUrl;
      _showPaymentWebView = true;
      _isLoadingPayment = false;
    });
  }

  void _handlePaymentComplete(PaymentResult result) {
    final orderId = _pendingOrderId;

    setState(() {
      _showPaymentWebView = false;
      _paymentUrl = null;
      _pendingTotalAmount = null;
      _walletPhoneNumber = null;
      _isWalletPayment = false;
      _pendingOrderId = null;
    });

    if (result.success) {
      // Payment successful - webhook will update order status
      // Navigate to order confirmation
      Tost.showCustomToast(
        context,
        widget.isRtl ? 'تم الدفع بنجاح!' : 'Payment successful!',
        backgroundColor: Colors.green,
        textColor: Colors.white,
      );
      context.go('/orders');
    } else if (result.message != 'Payment cancelled by user') {
      // Payment failed - update order status to payment_failed
      if (orderId != null) {
        context.read<OrdersCubit>().updateOrderStatus(
              orderId,
              OrderStatus.paymentFailed,
            );
      }
      Tost.showCustomToast(
        context,
        result.message ?? (widget.isRtl ? 'فشل الدفع' : 'Payment failed'),
        backgroundColor: Colors.red,
        textColor: Colors.white,
      );
      // Navigate to orders page to show failed order
      context.go('/orders');
    }
  }

  void _handlePaymentCancel() {
    setState(() {
      _showPaymentWebView = false;
      _paymentUrl = null;
      _pendingTotalAmount = null;
      _walletPhoneNumber = null;
      _isWalletPayment = false;
      _pendingOrderId = null;
    });

    // Order remains with pending status - user can retry payment later
    Tost.showCustomToast(
      context,
      widget.isRtl
          ? 'تم إلغاء الدفع - يمكنك الدفع لاحقاً من صفحة الطلبات'
          : 'Payment cancelled - you can pay later from orders page',
      backgroundColor: Colors.orange,
      textColor: Colors.white,
    );
  }

  void _handleOrderState(BuildContext context, OrdersState state) {
    final paymentCubit = context.read<PaymentCubit>();
    final selectedMethod = paymentCubit.selectedMethod;
    final isOnlinePayment = selectedMethod == PaymentMethodType.card ||
        selectedMethod == PaymentMethodType.wallet;

    if (state is MultiVendorOrderCreated &&
        isOnlinePayment &&
        _pendingTotalAmount != null) {
      // Order created for card/wallet payment - open payment page
      _openPaymentPage(state.parentOrderId, selectedMethod);
    } else {
      // Cash on delivery or other states - use default handler
      _stateHandler.handleState(context, state);
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Directionality(
      textDirection: widget.isRtl ? ui.TextDirection.rtl : ui.TextDirection.ltr,
      child: BlocListener<OrdersCubit, OrdersState>(
        listener: _handleOrderState,
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
                  isWalletPayment: _isWalletPayment,
                )
              : Stack(
                  children: [
                    CheckoutBody(
                      formKey: widget.formKey,
                      addressController: widget.addressController,
                      nameController: widget.nameController,
                      phoneController: widget.phoneController,
                      notesController: widget.notesController,
                      locale: widget.locale,
                      onPlaceOrder: _handlePlaceOrder,
                    ),
                    if (_isLoadingPayment)
                      Container(
                        color: Colors.black.withValues(alpha: 0.5),
                        child: Center(
                          child: Container(
                            padding: const EdgeInsets.all(24),
                            decoration: BoxDecoration(
                              color: theme.colorScheme.surface,
                              borderRadius: BorderRadius.circular(16),
                            ),
                            child: Column(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                CircularProgressIndicator(
                                  color: theme.colorScheme.primary,
                                ),
                                const SizedBox(height: 16),
                                Text(
                                  widget.isRtl
                                      ? 'جاري تحميل صفحة الدفع...'
                                      : 'Loading payment page...',
                                  style: TextStyle(
                                    fontSize: 16,
                                    fontWeight: FontWeight.w500,
                                    color: theme.colorScheme.onSurface,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ),
                  ],
                ),
        ),
      ),
    );
  }
}
