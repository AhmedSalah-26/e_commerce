import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../features/auth/presentation/cubit/auth_cubit.dart';
import '../../../features/auth/presentation/cubit/auth_state.dart';
import '../../../features/cart/presentation/cubit/cart_cubit.dart';
import '../../../features/cart/presentation/cubit/cart_state.dart';
import '../../../features/products/domain/entities/product_entity.dart';
import '../../../features/products/presentation/cubit/products_cubit.dart';
import '../network_error_widget.dart';
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
  late int _localQuantity;
  bool _isUpdating = false;
  bool _isRemoving = false;

  int get displayQuantity => _localQuantity < 1 ? 1 : _localQuantity;

  @override
  void initState() {
    super.initState();
    _localQuantity = widget.quantity < 1 ? 1 : widget.quantity;
  }

  @override
  void didUpdateWidget(_QuantityControls oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (!_isUpdating && !_isRemoving && widget.quantity != _localQuantity) {
      _localQuantity = widget.quantity < 1 ? 1 : widget.quantity;
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        _QuantityButton(icon: Icons.remove, onTap: _decrease),
        SizedBox(
          width: 30,
          child: Center(
            child: Text(
              '$displayQuantity',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: theme.colorScheme.onSurface,
              ),
            ),
          ),
        ),
        _QuantityButton(
          icon: Icons.add,
          onTap: _localQuantity >= widget.maxStock ? null : _increase,
        ),
      ],
    );
  }

  void _decrease() async {
    if (_isRemoving || _isUpdating) return;

    final cartCubit = context.read<CartCubit>();
    final productsCubit = context.read<ProductsCubit>();

    if (_localQuantity <= 1) {
      setState(() => _isRemoving = true);
      final success = await cartCubit.removeFromCartDirect(widget.cartItemId);
      if (mounted) setState(() => _isRemoving = false);

      if (!success && mounted) {
        NetworkErrorWidget.showForAddToCart(
          context,
          productsCubit: productsCubit,
        );
      }
      return;
    }

    final newQuantity = _localQuantity - 1;
    setState(() {
      _localQuantity = newQuantity;
      _isUpdating = true;
    });

    final success =
        await cartCubit.updateQuantityDirect(widget.cartItemId, newQuantity);
    if (mounted) setState(() => _isUpdating = false);

    if (!success && mounted) {
      NetworkErrorWidget.showForAddToCart(
        context,
        productsCubit: productsCubit,
      );
    }
  }

  void _increase() async {
    if (_isRemoving || _localQuantity >= widget.maxStock) return;

    final cartCubit = context.read<CartCubit>();
    final productsCubit = context.read<ProductsCubit>();
    final newQuantity = _localQuantity + 1;

    setState(() {
      _localQuantity = newQuantity;
      _isUpdating = true;
    });

    final success =
        await cartCubit.updateQuantityDirect(widget.cartItemId, newQuantity);
    if (mounted) setState(() => _isUpdating = false);

    if (!success && mounted) {
      NetworkErrorWidget.showForAddToCart(
        context,
        productsCubit: productsCubit,
      );
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
    final isDisabled = onTap == null;

    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 36,
        height: 36,
        decoration: BoxDecoration(
          color: isDisabled ? Colors.grey.shade400 : theme.colorScheme.primary,
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
        onPressed:
            widget.product.isOutOfStock || _isLoading ? null : _handleAddToCart,
        style: ElevatedButton.styleFrom(
          backgroundColor: widget.product.isOutOfStock
              ? Colors.grey
              : theme.colorScheme.primary,
          padding: EdgeInsets.zero,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(6)),
          elevation: 0,
          disabledBackgroundColor:
              theme.colorScheme.primary.withValues(alpha: 0.7),
        ),
        child: _isLoading
            ? const SizedBox(
                width: 20,
                height: 20,
                child: CircularProgressIndicator(
                    strokeWidth: 2, color: Colors.white),
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

  void _handleAddToCart() async {
    final authState = context.read<AuthCubit>().state;
    if (authState is! AuthAuthenticated) {
      Tost.showCustomToast(context, 'login_required'.tr(),
          backgroundColor: Colors.orange);
      return;
    }

    final cartCubit = context.read<CartCubit>();
    cartCubit.setUserId(authState.user.id);

    setState(() => _isLoading = true);

    final success = await cartCubit.addToCart(widget.product.id,
        quantity: 1, product: widget.product);

    if (mounted) {
      setState(() => _isLoading = false);
      if (success) {
        Tost.showCustomToast(context, 'added_to_cart'.tr(),
            backgroundColor: Colors.green);
      } else {
        // Show error dialog that reloads home page
        NetworkErrorWidget.showForAddToCart(
          context,
          productsCubit: context.read<ProductsCubit>(),
        );
      }
    }
  }
}
