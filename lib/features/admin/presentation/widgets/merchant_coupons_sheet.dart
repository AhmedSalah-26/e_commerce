import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../cubit/admin_cubit.dart';

class MerchantCouponsSheet extends StatefulWidget {
  final String merchantId;
  final String merchantName;
  final bool isRtl;

  const MerchantCouponsSheet({
    super.key,
    required this.merchantId,
    required this.merchantName,
    required this.isRtl,
  });

  @override
  State<MerchantCouponsSheet> createState() => _MerchantCouponsSheetState();
}

class _MerchantCouponsSheetState extends State<MerchantCouponsSheet> {
  List<Map<String, dynamic>> _coupons = [];
  bool _loading = true;

  @override
  void initState() {
    super.initState();
    _loadCoupons();
  }

  Future<void> _loadCoupons() async {
    setState(() => _loading = true);
    final coupons =
        await context.read<AdminCubit>().getMerchantCoupons(widget.merchantId);
    if (mounted) {
      setState(() {
        _coupons = coupons;
        _loading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return DraggableScrollableSheet(
      initialChildSize: 0.7,
      minChildSize: 0.5,
      maxChildSize: 0.95,
      builder: (context, scrollController) => Container(
        decoration: BoxDecoration(
          color: theme.scaffoldBackgroundColor,
          borderRadius: const BorderRadius.vertical(top: Radius.circular(20)),
        ),
        child: Column(
          children: [
            _buildHeader(theme),
            if (_loading)
              const Expanded(child: Center(child: CircularProgressIndicator()))
            else if (_coupons.isEmpty)
              Expanded(
                child: Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Icon(Icons.local_offer_outlined,
                          size: 64, color: Colors.grey),
                      const SizedBox(height: 16),
                      Text(
                        widget.isRtl
                            ? 'لا توجد كوبونات لهذا التاجر'
                            : 'No coupons for this merchant',
                        style: const TextStyle(color: Colors.grey),
                      ),
                    ],
                  ),
                ),
              )
            else
              Expanded(
                child: ListView.builder(
                  controller: scrollController,
                  padding: const EdgeInsets.all(16),
                  itemCount: _coupons.length,
                  itemBuilder: (_, i) => _CouponCard(
                    coupon: _coupons[i],
                    isRtl: widget.isRtl,
                    onSuspend: () => _suspendCoupon(_coupons[i]),
                    onUnsuspend: () => _unsuspendCoupon(_coupons[i]),
                    onToggle: () => _toggleCoupon(_coupons[i]),
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildHeader(ThemeData theme) {
    final hasSuspended = _coupons.any((c) => c['is_suspended'] == true);
    final hasActive = _coupons.any((c) => c['is_suspended'] != true);

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        border: Border(bottom: BorderSide(color: theme.dividerColor)),
      ),
      child: Column(
        children: [
          Container(
            width: 40,
            height: 4,
            margin: const EdgeInsets.only(bottom: 16),
            decoration: BoxDecoration(
              color: Colors.grey[300],
              borderRadius: BorderRadius.circular(2),
            ),
          ),
          Row(
            children: [
              const Icon(Icons.local_offer, color: Colors.orange),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      widget.isRtl
                          ? 'كوبونات ${widget.merchantName}'
                          : '${widget.merchantName}\'s Coupons',
                      style: theme.textTheme.titleMedium
                          ?.copyWith(fontWeight: FontWeight.bold),
                    ),
                    Text(
                      '${_coupons.length} ${widget.isRtl ? 'كوبون' : 'coupons'}',
                      style: TextStyle(color: Colors.grey[600], fontSize: 12),
                    ),
                  ],
                ),
              ),
              if (_coupons.isNotEmpty) ...[
                if (hasActive)
                  TextButton.icon(
                    onPressed: _suspendAll,
                    icon: const Icon(Icons.block, size: 18, color: Colors.red),
                    label: Text(
                      widget.isRtl ? 'إيقاف الكل' : 'Suspend All',
                      style: const TextStyle(color: Colors.red, fontSize: 12),
                    ),
                  ),
                if (hasSuspended)
                  TextButton.icon(
                    onPressed: _unsuspendAll,
                    icon: const Icon(Icons.check_circle,
                        size: 18, color: Colors.green),
                    label: Text(
                      widget.isRtl ? 'تفعيل الكل' : 'Unsuspend All',
                      style: const TextStyle(color: Colors.green, fontSize: 12),
                    ),
                  ),
              ],
            ],
          ),
        ],
      ),
    );
  }

  Future<void> _suspendCoupon(Map<String, dynamic> coupon) async {
    final reason = await _showSuspendDialog();
    if (reason != null && mounted) {
      final ok =
          await context.read<AdminCubit>().suspendCoupon(coupon['id'], reason);
      if (ok && mounted) {
        _showSnack(widget.isRtl ? 'تم إيقاف الكوبون' : 'Coupon suspended');
        _loadCoupons();
      }
    }
  }

  Future<void> _unsuspendCoupon(Map<String, dynamic> coupon) async {
    final ok = await context.read<AdminCubit>().unsuspendCoupon(coupon['id']);
    if (ok && mounted) {
      _showSnack(widget.isRtl ? 'تم تفعيل الكوبون' : 'Coupon unsuspended');
      _loadCoupons();
    }
  }

  Future<void> _toggleCoupon(Map<String, dynamic> coupon) async {
    final isActive = coupon['is_active'] ?? false;
    final ok = await context
        .read<AdminCubit>()
        .toggleCouponStatus(coupon['id'], !isActive);
    if (ok && mounted) {
      _showSnack(widget.isRtl ? 'تم التحديث' : 'Updated');
      _loadCoupons();
    }
  }

  Future<void> _suspendAll() async {
    final reason = await _showSuspendDialog(isAll: true);
    if (reason != null && mounted) {
      final ok = await context
          .read<AdminCubit>()
          .suspendAllMerchantCoupons(widget.merchantId, reason);
      if (ok && mounted) {
        _showSnack(
            widget.isRtl ? 'تم إيقاف جميع الكوبونات' : 'All coupons suspended');
        _loadCoupons();
      }
    }
  }

  Future<void> _unsuspendAll() async {
    final ok = await context
        .read<AdminCubit>()
        .unsuspendAllMerchantCoupons(widget.merchantId);
    if (ok && mounted) {
      _showSnack(
          widget.isRtl ? 'تم تفعيل جميع الكوبونات' : 'All coupons unsuspended');
      _loadCoupons();
    }
  }

  Future<String?> _showSuspendDialog({bool isAll = false}) async {
    final controller = TextEditingController();
    return showDialog<String>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Row(
          children: [
            const Icon(Icons.block, color: Colors.red),
            const SizedBox(width: 8),
            Text(widget.isRtl
                ? (isAll ? 'إيقاف جميع الكوبونات' : 'إيقاف الكوبون')
                : (isAll ? 'Suspend All Coupons' : 'Suspend Coupon')),
          ],
        ),
        content: TextField(
          controller: controller,
          decoration: InputDecoration(
            labelText: widget.isRtl ? 'سبب الإيقاف' : 'Suspension Reason',
            border: const OutlineInputBorder(),
          ),
          maxLines: 2,
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: Text(widget.isRtl ? 'إلغاء' : 'Cancel'),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
            onPressed: () {
              if (controller.text.trim().isNotEmpty) {
                Navigator.pop(ctx, controller.text.trim());
              }
            },
            child: Text(
              widget.isRtl ? 'إيقاف' : 'Suspend',
              style: const TextStyle(color: Colors.white),
            ),
          ),
        ],
      ),
    );
  }

  void _showSnack(String msg) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(msg), backgroundColor: Colors.green),
    );
  }
}

class _CouponCard extends StatelessWidget {
  final Map<String, dynamic> coupon;
  final bool isRtl;
  final VoidCallback onSuspend;
  final VoidCallback onUnsuspend;
  final VoidCallback onToggle;

  const _CouponCard({
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
            Row(
              children: [
                Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
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
                  padding:
                      const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
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
            ),
            const SizedBox(height: 12),
            Row(
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
            ),
            if (isSuspended && suspensionReason != null) ...[
              const SizedBox(height: 8),
              Container(
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
                        suspensionReason,
                        style: const TextStyle(color: Colors.red, fontSize: 12),
                      ),
                    ),
                  ],
                ),
              ),
            ],
            const SizedBox(height: 12),
            Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                if (isSuspended)
                  TextButton.icon(
                    onPressed: onUnsuspend,
                    icon: const Icon(Icons.check_circle,
                        size: 18, color: Colors.green),
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
                      style: TextStyle(
                          color: isActive ? Colors.orange : Colors.green),
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
            ),
          ],
        ),
      ),
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
