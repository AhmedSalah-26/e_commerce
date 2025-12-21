import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';

import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_text_style.dart';

class EmptyCartMessage extends StatelessWidget {
  const EmptyCartMessage({super.key});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Icon(
            Icons.shopping_cart_outlined,
            size: 100,
            color: AppColours.greyMedium,
          ),
          const SizedBox(height: 20),
          Text(
            'cart_empty'.tr(),
            style: AppTextStyle.semiBold_20_dark_brown,
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
