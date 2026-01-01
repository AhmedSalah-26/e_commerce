import 'package:flutter/material.dart';

class ReviewReportComment extends StatelessWidget {
  final String? comment;
  final ThemeData theme;

  const ReviewReportComment({
    super.key,
    required this.comment,
    required this.theme,
  });

  @override
  Widget build(BuildContext context) {
    if (comment == null || comment!.isEmpty) {
      return const SizedBox.shrink();
    }

    return Column(
      children: [
        const SizedBox(height: 12),
        Container(
          width: double.infinity,
          padding: const EdgeInsets.all(10),
          decoration: BoxDecoration(
            color: theme.colorScheme.surfaceContainerHighest,
            borderRadius: BorderRadius.circular(8),
          ),
          child: Text(
            comment!,
            style: TextStyle(fontSize: 13, color: Colors.grey[700]),
          ),
        ),
      ],
    );
  }
}
