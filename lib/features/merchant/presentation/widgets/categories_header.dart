import 'package:flutter/material.dart';

class CategoriesHeader extends StatelessWidget {
  final String title;
  final VoidCallback onAdd;

  const CategoriesHeader({
    super.key,
    required this.title,
    required this.onAdd,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            theme.colorScheme.primary,
            theme.colorScheme.primary.withValues(alpha: 0.7),
          ],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            title,
            style: const TextStyle(
              fontSize: 22,
              fontWeight: FontWeight.w600,
              color: Colors.white,
            ),
          ),
          IconButton(
            onPressed: onAdd,
            icon: const Icon(
              Icons.add_circle_outline,
              color: Colors.white,
              size: 28,
            ),
          ),
        ],
      ),
    );
  }
}
