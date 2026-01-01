import 'package:flutter/material.dart';

class ReviewReportAdminResponse extends StatelessWidget {
  final String? adminResponse;
  final String? adminName;
  final bool isArabic;
  final ThemeData theme;

  const ReviewReportAdminResponse({
    super.key,
    required this.adminResponse,
    required this.adminName,
    required this.isArabic,
    required this.theme,
  });

  @override
  Widget build(BuildContext context) {
    if (adminResponse == null) {
      return const SizedBox.shrink();
    }

    return Column(
      children: [
        const SizedBox(height: 12),
        Container(
          padding: const EdgeInsets.all(10),
          decoration: BoxDecoration(
            color: theme.colorScheme.primary.withValues(alpha: 0.1),
            borderRadius: BorderRadius.circular(8),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                '${isArabic ? 'الرد:' : 'Response:'} ${adminName ?? 'Admin'}',
                style: TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.w600,
                  color: theme.colorScheme.primary,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                adminResponse!,
                style: const TextStyle(fontSize: 13),
              ),
            ],
          ),
        ),
      ],
    );
  }
}
