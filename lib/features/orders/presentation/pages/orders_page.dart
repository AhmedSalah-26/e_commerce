import 'dart:async';
import 'dart:ui' as ui;
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:supabase_flutter/supabase_flutter.dart' hide AuthState;

import '../../../../core/shared_widgets/skeleton_widgets.dart';
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
  List<ParentOrderEntity>? _cachedParentOrders;
  StreamSubscription? _authSubscription;

  @override
  void initState() {
    super.initState();
    _loadOrdersIfNeeded();
    _setupAuthListener();
  }

  @override
  void dispose() {
    _authSubscription?.cancel();
    super.dispose();
  }

  void _setupAuthListener() {
    _authSubscription =
        Supabase.instance.client.auth.onAuthStateChange.listen((data) async {
      final event = data.event;
      if (event == AuthChangeEvent.tokenRefreshed) {
        _safeLoadOrders();
      }
      if (event == AuthChangeEvent.signedOut) {
        if (mounted) {
          context.go('/login');
        }
      }
    });
  }

  Future<void> _safeLoadOrders() async {
    try {
      _loadOrders();
    } catch (e) {
      if (e.toString().contains('JWT') || e.toString().contains('token')) {
        try {
          await Supabase.instance.client.auth.refreshSession();
          _loadOrders();
        } catch (_) {
          if (mounted) {
            context.go('/login');
          }
        }
      }
    }
  }

  void _loadOrdersIfNeeded() {
    final currentState = context.read<OrdersCubit>().state;
    if (currentState is! ParentOrdersLoaded) {
      _watchOrders();
    }
  }

  void _watchOrders() {
    final authState = context.read<AuthCubit>().state;
    if (authState is AuthAuthenticated) {
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
    final theme = Theme.of(context);

    return Directionality(
      textDirection: isRtl ? ui.TextDirection.rtl : ui.TextDirection.ltr,
      child: Scaffold(
        backgroundColor: theme.scaffoldBackgroundColor,
        appBar: AppBar(
          backgroundColor: theme.scaffoldBackgroundColor,
          leading: IconButton(
            icon: Icon(Icons.arrow_back, color: theme.colorScheme.primary),
            onPressed: () => context.go('/home'),
          ),
          title: Text(
            'my_orders'.tr(),
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.w600,
              color: theme.colorScheme.primary,
            ),
          ),
          centerTitle: true,
        ),
        body: BlocBuilder<OrdersCubit, OrdersState>(
          buildWhen: (previous, current) {
            if (current is ParentOrderLoaded) {
              return false;
            }
            return true;
          },
          builder: (context, state) {
            if (state is ParentOrderLoaded && _cachedParentOrders != null) {
              return _buildOrdersList(_cachedParentOrders!);
            }

            if (state is OrdersLoading) {
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

            WidgetsBinding.instance.addPostFrameCallback((_) {
              _watchOrders();
            });

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
    final theme = Theme.of(context);

    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.receipt_long_outlined,
            size: 80,
            color: theme.colorScheme.onSurface.withValues(alpha: 0.4),
          ),
          const SizedBox(height: 16),
          Text(
            'no_orders'.tr(),
            style: TextStyle(
              fontSize: 18,
              color: theme.colorScheme.onSurface.withValues(alpha: 0.6),
            ),
          ),
          const SizedBox(height: 16),
          ElevatedButton(
            onPressed: () => context.go('/home'),
            style: ElevatedButton.styleFrom(
              backgroundColor: theme.colorScheme.primary,
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
