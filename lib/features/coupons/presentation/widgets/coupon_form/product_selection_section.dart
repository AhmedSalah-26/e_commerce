import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import '../../../../../core/theme/app_colors.dart';
import '../../../../products/domain/entities/product_entity.dart';

class ProductSelectionSection extends StatelessWidget {
  final List<String> selectedProductIds;
  final List<ProductEntity> storeProducts;
  final VoidCallback onSelectProducts;
  final ValueChanged<String> onRemoveProduct;

  const ProductSelectionSection({
    super.key,
    required this.selectedProductIds,
    required this.storeProducts,
    required this.onSelectProducts,
    required this.onRemoveProduct,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text('selected_products'.tr(),
                style: const TextStyle(fontWeight: FontWeight.w500)),
            TextButton.icon(
              onPressed: onSelectProducts,
              icon: const Icon(Icons.add, size: 18),
              label: Text('select_products'.tr()),
              style:
                  TextButton.styleFrom(foregroundColor: AppColours.brownMedium),
            ),
          ],
        ),
        const SizedBox(height: 8),
        if (selectedProductIds.isEmpty)
          _EmptySelectionBox(message: 'no_products_selected'.tr())
        else
          _SelectedItemsList(
            itemIds: selectedProductIds,
            items: storeProducts,
            onRemove: onRemoveProduct,
            getItemName: (p) => p.name,
            getItemImage: (p) => p.images.isNotEmpty ? p.images.first : null,
            emptyIcon: Icons.inventory_2,
          ),
      ],
    );
  }
}

class _EmptySelectionBox extends StatelessWidget {
  final String message;

  const _EmptySelectionBox({required this.message});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.grey.shade100,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: Colors.grey.shade300),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.info_outline, color: Colors.grey.shade600, size: 18),
          const SizedBox(width: 8),
          Text(message, style: TextStyle(color: Colors.grey.shade600)),
        ],
      ),
    );
  }
}

class _SelectedItemsList<T> extends StatelessWidget {
  final List<String> itemIds;
  final List<T> items;
  final ValueChanged<String> onRemove;
  final String Function(T) getItemName;
  final String? Function(T) getItemImage;
  final IconData emptyIcon;

  const _SelectedItemsList({
    required this.itemIds,
    required this.items,
    required this.onRemove,
    required this.getItemName,
    required this.getItemImage,
    required this.emptyIcon,
  });

  T? _findItem(String id) {
    try {
      return items.firstWhere((item) {
        if (item is ProductEntity) return item.id == id;
        return false;
      });
    } catch (_) {
      return null;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      constraints: const BoxConstraints(maxHeight: 150),
      decoration: BoxDecoration(
        border: Border.all(color: Colors.grey.shade300),
        borderRadius: BorderRadius.circular(8),
      ),
      child: ListView.builder(
        shrinkWrap: true,
        itemCount: itemIds.length,
        itemBuilder: (context, index) {
          final itemId = itemIds[index];
          final item = _findItem(itemId);
          if (item == null) return const SizedBox.shrink();

          final imageUrl = getItemImage(item);
          return ListTile(
            dense: true,
            leading: imageUrl != null
                ? ClipRRect(
                    borderRadius: BorderRadius.circular(4),
                    child: Image.network(
                      imageUrl,
                      width: 40,
                      height: 40,
                      fit: BoxFit.cover,
                      errorBuilder: (_, __, ___) =>
                          _PlaceholderIcon(icon: emptyIcon),
                    ),
                  )
                : _PlaceholderIcon(icon: emptyIcon),
            title: Text(
              getItemName(item),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: const TextStyle(fontSize: 14),
            ),
            trailing: IconButton(
              icon: const Icon(Icons.close, size: 18),
              onPressed: () => onRemove(itemId),
            ),
          );
        },
      ),
    );
  }
}

class _PlaceholderIcon extends StatelessWidget {
  final IconData icon;

  const _PlaceholderIcon({required this.icon});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 40,
      height: 40,
      decoration: BoxDecoration(
        color: Colors.grey.shade200,
        borderRadius: BorderRadius.circular(4),
      ),
      child: Icon(icon, size: 20),
    );
  }
}
