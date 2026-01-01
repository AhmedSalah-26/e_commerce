import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import '../../../../../core/shared_widgets/custom_button.dart';
import '../../../domain/entities/product_entity.dart';
import '../../utils/product_actions.dart';
import '../../../../cart/presentation/cubit/cart_cubit.dart';
import '../../../../cart/presentation/cubit/cart_state.dart';

class ProductScreenBottomBar extends StatelessWidget {
  final ProductEntity product;
  final int quantity;
  final bool isRtl;

  static const _actions = ProductActions();

  const ProductScreenBottomBar({
    super.key,
    required this.product,
    required this.quantity,
    required this.isRtl,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: theme.scaffoldBackgroundColor,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.1),
            blurRadius: 10,
            offset: const Offset(0, -2),
          ),
        ],
      ),
      child: SafeArea(
        child: Row(
          children: [
            // Price
            Expanded(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  if (product.hasDiscount) ...[
                    Text(
                      '${product.originalPrice.toStringAsFixed(0)} ${isRtl ? 'ج.م' : 'EGP'}',
                      style: theme.textTheme.bodySmall?.copyWith(
                        decoration: TextDecoration.lineThrough,
                        color:
                            theme.colorScheme.onSurface.withValues(alpha: 0.6),
                      ),
                    ),
                    const SizedBox(height: 2),
                  ],
                  Text(
                    '${product.price.toStringAsFixed(0)} ${isRtl ? 'ج.م' : 'EGP'}',
                    style: theme.textTheme.titleLarge?.copyWith(
                      fontWeight: FontWeight.bold,
                      color: theme.colorScheme.primary,
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(width: 16),

            // Add to Cart Button
            Expanded(
              flex: 2,
              child: BlocBuilder<CartCubit, CartState>(
                builder: (context, state) {
                  final isInCart = state is CartLoaded &&
                      state.items.any((item) => item.productId == product.id);

                  return CustomButton(
                    text: isInCart
                        ? (isRtl ? 'في السلة' : 'In Cart')
                        : (isRtl ? 'أضف للسلة' : 'Add to Cart'),
                    onPressed: product.stock > 0
                        ? () => _handleAddToCart(context, isInCart)
                        : null,
                    icon: isInCart ? Icons.check : Icons.shopping_cart,
                    backgroundColor: isInCart
                        ? theme.colorScheme.secondary
                        : theme.colorScheme.primary,
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _handleAddToCart(BuildContext context, bool isInCart) {
    if (isInCart) {
      context.go('/cart');
    } else {
      _actions.addToCart(
        context,
        product,
        quantity,
        onSuccess: () {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(
                isRtl ? 'تم إضافة المنتج للسلة' : 'Product added to cart',
              ),
              backgroundColor: Theme.of(context).colorScheme.primary,
            ),
          );
        },
      );
    }
  }
}
