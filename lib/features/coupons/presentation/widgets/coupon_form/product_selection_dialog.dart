import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import '../../../../products/domain/entities/product_entity.dart';

class ProductSelectionDialog extends StatefulWidget {
  final List<ProductEntity> products;
  final List<String> selectedIds;
  final ValueChanged<List<String>> onConfirm;

  const ProductSelectionDialog({
    super.key,
    required this.products,
    required this.selectedIds,
    required this.onConfirm,
  });

  @override
  State<ProductSelectionDialog> createState() => _ProductSelectionDialogState();
}

class _ProductSelectionDialogState extends State<ProductSelectionDialog> {
  late List<String> _tempSelectedIds;
  String _searchQuery = '';

  @override
  void initState() {
    super.initState();
    _tempSelectedIds = List.from(widget.selectedIds);
  }

  List<ProductEntity> get _filteredProducts {
    if (_searchQuery.isEmpty) return widget.products;
    return widget.products
        .where((p) => p.name.toLowerCase().contains(_searchQuery.toLowerCase()))
        .toList();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Dialog(
      backgroundColor: theme.colorScheme.surface,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Container(
        width: MediaQuery.of(context).size.width * 0.9,
        constraints: const BoxConstraints(maxHeight: 500),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            _buildHeader(theme),
            _buildSearchField(theme),
            Flexible(child: _buildProductsList(theme)),
            _buildActions(theme),
          ],
        ),
      ),
    );
  }

  Widget _buildHeader(ThemeData theme) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: theme.colorScheme.primary,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(16)),
      ),
      child: Row(
        children: [
          const Icon(Icons.inventory_2, color: Colors.white),
          const SizedBox(width: 8),
          Text(
            'select_products'.tr(),
            style: const TextStyle(
                fontSize: 18, fontWeight: FontWeight.bold, color: Colors.white),
          ),
          const Spacer(),
          IconButton(
            icon: const Icon(Icons.close, color: Colors.white),
            onPressed: () => Navigator.pop(context),
          ),
        ],
      ),
    );
  }

  Widget _buildSearchField(ThemeData theme) {
    return Padding(
      padding: const EdgeInsets.all(12),
      child: TextField(
        onChanged: (v) => setState(() => _searchQuery = v),
        decoration: InputDecoration(
          hintText: 'search_products'.tr(),
          prefixIcon: const Icon(Icons.search),
          border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
          contentPadding: const EdgeInsets.symmetric(horizontal: 12),
        ),
      ),
    );
  }

  Widget _buildProductsList(ThemeData theme) {
    if (_filteredProducts.isEmpty) {
      return Center(
        child: Text('no_products'.tr(),
            style: TextStyle(
                color: theme.colorScheme.onSurface.withValues(alpha: 0.6))),
      );
    }

    return ListView.builder(
      itemCount: _filteredProducts.length,
      itemBuilder: (context, index) {
        final product = _filteredProducts[index];
        final isSelected = _tempSelectedIds.contains(product.id);
        return CheckboxListTile(
          value: isSelected,
          onChanged: (v) {
            setState(() {
              if (v == true) {
                _tempSelectedIds.add(product.id);
              } else {
                _tempSelectedIds.remove(product.id);
              }
            });
          },
          secondary: _buildProductImage(product, theme),
          title:
              Text(product.name, maxLines: 1, overflow: TextOverflow.ellipsis),
          subtitle: Text(
            '${product.price} ${'egp'.tr()}',
            style: TextStyle(
                color: theme.colorScheme.onSurface.withValues(alpha: 0.6),
                fontSize: 12),
          ),
          activeColor: theme.colorScheme.primary,
        );
      },
    );
  }

  Widget _buildProductImage(ProductEntity product, ThemeData theme) {
    if (product.images.isNotEmpty) {
      return ClipRRect(
        borderRadius: BorderRadius.circular(4),
        child: Image.network(
          product.images.first,
          width: 40,
          height: 40,
          fit: BoxFit.cover,
          errorBuilder: (_, __, ___) => _buildPlaceholder(theme),
        ),
      );
    }
    return _buildPlaceholder(theme);
  }

  Widget _buildPlaceholder(ThemeData theme) {
    return Container(
      width: 40,
      height: 40,
      decoration: BoxDecoration(
        color: theme.colorScheme.outline.withValues(alpha: 0.2),
        borderRadius: BorderRadius.circular(4),
      ),
      child: const Icon(Icons.inventory_2, size: 20),
    );
  }

  Widget _buildActions(ThemeData theme) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        border: Border(
            top: BorderSide(
                color: theme.colorScheme.outline.withValues(alpha: 0.3))),
      ),
      child: Row(
        children: [
          Text(
            '${_tempSelectedIds.length} ${'selected'.tr()}',
            style: TextStyle(
                color: theme.colorScheme.onSurface.withValues(alpha: 0.6)),
          ),
          const Spacer(),
          TextButton(
              onPressed: () => Navigator.pop(context),
              child: Text('cancel'.tr())),
          const SizedBox(width: 8),
          ElevatedButton(
            onPressed: () {
              widget.onConfirm(_tempSelectedIds);
              Navigator.pop(context);
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: theme.colorScheme.primary,
              foregroundColor: Colors.white,
            ),
            child: Text('confirm'.tr()),
          ),
        ],
      ),
    );
  }
}
