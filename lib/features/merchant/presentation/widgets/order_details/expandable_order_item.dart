import 'package:cached_network_image/cached_network_image.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../../../../orders/domain/entities/order_entity.dart';

/// Expandable widget for order item with product details
class ExpandableOrderItem extends StatefulWidget {
  final OrderItemEntity item;
  final bool isRtl;

  const ExpandableOrderItem({
    super.key,
    required this.item,
    required this.isRtl,
  });

  @override
  State<ExpandableOrderItem> createState() => _ExpandableOrderItemState();
}

class _ExpandableOrderItemState extends State<ExpandableOrderItem> {
  bool _isExpanded = false;

  String get _locale => widget.isRtl ? 'ar' : 'en';

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final localizedName = widget.item.getLocalizedName(_locale);
    final localizedDescription = widget.item.getLocalizedDescription(_locale);
    final hasDescription =
        localizedDescription != null && localizedDescription.isNotEmpty;

    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      decoration: BoxDecoration(
        color: theme.colorScheme.surface,
        borderRadius: BorderRadius.circular(8),
        border:
            Border.all(color: theme.colorScheme.outline.withValues(alpha: 0.3)),
      ),
      child: Column(
        children: [
          InkWell(
            onTap: () => setState(() => _isExpanded = !_isExpanded),
            borderRadius: BorderRadius.circular(8),
            child: Padding(
              padding: const EdgeInsets.all(10),
              child: Row(
                children: [
                  _buildProductImage(theme),
                  const SizedBox(width: 12),
                  Expanded(
                    child: _buildProductInfo(
                      theme,
                      localizedName,
                      hasDescription,
                      localizedDescription,
                    ),
                  ),
                  _buildPriceAndExpand(theme),
                ],
              ),
            ),
          ),
          if (_isExpanded) _buildExpandedDetails(theme),
        ],
      ),
    );
  }

  Widget _buildProductImage(ThemeData theme) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(8),
      child: widget.item.productImage != null
          ? CachedNetworkImage(
              imageUrl: widget.item.productImage!,
              width: 50,
              height: 50,
              fit: BoxFit.cover,
              placeholder: (_, __) => _buildPlaceholder(theme),
              errorWidget: (_, __, ___) => _buildPlaceholder(theme),
            )
          : _buildPlaceholder(theme),
    );
  }

  Widget _buildProductInfo(
    ThemeData theme,
    String localizedName,
    bool hasDescription,
    String? localizedDescription,
  ) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          localizedName,
          style: TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w600,
            color: theme.colorScheme.onSurface,
          ),
          maxLines: 2,
          overflow: TextOverflow.ellipsis,
        ),
        const SizedBox(height: 4),
        Row(
          children: [
            Text(
              widget.isRtl ? 'الكمية: ' : 'Qty: ',
              style: TextStyle(
                fontSize: 12,
                color: theme.colorScheme.onSurface,
              ),
            ),
            Text(
              '${widget.item.quantity}',
              style: TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.w600,
                color: theme.colorScheme.onSurface,
              ),
            ),
            const SizedBox(width: 8),
            Text(
              '× ${widget.item.price.toStringAsFixed(2)} ${widget.isRtl ? 'ج.م' : 'EGP'}',
              style: TextStyle(
                fontSize: 12,
                color: theme.colorScheme.onSurface,
              ),
            ),
          ],
        ),
        if (hasDescription) ...[
          const SizedBox(height: 4),
          Text(
            localizedDescription!,
            style: TextStyle(
              fontSize: 11,
              color: theme.colorScheme.onSurface,
            ),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
        ],
      ],
    );
  }

  Widget _buildPriceAndExpand(ThemeData theme) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.end,
      children: [
        Text(
          '${widget.item.itemTotal.toStringAsFixed(2)} ${widget.isRtl ? 'ج.م' : 'EGP'}',
          style: TextStyle(
            fontSize: 12,
            fontWeight: FontWeight.w600,
            color: theme.colorScheme.onSurface,
          ),
        ),
        const SizedBox(height: 4),
        Icon(
          _isExpanded ? Icons.keyboard_arrow_up : Icons.keyboard_arrow_down,
          color: theme.colorScheme.primary,
          size: 20,
        ),
      ],
    );
  }

  Widget _buildExpandedDetails(ThemeData theme) {
    final localizedDescription = widget.item.getLocalizedDescription(_locale);
    final productId = widget.item.productId ?? '';

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: theme.colorScheme.surface,
        borderRadius: const BorderRadius.vertical(bottom: Radius.circular(8)),
        border: Border(
          top: BorderSide(
            color: theme.colorScheme.outline.withValues(alpha: 0.3),
          ),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'product_name'.tr(),
            style: TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.w600,
              color: theme.colorScheme.onSurface,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            widget.item.getLocalizedName(_locale),
            style: theme.textTheme.bodyMedium,
          ),
          const SizedBox(height: 12),
          if (productId.isNotEmpty) ...[
            Row(
              children: [
                Expanded(
                  child: Text(
                    '${'product_id'.tr()}: $productId',
                    style: TextStyle(
                      fontSize: 12,
                      color: theme.colorScheme.onSurface,
                    ),
                  ),
                ),
                InkWell(
                  onTap: () {
                    Clipboard.setData(ClipboardData(text: productId));
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: Text('product_id_copied'.tr()),
                        duration: const Duration(seconds: 1),
                      ),
                    );
                  },
                  child: Icon(
                    Icons.copy,
                    size: 16,
                    color: theme.colorScheme.primary,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
          ],
          if (localizedDescription != null &&
              localizedDescription.isNotEmpty) ...[
            Text(
              'product_description'.tr(),
              style: TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.w600,
                color: theme.colorScheme.onSurface,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              localizedDescription,
              style: TextStyle(
                fontSize: 12,
                color: theme.colorScheme.onSurface,
              ),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildPlaceholder(ThemeData theme) {
    return Container(
      width: 50,
      height: 50,
      color: theme.colorScheme.outline.withValues(alpha: 0.2),
      child: Icon(Icons.image_outlined, color: theme.colorScheme.outline),
    );
  }
}
