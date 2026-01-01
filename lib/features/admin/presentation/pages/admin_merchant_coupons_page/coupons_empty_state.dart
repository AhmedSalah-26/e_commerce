import 'package:flutter/material.dart';

class CouponsEmptyState extends StatelessWidget {
  final bool isRtl;
  final bool isDark;

  const CouponsEmptyState({
    super.key,
    required this.isRtl,
    required this.isDark,
  });

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            padding: const EdgeInsets.all(24),
            decoration: BoxDecoration(
              color:
                  (isDark ? Colors.white : Colors.grey).withValues(alpha: 0.1),
              shape: BoxShape.circle,
            ),
            child: Icon(Icons.local_offer_outlined,
                size: 48, color: isDark ? Colors.white38 : Colors.grey[400]),
          ),
          const SizedBox(height: 16),
          Text(
            isRtl ? 'لا توجد كوبونات' : 'No coupons found',
            style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.w600,
                color: isDark ? Colors.white70 : Colors.grey[600]),
          ),
        ],
      ),
    );
  }
}
