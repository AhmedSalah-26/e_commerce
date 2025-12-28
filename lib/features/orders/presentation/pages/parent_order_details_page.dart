import 'dart:ui' as ui;
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/shared_widgets/network_error_widget.dart';
import '../../../../core/shared_widgets/skeleton_widgets.dart';
import '../../../../core/utils/error_helper.dart';
import '../../../auth/presentation/cubit/auth_cubit.dart';
import '../../../auth/presentation/cubit/auth_state.dart';
import '../../domain/entities/parent_order_entity.dart';
import '../cubit/orders_cubit.dart';
import '../cubit/orders_state.dart';
import '../widgets/merchant_order_card.dart';
import '../widgets/parent_order/order_summary_card.dart';
import '../widgets/parent_order/customer_info_card.dart';
import '../widgets/parent_order/payment_method_card.dart';
import '../widgets/parent_order/total_summary_card.dart';
import '../widgets/parent_order/notes_card.dart';

class ParentOrderDetailsPage extends StatefulWidget {
  final String parentOrderId;

  const ParentOrderDetailsPage({super.key, required this.parentOrderId});

  @override
  State<ParentOrderDetailsPage> createState() => _ParentOrderDetailsPageState();
}

class _ParentOrderDetailsPageState extends State<ParentOrderDetailsPage> {
  @override
  void initState() {
    super.initState();
    _loadDetails();
  }

  void _loadDetails() {
    context.read<OrdersCubit>().loadParentOrderDetails(widget.parentOrderId);
  }

  void _goBackToOrders() {
    final authState = context.read<AuthCubit>().state;
    if (authState is AuthAuthenticated) {
      context.read<OrdersCubit>().watchUserParentOrders(authState.user.id);
    }
    context.go('/orders');
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isRtl = context.locale.languageCode == 'ar';

    return Directionality(
      textDirection: isRtl ? ui.TextDirection.rtl : ui.TextDirection.ltr,
      child: Scaffold(
        backgroundColor: theme.scaffoldBackgroundColor,
        appBar: AppBar(
          backgroundColor: theme.scaffoldBackgroundColor,
          leading: IconButton(
            icon: Icon(Icons.arrow_back_ios, color: theme.colorScheme.primary),
            onPressed: _goBackToOrders,
          ),
          title: Text(
            'order_details'.tr(),
            style: theme.textTheme.titleLarge?.copyWith(
              fontWeight: FontWeight.w600,
              color: theme.colorScheme.primary,
            ),
          ),
          centerTitle: true,
        ),
        body: BlocBuilder<OrdersCubit, OrdersState>(
          builder: (context, state) {
            if (state is OrdersLoading) {
              return const OrderDetailsSkeleton();
            }

            if (state is OrdersError) {
              return NetworkErrorWidget(
                message: ErrorHelper.getUserFriendlyMessage(state.message),
                onRetry: _loadDetails,
              );
            }

            if (state is ParentOrderLoaded) {
              return _buildContent(state.parentOrder, isRtl, theme);
            }

            WidgetsBinding.instance.addPostFrameCallback((_) => _loadDetails());
            return const OrderDetailsSkeleton();
          },
        ),
      ),
    );
  }

  Widget _buildContent(
      ParentOrderEntity parentOrder, bool isRtl, ThemeData theme) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          OrderSummaryCard(parentOrder: parentOrder),
          const SizedBox(height: 16),
          CustomerInfoCard(parentOrder: parentOrder),
          const SizedBox(height: 16),
          PaymentMethodCard(parentOrder: parentOrder),
          const SizedBox(height: 16),
          Text(
            'merchant_orders'.tr(),
            style: theme.textTheme.titleMedium?.copyWith(
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: 12),
          ...parentOrder.subOrders.map((order) => Padding(
                padding: const EdgeInsets.only(bottom: 12),
                child: MerchantOrderCard(order: order, isRtl: isRtl),
              )),
          const SizedBox(height: 16),
          TotalSummaryCard(parentOrder: parentOrder),
          if (parentOrder.notes != null && parentOrder.notes!.isNotEmpty) ...[
            const SizedBox(height: 16),
            NotesCard(notes: parentOrder.notes!),
          ],
          const SizedBox(height: 32),
        ],
      ),
    );
  }
}
