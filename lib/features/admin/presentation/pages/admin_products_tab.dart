import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../cubit/admin_cubit.dart';
import '../cubit/admin_state.dart';

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

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 4, vsync: this);
    _tabController.addListener(_onTabChanged);
    _loadProducts(null);
  }

  @override
  void dispose() {
    _tabController.dispose();
    _searchController.dispose();
    super.dispose();
  }

  void _onTabChanged() {
    if (!_tabController.indexIsChanging) {
      final isActive = _tabController.index == 0
          ? null
          : _tabController.index == 1
              ? true
              : _tabController.index == 2
                  ? false
                  : null;
      _loadProducts(isActive);
    }
  }

  void _loadProducts(bool? isActive) {
    context.read<AdminCubit>().loadProducts(
          isActive: isActive,
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
        _buildHeader(theme, isMobile),
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
                  Icon(Icons.block, size: 14, color: Colors.red),
                  SizedBox(width: 4),
                  Text(widget.isRtl ? 'موقوف' : 'Suspended'),
                ],
              ),
            ),
          ],
        ),
        Expanded(
          child: TabBarView(
            controller: _tabController,
            children: List.generate(4, (_) => _buildProductsList(isMobile)),
          ),
        ),
      ],
    );
  }

  Widget _buildHeader(ThemeData theme, bool isMobile) {
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
        onSubmitted: (_) {
          final isActive = _tabController.index == 0
              ? null
              : _tabController.index == 1
                  ? true
                  : _tabController.index == 2
                      ? false
                      : null;
          _loadProducts(isActive);
        },
      ),
    );
  }

  Widget _buildProductsList(bool isMobile) {
    return BlocBuilder<AdminCubit, AdminState>(
      builder: (context, state) {
        if (state is AdminProductsLoading) {
          return const Center(child: CircularProgressIndicator());
        }
        if (state is AdminError) {
          return Center(child: Text(state.message));
        }
        if (state is AdminProductsLoaded) {
          var products = state.products;

          // Filter suspended products for tab 3
          if (_tabController.index == 3) {
            products =
                products.where((p) => p['is_suspended'] == true).toList();
          } else if (_tabController.index != 0) {
            // For active/inactive tabs, exclude suspended
            products =
                products.where((p) => p['is_suspended'] != true).toList();
          }

          if (products.isEmpty) {
            return Center(
              child:
                  Text(widget.isRtl ? 'لا توجد منتجات' : 'No products found'),
            );
          }
          return RefreshIndicator(
            onRefresh: () async {
              final isActive = _tabController.index == 0
                  ? null
                  : _tabController.index == 1
                      ? true
                      : _tabController.index == 2
                          ? false
                          : null;
              _loadProducts(isActive);
            },
            child: ListView.builder(
              padding: EdgeInsets.all(isMobile ? 12 : 16),
              itemCount: products.length,
              itemBuilder: (context, index) =>
                  _buildProductCard(products[index], isMobile),
            ),
          );
        }
        return const SizedBox.shrink();
      },
    );
  }

  Widget _buildProductCard(Map<String, dynamic> product, bool isMobile) {
    final theme = Theme.of(context);
    final isActive = product['is_active'] ?? true;
    final isSuspended = product['is_suspended'] ?? false;
    final suspensionReason = product['suspension_reason'];
    final name = widget.isRtl
        ? (product['name_ar'] ?? product['name'])
        : product['name'];
    final price = (product['price'] ?? 0).toDouble();
    final stock = product['stock'] ?? 0;
    final images = product['images'] as List? ?? [];
    final imageUrl = images.isNotEmpty ? images[0] : null;
    final merchant = product['profiles'];
    final merchantName = merchant?['name'] ?? '';

    return Card(
      margin: EdgeInsets.only(bottom: isMobile ? 8 : 12),
      color: isSuspended ? Colors.red.withValues(alpha: 0.05) : null,
      child: Column(
        children: [
          ListTile(
            contentPadding: EdgeInsets.all(isMobile ? 8 : 12),
            leading: Stack(
              children: [
                ClipRRect(
                  borderRadius: BorderRadius.circular(8),
                  child: imageUrl != null
                      ? Image.network(
                          imageUrl,
                          width: isMobile ? 50 : 60,
                          height: isMobile ? 50 : 60,
                          fit: BoxFit.cover,
                          errorBuilder: (_, __, ___) =>
                              _buildPlaceholder(isMobile),
                        )
                      : _buildPlaceholder(isMobile),
                ),
                if (isSuspended)
                  Positioned.fill(
                    child: Container(
                      decoration: BoxDecoration(
                        color: Colors.red.withValues(alpha: 0.7),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: const Icon(Icons.block, color: Colors.white),
                    ),
                  ),
              ],
            ),
            title: Text(
              name ?? '',
              style: TextStyle(
                fontSize: isMobile ? 13 : 14,
                decoration: isSuspended ? TextDecoration.lineThrough : null,
              ),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
            subtitle: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  '${price.toStringAsFixed(0)} ${widget.isRtl ? 'ج.م' : 'EGP'}',
                  style: TextStyle(
                    color: theme.colorScheme.primary,
                    fontWeight: FontWeight.bold,
                    fontSize: isMobile ? 12 : 13,
                  ),
                ),
                Row(
                  children: [
                    Text(
                      '${widget.isRtl ? 'المخزون:' : 'Stock:'} $stock',
                      style: TextStyle(fontSize: isMobile ? 11 : 12),
                    ),
                    if (merchantName.isNotEmpty) ...[
                      const Text(' • '),
                      Expanded(
                        child: Text(
                          merchantName,
                          style: TextStyle(
                            fontSize: isMobile ? 10 : 11,
                            color: theme.colorScheme.outline,
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                    ],
                  ],
                ),
              ],
            ),
            trailing: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                _buildStatusBadges(isActive, isSuspended, isMobile),
                PopupMenuButton<String>(
                  itemBuilder: (context) =>
                      _buildMenuItems(isActive, isSuspended),
                  onSelected: (value) =>
                      _handleAction(value, product, isActive, isSuspended),
                ),
              ],
            ),
          ),
          if (isSuspended && suspensionReason != null)
            Container(
              width: double.infinity,
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
              decoration: BoxDecoration(
                color: Colors.red.withValues(alpha: 0.1),
                borderRadius:
                    const BorderRadius.vertical(bottom: Radius.circular(12)),
              ),
              child: Row(
                children: [
                  const Icon(Icons.warning, size: 16, color: Colors.red),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      '${widget.isRtl ? 'سبب الإيقاف:' : 'Reason:'} $suspensionReason',
                      style: const TextStyle(fontSize: 12, color: Colors.red),
                    ),
                  ),
                ],
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildStatusBadges(bool isActive, bool isSuspended, bool isMobile) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        if (isSuspended)
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
            decoration: BoxDecoration(
              color: Colors.red.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Text(
              widget.isRtl ? 'موقوف' : 'Suspended',
              style: const TextStyle(color: Colors.red, fontSize: 10),
            ),
          )
        else
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
            decoration: BoxDecoration(
              color: isActive
                  ? Colors.green.withValues(alpha: 0.1)
                  : Colors.orange.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Text(
              isActive
                  ? (widget.isRtl ? 'نشط' : 'Active')
                  : (widget.isRtl ? 'معطل' : 'Inactive'),
              style: TextStyle(
                color: isActive ? Colors.green : Colors.orange,
                fontSize: 10,
              ),
            ),
          ),
      ],
    );
  }

  List<PopupMenuEntry<String>> _buildMenuItems(
      bool isActive, bool isSuspended) {
    return [
      if (isSuspended)
        PopupMenuItem(
          value: 'unsuspend',
          child: Row(
            children: [
              const Icon(Icons.check_circle, size: 18, color: Colors.green),
              const SizedBox(width: 8),
              Text(widget.isRtl ? 'إلغاء الإيقاف' : 'Unsuspend'),
            ],
          ),
        )
      else ...[
        PopupMenuItem(
          value: 'suspend',
          child: Row(
            children: [
              const Icon(Icons.block, size: 18, color: Colors.red),
              const SizedBox(width: 8),
              Text(
                widget.isRtl ? 'إيقاف (مخالفة)' : 'Suspend (Violation)',
                style: const TextStyle(color: Colors.red),
              ),
            ],
          ),
        ),
        PopupMenuItem(
          value: 'toggle',
          child: Row(
            children: [
              Icon(
                isActive ? Icons.visibility_off : Icons.visibility,
                size: 18,
              ),
              const SizedBox(width: 8),
              Text(isActive
                  ? (widget.isRtl ? 'تعطيل (تاجر)' : 'Deactivate (Merchant)')
                  : (widget.isRtl ? 'تفعيل' : 'Activate')),
            ],
          ),
        ),
      ],
      const PopupMenuDivider(),
      PopupMenuItem(
        value: 'delete',
        child: Row(
          children: [
            const Icon(Icons.delete, size: 18, color: Colors.red),
            const SizedBox(width: 8),
            Text(
              widget.isRtl ? 'حذف' : 'Delete',
              style: const TextStyle(color: Colors.red),
            ),
          ],
        ),
      ),
    ];
  }

  Widget _buildPlaceholder(bool isMobile) {
    return Container(
      width: isMobile ? 50 : 60,
      height: isMobile ? 50 : 60,
      color: Colors.grey[200],
      child: const Icon(Icons.image, color: Colors.grey),
    );
  }

  Future<void> _handleAction(String value, Map<String, dynamic> product,
      bool isActive, bool isSuspended) async {
    final productId = product['id'];
    final cubit = context.read<AdminCubit>();

    if (value == 'suspend') {
      final reason = await _showSuspendDialog();
      if (reason != null && mounted) {
        final success = await cubit.suspendProduct(productId, reason);
        if (success && mounted) {
          _showSnackBar(widget.isRtl ? 'تم إيقاف المنتج' : 'Product suspended');
          _reloadProducts();
        }
      }
    } else if (value == 'unsuspend') {
      final success = await cubit.unsuspendProduct(productId);
      if (success && mounted) {
        _showSnackBar(
            widget.isRtl ? 'تم إلغاء الإيقاف' : 'Product unsuspended');
        _reloadProducts();
      }
    } else if (value == 'toggle') {
      final success = await cubit.toggleProductStatus(productId, !isActive);
      if (success && mounted) {
        _reloadProducts();
      }
    } else if (value == 'delete') {
      final confirm = await _showDeleteDialog();
      if (confirm == true && mounted) {
        final success = await cubit.deleteProduct(productId);
        if (success && mounted) {
          _showSnackBar(widget.isRtl ? 'تم الحذف' : 'Deleted');
          _reloadProducts();
        }
      }
    }
  }

  void _reloadProducts() {
    final isActive = _tabController.index == 0
        ? null
        : _tabController.index == 1
            ? true
            : _tabController.index == 2
                ? false
                : null;
    _loadProducts(isActive);
  }

  void _showSnackBar(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(message), backgroundColor: Colors.green),
    );
  }

  Future<String?> _showSuspendDialog() async {
    final controller = TextEditingController();
    return showDialog<String>(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(widget.isRtl ? 'إيقاف المنتج' : 'Suspend Product'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              widget.isRtl
                  ? 'هذا الإيقاف للمنتجات المخالفة فقط. التاجر لن يستطيع إعادة تفعيله.'
                  : 'This suspension is for policy violations. Merchant cannot reactivate.',
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
            onPressed: () => Navigator.pop(context),
            child: Text(widget.isRtl ? 'إلغاء' : 'Cancel'),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
            onPressed: () {
              if (controller.text.trim().isNotEmpty) {
                Navigator.pop(context, controller.text.trim());
              }
            },
            child: Text(
              widget.isRtl ? 'إيقاف' : 'Suspend',
              style: const TextStyle(color: Colors.white),
            ),
          ),
        ],
      ),
    );
  }

  Future<bool?> _showDeleteDialog() {
    return showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(widget.isRtl ? 'تأكيد الحذف' : 'Confirm Delete'),
        content: Text(
            widget.isRtl ? 'هل تريد حذف هذا المنتج؟' : 'Delete this product?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: Text(widget.isRtl ? 'إلغاء' : 'Cancel'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            child: Text(widget.isRtl ? 'حذف' : 'Delete',
                style: const TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );
  }
}
