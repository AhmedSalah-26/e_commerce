import 'package:flutter/material.dart';

class ReviewReportDescription extends StatelessWidget {
  final String? description;

  const ReviewReportDescription({
    super.key,
    required this.description,
  });

  @override
  Widget build(BuildContext context) {
    if (description == null || description!.isEmpty) {
      return const SizedBox.shrink();
    }

    return Column(
      children: [
        const SizedBox(height: 8),
        Text(
          description!,
          style: TextStyle(fontSize: 13, color: Colors.grey[700]),
        ),
      ],
    );
  }
}
