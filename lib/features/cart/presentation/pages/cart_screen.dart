import 'dart:ui' as ui;
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/shared_widgets/custom_button.dart';
import '../../../../core/shared_widgets/skeleton_widgets.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_text_style.dart';
import '../../../auth/presentation/cubit/auth_cubit.dart';
import '../../../auth/presentation/cubit/auth_state.dart';
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

  @override
  Widget build(BuildContext context) {
    final isRtl = context.locale.languageCode == 'ar';

    return Directionality(
      textDirection: isRtl ? ui.TextDirection.rtl : ui.TextDirection.ltr,
      child: Scaffold(
        backgroundColor: Colors.white,
        appBar: AppBar(
          backgroundColor: Colors.white,
          elevation: 0,
          title: Text(
            'shopping_cart'.tr(),
            style: AppTextStyle.semiBold_20_dark_brown.copyWith(
              color: AppColours.brownMedium,
            ),
          ),
          centerTitle: true,
        ),
        body: Padding(
          padding: const EdgeInsets.all(16.0),
          child: BlocBuilder<CartCubit, CartState>(
            builder: (context, state) {
              if (state is CartLoading) {
                return const CartListSkeleton(itemCount: 3);
              }

              if (state is CartError) {
                return Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(
                        state.message,
                        style: const TextStyle(color: Colors.red),
                        textAlign: TextAlign.center,
                      ),
                      const SizedBox(height: 16),
                      ElevatedButton(
                        onPressed: _loadCart,
                        child: Text('retry'.tr()),
                      ),
                    ],
                  ),
                );
              }

              if (state is CartLoaded) {
                if (state.isEmpty) {
                  return const EmptyCartMessage();
                }

                return Column(
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
                            onRemove: () {
                              context
                                  .read<CartCubit>()
                                  .removeFromCart(cartItem.id);
                            },
                            onIncreaseQuantity: () {
                              context.read<CartCubit>().updateQuantity(
                                    cartItem.id,
                                    cartItem.quantity + 1,
                                  );
                            },
                            onDecreaseQuantity: () {
                              if (cartItem.quantity > 1) {
                                context.read<CartCubit>().updateQuantity(
                                      cartItem.id,
                                      cartItem.quantity - 1,
                                    );
                              } else {
                                context
                                    .read<CartCubit>()
                                    .removeFromCart(cartItem.id);
                              }
                            },
                          );
                        },
                      ),
                    ),
                    // Cart Summary
                    Container(
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: Colors.grey.shade100,
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Column(
                        children: [
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Text(
                                '${'total'.tr()}:',
                                style: const TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              Text(
                                '${state.total.toStringAsFixed(2)} ${'egp'.tr()}',
                                style: const TextStyle(
                                  fontSize: 18,
                                  fontWeight: FontWeight.bold,
                                  color: AppColours.brownMedium,
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 16),
                          SizedBox(
                            width: double.infinity,
                            child: CustomButton(
                              onPressed: () {
                                context.push('/checkout');
                              },
                              label: 'checkout'.tr(),
                              color: AppColours.brownLight,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                );
              }

              // Not authenticated
              return Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Icon(
                      Icons.shopping_cart_outlined,
                      size: 80,
                      color: Colors.grey,
                    ),
                    const SizedBox(height: 16),
                    Text(
                      'login_required'.tr(),
                      style: const TextStyle(fontSize: 18, color: Colors.grey),
                    ),
                    const SizedBox(height: 16),
                    ElevatedButton(
                      onPressed: () {
                        context.go('/login');
                      },
                      child: Text('login'.tr()),
                    ),
                  ],
                ),
              );
            },
          ),
        ),
      ),
    );
  }
}
