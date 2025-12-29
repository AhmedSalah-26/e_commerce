import 'package:flutter/material.dart';

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
    final suspensionReason = product['suspension_reason'];
    final name =
        isRtl ? (product['name_ar'] ?? product['name']) : product['name'];
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
            leading: _buildImage(imageUrl, isSuspended),
            title: Text(
              name ?? '',
              style: TextStyle(
                fontSize: isMobile ? 13 : 14,
                decoration: isSuspended ? TextDecoration.lineThrough : null,
              ),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
            subtitle: _buildSubtitle(theme, price, stock, merchantName),
            trailing: _buildTrailing(isActive, isSuspended),
          ),
          if (isSuspended && suspensionReason != null)
            _buildSuspensionBanner(suspensionReason),
        ],
      ),
    );
  }

  Widget _buildImage(String? imageUrl, bool isSuspended) {
    final size = isMobile ? 50.0 : 60.0;
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
              child: const Icon(Icons.block, color: Colors.white),
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

  Widget _buildSubtitle(
      ThemeData theme, double price, int stock, String merchantName) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          '${price.toStringAsFixed(0)} ${isRtl ? 'ج.م' : 'EGP'}',
          style: TextStyle(
            color: theme.colorScheme.primary,
            fontWeight: FontWeight.bold,
            fontSize: isMobile ? 12 : 13,
          ),
        ),
        Row(
          children: [
            Text('${isRtl ? 'المخزون:' : 'Stock:'} $stock',
                style: TextStyle(fontSize: isMobile ? 11 : 12)),
            if (merchantName.isNotEmpty) ...[
              const Text(' • '),
              Expanded(
                child: Text(
                  merchantName,
                  style: TextStyle(
                      fontSize: isMobile ? 10 : 11,
                      color: theme.colorScheme.outline),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
            ],
          ],
        ),
      ],
    );
  }

  Widget _buildTrailing(bool isActive, bool isSuspended) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        _statusBadge(isActive, isSuspended),
        PopupMenuButton<String>(
          itemBuilder: (_) => _buildMenuItems(isActive, isSuspended),
          onSelected: onAction,
        ),
      ],
    );
  }

  Widget _statusBadge(bool isActive, bool isSuspended) {
    final color =
        isSuspended ? Colors.red : (isActive ? Colors.green : Colors.orange);
    final text = isSuspended
        ? (isRtl ? 'موقوف' : 'Suspended')
        : isActive
            ? (isRtl ? 'نشط' : 'Active')
            : (isRtl ? 'معطل' : 'Inactive');

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Text(text, style: TextStyle(color: color, fontSize: 10)),
    );
  }

  List<PopupMenuEntry<String>> _buildMenuItems(
      bool isActive, bool isSuspended) {
    return [
      if (isSuspended)
        _menuItem('unsuspend', Icons.check_circle,
            isRtl ? 'إلغاء الإيقاف' : 'Unsuspend', Colors.green)
      else ...[
        _menuItem('suspend', Icons.block,
            isRtl ? 'إيقاف (مخالفة)' : 'Suspend (Violation)', Colors.red),
        _menuItem(
          'toggle',
          isActive ? Icons.visibility_off : Icons.visibility,
          isActive
              ? (isRtl ? 'تعطيل (تاجر)' : 'Deactivate (Merchant)')
              : (isRtl ? 'تفعيل' : 'Activate'),
        ),
      ],
      const PopupMenuDivider(),
      _menuItem('delete', Icons.delete, isRtl ? 'حذف' : 'Delete', Colors.red),
    ];
  }

  PopupMenuItem<String> _menuItem(String value, IconData icon, String text,
      [Color? color]) {
    return PopupMenuItem(
      value: value,
      child: Row(
        children: [
          Icon(icon, size: 18, color: color),
          const SizedBox(width: 8),
          Text(text, style: color != null ? TextStyle(color: color) : null),
        ],
      ),
    );
  }

  Widget _buildSuspensionBanner(String reason) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      decoration: BoxDecoration(
        color: Colors.red.withValues(alpha: 0.1),
        borderRadius: const BorderRadius.vertical(bottom: Radius.circular(12)),
      ),
      child: Row(
        children: [
          const Icon(Icons.warning, size: 16, color: Colors.red),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              '${isRtl ? 'سبب الإيقاف:' : 'Reason:'} $reason',
              style: const TextStyle(fontSize: 12, color: Colors.red),
            ),
          ),
        ],
      ),
    );
  }
}
