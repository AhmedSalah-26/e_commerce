import 'package:flutter/material.dart';
import 'package:shimmer/shimmer.dart';

import '../../theme/app_colors.dart';

/// Skeleton for order details page
class OrderDetailsSkeleton extends StatelessWidget {
  const OrderDetailsSkeleton({super.key});

  @override
  Widget build(BuildContext context) {
    return Shimmer.fromColors(
      baseColor: AppColours.greyLighter,
      highlightColor: Colors.white,
      child: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Order Summary Card
            _buildCardSkeleton(
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    _buildBox(width: 140, height: 16),
                    _buildBox(width: 80, height: 28, radius: 14),
                  ],
                ),
                const SizedBox(height: 12),
                _buildBox(width: 120, height: 14),
                const SizedBox(height: 8),
                _buildBox(width: 150, height: 12),
              ],
            ),
            const SizedBox(height: 16),
            // Customer Info Card
            _buildCardSkeleton(
              children: [
                _buildBox(width: 100, height: 14),
                const SizedBox(height: 16),
                _buildInfoRowSkeleton(),
                const SizedBox(height: 12),
                _buildInfoRowSkeleton(),
                const SizedBox(height: 12),
                _buildInfoRowSkeleton(),
              ],
            ),
            const SizedBox(height: 16),
            // Merchant Orders Title
            _buildBox(width: 120, height: 16),
            const SizedBox(height: 12),
            // Merchant Order Cards
            _buildMerchantOrderSkeleton(),
            const SizedBox(height: 12),
            _buildMerchantOrderSkeleton(),
            const SizedBox(height: 16),
            // Total Summary Card
            _buildCardSkeleton(
              children: [
                _buildPriceRowSkeleton(),
                const SizedBox(height: 12),
                _buildPriceRowSkeleton(),
                const Divider(height: 24),
                _buildPriceRowSkeleton(isTotal: true),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildCardSkeleton({required List<Widget> children}) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: children,
      ),
    );
  }

  Widget _buildBox({
    required double width,
    required double height,
    double radius = 4,
  }) {
    return Container(
      width: width,
      height: height,
      decoration: BoxDecoration(
        color: AppColours.greyLighter,
        borderRadius: BorderRadius.circular(radius),
      ),
    );
  }

  Widget _buildInfoRowSkeleton() {
    return Row(
      children: [
        _buildBox(width: 20, height: 20, radius: 4),
        const SizedBox(width: 12),
        Expanded(child: _buildBox(width: double.infinity, height: 14)),
      ],
    );
  }

  Widget _buildPriceRowSkeleton({bool isTotal = false}) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        _buildBox(width: isTotal ? 60 : 80, height: isTotal ? 16 : 14),
        _buildBox(width: isTotal ? 100 : 80, height: isTotal ? 16 : 14),
      ],
    );
  }

  Widget _buildMerchantOrderSkeleton() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              _buildBox(width: 100, height: 14),
              _buildBox(width: 70, height: 24, radius: 12),
            ],
          ),
          const SizedBox(height: 16),
          // Product items
          _buildProductItemSkeleton(),
          const SizedBox(height: 12),
          _buildProductItemSkeleton(),
          const Divider(height: 24),
          // Subtotal
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              _buildBox(width: 60, height: 14),
              _buildBox(width: 80, height: 14),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildProductItemSkeleton() {
    return Row(
      children: [
        _buildBox(width: 50, height: 50, radius: 8),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildBox(width: double.infinity, height: 14),
              const SizedBox(height: 6),
              _buildBox(width: 80, height: 12),
            ],
          ),
        ),
        _buildBox(width: 60, height: 14),
      ],
    );
  }
}
