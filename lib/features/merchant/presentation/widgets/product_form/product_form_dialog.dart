import 'package:flutter/material.dart';
import '../../../../../core/theme/app_colors.dart';
import '../../../../../Core/Theme/app_text_style.dart';
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
    return Dialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Container(
        constraints: const BoxConstraints(maxHeight: 700, maxWidth: 500),
        child: Column(
          children: [
            _buildHeader(context),
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

  Widget _buildHeader(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: const BoxDecoration(
        color: AppColours.primary,
        borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            product == null
                ? (isRtl ? 'إضافة منتج جديد' : 'Add New Product')
                : (isRtl ? 'تعديل المنتج' : 'Edit Product'),
            style: AppTextStyle.semiBold_18_white,
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
