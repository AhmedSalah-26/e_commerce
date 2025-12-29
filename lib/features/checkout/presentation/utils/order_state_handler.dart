import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import '../../../../core/di/injection_container.dart';
import '../../../../core/services/network_error_handler.dart';
import '../../../../core/shared_widgets/toast.dart';
import '../../../../core/utils/error_helper.dart';
import '../../../auth/presentation/cubit/auth_cubit.dart';
import '../../../auth/presentation/cubit/auth_state.dart';
import '../../../cart/presentation/cubit/cart_cubit.dart';
import '../../../cart/presentation/cubit/cart_state.dart';
import '../../../notifications/data/services/local_notification_service.dart';
import '../../../orders/presentation/cubit/orders_state.dart';

/// Handles order state changes - reduces complexity in checkout page
class OrderStateHandler {
  const OrderStateHandler();

  /// Handle order state changes
  void handleState(BuildContext context, OrdersState state) {
    switch (state) {
      case OrderCreated():
        _handleOrderCreated(context, state.orderId);
      case MultiVendorOrderCreated():
        _handleMultiVendorOrderCreated(context, state.parentOrderId);
      case OrdersError():
        _handleOrderError(context, state.message);
      default:
        break;
    }
  }

  void _handleOrderCreated(BuildContext context, String orderId) {
    _showNotification(context, orderId);
    _showSuccessToast(context);
    _reloadCart(context);
    context.go('/orders');
  }

  void _handleMultiVendorOrderCreated(
      BuildContext context, String parentOrderId) {
    _showNotification(context, parentOrderId);
    _showSuccessToast(context);
    _reloadCart(context);
    context.go('/parent-order/$parentOrderId');
  }

  void _handleOrderError(BuildContext context, String message) {
    // Check if it's a network error
    if (NetworkErrorHandler.isNetworkError(message)) {
      // Show full screen network error
      _showNetworkErrorDialog(context);
    } else {
      final locale = context.locale.languageCode;
      Tost.showCustomToast(
        context,
        ErrorHelper.getUserFriendlyMessage(message, locale: locale),
        backgroundColor: Colors.red,
        textColor: Colors.white,
      );
    }
  }

  void _showNetworkErrorDialog(BuildContext context) {
    final cartCubit = context.read<CartCubit>();
    final authState = context.read<AuthCubit>().state;
    final userId = authState is AuthAuthenticated ? authState.user.id : null;

    showDialog(
      context: context,
      barrierDismissible: false,
      useRootNavigator: true,
      builder: (dialogContext) => PopScope(
        canPop: false,
        child: Dialog.fullscreen(
          backgroundColor: Theme.of(dialogContext).scaffoldBackgroundColor,
          child: _CheckoutRetryContent(
            cartCubit: cartCubit,
            userId: userId,
            onClose: () => Navigator.of(dialogContext).pop(),
          ),
        ),
      ),
    );
  }

  void _showNotification(BuildContext context, String orderId) {
    sl<LocalNotificationService>().createOrderStatusNotification(
      orderId: orderId,
      status: 'pending',
      locale: context.locale.languageCode,
    );
  }

  void _showSuccessToast(BuildContext context) {
    Tost.showCustomToast(
      context,
      'order_placed'.tr(),
      backgroundColor: Colors.green,
      textColor: Colors.white,
    );
  }

  void _reloadCart(BuildContext context) {
    final authState = context.read<AuthCubit>().state;
    if (authState is AuthAuthenticated) {
      context.read<CartCubit>().loadCart(authState.user.id);
    }
  }
}

class _CheckoutRetryContent extends StatefulWidget {
  final CartCubit cartCubit;
  final String? userId;
  final VoidCallback onClose;

  const _CheckoutRetryContent({
    required this.cartCubit,
    required this.userId,
    required this.onClose,
  });

  @override
  State<_CheckoutRetryContent> createState() => _CheckoutRetryContentState();
}

class _CheckoutRetryContentState extends State<_CheckoutRetryContent> {
  bool _isRetrying = false;

  Future<void> _handleRetry() async {
    if (_isRetrying || widget.userId == null) return;

    setState(() => _isRetrying = true);

    try {
      // Reload cart
      await widget.cartCubit.loadCart(widget.userId!);

      if (!mounted) return;

      // Check if cart loaded successfully
      final state = widget.cartCubit.state;
      if (state is CartLoaded) {
        widget.onClose();
      } else {
        setState(() => _isRetrying = false);
      }
    } catch (e) {
      if (mounted) {
        setState(() => _isRetrying = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.wifi_off_rounded,
              size: 80,
              color: theme.colorScheme.error.withValues(alpha: 0.7),
            ),
            const SizedBox(height: 24),
            Text(
              'error_network'.tr(),
              style: TextStyle(
                color: theme.colorScheme.onSurface,
                fontSize: 18,
                fontWeight: FontWeight.w500,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 8),
            Text(
              'check_connection'.tr(),
              style: TextStyle(
                color: theme.colorScheme.onSurface.withValues(alpha: 0.6),
                fontSize: 14,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 24),
            ElevatedButton.icon(
              onPressed: _isRetrying ? null : _handleRetry,
              icon: _isRetrying
                  ? const SizedBox(
                      width: 20,
                      height: 20,
                      child: CircularProgressIndicator(
                        strokeWidth: 2,
                        color: Colors.white,
                      ),
                    )
                  : const Icon(Icons.refresh),
              label: Text('retry'.tr()),
              style: ElevatedButton.styleFrom(
                padding: const EdgeInsets.symmetric(
                  horizontal: 24,
                  vertical: 12,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
