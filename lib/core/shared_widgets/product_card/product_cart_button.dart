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
  bool _isLoading = false;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        _QuantityButton(
          icon: Icons.remove,
          onTap: _isLoading ? null : () => _decrease(context),
        ),
        _isLoading
            ? SizedBox(
                width: 18,
                height: 18,
                child: CircularProgressIndicator(
                  strokeWidth: 2,
                  color: theme.colorScheme.primary,
                ),
              )
            : Text(
                '${widget.quantity}',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: theme.colorScheme.onSurface,
                ),
              ),
        _QuantityButton(
          icon: Icons.add,
          onTap: _isLoading || widget.quantity >= widget.maxStock
              ? null
              : () => _increase(context),
        ),
      ],
    );
  }

  Future<void> _decrease(BuildContext context) async {
    if (_isLoading) return;

    setState(() {
      _isLoading = true;
    });

    await context
        .read<CartCubit>()
        .updateQuantity(widget.cartItemId, widget.quantity - 1);

    if (mounted) {
      setState(() {
        _isLoading = false;
      });
    }
  }

  Future<void> _increase(BuildContext context) async {
    if (_isLoading || widget.quantity >= widget.maxStock) return;

    setState(() {
      _isLoading = true;
    });

    await context
        .read<CartCubit>()
        .updateQuantity(widget.cartItemId, widget.quantity + 1);

    if (mounted) {
      setState(() {
        _isLoading = false;
      });
    }
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

class _AddToCartButton extends StatefulWidget {
  final ProductEntity product;

  const _AddToCartButton({required this.product});

  @override
  State<_AddToCartButton> createState() => _AddToCartButtonState();
}

class _AddToCartButtonState extends State<_AddToCartButton> {
  bool _isLoading = false;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return SizedBox(
      width: double.infinity,
      height: 40,
      child: ElevatedButton(
        onPressed: widget.product.isOutOfStock || _isLoading
            ? null
            : () => _addToCart(context),
        style: ElevatedButton.styleFrom(
          backgroundColor: widget.product.isOutOfStock
              ? Colors.grey
              : theme.colorScheme.primary,
          padding: EdgeInsets.zero,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(6),
          ),
          elevation: 0,
          disabledBackgroundColor: theme.colorScheme.primary.withOpacity(0.6),
        ),
        child: _isLoading
            ? const SizedBox(
                width: 20,
                height: 20,
                child: CircularProgressIndicator(
                  strokeWidth: 2,
                  color: Colors.white,
                ),
              )
            : Text(
                widget.product.isOutOfStock
                    ? 'out_of_stock'.tr()
                    : 'add_to_cart'.tr(),
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 13,
                  fontWeight: FontWeight.bold,
                ),
              ),
      ),
    );
  }

  Future<void> _addToCart(BuildContext context) async {
    if (_isLoading) return;

    final authState = context.read<AuthCubit>().state;
    if (authState is! AuthAuthenticated) {
      Tost.showCustomToast(context, 'login_required'.tr(),
          backgroundColor: Colors.orange);
      return;
    }

    setState(() {
      _isLoading = true;
    });

    final cubit = context.read<CartCubit>();
    cubit.setUserId(authState.user.id);
    await cubit.addToCart(widget.product.id,
        quantity: 1, product: widget.product);

    if (mounted) {
      setState(() {
        _isLoading = false;
      });
      Tost.showCustomToast(context, 'added_to_cart'.tr(),
          backgroundColor: Colors.green);
    }
  }
}
