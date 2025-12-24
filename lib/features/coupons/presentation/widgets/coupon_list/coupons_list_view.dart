import 'package:flutter/material.dart';
import '../../../domain/entities/coupon_entity.dart';
import 'coupon_card.dart';

class CouponsListView extends StatelessWidget {
  final List<CouponEntity> coupons;
  final String storeId;
  final Function(CouponEntity) onEdit;
  final Function(CouponEntity, bool) onToggle;
  final VoidCallback onRefresh;

  const CouponsListView({
    super.key,
    required this.coupons,
    required this.storeId,
    required this.onEdit,
    required this.onToggle,
    required this.onRefresh,
  });

  @override
  Widget build(BuildContext context) {
    return RefreshIndicator(
      onRefresh: () async => onRefresh(),
      child: ListView.builder(
        padding: const EdgeInsets.all(16),
        itemCount: coupons.length,
        itemBuilder: (context, index) {
          final coupon = coupons[index];
          return CouponCard(
            coupon: coupon,
            onEdit: () => onEdit(coupon),
            onToggle: (value) => onToggle(coupon, value),
          );
        },
      ),
    );
  }
}
