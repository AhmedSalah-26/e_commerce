import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import '../../../categories/domain/entities/category_entity.dart';

class CategoryListItem extends StatelessWidget {
  final CategoryEntity category;
  final VoidCallback onEdit;

  const CategoryListItem({
    super.key,
    required this.category,
    required this.onEdit,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        color: theme.colorScheme.surface,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: theme.colorScheme.outline),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withValues(alpha: 0.1),
            blurRadius: 4,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: ListTile(
        leading: ClipRRect(
          borderRadius: BorderRadius.circular(8),
          child: category.imageUrl != null && category.imageUrl!.isNotEmpty
              ? CachedNetworkImage(
                  imageUrl: category.imageUrl!,
                  width: 50,
                  height: 50,
                  fit: BoxFit.cover,
                  memCacheWidth: 100,
                  placeholder: (_, __) => _buildCategoryPlaceholder(theme),
                  errorWidget: (_, __, ___) => _buildCategoryPlaceholder(theme),
                )
              : _buildCategoryPlaceholder(theme),
        ),
        title: Text(
          category.name,
          style: theme.textTheme.titleMedium?.copyWith(
            fontWeight: FontWeight.w600,
          ),
        ),
        trailing: IconButton(
          onPressed: onEdit,
          icon: Icon(
            Icons.edit_outlined,
            color: theme.colorScheme.primary,
          ),
        ),
      ),
    );
  }

  Widget _buildCategoryPlaceholder(ThemeData theme) {
    return Container(
      width: 50,
      height: 50,
      decoration: BoxDecoration(
        color: theme.colorScheme.primary.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Icon(
        Icons.category,
        color: theme.colorScheme.primary,
        size: 24,
      ),
    );
  }
}
