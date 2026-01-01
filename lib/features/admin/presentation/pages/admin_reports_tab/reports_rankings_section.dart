import 'package:flutter/material.dart';

import '../../widgets/reports/ranking_button.dart';

class ReportsRankingsSection extends StatelessWidget {
  final bool isRtl;
  final bool isMobile;
  final void Function(String, String) onOpenRankings;

  const ReportsRankingsSection({
    super.key,
    required this.isRtl,
    required this.isMobile,
    required this.onOpenRankings,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          isRtl ? 'الترتيبات' : 'Rankings',
          style: theme.textTheme.titleMedium
              ?.copyWith(fontWeight: FontWeight.w600),
        ),
        const SizedBox(height: 12),
        _buildRankingsGrid(),
      ],
    );
  }

  Widget _buildRankingsGrid() {
    final items = [
      (
        Icons.trending_up,
        isRtl ? 'التجار الأكثر مبيعاً' : 'Top Selling',
        Colors.green,
        'top_selling'
      ),
      (
        Icons.shopping_cart,
        isRtl ? 'العملاء الأكثر طلباً' : 'Top Customers',
        Colors.blue,
        'top_customers'
      ),
      (
        Icons.cancel,
        isRtl ? 'الأكثر إلغاءً' : 'Most Cancellations',
        Colors.orange,
        'most_cancellations'
      ),
      (
        Icons.warning,
        isRtl ? 'تجار مشكلة' : 'Problematic',
        Colors.red,
        'problematic'
      ),
    ];

    final cards = items
        .map((i) => RankingButton(
              icon: i.$1,
              title: i.$2,
              color: i.$3,
              onTap: () => onOpenRankings(i.$4, i.$2),
              isRtl: isRtl,
            ))
        .toList();

    if (isMobile) return Column(children: cards);

    return GridView.count(
      crossAxisCount: 2,
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      mainAxisSpacing: 12,
      crossAxisSpacing: 12,
      childAspectRatio: 2.5,
      children: cards,
    );
  }
}
