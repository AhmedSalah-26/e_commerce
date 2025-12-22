import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:easy_localization/easy_localization.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_text_style.dart';
import '../../../products/domain/entities/product_entity.dart';

class MerchantProductCard extends StatelessWidget {
  final ProductEntity product;
  final VoidCallback onEdit;
  final VoidCallback onToggleActive;

  const MerchantProductCard({
    super.key,
    required this.product,
    required this.onEdit,
    required this.onToggleActive,
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
      child: Column(
        children: [
          // Active/Inactive badge at top
          Container(
            width: double.infinity,
            padding: const EdgeInsets.symmetric(vertical: 6),
            decoration: BoxDecoration(
              color: product.isActive ? Colors.green : Colors.grey,
              borderRadius: const BorderRadius.only(
                topLeft: Radius.circular(12),
                topRight: Radius.circular(12),
              ),
            ),
            child: Text(
              product.isActive
                  ? (isRtl ? 'نشط' : 'Active')
                  : (isRtl ? 'غير نشط' : 'Inactive'),
              style: const TextStyle(
                color: Colors.white,
                fontSize: 12,
                fontWeight: FontWeight.bold,
              ),
              textAlign: TextAlign.center,
            ),
          ),
          // Product content
          Padding(
            padding: const EdgeInsets.all(12),
            child: Row(
              children: [
                // Product image
                ClipRRect(
                  borderRadius: BorderRadius.circular(8),
                  child: product.images.isNotEmpty
                      ? CachedNetworkImage(
                          imageUrl: product.images.first,
                          width: 80,
                          height: 80,
                          fit: BoxFit.cover,
                          memCacheWidth: 160,
                          placeholder: (_, __) => _buildPlaceholder(),
                          errorWidget: (_, __, ___) => _buildPlaceholder(),
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
                      icon: const Icon(
                        Icons.edit_outlined,
                        color: AppColours.brownMedium,
                      ),
                      padding: EdgeInsets.zero,
                      constraints: const BoxConstraints(),
                      tooltip: isRtl ? 'تعديل' : 'Edit',
                    ),
                    const SizedBox(height: 8),
                    IconButton(
                      onPressed: () => _showToggleConfirmation(context, isRtl),
                      icon: Icon(
                        product.isActive
                            ? Icons.visibility_off_outlined
                            : Icons.visibility_outlined,
                        color: product.isActive ? Colors.orange : Colors.green,
                      ),
                      padding: EdgeInsets.zero,
                      constraints: const BoxConstraints(),
                      tooltip: product.isActive
                          ? (isRtl ? 'إلغاء التنشيط' : 'Deactivate')
                          : (isRtl ? 'تنشيط' : 'Activate'),
                    ),
                  ],
                ),
              ],
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
      child: const Icon(
        Icons.image_outlined,
        color: AppColours.greyMedium,
        size: 32,
      ),
    );
  }

  void _showToggleConfirmation(BuildContext context, bool isRtl) {
    final willDeactivate = product.isActive;

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(
          willDeactivate
              ? (isRtl ? 'إلغاء تنشيط المنتج' : 'Deactivate Product')
              : (isRtl ? 'تنشيط المنتج' : 'Activate Product'),
        ),
        content: Text(
          willDeactivate
              ? (isRtl
                  ? 'هل أنت متأكد من إلغاء تنشيط هذا المنتج؟ لن يظهر للعملاء.'
                  : 'Are you sure you want to deactivate this product? It won\'t be visible to customers.')
              : (isRtl
                  ? 'هل أنت متأكد من تنشيط هذا المنتج؟ سيظهر للعملاء.'
                  : 'Are you sure you want to activate this product? It will be visible to customers.'),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text(isRtl ? 'إلغاء' : 'Cancel'),
          ),
          TextButton(
            onPressed: () {
              Navigator.pop(context);
              onToggleActive();
            },
            style: TextButton.styleFrom(
              foregroundColor: willDeactivate ? Colors.orange : Colors.green,
            ),
            child: Text(
              willDeactivate
                  ? (isRtl ? 'إلغاء التنشيط' : 'Deactivate')
                  : (isRtl ? 'تنشيط' : 'Activate'),
            ),
          ),
        ],
      ),
    );
  }
}
