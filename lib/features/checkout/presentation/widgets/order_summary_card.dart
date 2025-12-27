import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../cart/presentation/cubit/cart_state.dart';
import '../../../coupons/presentation/cubit/coupon_cubit.dart';
import '../../../coupons/presentation/cubit/coupon_state.dart';
import 'order_summary/merchant_items_section.dart';
import 'order_summary/order_totals_section.dart';
import 'order_summary/shipping_warning.dart';

class OrderSummaryCard extends StatelessWidget {
  final CartLoaded cartState;
  final double shippingPrice;
  final Map<String, double>? merchantShippingPrices;

  const OrderSummaryCard({
    super.key,
    required this.cartState,
    required this.shippingPrice,
    this.merchantShippingPrices,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final groupedData = _groupItemsByMerchant();
    final totalShipping = _calculateTotalShipping(groupedData.merchantIds);

    return BlocBuilder<CouponCubit, CouponState>(
      builder: (context, couponState) {
        final appliedCoupon =
            couponState is CouponApplied ? couponState.result : null;
        final couponDiscount = appliedCoupon?.discountAmount ?? 0;
        final total = cartState.total + totalShipping - couponDiscount;

        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'order_summary'.tr(),
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: theme.colorScheme.primary,
              ),
            ),
            const SizedBox(height: 12),
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: theme.scaffoldBackgroundColor,
                borderRadius: BorderRadius.circular(12),
              ),
              child: Column(
                children: [
                  // Merchant sections
                  ...groupedData.itemsByMerchant.entries.map((entry) {
                    final merchantId = entry.key;
                    final items = entry.value;
                    final merchantName =
                        groupedData.merchantNames[merchantId] ?? '';
                    final merchantShipping = _getMerchantShipping(merchantId);
                    final isUnavailable = _isShippingUnavailable(merchantId);

                    return MerchantItemsSection(
                      merchantId: merchantId,
                      merchantName: merchantName,
                      items: items,
                      merchantShipping: merchantShipping,
                      isShippingUnavailable: isUnavailable,
                      showMerchantHeader:
                          groupedData.itemsByMerchant.length > 1,
                    );
                  }),
                  // Totals with coupon
                  OrderTotalsSection(
                    subtotal: cartState.total,
                    totalShipping: totalShipping,
                    couponDiscount: couponDiscount,
                    couponCode: appliedCoupon?.code,
                    total: total,
                    merchantCount: groupedData.itemsByMerchant.length,
                  ),
                  // Warning
                  if (_hasUnavailableShipping(groupedData.merchantIds)) ...[
                    const SizedBox(height: 12),
                    const ShippingWarning(),
                  ],
                ],
              ),
            ),
          ],
        );
      },
    );
  }

  _GroupedData _groupItemsByMerchant() {
    final Map<String?, List<dynamic>> itemsByMerchant = {};
    final Map<String?, String> merchantNames = {};
    final Set<String?> merchantIds = {};

    for (final item in cartState.items) {
      final merchantId = item.product?.merchantId;
      final merchantName = item.product?.storeName ?? 'unknown_merchant'.tr();

      if (!itemsByMerchant.containsKey(merchantId)) {
        itemsByMerchant[merchantId] = [];
        merchantNames[merchantId] = merchantName;
      }
      itemsByMerchant[merchantId]!.add(item);
      merchantIds.add(merchantId);
    }

    return _GroupedData(
      itemsByMerchant: itemsByMerchant,
      merchantNames: merchantNames,
      merchantIds: merchantIds,
    );
  }

  double _calculateTotalShipping(Set<String?> merchantIds) {
    if (merchantShippingPrices != null && merchantShippingPrices!.isNotEmpty) {
      double total = 0;
      for (final merchantId in merchantIds) {
        if (merchantId != null) {
          final price = merchantShippingPrices![merchantId];
          if (price != null) total += price;
        }
      }
      return total;
    }
    return shippingPrice * merchantIds.length;
  }

  double? _getMerchantShipping(String? merchantId) {
    if (merchantId == null || merchantShippingPrices == null) return null;
    return merchantShippingPrices![merchantId];
  }

  bool _isShippingUnavailable(String? merchantId) {
    if (merchantShippingPrices == null || merchantShippingPrices!.isEmpty) {
      return false;
    }
    return merchantId != null &&
        !merchantShippingPrices!.containsKey(merchantId);
  }

  bool _hasUnavailableShipping(Set<String?> merchantIds) {
    if (merchantShippingPrices == null || merchantShippingPrices!.isEmpty) {
      return false;
    }
    for (final merchantId in merchantIds) {
      if (merchantId != null &&
          !merchantShippingPrices!.containsKey(merchantId)) {
        return true;
      }
    }
    return false;
  }
}

class _GroupedData {
  final Map<String?, List<dynamic>> itemsByMerchant;
  final Map<String?, String> merchantNames;
  final Set<String?> merchantIds;

  _GroupedData({
    required this.itemsByMerchant,
    required this.merchantNames,
    required this.merchantIds,
  });
}
