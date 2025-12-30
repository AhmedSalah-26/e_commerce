import 'dart:ui' as ui;
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/shared_widgets/animated_order_button.dart';
import '../../../../core/shared_widgets/network_error_widget.dart';
import '../../../../core/shared_widgets/skeleton_widgets.dart';
import '../../../../core/utils/error_helper.dart';
import '../../../auth/presentation/cubit/auth_cubit.dart';
import '../../../auth/presentation/cubit/auth_state.dart';
import '../../domain/entities/cart_item_entity.dart';
import '../cubit/cart_cubit.dart';
import '../cubit/cart_state.dart';
import '../widgets/cart_item_card.dart';
import '../widgets/empty_cart_message.dart';

class CartScreen extends StatefulWidget {
  const CartScreen({super.key});

  @override
  State<CartScreen> createState() => _CartScreenState();
}

class _CartScreenState extends State<CartScreen> {
  bool _isCheckingOut = false;

  @override
  void initState() {
    super.initState();
    _loadCart();
  }

  void _loadCart() {
    final authState = context.read<AuthCubit>().state;
    if (authState is AuthAuthenticated) {
      context.read<CartCubit>().loadCart(authState.user.id);
    }
  }

  Future<void> _handleCheckout() async {
    if (_isCheckingOut) return;

    final authState = context.read<AuthCubit>().state;
    if (authState is! AuthAuthenticated) return;

    setState(() => _isCheckingOut = true);

    final cartCubit = context.read<CartCubit>();

    // Try to reload cart to check network connectivity and get fresh product status
    await cartCubit.loadCart(authState.user.id);

    if (!mounted) return;

    setState(() => _isCheckingOut = false);

    final state = cartCubit.state;
    if (state is CartLoaded && state.items.isNotEmpty) {
      // Check for unavailable products
      final unavailableItems = _getUnavailableItems(state.items);

      if (unavailableItems.isNotEmpty) {
        _showUnavailableProductsDialog(unavailableItems);
        return;
      }

      // All products are available, go to checkout
      context.push('/checkout');
    } else if (state is CartError) {
      // Network error - show full screen error
      _showNetworkErrorDialog();
    }
  }

  List<_UnavailableItem> _getUnavailableItems(List<CartItemEntity> items) {
    final unavailable = <_UnavailableItem>[];

    for (final item in items) {
      if (item.product == null) continue;

      final product = item.product!;

      if (product.isSuspended) {
        unavailable.add(_UnavailableItem(
          name: product.name,
          reason: _UnavailableReason.suspended,
        ));
      } else if (!product.isActive) {
        unavailable.add(_UnavailableItem(
          name: product.name,
          reason: _UnavailableReason.inactive,
        ));
      } else if (product.isOutOfStock) {
        unavailable.add(_UnavailableItem(
          name: product.name,
          reason: _UnavailableReason.outOfStock,
        ));
      }
    }

    return unavailable;
  }

