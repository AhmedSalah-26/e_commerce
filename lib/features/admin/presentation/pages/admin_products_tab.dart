import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../cubit/admin_cubit.dart';
import '../cubit/admin_state.dart';
import '../widgets/product_card.dart';
import '../widgets/admin_error_widget.dart';

class AdminProductsTab extends StatefulWidget {
  final bool isRtl;
  const AdminProductsTab({super.key, required this.isRtl});

  @override
  State<AdminProductsTab> createState() => _AdminProductsTabState();
}

class _AdminProductsTabState extends State<AdminProductsTab>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;
  final _searchController = TextEditingController();
  final List<ScrollController> _scrollControllers = [];
  String? _currentSearch;
  bool _isLoadingMore = false;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 4, vsync: this);

    // إنشاء scroll controller منفصل لكل tab
    for (int i = 0; i < 4; i++) {
      final controller = ScrollController();
      controller.addListener(() => _onScroll(i));
      _scrollControllers.add(controller);
    }

    _tabController.addListener(() {
      if (!_tabController.indexIsChanging) _loadProducts();
    });
    _loadProducts();
  }

  @override
  void dispose() {
    _tabController.dispose();
    _searchController.dispose();
    for (final controller in _scrollControllers) {
      controller.dispose();
    }
    super.dispose();
  }

  void _onScroll(int tabIndex) {
    // تأكد إن الـ tab الحالي هو اللي بيعمل scroll
    if (_tabController.index != tabIndex) return;

    // تاب "موقوف" (index 3) - الفلترة محلية فمش محتاجين load more
    if (tabIndex == 3) return;

    final controller = _scrollControllers[tabIndex];
    if (controller.position.pixels >=
        controller.position.maxScrollExtent - 200) {
      _loadMoreProducts();
    }
  }

  bool? get _currentFilter {
    return switch (_tabController.index) {
      1 => true,
      2 => false,
      _ => null,
    };
  }

  void _loadProducts() {
    _currentSearch =
        _searchController.text.isEmpty ? null : _searchController.text;
    context.read<AdminCubit>().loadProducts(
          isActive: _currentFilter,
          search: _currentSearch,
        );
  }

  void _loadMoreProducts() {
    // منع التحميل المتكرر
    if (_isLoadingMore) return;
    _isLoadingMore = true;

    context
        .read<AdminCubit>()
        .loadProducts(
          isActive: _currentFilter,
          search: _currentSearch,
          loadMore: true,
        )
        .then((_) {
      _isLoadingMore = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isMobile = MediaQuery.of(context).size.width < 600;

    return Column(
      children: [
        Padding(
          padding: EdgeInsets.all(isMobile ? 12 : 16),
          child: Center(
            child: Text(
              widget.isRtl ? 'إدارة المنتجات' : 'Products Management',
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.w600,
                color: theme.colorScheme.primary,
              ),
            ),
          ),
        ),
        _buildSearchBar(isMobile),
        TabBar(
          controller: _tabController,
          labelColor: theme.colorScheme.primary,
          labelStyle: TextStyle(fontSize: isMobile ? 11 : 14),
          isScrollable: isMobile,
          tabs: [
            Tab(text: widget.isRtl ? 'الكل' : 'All'),
            Tab(text: widget.isRtl ? 'نشط' : 'Active'),
            Tab(text: widget.isRtl ? 'معطل' : 'Inactive'),
            Tab(
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Icon(Icons.block, size: 14, color: Colors.red),
                  const SizedBox(width: 4),
                  Text(widget.isRtl ? 'موقوف' : 'Suspended'),
                ],
              ),
            ),
          ],
        ),
        Expanded(
          child: TabBarView(
            controller: _tabController,
            children: List.generate(
                4, (index) => _buildProductsList(isMobile, index)),
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
          hintText:
              widget.isRtl ? 'بحث بالاسم أو ID...' : 'Search by name or ID...',
          prefixIcon: const Icon(Icons.search),
          border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
          isDense: isMobile,
        ),
        onSubmitted: (_) => _loadProducts(),
      ),
    );
  }

  Widget _buildProductsList(bool isMobile, int tabIndex) {
    return BlocBuilder<AdminCubit, AdminState>(
      builder: (context, state) {
        if (state is AdminProductsLoading) {
          return const Center(child: CircularProgressIndicator());
        }
        if (state is AdminError) {
          return AdminErrorWidget(
            message: state.message,
            isRtl: widget.isRtl,
            onRetry: _loadProducts,
          );
        }
        if (state is AdminProductsLoaded) {
          var products = _filterProducts(state.products, tabIndex);
          if (products.isEmpty) {
            return Center(
                child: Text(widget.isRtl ? 'لا توجد منتجات' : 'No products'));
          }

          // للتاب "موقوف" (index 3) - لا نعرض loading لأن الفلترة محلية
          // للتابات الأخرى - نعرض loading فقط لو hasMore و مش بنفلتر محلياً
          final showLoadingIndicator = tabIndex != 3 && state.hasMore;

          return RefreshIndicator(
            onRefresh: () async => _loadProducts(),
            child: ListView.builder(
              controller: _scrollControllers[tabIndex],
              padding: EdgeInsets.all(isMobile ? 12 : 16),
              itemCount: products.length + (showLoadingIndicator ? 1 : 0),
              itemBuilder: (_, i) {
                if (i >= products.length) {
                  return const Padding(
                    padding: EdgeInsets.all(16),
                    child: Center(child: CircularProgressIndicator()),
                  );
                }
                return ProductCard(
                  product: products[i],
                  isRtl: widget.isRtl,
                  isMobile: isMobile,
                  onAction: (action) => _handleAction(action, products[i]),
                );
              },
            ),
          );
        }
        return const SizedBox.shrink();
      },
    );
  }

  List<Map<String, dynamic>> _filterProducts(
      List<Map<String, dynamic>> products, int tabIndex) {
    if (tabIndex == 3) {
      return products.where((p) => p['is_suspended'] == true).toList();
    } else if (tabIndex != 0) {
      return products.where((p) => p['is_suspended'] != true).toList();
    }
    return products;
  }

  Future<void> _handleAction(
      String action, Map<String, dynamic> product) async {
    final cubit = context.read<AdminCubit>();
    final productId = product['id'];
    final isActive = product['is_active'] ?? true;

    debugPrint('📦 Admin Product Action: $action for product: $productId');

    switch (action) {
      case 'suspend':
        final reason = await _showSuspendDialog();
        debugPrint('📦 Suspend reason: $reason');
        if (reason != null && mounted) {
          final ok = await cubit.suspendProduct(productId, reason);
          debugPrint('📦 Suspend result: $ok');
          if (ok && mounted) {
            _showSnack(widget.isRtl ? 'تم إيقاف المنتج' : 'Product suspended');
            _loadProducts();
          }
        }
        break;
      case 'unsuspend':
        final ok = await cubit.unsuspendProduct(productId);
        debugPrint('📦 Unsuspend result: $ok');
        if (ok && mounted) {
          _showSnack(widget.isRtl ? 'تم إلغاء الإيقاف' : 'Product unsuspended');
          _loadProducts();
        }
        break;
      case 'toggle':
        final ok = await cubit.toggleProductStatus(productId, !isActive);
        debugPrint('📦 Toggle result: $ok');
        if (ok && mounted) _loadProducts();
        break;
      case 'delete':
        final confirm = await _showDeleteDialog();
        debugPrint('📦 Delete confirmed: $confirm');
        if (confirm == true && mounted) {
          final ok = await cubit.deleteProduct(productId);
          debugPrint('📦 Delete result: $ok');
          if (ok && mounted) {
            _showSnack(widget.isRtl ? 'تم الحذف' : 'Deleted');
            _loadProducts();
          }
        }
        break;
    }
  }

  Future<String?> _showSuspendDialog() async {
    final controller = TextEditingController();
    return showDialog<String>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text(widget.isRtl ? 'إيقاف المنتج' : 'Suspend Product'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              widget.isRtl
                  ? 'هذا الإيقاف للمنتجات المخالفة فقط.'
                  : 'This suspension is for policy violations.',
              style: TextStyle(fontSize: 12, color: Colors.grey[600]),
            ),
            const SizedBox(height: 16),
            TextField(
              controller: controller,
              decoration: InputDecoration(
                labelText: widget.isRtl ? 'سبب الإيقاف' : 'Suspension Reason',
                border: const OutlineInputBorder(),
              ),
              maxLines: 2,
            ),
          ],
        ),
        actions: [
          TextButton(
              onPressed: () => Navigator.pop(ctx),
              child: Text(widget.isRtl ? 'إلغاء' : 'Cancel')),
          ElevatedButton(
            style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
            onPressed: () {
              if (controller.text.trim().isNotEmpty) {
                Navigator.pop(ctx, controller.text.trim());
              }
            },
            child: Text(widget.isRtl ? 'إيقاف' : 'Suspend',
                style: const TextStyle(color: Colors.white)),
          ),
        ],
      ),
    );
  }

  Future<bool?> _showDeleteDialog() {
    return showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text(widget.isRtl ? 'تأكيد الحذف' : 'Confirm Delete'),
        content: Text(
            widget.isRtl ? 'هل تريد حذف هذا المنتج؟' : 'Delete this product?'),
        actions: [
          TextButton(
              onPressed: () => Navigator.pop(ctx, false),
              child: Text(widget.isRtl ? 'إلغاء' : 'Cancel')),
          TextButton(
              onPressed: () => Navigator.pop(ctx, true),
              child: Text(widget.isRtl ? 'حذف' : 'Delete',
                  style: const TextStyle(color: Colors.red))),
        ],
      ),
    );
  }

  void _showSnack(String msg) {
    ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(msg), backgroundColor: Colors.green));
  }
}
