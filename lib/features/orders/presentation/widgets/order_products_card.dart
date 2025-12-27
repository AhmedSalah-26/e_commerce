import 'package:cached_network_image/cached_network_image.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/theme/app_text_style.dart';
import '../../domain/entities/order_entity.dart';
import 'order_card_wrapper.dart';

class OrderProductsCard extends StatelessWidget {
  final OrderEntity order;
  final bool isRtl;
  final double screenWidth;

  const OrderProductsCard({
    super.key,
    required this.order,
    required this.isRtl,
    required this.screenWidth,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final locale = context.locale.languageCode;
    return OrderCardWrapper(
      title: isRtl ? 'المنتجات' : 'Products',
      icon: Icons.shopping_bag_outlined,
      children: [
        ...order.items.asMap().entries.map((entry) {
          final index = entry.key;
          final item = entry.value;
          return Column(
            children: [
              _buildProductItem(context, item, locale, theme),
              if (index < order.items.length - 1)
                Divider(height: 1, color: theme.colorScheme.outline),
            ],
          );
        }),
      ],
    );
  }

  Widget _buildProductItem(BuildContext context, OrderItemEntity item,
      String locale, ThemeData theme) {
    return InkWell(
      onTap: item.productId != null
          ? () => context.push('/product/${item.productId}')
          : null,
      borderRadius: BorderRadius.circular(8),
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 8),
        child: Row(
          children: [
            ClipRRect(
              borderRadius: BorderRadius.circular(8),
              child: item.productImage != null && item.productImage!.isNotEmpty
                  ? CachedNetworkImage(
                      imageUrl: item.productImage!,
                      width: 60,
                      height: 60,
                      fit: BoxFit.cover,
                      memCacheWidth: 120,
                      placeholder: (_, __) => _buildImagePlaceholder(theme),
                      errorWidget: (_, __, ___) =>
                          _buildImagePlaceholder(theme),
                    )
                  : _buildImagePlaceholder(theme),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    item.getLocalizedName(locale),
                    style: AppTextStyle.semiBold_16_dark_brown.copyWith(
                      color: theme.colorScheme.onSurface,
                    ),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 4),
                  Text(
                    '${item.price.toStringAsFixed(2)} ${isRtl ? 'ج.م' : 'EGP'} × ${item.quantity}',
                    style: AppTextStyle.normal_14_greyDark.copyWith(
                      color: theme.colorScheme.onSurface.withValues(alpha: 0.6),
                    ),
                  ),
                ],
              ),
            ),
            Column(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                Text(
                  '${item.itemTotal.toStringAsFixed(2)} ${isRtl ? 'ج.م' : 'EGP'}',
                  style: AppTextStyle.semiBold_16_dark_brown.copyWith(
                    color: theme.colorScheme.primary,
                  ),
                ),
                if (item.productId != null) ...[
                  const SizedBox(height: 4),
                  Icon(
                    Icons.arrow_forward_ios,
                    size: 14,
                    color: theme.colorScheme.onSurface.withValues(alpha: 0.4),
                  ),
                ],
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildImagePlaceholder(ThemeData theme) {
    return Container(
      width: 60,
      height: 60,
      color: theme.colorScheme.surface,
      child: Icon(Icons.image_outlined,
          color: theme.colorScheme.onSurface.withValues(alpha: 0.4)),
    );
  }
}
