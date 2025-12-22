import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../cart/presentation/cubit/cart_state.dart';

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

  /// Check if any merchant has unavailable shipping (null or 0)
  bool get hasUnavailableShipping {
    if (merchantShippingPrices == null || merchantShippingPrices!.isEmpty) {
      return false;
    }

    // Get all merchant IDs from cart
    final merchantIds = <String?>{};
    for (final item in cartState.items) {
      merchantIds.add(item.product?.merchantId);
    }

    // Check if any merchant has no shipping price set
    for (final merchantId in merchantIds) {
      if (merchantId != null) {
        final price = merchantShippingPrices![merchantId];
        // If price is null, merchant doesn't support shipping to this governorate
        if (price == null) {
          return true;
        }
      }
    }
    return false;
  }

  /// Get list of merchants with unavailable shipping
  List<String> get merchantsWithUnavailableShipping {
    final result = <String>[];
    if (merchantShippingPrices == null) return result;

    final Map<String?, String> merchantNames = {};
    for (final item in cartState.items) {
      final merchantId = item.product?.merchantId;
      if (merchantId != null && !merchantNames.containsKey(merchantId)) {
        merchantNames[merchantId] =
            item.product?.storeName ?? 'unknown_merchant'.tr();
      }
    }

    for (final entry in merchantNames.entries) {
      final merchantId = entry.key;
      if (merchantId != null) {
        final price = merchantShippingPrices![merchantId];
        if (price == null) {
          result.add(entry.value);
        }
      }
    }
    return result;
  }

  @override
  Widget build(BuildContext context) {
    // Group items by merchant
    final Map<String?, List<dynamic>> itemsByMerchant = {};
    final Map<String?, String> merchantNames = {};

    for (final item in cartState.items) {
      final merchantId = item.product?.merchantId;
      final merchantName = item.product?.storeName ?? 'unknown_merchant'.tr();

      if (!itemsByMerchant.containsKey(merchantId)) {
        itemsByMerchant[merchantId] = [];
        merchantNames[merchantId] = merchantName;
      }
      itemsByMerchant[merchantId]!.add(item);
    }

    // Calculate total shipping (only for merchants with available shipping)
    double totalShipping = 0;
    if (merchantShippingPrices != null && merchantShippingPrices!.isNotEmpty) {
      for (final merchantId in itemsByMerchant.keys) {
        if (merchantId != null) {
          final price = merchantShippingPrices![merchantId];
          if (price != null) {
            totalShipping += price;
          }
        }
      }
    } else {
      // Fallback: use single shipping price * merchant count
      totalShipping = shippingPrice * itemsByMerchant.length;
    }

    final total = cartState.total + totalShipping;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'order_summary'.tr(),
          style: const TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
            color: AppColours.brownMedium,
          ),
        ),
        const SizedBox(height: 12),
        Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: Colors.grey.shade100,
            borderRadius: BorderRadius.circular(12),
          ),
          child: Column(
            children: [
              // Show items grouped by merchant
              ...itemsByMerchant.entries.map((entry) {
                final merchantId = entry.key;
                final items = entry.value;
                final merchantName = merchantNames[merchantId] ?? '';

                // Check if shipping is available for this merchant
                final hasShippingPrice = merchantId != null &&
                    merchantShippingPrices != null &&
                    merchantShippingPrices!.containsKey(merchantId);
                final merchantShipping = hasShippingPrice
                    ? merchantShippingPrices![merchantId]!
                    : null;
                final isShippingUnavailable = merchantShippingPrices != null &&
                    merchantShippingPrices!.isNotEmpty &&
                    merchantShipping == null;

                return Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Merchant header
                    if (itemsByMerchant.length > 1) ...[
                      Container(
                        padding: const EdgeInsets.symmetric(
                            vertical: 8, horizontal: 12),
                        decoration: BoxDecoration(
                          color: isShippingUnavailable
                              ? Colors.red.shade50
                              : AppColours.brownLight.withValues(alpha: 0.1),
                          borderRadius: BorderRadius.circular(8),
                          border: isShippingUnavailable
                              ? Border.all(color: Colors.red.shade200)
                              : null,
                        ),
                        child: Row(
                          children: [
                            Icon(
                              Icons.store_outlined,
                              size: 16,
                              color: isShippingUnavailable
                                  ? Colors.red.shade700
                                  : AppColours.brownMedium,
                            ),
                            const SizedBox(width: 8),
                            Expanded(
                              child: Text(
                                merchantName,
                                style: TextStyle(
                                  fontWeight: FontWeight.w600,
                                  color: isShippingUnavailable
                                      ? Colors.red.shade700
                                      : AppColours.brownMedium,
                                  fontSize: 13,
                                ),
                              ),
                            ),
                            if (isShippingUnavailable)
                              Container(
                                padding: const EdgeInsets.symmetric(
                                    horizontal: 8, vertical: 2),
                                decoration: BoxDecoration(
                                  color: Colors.red.shade100,
                                  borderRadius: BorderRadius.circular(4),
                                ),
                                child: Text(
                                  'shipping_unavailable'.tr(),
                                  style: TextStyle(
                                    fontSize: 10,
                                    fontWeight: FontWeight.w600,
                                    color: Colors.red.shade700,
                                  ),
                                ),
                              )
                            else
                              Text(
                                '${'shipping'.tr()}: ${merchantShipping?.toStringAsFixed(2) ?? '-'} ${'egp'.tr()}',
                                style: TextStyle(
                                  fontSize: 11,
                                  color: Colors.grey.shade600,
                                ),
                              ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 8),
                    ],
                    // Items
                    ...items.map((item) => Padding(
                          padding: const EdgeInsets.symmetric(vertical: 6),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Expanded(
                                child: Text(
                                  '${item.product?.name ?? 'منتج'} x${item.quantity}',
                                  style: const TextStyle(fontSize: 14),
                                  overflow: TextOverflow.ellipsis,
                                ),
                              ),
                              Text(
                                '${item.itemTotal.toStringAsFixed(2)} ${'egp'.tr()}',
                                style: const TextStyle(
                                    fontWeight: FontWeight.w500),
                              ),
                            ],
                          ),
                        )),
                    if (itemsByMerchant.length > 1) const Divider(height: 16),
                  ],
                );
              }),
              if (itemsByMerchant.length <= 1) const Divider(),
              // Subtotal
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text('subtotal'.tr()),
                  Text('${cartState.total.toStringAsFixed(2)} ${'egp'.tr()}'),
                ],
              ),
              const SizedBox(height: 8),
              // Shipping
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Row(
                    children: [
                      Text('shipping_cost'.tr()),
                      if (itemsByMerchant.length > 1) ...[
                        const SizedBox(width: 4),
                        Text(
                          '(${itemsByMerchant.length} ${'merchants'.tr()})',
                          style: TextStyle(
                            fontSize: 12,
                            color: Colors.grey.shade600,
                          ),
                        ),
                      ],
                    ],
                  ),
                  Text(
                    totalShipping > 0
                        ? '${totalShipping.toStringAsFixed(2)} ${'egp'.tr()}'
                        : '-',
                    style: TextStyle(
                      color: totalShipping > 0 ? null : Colors.grey,
                    ),
                  ),
                ],
              ),
              const Divider(),
              // Total
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'total'.tr(),
                    style: const TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  Text(
                    '${total.toStringAsFixed(2)} ${'egp'.tr()}',
                    style: const TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: AppColours.brownMedium,
                    ),
                  ),
                ],
              ),
              // Warning if shipping unavailable
              if (hasUnavailableShipping) ...[
                const SizedBox(height: 12),
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: Colors.red.shade50,
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(color: Colors.red.shade200),
                  ),
                  child: Row(
                    children: [
                      Icon(Icons.warning_amber_rounded,
                          color: Colors.red.shade700, size: 20),
                      const SizedBox(width: 8),
                      Expanded(
                        child: Text(
                          'shipping_not_supported'.tr(),
                          style: TextStyle(
                            color: Colors.red.shade700,
                            fontSize: 12,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ],
          ),
        ),
      ],
    );
  }
}
