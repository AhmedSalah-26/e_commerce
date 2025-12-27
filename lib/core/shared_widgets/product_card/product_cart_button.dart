import 'dart:async';

import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../features/auth/presentation/cubit/auth_cubit.dart';
import '../../../features/auth/presentation/cubit/auth_state.dart';
import '../../../features/cart/presentation/cubit/cart_cubit.dart';
import '../../../features/cart/presentation/cubit/cart_state.dart';
import '../../../features/products/domain/entities/product_entity.dart';
import '../toast.dart';

class ProductCartButton extends StatelessWidget {
  final ProductEntity product;

  const ProductCartButton({super.key, required this.product});

  @override
  Widget build(BuildContext context) {
    return BlocSelector<CartCubit, CartState, _CartData>(
      selector: (state) => _getCartData(state),
      builder: (context, data) {
        if (data.isInCart) {
          return _QuantityControls(
            quantity: data.quantity,
            cartItemId: data.cartItemId!,
            maxStock: product.stock,
          );
        }
        return _AddToCartButton(product: product);
      },
    );
  }

  _CartData _getCartData(CartState state) {
    if (state is CartLoaded) {
      final item =
          state.items.where((item) => item.productId == product.id).firstOrNull;
      if (item != null) {
        return _CartData(
          isInCart: true,
          cartItemId: item.id,
          quantity: item.quantity,
        );
      }
    }
    return const _CartData(isInCart: false, quantity: 1);
  }
}

class _CartData {
  final bool isInCart;
  final String? cartItemId;
  final int quantity;

  const _CartData({
    required this.isInCart,
    this.cartItemId,
    required this.quantity,
  });

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is _CartData &&
          isInCart == other.isInCart &&
          cartItemId == other.cartItemId &&
          quantity == other.quantity;

  @override
  int get hashCode => Object.hash(isInCart, cartItemId, quantity);
}

class _QuantityControls extends StatefulWidget {
  final int quantity;
  final String cartItemId;
  final int maxStock;

  const _QuantityControls({
    required this.quantity,
    required this.cartItemId,
    required this.maxStock,
  });

  @override
  State<_QuantityControls> createState() => _QuantityControlsState();
}

class _QuantityControlsState extends State<_QuantityControls> {
  Timer? _debounceTimer;
  late int _localQuantity;

  @override
  void initState() {
    super.initState();
    _localQuantity = widget.quantity;
  }

  @override
  void didUpdateWidget(_QuantityControls oldWidget) {
    super.didUpdateWidget(oldWidget);
    // Update local quantity when cart state changes from server
    if (widget.quantity != oldWidget.quantity && _debounceTimer == null) {
      _localQuantity = widget.quantity;
    }
  }

  @override
  void dispose() {
    _debounceTimer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        _QuantityButton(
          icon: Icons.remove,
          onTap: () => _decrease(context),
        ),
        Text(
          '$_localQuantity',
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
            color: theme.colorScheme.onSurface,
          ),
        ),
        _QuantityButton(
          icon: Icons.add,
          onTap: _localQuantity < widget.maxStock
              ? () => _increase(context)
              : null,
        ),
      ],
    );
  }

  void _decrease(BuildContext context) {
    setState(() {
      _localQuantity--;
    });

    _debounceTimer?.cancel();

    if (_localQuantity < 1) {
      // Remove immediately if quantity is 0
      final cubit = context.read<CartCubit>();
      cubit.removeFromCart(widget.cartItemId);
      Tost.showCustomToast(context, 'removed_from_cart'.tr(),
          backgroundColor: Colors.orange);
      return;
    }

    // Debounce the update
    _debounceTimer = Timer(const Duration(milliseconds: 500), () {
      if (mounted) {
        context
            .read<CartCubit>()
            .updateQuantity(widget.cartItemId, _localQuantity);
      }
    });
  }

  void _increase(BuildContext context) {
    if (_localQuantity >= widget.maxStock) return;

    setState(() {
      _localQuantity++;
    });

    _debounceTimer?.cancel();
    _debounceTimer = Timer(const Duration(milliseconds: 500), () {
      if (mounted) {
        context
            .read<CartCubit>()
            .updateQuantity(widget.cartItemId, _localQuantity);
      }
    });
  }
}

class _QuantityButton extends StatelessWidget {
  final IconData icon;
  final VoidCallback? onTap;

  const _QuantityButton({required this.icon, this.onTap});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 36,
        height: 36,
        decoration: BoxDecoration(
          color: onTap != null ? theme.colorScheme.primary : Colors.grey,
          borderRadius: BorderRadius.circular(8),
        ),
        child: Icon(icon, color: Colors.white, size: 20),
      ),
    );
  }
}

class _AddToCartButton extends StatelessWidget {
  final ProductEntity product;

  const _AddToCartButton({required this.product});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return SizedBox(
      width: double.infinity,
      height: 40,
      child: ElevatedButton(
        onPressed: product.isOutOfStock ? null : () => _addToCart(context),
        style: ElevatedButton.styleFrom(
          backgroundColor:
              product.isOutOfStock ? Colors.grey : theme.colorScheme.primary,
          padding: EdgeInsets.zero,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(6),
          ),
          elevation: 0,
        ),
        child: Text(
          product.isOutOfStock ? 'out_of_stock'.tr() : 'add_to_cart'.tr(),
          style: const TextStyle(
            color: Colors.white,
            fontSize: 13,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
    );
  }

  void _addToCart(BuildContext context) {
    final authState = context.read<AuthCubit>().state;
    if (authState is! AuthAuthenticated) {
      Tost.showCustomToast(context, 'login_required'.tr(),
          backgroundColor: Colors.orange);
      return;
    }

    final cubit = context.read<CartCubit>();
    cubit.setUserId(authState.user.id);
    cubit.addToCart(product.id, quantity: 1, product: product);
    Tost.showCustomToast(context, 'added_to_cart'.tr(),
        backgroundColor: Colors.green);
  }
}
