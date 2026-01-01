import 'package:flutter/material.dart';

import '../../widgets/merchant_coupon_card.dart';

class CouponsList extends StatelessWidget {
  final List<Map<String, dynamic>> coupons;
  final bool hasMore;
  final ScrollController scrollController;
  final bool isRtl;
  final Future<void> Function() onRefresh;
  final Future<void> Function(Map<String, dynamic>) onToggle;
  final Future<void> Function(Map<String, dynamic>) onSuspend;
  final void Function(Map<String, dynamic>) onTap;

  const CouponsList({
    super.key,
    required this.coupons,
    required this.hasMore,
    required this.scrollController,
    required this.isRtl,
    required this.onRefresh,
    required this.onToggle,
    required this.onSuspend,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return RefreshIndicator(
      onRefresh: onRefresh,
      child: ListView.builder(
        controller: scrollController,
        padding: const EdgeInsets.symmetric(horizontal: 16),
        itemCount: coupons.length + (hasMore ? 1 : 0),
        itemBuilder: (context, index) {
          if (index == coupons.length) {
            return const Center(
                child: Padding(
                    padding: EdgeInsets.all(16),
                    child: CircularProgressIndicator()));
          }
          return MerchantCouponCard(
            coupon: coupons[index],
            isRtl: isRtl,
            onToggle: () => onToggle(coupons[index]),
            onSuspend: () => onSuspend(coupons[index]),
            onTap: () => onTap(coupons[index]),
          );
        },
      ),
    );
  }
}
