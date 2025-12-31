import 'package:flutter/material.dart';

class SheetCouponCard extends StatelessWidget {
  final Map<String, dynamic> coupon;
  final bool isRtl;
  final VoidCallback onSuspend;
  final VoidCallback onUnsuspend;
  final VoidCallback onToggle;

  const SheetCouponCard({
    super.key,
    required this.coupon,
    required this.isRtl,
    required this.onSuspend,
    required this.onUnsuspend,
    required this.onToggle,
  });

  @override
  Widget build(BuildContext context) {
    final code = coupon['code'] ?? '';
    final discountType = coupon['discount_type'] ?? 'percentage';
    final discountValue = (coupon['discount_value'] ?? 0).toDouble();
    final isActive = coupon['is_active'] ?? false;
    final isSuspended = coupon['is_suspended'] ?? false;
    final suspensionReason = coupon['suspension_reason'];
    final usageCount = coupon['usage_count'] ?? 0;
    final maxUsage = coupon['max_usage'];

    final discountText = discountType == 'percentage'
        ? '${discountValue.toStringAsFixed(0)}%'
        : '${discountValue.toStringAsFixed(0)} ${isRtl ? 'ج.م' : 'EGP'}';

    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      color: isSuspended ? Colors.red.withValues(alpha: 0.05) : null,
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildHeader(code, discountText, isActive, isSuspended),
            const SizedBox(height: 12),
            _buildUsageInfo(usageCount, maxUsage),
            if (isSuspended && suspensionReason != null)
              _buildSuspensionReason(suspensionReason),
            const SizedBox(height: 12),
            _buildActions(isActive, isSuspended),
          ],
        ),
      ),
    );
  }

  Widget _buildHeader(
      String code, String discountText, bool isActive, bool isSuspended) {
    return Row(
      children: [
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
          decoration: BoxDecoration(
            color: isSuspended
                ? Colors.red.withValues(alpha: 0.1)
                : Colors.orange.withValues(alpha: 0.1),
            borderRadius: BorderRadius.circular(8),
          ),
          child: Text(
            code,
            style: TextStyle(
              fontWeight: FontWeight.bold,
              color: isSuspended ? Colors.red : Colors.orange,
              fontSize: 16,
            ),
          ),
        ),
        const SizedBox(width: 12),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
          decoration: BoxDecoration(
            color: Colors.green.withValues(alpha: 0.1),
            borderRadius: BorderRadius.circular(6),
          ),
          child: Text(
            discountText,
            style: const TextStyle(
              color: Colors.green,
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
        const Spacer(),
        _buildStatusChip(isActive, isSuspended),
      ],
    );
  }

  Widget _buildUsageInfo(int usageCount, int? maxUsage) {
    return Row(
      children: [
        Icon(Icons.people, size: 16, color: Colors.grey[600]),
        const SizedBox(width: 4),
        Text(
          maxUsage != null
              ? '$usageCount / $maxUsage'
              : '$usageCount ${isRtl ? 'استخدام' : 'uses'}',
          style: TextStyle(color: Colors.grey[600], fontSize: 12),
        ),
        if (coupon['min_order_amount'] != null) ...[
          const SizedBox(width: 16),
          Icon(Icons.shopping_cart, size: 16, color: Colors.grey[600]),
          const SizedBox(width: 4),
          Text(
            '${isRtl ? 'الحد الأدنى' : 'Min'}: ${coupon['min_order_amount']}',
            style: TextStyle(color: Colors.grey[600], fontSize: 12),
          ),
        ],
      ],
    );
  }

  Widget _buildSuspensionReason(String reason) {
    return Padding(
      padding: const EdgeInsets.only(top: 8),
      child: Container(
        padding: const EdgeInsets.all(8),
        decoration: BoxDecoration(
          color: Colors.red.withValues(alpha: 0.1),
          borderRadius: BorderRadius.circular(8),
        ),
        child: Row(
          children: [
            const Icon(Icons.warning, size: 16, color: Colors.red),
            const SizedBox(width: 8),
            Expanded(
              child: Text(
                reason,
                style: const TextStyle(color: Colors.red, fontSize: 12),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildActions(bool isActive, bool isSuspended) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.end,
      children: [
        if (isSuspended)
          TextButton.icon(
            onPressed: onUnsuspend,
            icon: const Icon(Icons.check_circle, size: 18, color: Colors.green),
            label: Text(
              isRtl ? 'إلغاء الإيقاف' : 'Unsuspend',
              style: const TextStyle(color: Colors.green),
            ),
          )
        else ...[
          TextButton.icon(
            onPressed: onToggle,
            icon: Icon(
              isActive ? Icons.pause : Icons.play_arrow,
              size: 18,
              color: isActive ? Colors.orange : Colors.green,
            ),
            label: Text(
              isActive
                  ? (isRtl ? 'تعطيل' : 'Disable')
                  : (isRtl ? 'تفعيل' : 'Enable'),
              style: TextStyle(color: isActive ? Colors.orange : Colors.green),
            ),
          ),
          TextButton.icon(
            onPressed: onSuspend,
            icon: const Icon(Icons.block, size: 18, color: Colors.red),
            label: Text(
              isRtl ? 'إيقاف' : 'Suspend',
              style: const TextStyle(color: Colors.red),
            ),
          ),
        ],
      ],
    );
  }

  Widget _buildStatusChip(bool isActive, bool isSuspended) {
    if (isSuspended) {
      return Container(
        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
        decoration: BoxDecoration(
          color: Colors.red,
          borderRadius: BorderRadius.circular(12),
        ),
        child: Text(
          isRtl ? 'موقوف' : 'Suspended',
          style: const TextStyle(color: Colors.white, fontSize: 11),
        ),
      );
    }
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: isActive ? Colors.green : Colors.grey,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Text(
        isActive ? (isRtl ? 'نشط' : 'Active') : (isRtl ? 'معطل' : 'Inactive'),
        style: const TextStyle(color: Colors.white, fontSize: 11),
      ),
    );
  }
}
