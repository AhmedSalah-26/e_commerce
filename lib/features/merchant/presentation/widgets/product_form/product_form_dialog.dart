import 'package:flutter/material.dart';
import '../../../../products/domain/entities/product_entity.dart';
import 'product_form_content.dart';

class ProductFormDialog extends StatelessWidget {
  final ProductEntity? product;
  final bool isRtl;
  final Future<bool> Function(Map<String, dynamic>) onSave;

  const ProductFormDialog({
    super.key,
    this.product,
    required this.isRtl,
    required this.onSave,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Dialog(
      backgroundColor: theme.colorScheme.surface,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Container(
        constraints: const BoxConstraints(maxHeight: 700, maxWidth: 500),
        child: Column(
          children: [
            _buildHeader(context, theme),
            Expanded(
              child: ProductFormContent(
                product: product,
                isRtl: isRtl,
                onSave: onSave,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildHeader(BuildContext context, ThemeData theme) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: theme.colorScheme.primary,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(16)),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            product == null
                ? (isRtl ? 'إضافة منتج جديد' : 'Add New Product')
                : (isRtl ? 'تعديل المنتج' : 'Edit Product'),
            style: const TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.w600,
              color: Colors.white,
            ),
          ),
          IconButton(
            icon: const Icon(Icons.close, color: Colors.white),
            onPressed: () => Navigator.pop(context),
          ),
        ],
      ),
    );
  }
}
