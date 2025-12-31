import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../cubit/admin_cubit.dart';
import 'coupons/coupon_sheet_header.dart';
import 'coupons/sheet_coupon_card.dart';

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
    final hasSuspended = _coupons.any((c) => c['is_suspended'] == true);
    final hasActive = _coupons.any((c) => c['is_suspended'] != true);

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
            CouponSheetHeader(
              merchantName: widget.merchantName,
              couponCount: _coupons.length,
              isRtl: widget.isRtl,
              hasActive: hasActive,
              hasSuspended: hasSuspended,
              onSuspendAll: _suspendAll,
              onUnsuspendAll: _unsuspendAll,
            ),
            if (_loading)
              const Expanded(child: Center(child: CircularProgressIndicator()))
            else if (_coupons.isEmpty)
              _buildEmptyState()
            else
              Expanded(
                child: ListView.builder(
                  controller: scrollController,
                  padding: const EdgeInsets.all(16),
                  itemCount: _coupons.length,
                  itemBuilder: (_, i) => SheetCouponCard(
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

  Widget _buildEmptyState() {
    return Expanded(
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
