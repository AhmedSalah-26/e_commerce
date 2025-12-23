import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:go_router/go_router.dart';

import '../../features/cart/presentation/cubit/cart_cubit.dart';
import '../../features/categories/presentation/cubit/categories_cubit.dart';
import '../../features/favorites/presentation/cubit/favorites_cubit.dart';
import '../../features/home/presentation/cubit/home_sliders_cubit.dart';
import '../../features/orders/presentation/cubit/orders_cubit.dart';
import '../../features/products/presentation/cubit/products_cubit.dart';
import '../../features/shipping/presentation/cubit/shipping_cubit.dart';

class LanguageToggleButton extends StatelessWidget {
  final Color? iconColor;
  final Color? backgroundColor;

  const LanguageToggleButton({
    super.key,
    this.iconColor,
    this.backgroundColor,
  });

  @override
  Widget build(BuildContext context) {
    final isArabic = context.locale.languageCode == 'ar';

    return Container(
      decoration: BoxDecoration(
        color: backgroundColor ?? Colors.white.withValues(alpha: 0.9),
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.1),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          borderRadius: BorderRadius.circular(12),
          onTap: () => _toggleLanguage(context, isArabic),
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(
                  Icons.language,
                  size: 20,
                  color: iconColor ?? Colors.black87,
                ),
                const SizedBox(width: 6),
                Text(
                  isArabic ? 'EN' : 'ع',
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.bold,
                    color: iconColor ?? Colors.black87,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  void _toggleLanguage(BuildContext context, bool isArabic) async {
    final newLocale = isArabic ? const Locale('en') : const Locale('ar');

    // Change locale
    await context.setLocale(newLocale);

    // Reset and reload all data
    if (context.mounted) {
      _resetAllData(context, newLocale.languageCode);

      // Navigate to home
      context.go('/home');
    }
  }

  void _resetAllData(BuildContext context, String locale) {
    try {
      // Reset products cubit
      final productsCubit = context.read<ProductsCubit>();
      productsCubit.setLocale(locale);
      productsCubit.reset();

      // Reset categories cubit
      final categoriesCubit = context.read<CategoriesCubit>();
      categoriesCubit.setLocale(locale);
      categoriesCubit.reset();

      // Reset sliders cubit
      final slidersCubit = context.read<HomeSlidersCubit>();
      slidersCubit.setLocale(locale);
      slidersCubit.reset();

      // Reset favorites cubit
      final favoritesCubit = context.read<FavoritesCubit>();
      favoritesCubit.setLocale(locale);
      favoritesCubit.reset();

      // Reset cart cubit
      final cartCubit = context.read<CartCubit>();
      cartCubit.setLocale(locale);
      cartCubit.reset();

      // Reset orders cubit
      context.read<OrdersCubit>().reset();

      // Reset shipping cubit
      context.read<ShippingCubit>().reset();
    } catch (_) {
      // Cubits might not be available in current context
    }
  }
}
