import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:toastification/toastification.dart';

import '../../../domain/entities/inventory_insight_entity.dart';
import 'status_badge.dart';

class ProductInventoryInfo extends StatelessWidget {
  final ProductInventoryDetail product;
  final String locale;
  final bool isRtl;
  final ThemeData theme;

  const ProductInventoryInfo({
    super.key,
    required this.product,
    required this.locale,
    required this.isRtl,
    required this.theme,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Expanded(
              child: Text(
                product.getName(locale),
                style: const TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 14,
                ),
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
              ),
            ),
            StatusBadge(
              status: product.stockStatus,
              isRtl: isRtl,
            ),
          ],
        ),
        const SizedBox(height: 4),
        // Product ID - copyable
        GestureDetector(
          onTap: () {
            Clipboard.setData(ClipboardData(text: product.id));
            toastification.show(
              context: context,
              title: Text('product_id_copied'.tr()),
              type: ToastificationType.success,
              autoCloseDuration: const Duration(seconds: 2),
            );
          },
          child: Row(
            children: [
              Icon(
                Icons.copy,
                size: 12,
                color: theme.colorScheme.onSurface.withValues(alpha: 0.5),
              ),
              const SizedBox(width: 4),
              Expanded(
                child: Text(
                  'ID: ${product.id.length > 8 ? '${product.id.substring(0, 8)}...' : product.id}',
                  style: TextStyle(
                    fontSize: 10,
                    color: theme.colorScheme.onSurface.withValues(alpha: 0.5),
                    fontFamily: 'monospace',
                  ),
                  overflow: TextOverflow.ellipsis,
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 4),
        Text(
          '${product.effectivePrice.toStringAsFixed(0)} ${isRtl ? 'ج.م' : 'EGP'}',
          style: TextStyle(
            color: theme.colorScheme.primary,
            fontWeight: FontWeight.w600,
          ),
        ),
      ],
    );
  }
}
