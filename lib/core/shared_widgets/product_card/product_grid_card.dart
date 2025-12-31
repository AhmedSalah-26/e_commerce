import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:go_router/go_router.dart';

import '../../../features/products/domain/entities/product_entity.dart';
import 'product_image_section.dart';
import 'product_info_section.dart';

class ProductGridCard extends StatefulWidget {
  final ProductEntity product;
  final bool compact;

  const ProductGridCard({
    super.key,
    required this.product,
    this.compact = false,
  });

  @override
  State<ProductGridCard> createState() => _ProductGridCardState();
}

class _ProductGridCardState extends State<ProductGridCard>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _scaleAnimation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: const Duration(milliseconds: 150),
      vsync: this,
    );
    _scaleAnimation = Tween<double>(begin: 1.0, end: 0.95).animate(
      CurvedAnimation(parent: _controller, curve: Curves.easeInOut),
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _onTapDown(TapDownDetails details) {
    _controller.forward();
  }

  void _onTapUp(TapUpDetails details) {
    _controller.reverse();
  }

  void _onTapCancel() {
    _controller.reverse();
  }

  @override
  Widget build(BuildContext context) {
    final isArabic = context.locale.languageCode == 'ar';
    final theme = Theme.of(context);

    return GestureDetector(
      onTapDown: _onTapDown,
      onTapUp: _onTapUp,
      onTapCancel: _onTapCancel,
      onTap: () {
        HapticFeedback.lightImpact();
        _navigateToProduct(context);
      },
      child: AnimatedBuilder(
        animation: _scaleAnimation,
        builder: (context, child) {
          return Transform.scale(
            scale: _scaleAnimation.value,
            child: child,
          );
        },
        child: Stack(
          clipBehavior: Clip.none,
          children: [
            Container(
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(8),
                color: theme.colorScheme.surface,
                border: Border.all(
                  color: theme.colorScheme.outline.withValues(alpha: 0.3),
                ),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: 0.05),
                    spreadRadius: 0,
                    blurRadius: 4,
                    offset: const Offset(0, 2),
                  ),
                ],
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Expanded(child: ProductImageSection(product: widget.product)),
                  ProductInfoSection(
                      product: widget.product,
                      isArabic: isArabic,
                      compact: widget.compact),
                ],
              ),
            ),
            if (widget.product.isFlashSaleActive)
              Positioned(
                top: widget.compact ? 4 : 8,
                right: isArabic ? null : (widget.compact ? 4 : 8),
                left: isArabic ? (widget.compact ? 4 : 8) : null,
                child: _FlashSaleBadge(compact: widget.compact),
              )
            else if (widget.product.hasDiscount)
              Positioned(
                top: widget.compact ? 4 : 8,
                right: isArabic ? null : (widget.compact ? 4 : 8),
                left: isArabic ? (widget.compact ? 4 : 8) : null,
                child: _DiscountBadge(
                    percentage: widget.product.discountPercentage,
                    compact: widget.compact),
              ),
          ],
        ),
      ),
    );
  }

  void _navigateToProduct(BuildContext context) {
    context.push('/product/${widget.product.id}');
  }
}

class _FlashSaleBadge extends StatelessWidget {
  final bool compact;

  const _FlashSaleBadge({this.compact = false});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.symmetric(
        horizontal: compact ? 4 : 6,
        vertical: compact ? 2 : 3,
      ),
      decoration: BoxDecoration(
        color: Colors.red,
        borderRadius: BorderRadius.circular(compact ? 3 : 4),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(Icons.flash_on, color: Colors.white, size: compact ? 8 : 10),
          const SizedBox(width: 2),
          Text(
            'flash_sale_badge'.tr(),
            style: TextStyle(
              color: Colors.white,
              fontSize: compact ? 7 : 9,
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
      ),
    );
  }
}

class _DiscountBadge extends StatelessWidget {
  final int percentage;
  final bool compact;

  const _DiscountBadge({required this.percentage, this.compact = false});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Container(
      padding: EdgeInsets.symmetric(
        horizontal: compact ? 4 : 6,
        vertical: compact ? 2 : 3,
      ),
      decoration: BoxDecoration(
        color: theme.colorScheme.primary,
        borderRadius: BorderRadius.circular(compact ? 3 : 4),
      ),
      child: Text(
        '-$percentage%',
        style: TextStyle(
          color: Colors.white,
          fontSize: compact ? 8 : 10,
          fontWeight: FontWeight.bold,
        ),
      ),
    );
  }
}
