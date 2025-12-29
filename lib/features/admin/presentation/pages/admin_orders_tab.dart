import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../cubit/admin_cubit.dart';
import '../cubit/admin_state.dart';
import '../widgets/order_card.dart';

class AdminOrdersTab extends StatefulWidget {
  final bool isRtl;
  const AdminOrdersTab({super.key, required this.isRtl});

  @override
  State<AdminOrdersTab> createState() => _AdminOrdersTabState();
}

class _AdminOrdersTabState extends State<AdminOrdersTab>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;
  final _searchController = TextEditingController();
  final _statuses = [
    '',
    'pending',
    'processing',
    'shipped',
    'delivered',
    'cancelled',
    'closed'
  ];

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 7, vsync: this);
    _tabController.addListener(() {
      if (!_tabController.indexIsChanging) _loadOrders();
    });
    _loadOrders();
  }

  @override
  void dispose() {
    _tabController.dispose();
    _searchController.dispose();
    super.dispose();
  }

  void _loadOrders() {
    final status = _statuses[_tabController.index];
    context.read<AdminCubit>().loadOrders(
          status: status.isEmpty ? null : status,
          search:
              _searchController.text.isEmpty ? null : _searchController.text,
        );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isMobile = MediaQuery.of(context).size.width < 600;

    return Column(
      children: [
        _buildSearchBar(isMobile),
        TabBar(
          controller: _tabController,
          isScrollable: true,
          labelColor: theme.colorScheme.primary,
          labelStyle: TextStyle(fontSize: isMobile ? 11 : 13),
          tabs: [
            Tab(text: widget.isRtl ? 'الكل' : 'All'),
            Tab(text: widget.isRtl ? 'جديد' : 'Pending'),
            Tab(text: widget.isRtl ? 'تجهيز' : 'Processing'),
            Tab(text: widget.isRtl ? 'شحن' : 'Shipped'),
            Tab(text: widget.isRtl ? 'تم' : 'Delivered'),
            Tab(text: widget.isRtl ? 'ملغي' : 'Cancelled'),
            Tab(text: widget.isRtl ? 'مغلق' : 'Closed'),
          ],
        ),
        Expanded(
          child: TabBarView(
            controller: _tabController,
            children: List.generate(7, (_) => _buildOrdersList(isMobile)),
          ),
        ),
      ],
    );
  }

  Widget _buildSearchBar(bool isMobile) {
    return Padding(
      padding: EdgeInsets.all(isMobile ? 12 : 16),
      child: TextField(
        controller: _searchController,
        decoration: InputDecoration(
          hintText: widget.isRtl ? 'بحث...' : 'Search...',
          prefixIcon: const Icon(Icons.search),
          border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
          isDense: isMobile,
        ),
        onSubmitted: (_) => _loadOrders(),
      ),
    );
  }

  Widget _buildOrdersList(bool isMobile) {
    return BlocBuilder<AdminCubit, AdminState>(
      builder: (context, state) {
        if (state is AdminOrdersLoading) {
          return const Center(child: CircularProgressIndicator());
        }
        if (state is AdminError) {
          return Center(child: Text(state.message));
        }
        if (state is AdminOrdersLoaded) {
          if (state.orders.isEmpty) {
            return Center(
                child: Text(widget.isRtl ? 'لا توجد طلبات' : 'No orders'));
          }
          return RefreshIndicator(
            onRefresh: () async => _loadOrders(),
            child: ListView.builder(
              padding: EdgeInsets.all(isMobile ? 12 : 16),
              itemCount: state.orders.length,
              itemBuilder: (_, i) => OrderCard(
                order: state.orders[i],
                isRtl: widget.isRtl,
                isMobile: isMobile,
                onRefresh: _loadOrders,
              ),
            ),
          );
        }
        return const SizedBox.shrink();
      },
    );
  }
}
