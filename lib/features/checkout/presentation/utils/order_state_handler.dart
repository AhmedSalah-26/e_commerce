import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import '../../../../core/di/injection_container.dart';
import '../../../../core/shared_widgets/toast.dart';
import '../../../../core/utils/error_helper.dart';
import '../../../auth/presentation/cubit/auth_cubit.dart';
import '../../../auth/presentation/cubit/auth_state.dart';
import '../../../cart/presentation/cubit/cart_cubit.dart';
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
    Tost.showCustomToast(
      context,
      ErrorHelper.getUserFriendlyMessage(message),
      backgroundColor: Colors.red,
      textColor: Colors.white,
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
