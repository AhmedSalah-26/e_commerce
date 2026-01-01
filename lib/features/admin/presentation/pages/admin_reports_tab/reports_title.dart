import 'package:flutter/material.dart';

class ReportsTitle extends StatelessWidget {
  final bool isRtl;

  const ReportsTitle({
    super.key,
    required this.isRtl,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Center(
      child: Text(
        isRtl ? 'التقارير والإحصائيات' : 'Reports & Statistics',
        style: TextStyle(
          fontSize: 20,
          fontWeight: FontWeight.w600,
          color: theme.colorScheme.primary,
        ),
      ),
    );
  }
}
