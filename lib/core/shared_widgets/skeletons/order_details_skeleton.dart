import 'package:flutter/material.dart';
import 'package:shimmer/shimmer.dart';

/// Skeleton for order details page
class OrderDetailsSkeleton extends StatelessWidget {
  const OrderDetailsSkeleton({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final skeletonColor = theme.colorScheme.surfaceContainerHighest;
    final highlightColor = theme.colorScheme.surface;

    return Shimmer.fromColors(
      baseColor: skeletonColor,
      highlightColor: highlightColor,
      child: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Order Summary Card
            _buildCardSkeleton(
              context,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    _buildBox(context, width: 140, height: 16),
                    _buildBox(context, width: 80, height: 28, radius: 14),
                  ],
                ),
                const SizedBox(height: 12),
                _buildBox(context, width: 120, height: 14),
                const SizedBox(height: 8),
                _buildBox(context, width: 150, height: 12),
              ],
            ),
            const SizedBox(height: 16),
            // Customer Info Card
            _buildCardSkeleton(
              context,
              children: [
                _buildBox(context, width: 100, height: 14),
                const SizedBox(height: 16),
                _buildInfoRowSkeleton(context),
                const SizedBox(height: 12),
                _buildInfoRowSkeleton(context),
                const SizedBox(height: 12),
                _buildInfoRowSkeleton(context),
              ],
            ),
            const SizedBox(height: 16),
            // Merchant Orders Title
            _buildBox(context, width: 120, height: 16),
            const SizedBox(height: 12),
            // Merchant Order Cards
            _buildMerchantOrderSkeleton(context),
            const SizedBox(height: 12),
            _buildMerchantOrderSkeleton(context),
            const SizedBox(height: 16),
            // Total Summary Card
            _buildCardSkeleton(
              context,
              children: [
                _buildPriceRowSkeleton(context),
                const SizedBox(height: 12),
                _buildPriceRowSkeleton(context),
                const Divider(height: 24),
                _buildPriceRowSkeleton(context, isTotal: true),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildCardSkeleton(BuildContext context,
      {required List<Widget> children}) {
    final theme = Theme.of(context);
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: theme.colorScheme.surface,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: children,
      ),
    );
  }

  Widget _buildBox(
    BuildContext context, {
    required double width,
    required double height,
    double radius = 4,
  }) {
    final theme = Theme.of(context);
    return Container(
      width: width,
      height: height,
      decoration: BoxDecoration(
        color: theme.colorScheme.surfaceContainerHighest,
        borderRadius: BorderRadius.circular(radius),
      ),
    );
  }

  Widget _buildInfoRowSkeleton(BuildContext context) {
    return Row(
      children: [
        _buildBox(context, width: 20, height: 20, radius: 4),
        const SizedBox(width: 12),
        Expanded(child: _buildBox(context, width: double.infinity, height: 14)),
      ],
    );
  }

  Widget _buildPriceRowSkeleton(BuildContext context, {bool isTotal = false}) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        _buildBox(context, width: isTotal ? 60 : 80, height: isTotal ? 16 : 14),
        _buildBox(context,
            width: isTotal ? 100 : 80, height: isTotal ? 16 : 14),
      ],
    );
  }

  Widget _buildMerchantOrderSkeleton(BuildContext context) {
    final theme = Theme.of(context);
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: theme.colorScheme.surface,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              _buildBox(context, width: 100, height: 14),
              _buildBox(context, width: 70, height: 24, radius: 12),
            ],
          ),
          const SizedBox(height: 16),
          // Product items
          _buildProductItemSkeleton(context),
          const SizedBox(height: 12),
          _buildProductItemSkeleton(context),
          const Divider(height: 24),
          // Subtotal
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              _buildBox(context, width: 60, height: 14),
              _buildBox(context, width: 80, height: 14),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildProductItemSkeleton(BuildContext context) {
    return Row(
      children: [
        _buildBox(context, width: 50, height: 50, radius: 8),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildBox(context, width: double.infinity, height: 14),
              const SizedBox(height: 6),
              _buildBox(context, width: 80, height: 12),
            ],
          ),
        ),
        _buildBox(context, width: 60, height: 14),
      ],
    );
  }
}
