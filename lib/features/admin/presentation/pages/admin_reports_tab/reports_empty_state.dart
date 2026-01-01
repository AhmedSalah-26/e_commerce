import 'package:flutter/material.dart';

class ReportsEmptyState extends StatelessWidget {
  final bool isRtl;
  final VoidCallback onRefresh;

  const ReportsEmptyState({
    super.key,
    required this.isRtl,
    required this.onRefresh,
  });

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Icon(Icons.analytics, size: 64, color: Colors.grey),
          const SizedBox(height: 16),
          ElevatedButton(
            onPressed: onRefresh,
            child: Text(isRtl ? 'تحديث' : 'Refresh'),
          ),
        ],
      ),
    );
  }
}
