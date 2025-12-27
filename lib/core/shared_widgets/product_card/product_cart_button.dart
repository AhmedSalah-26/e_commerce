import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../features/auth/presentation/cubit/auth_cubit.dart';
import '../../../features/auth/presentation/cubit/auth_state.dart';
import '../../../features/cart/presentation/cubit/cart_cubit.dart';
import '../../../features/cart/presentation/cubit/cart_state.dart';
import '../../../features/products/domain/entities/product_entity.dart';
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
  late CartCubit _cartCubit;

  // Always return at least 1 for display
  int get displayQuantity => _localQuantity < 1 ? 1 : _localQuantity;

  @override
  void initState() {
    super.initState();
    _localQuantity = widget.quantity < 1 ? 1 : widget.quantity;
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    _cartCubit = context.read<CartCubit>();
  }

  @override
  void didUpdateWidget(_QuantityControls oldWidget) {
    super.didUpdateWidget(oldWidget);
    // Only update local quantity if not currently updating
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
        _QuantityButton(
          icon: Icons.remove,
          onTap: _decrease,
          isLoading: false,
        ),
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
          isLoading: false,
        ),
      ],
    );
  }

  void _decrease() {
    // Prevent multiple rapid clicks
    if (_isRemoving || _isUpdating) return;

    // Prevent going below 1
    if (_localQuantity <= 1) {
      // Remove from cart
      setState(() => _isRemoving = true);
      _removeWithRetry();
      return;
    }

    final newQuantity = _localQuantity - 1;

    // Optimistic update - ensure never goes below 1
    setState(() {
      _localQuantity = newQuantity < 1 ? 1 : newQuantity;
      _isUpdating = true;
    });

    _updateWithRetry(_localQuantity);
  }

  void _increase() {
    if (_isRemoving || _localQuantity >= widget.maxStock) return;

    final newQuantity = _localQuantity + 1;

    // Optimistic update
    setState(() {
      _localQuantity = newQuantity;
      _isUpdating = true;
    });

    _updateWithRetry(_localQuantity);
  }

  Future<bool> _updateWithRetry(int quantity) async {
    debugPrint(
        '🔄 _updateWithRetry: quantity=$quantity, cartItemId=${widget.cartItemId}');
    final success =
        await _cartCubit.updateQuantityDirect(widget.cartItemId, quantity);
    debugPrint('🔄 _updateWithRetry: success=$success');

    if (mounted) {
      setState(() => _isUpdating = false);
    }

    if (!success && mounted) {
      NetworkErrorWidget.showFullScreen(
        context,
        onRetry: () => _updateWithRetry(quantity),
      );
    }
    return success;
  }

  Future<bool> _removeWithRetry() async {
    debugPrint('🔄 _removeWithRetry: cartItemId=${widget.cartItemId}');
    final success = await _cartCubit.removeFromCartDirect(widget.cartItemId);
    debugPrint('🔄 _removeWithRetry: success=$success');

    if (mounted) {
      setState(() => _isRemoving = false);
    }

    if (!success && mounted) {
      NetworkErrorWidget.showFullScreen(
        context,
        onRetry: _removeWithRetry,
      );
    }
    return success;
  }
}

class _QuantityButton extends StatelessWidget {
  final IconData icon;
  final VoidCallback? onTap;
  final bool isLoading;

  const _QuantityButton({
    required this.icon,
    this.onTap,
    this.isLoading = false,
  });

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
  late CartCubit _cartCubit;
  late AuthCubit _authCubit;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    _cartCubit = context.read<CartCubit>();
    _authCubit = context.read<AuthCubit>();
  }

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
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(6),
          ),
          elevation: 0,
          disabledBackgroundColor:
              theme.colorScheme.primary.withValues(alpha: 0.7),
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

  void _handleAddToCart() async {
    final authState = _authCubit.state;
    if (authState is! AuthAuthenticated) {
      Tost.showCustomToast(context, 'login_required'.tr(),
          backgroundColor: Colors.orange);
      return;
    }

    setState(() => _isLoading = true);

    _cartCubit.setUserId(authState.user.id);
    final success = await _addToCart();

    if (mounted) {
      setState(() => _isLoading = false);
      if (success) {
        Tost.showCustomToast(context, 'added_to_cart'.tr(),
            backgroundColor: Colors.green);
      } else {
        NetworkErrorWidget.showFullScreen(context, onRetry: _addToCart);
      }
    }
  }

  Future<bool> _addToCart() async {
    debugPrint('🔄 _addToCart: productId=${widget.product.id}');
    final success = await _cartCubit.addToCart(
      widget.product.id,
      quantity: 1,
      product: widget.product,
    );
    debugPrint('🔄 _addToCart: success=$success');
    return success;
  }
}
