import 'dart:ui' as ui;
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/shared_widgets/skeleton_widgets.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_text_style.dart';
import '../../../auth/presentation/cubit/auth_cubit.dart';
import '../../../auth/presentation/cubit/auth_state.dart';
import '../cubit/orders_cubit.dart';
import '../cubit/orders_state.dart';
import '../../domain/entities/parent_order_entity.dart';
import '../widgets/parent_order_item_card.dart';

class OrdersPage extends StatefulWidget {
  const OrdersPage({super.key});

  @override
  State<OrdersPage> createState() => _OrdersPageState();
}

class _OrdersPageState extends State<OrdersPage> {
  // Cache the last loaded parent orders to avoid white screen
  List<ParentOrderEntity>? _cachedParentOrders;

  @override
  void initState() {
    super.initState();
    _loadOrdersIfNeeded();
  }

  void _loadOrdersIfNeeded() {
    final currentState = context.read<OrdersCubit>().state;
    // Only reload if not already showing parent orders list
    if (currentState is! ParentOrdersLoaded) {
      _watchOrders();
    }
  }

  void _watchOrders() {
    final authState = context.read<AuthCubit>().state;
    if (authState is AuthAuthenticated) {
      // Use real-time watching for parent orders (multi-vendor)
      context.read<OrdersCubit>().watchUserParentOrders(authState.user.id);
    }
  }

  void _loadOrders() {
    final authState = context.read<AuthCubit>().state;
    if (authState is AuthAuthenticated) {
      context.read<OrdersCubit>().loadUserParentOrders(authState.user.id);
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
          leading: IconButton(
            icon: const Icon(Icons.arrow_back, color: AppColours.brownMedium),
            onPressed: () => context.go('/home'),
          ),
          title: Text(
            'my_orders'.tr(),
            style: AppTextStyle.semiBold_20_dark_brown.copyWith(
              color: AppColours.brownMedium,
            ),
          ),
          centerTitle: true,
        ),
        body: BlocBuilder<OrdersCubit, OrdersState>(
          buildWhen: (previous, current) {
            // Don't rebuild for ParentOrderLoaded (single order details)
            // We want to keep showing the list
            if (current is ParentOrderLoaded) {
              return false;
            }
            return true;
          },
          builder: (context, state) {
            // If we have cached orders and state is ParentOrderLoaded, use cache
            if (state is ParentOrderLoaded && _cachedParentOrders != null) {
              return _buildOrdersList(_cachedParentOrders!);
            }

            if (state is OrdersLoading) {
              // If we have cached data, show it instead of skeleton
              if (_cachedParentOrders != null &&
                  _cachedParentOrders!.isNotEmpty) {
                return _buildOrdersList(_cachedParentOrders!);
              }
              return const SingleChildScrollView(
                child: OrdersListSkeleton(itemCount: 4),
              );
            }

            if (state is OrdersError) {
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
                      onPressed: _loadOrders,
                      child: Text('retry'.tr()),
                    ),
                  ],
                ),
              );
            }

            if (state is OrdersLoaded) {
              if (state.orders.isEmpty) {
                return _buildEmptyOrders();
              }

              // Convert to parent orders for display
              final parentOrders = state.orders
                  .map((order) => ParentOrderEntity(
                        id: order.id,
                        userId: order.userId,
                        total: order.total,
                        subtotal: order.subtotal,
                        shippingCost: order.shippingCost,
                        deliveryAddress: order.deliveryAddress,
                        customerName: order.customerName,
                        customerPhone: order.customerPhone,
                        notes: order.notes,
                        createdAt: order.createdAt,
                        subOrders: [order],
                      ))
                  .toList();

              _cachedParentOrders = parentOrders;
              return _buildOrdersList(parentOrders);
            }

            if (state is ParentOrdersLoaded) {
              _cachedParentOrders = state.parentOrders;

              if (state.parentOrders.isEmpty) {
                return _buildEmptyOrders();
              }

              return _buildOrdersList(state.parentOrders);
            }

            // For any other state, reload orders
            WidgetsBinding.instance.addPostFrameCallback((_) {
              _watchOrders();
            });

            // Show cached data if available
            if (_cachedParentOrders != null &&
                _cachedParentOrders!.isNotEmpty) {
              return _buildOrdersList(_cachedParentOrders!);
            }

            return const SingleChildScrollView(
              child: OrdersListSkeleton(itemCount: 4),
            );
          },
        ),
      ),
    );
  }

  Widget _buildEmptyOrders() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Icon(
            Icons.receipt_long_outlined,
            size: 80,
            color: Colors.grey,
          ),
          const SizedBox(height: 16),
          Text(
            'no_orders'.tr(),
            style: const TextStyle(fontSize: 18, color: Colors.grey),
          ),
          const SizedBox(height: 16),
          ElevatedButton(
            onPressed: () => context.go('/home'),
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColours.brownLight,
            ),
            child: Text(
              'start_shopping'.tr(),
              style: const TextStyle(color: Colors.white),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildOrdersList(List<ParentOrderEntity> parentOrders) {
    return RefreshIndicator(
      onRefresh: () async => _loadOrders(),
      child: ListView.builder(
        padding: const EdgeInsets.all(16),
        itemCount: parentOrders.length,
        addAutomaticKeepAlives: false,
        cacheExtent: 500,
        itemBuilder: (context, index) {
          final parentOrder = parentOrders[index];
          return ParentOrderItemCard(parentOrder: parentOrder);
        },
      ),
    );
  }
}
