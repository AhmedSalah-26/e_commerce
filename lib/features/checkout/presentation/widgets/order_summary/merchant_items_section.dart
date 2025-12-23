import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import '../../../../../core/theme/app_colors.dart';

class MerchantItemsSection extends StatelessWidget {
  final String? merchantId;
  final String merchantName;
  final List<dynamic> items;
  final double? merchantShipping;
  final bool isShippingUnavailable;
  final bool showMerchantHeader;

  const MerchantItemsSection({
    super.key,
    required this.merchantId,
    required this.merchantName,
    required this.items,
    required this.merchantShipping,
    required this.isShippingUnavailable,
    required this.showMerchantHeader,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        if (showMerchantHeader) ...[
          _MerchantHeader(
            merchantName: merchantName,
            merchantShipping: merchantShipping,
            isShippingUnavailable: isShippingUnavailable,
          ),
          const SizedBox(height: 8),
        ],
        ...items.map((item) => _OrderItemRow(item: item)),
        if (showMerchantHeader) const Divider(height: 16),
      ],
    );
  }
}

class _MerchantHeader extends StatelessWidget {
  final String merchantName;
  final double? merchantShipping;
  final bool isShippingUnavailable;

  const _MerchantHeader({
    required this.merchantName,
    required this.merchantShipping,
    required this.isShippingUnavailable,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 12),
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
            _UnavailableBadge()
          else
            Text(
              '${'shipping'.tr()}: ${merchantShipping?.toStringAsFixed(2) ?? '-'} ${'egp'.tr()}',
              style: TextStyle(fontSize: 11, color: Colors.grey.shade600),
            ),
        ],
      ),
    );
  }
}

class _UnavailableBadge extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
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
    );
  }
}

class _OrderItemRow extends StatelessWidget {
  final dynamic item;

  const _OrderItemRow({required this.item});

  @override
  Widget build(BuildContext context) {
    return Padding(
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
            style: const TextStyle(fontWeight: FontWeight.w500),
          ),
        ],
      ),
    );
  }
}