  void _showUnavailableProductsDialog(List<_UnavailableItem> items) {
    final isArabic = context.locale.languageCode == 'ar';

    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Row(
          children: [
            Icon(Icons.warning_amber_rounded, color: Colors.orange[700]),
            const SizedBox(width: 8),
            Expanded(
              child: Text(
                isArabic ? 'منتجات غير متاحة' : 'Unavailable Products',
                style: const TextStyle(fontSize: 18),
              ),
            ),
          ],
        ),
        content: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                isArabic
                    ? 'يرجى إزالة المنتجات التالية من السلة قبل إتمام الطلب:'
                    : 'Please remove the following products from cart before checkout:',
                style: TextStyle(color: Colors.grey[700]),
              ),
              const SizedBox(height: 16),
              ...items.map((item) => Padding(
                    padding: const EdgeInsets.only(bottom: 8),
                    child: Row(
                      children: [
                        Container(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 6, vertical: 2),
                          decoration: BoxDecoration(
                            color: item.reason.color.withValues(alpha: 0.1),
                            borderRadius: BorderRadius.circular(4),
                          ),
                          child: Text(
                            item.reason.getLabel(isArabic),
                            style: TextStyle(
                              fontSize: 10,
                              fontWeight: FontWeight.w600,
                              color: item.reason.color,
                            ),
                          ),
                        ),
                        const SizedBox(width: 8),
                        Expanded(
                          child: Text(
                            item.name,
                            style: const TextStyle(fontSize: 13),
                            maxLines: 2,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                      ],
                    ),
                  )),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(),
            child: Text(isArabic ? 'حسناً' : 'OK'),
          ),
        ],
      ),
    );
  }

  void _showNetworkErrorDialog() {
    final cartCubit = context.read<CartCubit>();
    final authState = context.read<AuthCubit>().state;
    final userId = authState is AuthAuthenticated ? authState.user.id : null;

    NetworkErrorWidget.showForCheckout(
      context,
      cartCubit: cartCubit,
      userId: userId,
      onSuccess: () => context.push('/checkout'),
    );
  }

  @override
  Widget build(BuildContext context) {
    final isRtl = context.locale.languageCode == 'ar';
    final theme = Theme.of(context);

    return Directionality(
      textDirection: isRtl ? ui.TextDirection.rtl : ui.TextDirection.ltr,
      child: Scaffold(
        backgroundColor: theme.scaffoldBackgroundColor,
        appBar: AppBar(
          backgroundColor: theme.scaffoldBackgroundColor,
          title: Text(
            'shopping_cart'.tr(),
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.w600,
              color: theme.colorScheme.primary,
            ),
          ),
          centerTitle: true,
        ),
        body: BlocBuilder<AuthCubit, AuthState>(
          builder: (context, authState) {
            if (authState is! AuthAuthenticated) {
              return EmptyStates.loginRequired(context,
                  message: 'login_to_see_cart'.tr());
            }

            return BlocBuilder<CartCubit, CartState>(
              builder: (context, state) {
                if (state is CartLoading) {
                  return const Padding(
                    padding: EdgeInsets.all(16.0),
                    child: CartListSkeleton(itemCount: 3),
                  );
                }

                if (state is CartError) {
                  return NetworkErrorWidget(
                    message: ErrorHelper.getUserFriendlyMessage(state.message),
                    onRetry: _loadCart,
                  );
                }

                if (state is CartLoaded) {
                  if (state.isEmpty) {
                    return const EmptyCartMessage();
                  }

                  return Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: Column(
                      children: [
                        Expanded(
                          child: ListView.builder(
                            itemCount: state.items.length,
                            addAutomaticKeepAlives: false,
                            cacheExtent: 300,
                            itemBuilder: (context, index) {
                              final cartItem = state.items[index];
                              return CartItemCard(
                                key: ValueKey(cartItem.id),
                                cartItem: cartItem,
                              );
                            },
                          ),
                        ),
                        Container(
                          padding: const EdgeInsets.all(16),
                          decoration: BoxDecoration(
                            color: theme.colorScheme.surface,
                            borderRadius: BorderRadius.circular(12),
                            border: Border.all(
                              color: theme.colorScheme.outline
                                  .withValues(alpha: 0.3),
                            ),
                          ),
                          child: Column(
                            children: [
                              Row(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceBetween,
                                children: [
                                  Text(
                                    '${'total'.tr()}:',
                                    style: TextStyle(
                                      fontSize: 16,
                                      fontWeight: FontWeight.bold,
                                      color: theme.colorScheme.onSurface,
                                    ),
                                  ),
                                  Text(
                                    '${state.total.toStringAsFixed(2)} ${'egp'.tr()}',
                                    style: TextStyle(
                                      fontSize: 18,
                                      fontWeight: FontWeight.bold,
                                      color: theme.colorScheme.primary,
                                    ),
                                  ),
                                ],
                              ),
                              const SizedBox(height: 16),
                              SizedBox(
                                width: double.infinity,
                                child: AnimatedOrderButton(
                                  onPressed:
                                      _isCheckingOut ? null : _handleCheckout,
                                  isLoading: _isCheckingOut,
                                  label: 'checkout'.tr(),
                                  color: theme.colorScheme.primary,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  );
                }

                return const Padding(
                  padding: EdgeInsets.all(16.0),
                  child: CartListSkeleton(itemCount: 3),
                );
              },
            );
          },
        ),
      ),
    );
  }
}

enum _UnavailableReason {
  suspended,
  inactive,
  outOfStock,
}

extension _UnavailableReasonExtension on _UnavailableReason {
  String getLabel(bool isArabic) {
    switch (this) {
      case _UnavailableReason.suspended:
        return isArabic ? 'محظور' : 'Blocked';
      case _UnavailableReason.inactive:
        return isArabic ? 'موقوف' : 'Inactive';
      case _UnavailableReason.outOfStock:
        return isArabic ? 'نفذ' : 'Out of Stock';
    }
  }

  Color get color {
    switch (this) {
      case _UnavailableReason.suspended:
        return Colors.red;
      case _UnavailableReason.inactive:
        return Colors.orange;
      case _UnavailableReason.outOfStock:
        return Colors.grey;
    }
  }
}

class _UnavailableItem {
  final String name;
  final _UnavailableReason reason;

  _UnavailableItem({required this.name, required this.reason});
}
