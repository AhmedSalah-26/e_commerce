import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/theme/app_colors.dart';
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
    return OrderCardWrapper(
      title: isRtl ? 'المنتجات' : 'Products',
      icon: Icons.shopping_bag_outlined,
      children: [
        ...order.items.asMap().entries.map((entry) {
          final index = entry.key;
          final item = entry.value;
          return Column(
            children: [
              _buildProductItem(context, item),
              if (index < order.items.length - 1)
                const Divider(height: 1, color: AppColours.greyLighter),
            ],
          );
        }),
      ],
    );
  }

  Widget _buildProductItem(BuildContext context, OrderItemEntity item) {
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
                      placeholder: (_, __) => _buildImagePlaceholder(),
                      errorWidget: (_, __, ___) => _buildImagePlaceholder(),
                    )
                  : _buildImagePlaceholder(),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    item.productName,
                    style: AppTextStyle.semiBold_16_dark_brown,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 4),
                  Text(
                    '${item.price.toStringAsFixed(2)} ${isRtl ? 'ج.م' : 'EGP'} × ${item.quantity}',
                    style: AppTextStyle.normal_14_greyDark,
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
                    color: AppColours.primary,
                  ),
                ),
                if (item.productId != null) ...[
                  const SizedBox(height: 4),
                  Icon(
                    Icons.arrow_forward_ios,
                    size: 14,
                    color: AppColours.greyMedium,
                  ),
                ],
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildImagePlaceholder() {
    return Container(
      width: 60,
      height: 60,
      color: AppColours.greyLighter,
      child: const Icon(Icons.image_outlined, color: AppColours.greyMedium),
    );
  }
}
