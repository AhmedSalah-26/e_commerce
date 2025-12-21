import 'package:flutter/material.dart';
import 'package:easy_localization/easy_localization.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../Core/Theme/app_text_style.dart';
import '../../../products/domain/entities/product_entity.dart';

class MerchantProductCard extends StatelessWidget {
  final ProductEntity product;
  final VoidCallback onEdit;
  final VoidCallback onDelete;

  const MerchantProductCard({
    super.key,
    required this.product,
    required this.onEdit,
    required this.onDelete,
  });

  @override
  Widget build(BuildContext context) {
    final isRtl = context.locale.languageCode == 'ar';

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppColours.greyLight),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withValues(alpha: 0.1),
            blurRadius: 4,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Stack(
        children: [
          Padding(
            padding: const EdgeInsets.all(12),
            child: Row(
              children: [
                // Product image
                ClipRRect(
                  borderRadius: BorderRadius.circular(8),
                  child: product.images.isNotEmpty
                      ? Image.network(
                          product.images.first,
                          width: 80,
                          height: 80,
                          fit: BoxFit.cover,
                          errorBuilder: (context, error, stackTrace) =>
                              _buildPlaceholder(),
                        )
                      : _buildPlaceholder(),
                ),
                const SizedBox(width: 12),
                // Product info
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        product.name,
                        style: AppTextStyle.semiBold_16_dark_brown,
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                      ),
                      const SizedBox(height: 4),
                      Text(
                        '${product.price.toStringAsFixed(2)} ${isRtl ? 'ج.م' : 'EGP'}',
                        style: AppTextStyle.semiBold_16_dark_brown.copyWith(
                          color: AppColours.primary,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Row(
                        children: [
                          Icon(
                            Icons.inventory_2_outlined,
                            size: 16,
                            color:
                                product.stock > 0 ? Colors.green : Colors.red,
                          ),
                          const SizedBox(width: 4),
                          Text(
                            '${isRtl ? 'المخزون' : 'Stock'}: ${product.stock}',
                            style: AppTextStyle.normal_14_greyDark.copyWith(
                              color:
                                  product.stock > 0 ? Colors.green : Colors.red,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
                // Actions
                Column(
                  children: [
                    IconButton(
                      onPressed: onEdit,
                      icon: Icon(
                        Icons.edit_outlined,
                        color: AppColours.primary,
                      ),
                      padding: EdgeInsets.zero,
                      constraints: const BoxConstraints(),
                    ),
                    const SizedBox(height: 8),
                    IconButton(
                      onPressed: () => _showDeleteConfirmation(context, isRtl),
                      icon: const Icon(
                        Icons.delete_outline,
                        color: Colors.red,
                      ),
                      padding: EdgeInsets.zero,
                      constraints: const BoxConstraints(),
                    ),
                  ],
                ),
              ],
            ),
          ),
          // Active/Inactive badge - corner ribbon style
          Positioned(
            top: 0,
            right: isRtl ? null : 0,
            left: isRtl ? 0 : null,
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
              decoration: BoxDecoration(
                color: product.isActive ? Colors.green : Colors.grey,
                borderRadius: BorderRadius.only(
                  topRight: isRtl ? Radius.zero : const Radius.circular(12),
                  topLeft: isRtl ? const Radius.circular(12) : Radius.zero,
                  bottomLeft: isRtl ? Radius.zero : const Radius.circular(12),
                  bottomRight: isRtl ? const Radius.circular(12) : Radius.zero,
                ),
              ),
              child: Text(
                product.isActive
                    ? (isRtl ? 'نشط' : 'Active')
                    : (isRtl ? 'غير نشط' : 'Inactive'),
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 10,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPlaceholder() {
    return Container(
      width: 80,
      height: 80,
      color: AppColours.greyLighter,
      child: Icon(
        Icons.image_outlined,
        color: AppColours.greyMedium,
        size: 32,
      ),
    );
  }

  void _showDeleteConfirmation(BuildContext context, bool isRtl) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(isRtl ? 'حذف المنتج' : 'Delete Product'),
        content: Text(
          isRtl
              ? 'هل أنت متأكد من حذف هذا المنتج؟'
              : 'Are you sure you want to delete this product?',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text(isRtl ? 'إلغاء' : 'Cancel'),
          ),
          TextButton(
            onPressed: () {
              Navigator.pop(context);
              onDelete();
            },
            style: TextButton.styleFrom(foregroundColor: Colors.red),
            child: Text(isRtl ? 'حذف' : 'Delete'),
          ),
        ],
      ),
    );
  }
}
