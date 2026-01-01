import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../../../core/shared_widgets/network_error_widget.dart';
import '../../../../../core/utils/error_helper.dart';
import '../../../../orders/presentation/cubit/orders_cubit.dart';
import '../../../../orders/presentation/cubit/orders_state.dart';
import '../../widgets/merchant_empty_state.dart';
import '../../widgets/order_card.dart';
import '../../widgets/order_details/order_details_sheet.dart';
import '../../widgets/orders_filter_section.dart';
import 'shimmer_effect.dart';

class MerchantOrdersList extends StatefulWidget {
  final String status;
  final ScrollController scrollController;
  final bool isRtl;
  final ThemeData theme;

  const MerchantOrdersList({
    super.key,
    required this.status,
    required this.scrollController,
    required this.isRtl,
    required this.theme,
  });

  @override
  State<MerchantOrdersList> createState() => _MerchantOrdersListState();
}

class _MerchantOrdersListState extends State<MerchantOrdersList> {
  final TextEditingController _searchController = TextEditingController();
  String _searchQuery = '';
  String _deliveredPeriod = 'week';
  String _cancelledPeriod = 'week';

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  void _loadOrdersForStatus() {
    // This would be called from parent widget
  }

  void _setFilterPeriod(String period) {
    setState(() {
      if (widget.status == 'delivered') {
        _deliveredPeriod = period;
      } else {
        _cancelledPeriod = period;
      }
    });
    _loadOrdersForStatus();
  }

  @override
  Widget build(BuildContext context) {
    final showFilters =
        widget.status == 'delivered' || widget.status == 'cancelled';
    final selectedPeriod =
        widget.status == 'delivered' ? _deliveredPeriod : _cancelledPeriod;

    return Column(
      children: [
        if (showFilters)
          OrdersFilterSection(
            isRtl: widget.isRtl,
            searchController: _searchController,
            searchQuery: _searchQuery,
            selectedPeriod: selectedPeriod,
            onSearchChanged: (value) => setState(() => _searchQuery = value),
            onClearSearch: () {
              _searchController.clear();
              setState(() => _searchQuery = '');
            },
            onPeriodChanged: _setFilterPeriod,
          ),
        Expanded(child: _buildOrdersList(showFilters)),
      ],
    );
  }

  Widget _buildOrdersList(bool showFilters) {
    return BlocConsumer<OrdersCubit, OrdersState>(
      listenWhen: (previous, current) {
        if (current is OrdersLoaded) {
          return current.currentStatus == widget.status;
        }
        return true;
      },
      buildWhen: (previous, current) {
        if (current is OrdersLoading) return true;
        if (current is OrdersError) return true;
        if (current is OrderStatusUpdating) {
          return current.currentStatus == widget.status;
        }
        if (current is OrdersLoaded) {
          return current.currentStatus == widget.status;
        }
        return false;
      },
      listener: (context, state) {
        // Handle state changes if needed
      },
      builder: (context, state) {
        if (state is OrdersLoading) {
          return const Center(child: CircularProgressIndicator());
        }

        if (state is OrderStatusUpdating &&
            state.currentStatus == widget.status) {
          return _buildShimmerList();
        }

        if (state is OrdersError) {
          return _buildErrorState(state.message);
        }

        if (state is OrdersLoaded && state.currentStatus == widget.status) {
          var filteredOrders = state.orders;
          if (_searchQuery.isNotEmpty && showFilters) {
            filteredOrders = filteredOrders
                .where((order) =>
                    order.id.toLowerCase().contains(_searchQuery.toLowerCase()))
                .toList();
          }

          if (filteredOrders.isEmpty) {
            return MerchantEmptyState(
              icon: Icons.inbox_outlined,
              title: widget.isRtl ? 'لا توجد طلبات' : 'No orders',
              subtitle: widget.isRtl
                  ? 'لا توجد طلبات بهذه الحالة'
                  : 'No orders with this status',
            );
          }

          return RefreshIndicator(
            onRefresh: () async => _loadOrdersForStatus(),
            child: ListView.builder(
              controller: widget.scrollController,
              padding: const EdgeInsets.all(16),
              itemCount: filteredOrders.length,
              itemBuilder: (context, index) {
                final order = filteredOrders[index];
                return OrderCard(
                  order: order,
                  onTap: () =>
                      OrderDetailsSheet.show(context, order, widget.isRtl),
                );
              },
            ),
          );
        }

        return const Center(child: CircularProgressIndicator());
      },
    );
  }

  Widget _buildShimmerList() {
    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: 5,
      itemBuilder: (context, index) {
        return Container(
          margin: const EdgeInsets.only(bottom: 12),
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: widget.theme.colorScheme.surface,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: widget.theme.colorScheme.outline),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  _buildShimmerBox(width: 100, height: 16),
                  _buildShimmerBox(width: 80, height: 24),
                ],
              ),
              const SizedBox(height: 12),
              _buildShimmerBox(width: 150, height: 14),
              const SizedBox(height: 8),
              _buildShimmerBox(width: 200, height: 14),
              const SizedBox(height: 12),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  _buildShimmerBox(width: 80, height: 14),
                  _buildShimmerBox(width: 60, height: 14),
                ],
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildShimmerBox({required double width, required double height}) {
    return Container(
      width: width,
      height: height,
      decoration: BoxDecoration(
        color: widget.theme.colorScheme.onSurface.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(4),
      ),
      child: const ShimmerEffect(),
    );
  }

  Widget _buildErrorState(String message) {
    return NetworkErrorWidget(
      message: ErrorHelper.getUserFriendlyMessage(message),
      onRetry: _loadOrdersForStatus,
    );
  }
}
