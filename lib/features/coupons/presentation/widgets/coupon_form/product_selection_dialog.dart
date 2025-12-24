import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import '../../../../../core/theme/app_colors.dart';
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
    return Dialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Container(
        width: MediaQuery.of(context).size.width * 0.9,
        constraints: const BoxConstraints(maxHeight: 500),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            _buildHeader(),
            _buildSearchField(),
            Flexible(child: _buildProductsList()),
            _buildActions(),
          ],
        ),
      ),
    );
  }

  Widget _buildHeader() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: const BoxDecoration(
        color: AppColours.brownLight,
        borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
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

  Widget _buildSearchField() {
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

  Widget _buildProductsList() {
    if (_filteredProducts.isEmpty) {
      return Center(
        child: Text('no_products'.tr(),
            style: TextStyle(color: Colors.grey.shade600)),
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
          secondary: _buildProductImage(product),
          title:
              Text(product.name, maxLines: 1, overflow: TextOverflow.ellipsis),
          subtitle: Text(
            '${product.price} ${'egp'.tr()}',
            style: TextStyle(color: Colors.grey.shade600, fontSize: 12),
          ),
          activeColor: AppColours.brownMedium,
        );
      },
    );
  }

  Widget _buildProductImage(ProductEntity product) {
    if (product.images.isNotEmpty) {
      return ClipRRect(
        borderRadius: BorderRadius.circular(4),
        child: Image.network(
          product.images.first,
          width: 40,
          height: 40,
          fit: BoxFit.cover,
          errorBuilder: (_, __, ___) => _buildPlaceholder(),
        ),
      );
    }
    return _buildPlaceholder();
  }

  Widget _buildPlaceholder() {
    return Container(
      width: 40,
      height: 40,
      decoration: BoxDecoration(
        color: Colors.grey.shade200,
        borderRadius: BorderRadius.circular(4),
      ),
      child: const Icon(Icons.inventory_2, size: 20),
    );
  }

  Widget _buildActions() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        border: Border(top: BorderSide(color: Colors.grey.shade200)),
      ),
      child: Row(
        children: [
          Text(
            '${_tempSelectedIds.length} ${'selected'.tr()}',
            style: TextStyle(color: Colors.grey.shade600),
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
              backgroundColor: AppColours.brownMedium,
              foregroundColor: Colors.white,
            ),
            child: Text('confirm'.tr()),
          ),
        ],
      ),
    );
  }
}
