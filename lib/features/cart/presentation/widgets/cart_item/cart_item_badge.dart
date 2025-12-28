import 'dart:ui' as ui;
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';

enum CartItemBadgeType { flashSale, inactive, discount }

class CartItemBadge extends StatelessWidget {
  final CartItemBadgeType type;
  final bool isRtl;
  final double topOffset;
  final int? discountPercent;

  const CartItemBadge({
    super.key,
    required this.type,
    required this.isRtl,
    required this.topOffset,
    this.discountPercent,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    Color bgColor;
    Widget child;

    switch (type) {
      case CartItemBadgeType.flashSale:
        bgColor = Colors.red;
        child = Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(Icons.flash_on, color: Colors.yellow, size: 12),
            Text(
              'flash_sale_badge'.tr(),
              style: const TextStyle(
                color: Colors.white,
                fontSize: 10,
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        );
        break;
      case CartItemBadgeType.inactive:
        bgColor = Colors.orange[700]!;
        child = Text(
          'shipping_unavailable'.tr(),
          style: const TextStyle(
            color: Colors.white,
            fontSize: 10,
            fontWeight: FontWeight.bold,
          ),
        );
        break;
      case CartItemBadgeType.discount:
        bgColor = theme.colorScheme.primary;
        child = Text(
          '-$discountPercent%',
          textDirection: ui.TextDirection.ltr,
          style: const TextStyle(
            color: Colors.white,
            fontSize: 10,
            fontWeight: FontWeight.bold,
          ),
        );
        break;
    }

    return Positioned(
      top: topOffset,
      left: isRtl ? null : 0,
      right: isRtl ? 0 : null,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 3),
        decoration: BoxDecoration(
          color: bgColor,
          borderRadius: BorderRadius.only(
            topLeft: isRtl ? Radius.zero : const Radius.circular(10),
            topRight: isRtl ? const Radius.circular(10) : Radius.zero,
            bottomLeft: isRtl ? const Radius.circular(10) : Radius.zero,
            bottomRight: isRtl ? Radius.zero : const Radius.circular(10),
          ),
        ),
        child: child,
      ),
    );
  }
}
