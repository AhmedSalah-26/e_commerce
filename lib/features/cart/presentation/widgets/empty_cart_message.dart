import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';

import '../../../../core/theme/app_text_style.dart';

class EmptyCartMessage extends StatelessWidget {
  const EmptyCartMessage({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.shopping_cart_outlined,
            size: 100,
            color: theme.colorScheme.onSurface.withValues(alpha: 0.6),
          ),
          const SizedBox(height: 20),
          Text(
            'cart_empty'.tr(),
            style: AppTextStyle.semiBold_20_dark_brown.copyWith(
              color: theme.colorScheme.onSurface,
            ),
          ),
          const SizedBox(height: 10),
          Text(
            'cart_empty_desc'.tr(),
            style: AppTextStyle.normal_16_greyDark,
          ),
        ],
      ),
    );
  }
}
