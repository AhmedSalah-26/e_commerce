import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:intl/intl.dart';

class MerchantCouponCard extends StatelessWidget {
  final Map<String, dynamic> coupon;
  final bool isRtl;
  final VoidCallback onToggle;
  final VoidCallback onSuspend;
  final VoidCallback onTap;

  const MerchantCouponCard({
    super.key,
    required this.coupon,
    required this.isRtl,
    required this.onToggle,
    required this.onSuspend,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    final code = coupon['code'] ?? '';
    final discountType = coupon['discount_type'] ?? 'percentage';
    final discountValue = (coupon['discount_value'] ?? 0).toDouble();
    final isActive = coupon['is_active'] ?? true;
    final isSuspended = coupon['is_suspended'] ?? false;
    final suspensionReason = coupon['suspension_reason'];

    final store = coupon['stores'] as Map<String, dynamic>?;
    final merchant = store?['profiles'] as Map<String, dynamic>?;
    final merchantName = merchant?['name'] ?? store?['name'] ?? '';
    final usageCount = coupon['usage_count'] ?? 0;
    final usageLimit = coupon['usage_limit'];
    final expiresAt = coupon['expires_at'];

    final isExpired = expiresAt != null &&
        DateTime.tryParse(expiresAt)?.isBefore(DateTime.now()) == true;

    final statusInfo = _getStatusInfo(isSuspended, isActive, isExpired);

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        color: isDark ? theme.colorScheme.surfaceContainerHigh : Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: isSuspended
              ? Colors.red.withValues(alpha: 0.4)
              : (isDark
                  ? Colors.white12
                  : Colors.black.withValues(alpha: 0.06)),
          width: isSuspended ? 1.5 : 1,
        ),
        boxShadow: isDark
            ? null
            : [
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.05),
                  blurRadius: 10,
                  offset: const Offset(0, 2),
                ),
              ],
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(16),
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    _buildDiscountBadge(
                        theme, discountType, discountValue, isSuspended),
                    const SizedBox(width: 12),
                    Expanded(
                      child: _buildCodeAndMerchant(
                        context,
                        theme,
                        code,
                        merchantName,
                        isSuspended,
                        isDark,
                      ),
                    ),
                    _buildMenu(theme, isActive, isSuspended),
                  ],
                ),
                const SizedBox(height: 12),
                _buildStatsRow(
                  theme,
                  statusInfo,
                  usageCount,
                  usageLimit,
                  expiresAt,
                  isExpired,
                  isDark,
                ),
                if (isSuspended && suspensionReason != null)
                  _buildSuspensionReason(suspensionReason),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildDiscountBadge(
    ThemeData theme,
    String discountType,
    double discountValue,
    bool isSuspended,
  ) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: isSuspended
              ? [Colors.grey.shade500, Colors.grey.shade600]
              : [
                  theme.colorScheme.primary,
                  theme.colorScheme.primary.withValues(alpha: 0.85)
                ],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(12),
        boxShadow: isSuspended
            ? null
            : [
                BoxShadow(
                  color: theme.colorScheme.primary.withValues(alpha: 0.3),
                  blurRadius: 8,
                  offset: const Offset(0, 2),
                ),
              ],
      ),
      child: Text(
        discountType == 'percentage'
            ? '${discountValue.toStringAsFixed(0)}%'
            : '${discountValue.toStringAsFixed(0)} ${isRtl ? 'ج.م' : 'EGP'}',
        style: const TextStyle(
          color: Colors.white,
          fontWeight: FontWeight.bold,
          fontSize: 16,
        ),
      ),
    );
  }

  Widget _buildCodeAndMerchant(
    BuildContext context,
    ThemeData theme,
    String code,
    String merchantName,
    bool isSuspended,
    bool isDark,
  ) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Expanded(
              child: Text(
                code,
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 18,
                  letterSpacing: 1.2,
                  decoration: isSuspended ? TextDecoration.lineThrough : null,
                  color: isSuspended
                      ? Colors.grey
                      : (isDark ? Colors.white : Colors.black87),
                ),
              ),
            ),
            _buildCopyButton(context, code, theme),
          ],
        ),
        if (merchantName.isNotEmpty) ...[
          const SizedBox(height: 4),
          Row(
            children: [
              Icon(
                Icons.store_rounded,
                size: 14,
                color: isDark ? Colors.white60 : Colors.black54,
              ),
              const SizedBox(width: 4),
              Expanded(
                child: Text(
                  merchantName,
                  style: TextStyle(
                    fontSize: 13,
                    color: isDark ? Colors.white60 : Colors.black54,
                  ),
                  overflow: TextOverflow.ellipsis,
                ),
              ),
            ],
          ),
        ],
      ],
    );
  }

  Widget _buildCopyButton(BuildContext context, String code, ThemeData theme) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        borderRadius: BorderRadius.circular(8),
        onTap: () {
          Clipboard.setData(ClipboardData(text: code));
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(isRtl ? 'تم النسخ' : 'Copied!'),
              duration: const Duration(seconds: 1),
              behavior: SnackBarBehavior.floating,
            ),
          );
        },
        child: Padding(
          padding: const EdgeInsets.all(6),
          child: Icon(
            Icons.copy_rounded,
            size: 18,
            color: theme.colorScheme.primary.withValues(alpha: 0.7),
          ),
        ),
      ),
    );
  }

  Widget _buildMenu(ThemeData theme, bool isActive, bool isSuspended) {
    return PopupMenuButton<String>(
      icon: Icon(Icons.more_vert, color: theme.colorScheme.outline),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      onSelected: (value) {
        if (value == 'toggle') onToggle();
        if (value == 'suspend') onSuspend();
      },
      itemBuilder: (_) => [
        PopupMenuItem(
          value: 'toggle',
          child: Row(
            children: [
              Icon(
                isActive
                    ? Icons.visibility_off_rounded
                    : Icons.visibility_rounded,
                size: 20,
                color: isActive ? Colors.orange : Colors.green,
              ),
              const SizedBox(width: 12),
              Text(isActive
                  ? (isRtl ? 'تعطيل' : 'Deactivate')
                  : (isRtl ? 'تفعيل' : 'Activate')),
            ],
          ),
        ),
        PopupMenuItem(
          value: 'suspend',
          child: Row(
            children: [
              Icon(
                isSuspended ? Icons.check_circle_rounded : Icons.block_rounded,
                size: 20,
                color: isSuspended ? Colors.green : Colors.red,
              ),
              const SizedBox(width: 12),
              Text(
                isSuspended
                    ? (isRtl ? 'إلغاء الإيقاف' : 'Unsuspend')
                    : (isRtl ? 'إيقاف' : 'Suspend'),
                style:
                    TextStyle(color: isSuspended ? Colors.green : Colors.red),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildStatsRow(
    ThemeData theme,
    _StatusInfo statusInfo,
    int usageCount,
    int? usageLimit,
    String? expiresAt,
    bool isExpired,
    bool isDark,
  ) {
    return Wrap(
      spacing: 8,
      runSpacing: 8,
      children: [
        _StatusChip(
          icon: statusInfo.icon,
          label: statusInfo.label,
          color: statusInfo.color,
          isDark: isDark,
        ),
        _StatusChip(
          icon: Icons.people_outline_rounded,
          label: '$usageCount${usageLimit != null ? '/$usageLimit' : ''}',
          color: isDark ? Colors.white70 : Colors.black54,
          isDark: isDark,
        ),
        if (expiresAt != null)
          _StatusChip(
            icon: Icons.event_rounded,
            label: DateFormat('dd/MM').format(DateTime.parse(expiresAt)),
            color: isExpired
                ? Colors.red
                : (isDark ? Colors.white70 : Colors.black54),
            isDark: isDark,
          ),
      ],
    );
  }

  Widget _buildSuspensionReason(String reason) {
    return Container(
      margin: const EdgeInsets.only(top: 12),
      width: double.infinity,
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.red.withValues(alpha: 0.08),
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: Colors.red.withValues(alpha: 0.2)),
      ),
      child: Row(
        children: [
          const Icon(Icons.warning_amber_rounded, size: 18, color: Colors.red),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              reason,
              style: const TextStyle(fontSize: 13, color: Colors.red),
            ),
          ),
        ],
      ),
    );
  }

  _StatusInfo _getStatusInfo(bool isSuspended, bool isActive, bool isExpired) {
    if (isSuspended) {
      return _StatusInfo(
        icon: Icons.block_rounded,
        label: isRtl ? 'موقوف' : 'Suspended',
        color: Colors.red,
      );
    } else if (!isActive) {
      return _StatusInfo(
        icon: Icons.pause_circle_rounded,
        label: isRtl ? 'معطل' : 'Inactive',
        color: Colors.orange,
      );
    } else if (isExpired) {
      return _StatusInfo(
        icon: Icons.timer_off_rounded,
        label: isRtl ? 'منتهي' : 'Expired',
        color: Colors.grey,
      );
    }
    return _StatusInfo(
      icon: Icons.check_circle_rounded,
      label: isRtl ? 'نشط' : 'Active',
      color: Colors.green,
    );
  }
}

class _StatusInfo {
  final IconData icon;
  final String label;
  final Color color;
  _StatusInfo({required this.icon, required this.label, required this.color});
}

class _StatusChip extends StatelessWidget {
  final IconData icon;
  final String label;
  final Color color;
  final bool isDark;

  const _StatusChip({
    required this.icon,
    required this.label,
    required this.color,
    required this.isDark,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(
        color: color.withValues(alpha: isDark ? 0.2 : 0.1),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 14, color: color),
          const SizedBox(width: 4),
          Text(
            label,
            style: TextStyle(
                fontSize: 12, fontWeight: FontWeight.w600, color: color),
          ),
        ],
      ),
    );
  }
}
