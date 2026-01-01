import 'package:flutter/material.dart';

class ProductSellThroughRate extends StatelessWidget {
  final double rate;
  final bool isRtl;
  final ThemeData theme;

  const ProductSellThroughRate({
    super.key,
    required this.rate,
    required this.isRtl,
    required this.theme,
  });

  Color _getSellThroughColor(double rate) {
    if (rate >= 70) return Colors.green;
    if (rate >= 40) return Colors.orange;
    return Colors.red;
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              isRtl ? 'معدل البيع' : 'Sell-through Rate',
              style: TextStyle(
                fontSize: 11,
                color: theme.colorScheme.onSurface.withValues(alpha: 0.6),
              ),
            ),
            Text(
              '${rate.toStringAsFixed(1)}%',
              style: TextStyle(
                fontSize: 11,
                fontWeight: FontWeight.bold,
                color: _getSellThroughColor(rate),
              ),
            ),
          ],
        ),
        const SizedBox(height: 4),
        ClipRRect(
          borderRadius: BorderRadius.circular(4),
          child: LinearProgressIndicator(
            value: rate / 100,
            backgroundColor: Colors.grey[200],
            valueColor: AlwaysStoppedAnimation<Color>(
              _getSellThroughColor(rate),
            ),
            minHeight: 6,
          ),
        ),
      ],
    );
  }
}
