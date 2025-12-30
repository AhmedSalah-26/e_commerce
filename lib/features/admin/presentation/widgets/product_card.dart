import 'package:flutter/material.dart';
import 'copyable_row.dart';
import 'status_chip.dart';

class ProductCard extends StatelessWidget {
  final Map<String, dynamic> product;
  final bool isRtl;
  final bool isMobile;
  final Function(String action) onAction;

  const ProductCard({
    super.key,
    required this.product,
    required this.isRtl,
    required this.isMobile,
    required this.onAction,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isActive = product['is_active'] ?? true;
    final isSuspended = product['is_suspended'] ?? false;
    final name =
        isRtl ? (product['name_ar'] ?? product['name']) : product['name'];
    final price = (product['price'] ?? 0).toDouble();
    final images = product['images'] as List? ?? [];
    final imageUrl = images.isNotEmpty ? images[0] : null;

    return Card(
      margin: EdgeInsets.only(bottom: isMobile ? 8 : 12),
      color: isSuspended ? Colors.red.withValues(alpha: 0.05) : null,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      child: ExpansionTile(
        tilePadding: EdgeInsets.symmetric(horizontal: isMobile ? 12 : 16),
        childrenPadding:
            EdgeInsets.fromLTRB(isMobile ? 12 : 16, 0, isMobile ? 12 : 16, 12),
        leading: _buildImage(imageUrl, isSuspended),
        title: Text(
          name ?? '',
          style: TextStyle(
            fontWeight: FontWeight.bold,
            fontSize: isMobile ? 14 : 16,
            decoration: isSuspended ? TextDecoration.lineThrough : null,
          ),
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
        ),
        subtitle: Text(
          '${price.toStringAsFixed(0)} ${isRtl ? 'ج.م' : 'EGP'}',
          style: TextStyle(
            color: theme.colorScheme.primary,
            fontWeight: FontWeight.bold,
            fontSize: 13,
          ),
        ),
        trailing: _statusChip(isActive, isSuspended),
        children: [
          _ProductDetails(product: product, isRtl: isRtl),
          const SizedBox(height: 12),
          _ProductActions(
            product: product,
            isRtl: isRtl,
            isActive: isActive,
            isSuspended: isSuspended,
            onAction: onAction,
          ),
        ],
      ),
    );
  }

  Widget _buildImage(String? imageUrl, bool isSuspended) {
    final size = isMobile ? 45.0 : 50.0;
    return Stack(
      children: [
        ClipRRect(
          borderRadius: BorderRadius.circular(8),
          child: imageUrl != null
              ? Image.network(
                  imageUrl,
                  width: size,
                  height: size,
                  fit: BoxFit.cover,
                  errorBuilder: (_, __, ___) => _placeholder(size),
                )
              : _placeholder(size),
        ),
        if (isSuspended)
          Positioned.fill(
            child: Container(
              decoration: BoxDecoration(
                color: Colors.red.withValues(alpha: 0.7),
                borderRadius: BorderRadius.circular(8),
              ),
              child: const Icon(Icons.block, color: Colors.white, size: 20),
            ),
          ),
      ],
    );
  }

  Widget _placeholder(double size) {
    return Container(
      width: size,
      height: size,
      color: Colors.grey[200],
      child: const Icon(Icons.image, color: Colors.grey),
    );
  }

  Widget _statusChip(bool isActive, bool isSuspended) {
    final status = isSuspended
        ? 'suspended'
        : isActive
            ? 'active'
            : 'inactive';
    return StatusChip(status: status, isRtl: isRtl);
  }
}

class _ProductDetails extends StatelessWidget {
  final Map<String, dynamic> product;
  final bool isRtl;

  const _ProductDetails({required this.product, required this.isRtl});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final productId = (product['id'] ?? '').toString();
    final stock = product['stock'] ?? 0;
    final merchant = product['profiles'];
    final merchantName = merchant?['name'] ?? '';
    final merchantId = merchant?['id'] ?? '';
    final category = product['categories'];
    final categoryName = isRtl
        ? (category?['name_ar'] ?? category?['name'] ?? '')
        : (category?['name'] ?? '');
    final description = isRtl
        ? (product['description_ar'] ?? product['description'] ?? '')
        : (product['description'] ?? '');
    final suspensionReason = product['suspension_reason'];

    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.grey[800],
        borderRadius: BorderRadius.circular(8),
      ),
      child: Column(
        children: [
          CopyableRow(
            label: isRtl ? 'رقم المنتج' : 'Product ID',
            value: productId,
            labelWidth: 90,
          ),
          CopyableRow(
            label: isRtl ? 'المخزون' : 'Stock',
            value: stock.toString(),
            labelWidth: 90,
          ),
          if (categoryName.isNotEmpty)
            CopyableRow(
              label: isRtl ? 'التصنيف' : 'Category',
              value: categoryName,
              labelWidth: 90,
            ),
          if (merchantName.isNotEmpty)
            CopyableRow(
              label: isRtl ? 'التاجر' : 'Merchant',
              value: merchantName,
              labelWidth: 90,
            ),
          if (merchantId.toString().isNotEmpty)
            CopyableRow(
              label: 'Merchant ID',
              value: merchantId.toString(),
              labelWidth: 90,
            ),
          if (description.isNotEmpty)
            CopyableRow(
              label: isRtl ? 'الوصف' : 'Description',
              value: description,
              labelWidth: 90,
            ),
          if (suspensionReason != null && suspensionReason.isNotEmpty)
            CopyableRow(
              label: isRtl ? 'سبب الإيقاف' : 'Suspension',
              value: suspensionReason,
              labelWidth: 90,
            ),
        ],
      ),
    );
  }
}

class _ProductActions extends StatelessWidget {
  final Map<String, dynamic> product;
  final bool isRtl;
  final bool isActive;
  final bool isSuspended;
  final Function(String action) onAction;

  const _ProductActions({
    required this.product,
    required this.isRtl,
    required this.isActive,
    required this.isSuspended,
    required this.onAction,
  });

  @override
  Widget build(BuildContext context) {
    return Wrap(
      spacing: 8,
      runSpacing: 8,
      children: [
        if (isSuspended)
          _ActionBtn(
            label: isRtl ? 'إلغاء الإيقاف' : 'Unsuspend',
            icon: Icons.check_circle,
            color: Colors.green,
            onTap: () {
              debugPrint('🔓 Unsuspend product: ${product['id']}');
              onAction('unsuspend');
            },
          )
        else
          _ActionBtn(
            label: isRtl ? 'إيقاف' : 'Suspend',
            icon: Icons.block,
            color: Colors.red,
            onTap: () {
              debugPrint('🚫 Suspend product: ${product['id']}');
              onAction('suspend');
            },
          ),
        _ActionBtn(
          label: isRtl ? 'حذف' : 'Delete',
          icon: Icons.delete,
          color: Colors.red,
          onTap: () {
            debugPrint('🗑️ Delete product: ${product['id']}');
            onAction('delete');
          },
        ),
      ],
    );
  }
}

class _ActionBtn extends StatelessWidget {
  final String label;
  final IconData icon;
  final VoidCallback onTap;
  final Color? color;

  const _ActionBtn({
    required this.label,
    required this.icon,
    required this.onTap,
    this.color,
  });

  @override
  Widget build(BuildContext context) {
    return OutlinedButton.icon(
      onPressed: onTap,
      icon: Icon(icon, size: 14, color: color),
      label: Text(label, style: TextStyle(fontSize: 11, color: color)),
      style: color != null
          ? OutlinedButton.styleFrom(side: BorderSide(color: color!))
          : null,
    );
  }
}
