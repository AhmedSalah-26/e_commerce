import 'package:flutter/material.dart';

class ProductReorderSuggestion extends StatelessWidget {
  final int suggestedQty;
  final bool isRtl;

  const ProductReorderSuggestion({
    super.key,
    required this.suggestedQty,
    required this.isRtl,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        const SizedBox(height: 12),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
          decoration: BoxDecoration(
            color: Colors.blue.withValues(alpha: 0.1),
            borderRadius: BorderRadius.circular(8),
            border: Border.all(
              color: Colors.blue.withValues(alpha: 0.3),
            ),
          ),
          child: Row(
            children: [
              const Icon(Icons.lightbulb_outline, color: Colors.blue, size: 18),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  isRtl
                      ? 'اقتراح: اطلب $suggestedQty وحدة'
                      : 'Suggestion: Reorder $suggestedQty units',
                  style: const TextStyle(
                    color: Colors.blue,
                    fontSize: 12,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}
