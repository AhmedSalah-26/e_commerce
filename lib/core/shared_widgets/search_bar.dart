import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import '../theme/app_text_style.dart';

class CustomSearchBar extends StatelessWidget {
  final VoidCallback? onTap;

  const CustomSearchBar({super.key, this.onTap});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final screenWidth = MediaQuery.of(context).size.width;
    double searchBarWidth = screenWidth > 600 ? 400 : screenWidth * 0.7;

    return GestureDetector(
      onTap: onTap,
      child: Container(
        alignment: Alignment.center,
        width: searchBarWidth,
        height: 45,
        padding: const EdgeInsets.symmetric(horizontal: 12),
        decoration: BoxDecoration(
          color: theme.colorScheme.surfaceContainerHighest,
          borderRadius: BorderRadius.circular(10),
        ),
        child: Row(
          children: [
            Icon(Icons.search, color: theme.colorScheme.primary),
            const SizedBox(width: 8),
            Text(
              'search'.tr(),
              style: AppTextStyle.normal_12_greyDark.copyWith(
                color: theme.colorScheme.onSurface.withValues(alpha: 0.6),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
