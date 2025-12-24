import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/theme/app_colors.dart';
import '../../../auth/presentation/cubit/auth_cubit.dart';
import '../../../auth/presentation/cubit/auth_state.dart';
import '../../../cart/presentation/cubit/cart_cubit.dart';
import '../../../categories/presentation/cubit/categories_cubit.dart';
import '../../../favorites/presentation/cubit/favorites_cubit.dart';
import '../../../home/presentation/cubit/home_sliders_cubit.dart';
import '../../../products/presentation/cubit/products_cubit.dart';

class LanguageSettingsScreen extends StatefulWidget {
  const LanguageSettingsScreen({super.key});

  @override
  State<LanguageSettingsScreen> createState() => _LanguageSettingsScreenState();
}

class _LanguageSettingsScreenState extends State<LanguageSettingsScreen> {
  late String _selectedLanguage;
  bool _isApplying = false;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    _selectedLanguage = context.locale.languageCode;
  }

  @override
  Widget build(BuildContext context) {
    final currentLocale = context.locale.languageCode;
    final hasChanges = _selectedLanguage != currentLocale;

    return Scaffold(
      appBar: AppBar(
        title: Text('language_settings'.tr()),
        backgroundColor: AppColours.white,
        foregroundColor: AppColours.brownDark,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => context.pop(),
        ),
      ),
      body: Column(
        children: [
          Expanded(
            child: ListView(
              padding: const EdgeInsets.all(16),
              children: [
                _buildLanguageOption(
                  title: 'العربية',
                  subtitle: 'Arabic',
                  languageCode: 'ar',
                  flag: '🇪🇬',
                ),
                const SizedBox(height: 12),
                _buildLanguageOption(
                  title: 'English',
                  subtitle: 'الإنجليزية',
                  languageCode: 'en',
                  flag: '🇺🇸',
                ),
              ],
            ),
          ),
          // Apply button
          Padding(
            padding: const EdgeInsets.all(16),
            child: SizedBox(
              width: double.infinity,
              height: 50,
              child: ElevatedButton(
                onPressed: hasChanges && !_isApplying ? _applyLanguage : null,
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColours.brownLight,
                  foregroundColor: Colors.white,
                  disabledBackgroundColor: Colors.grey[300],
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                child: _isApplying
                    ? const SizedBox(
                        width: 24,
                        height: 24,
                        child: CircularProgressIndicator(
                          color: Colors.white,
                          strokeWidth: 2,
                        ),
                      )
                    : Text(
                        'apply'.tr(),
                        style: const TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildLanguageOption({
    required String title,
    required String subtitle,
    required String languageCode,
    required String flag,
  }) {
    final isSelected = _selectedLanguage == languageCode;

    return InkWell(
      onTap: () => setState(() => _selectedLanguage = languageCode),
      borderRadius: BorderRadius.circular(12),
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: isSelected
              ? AppColours.brownLight.withValues(alpha: 0.1)
              : Colors.white,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: isSelected ? AppColours.brownLight : Colors.grey[300]!,
            width: isSelected ? 2 : 1,
          ),
        ),
        child: Row(
          children: [
            Text(flag, style: const TextStyle(fontSize: 32)),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: isSelected
                          ? AppColours.brownLight
                          : AppColours.brownDark,
                    ),
                  ),
                  Text(
                    subtitle,
                    style: TextStyle(
                      fontSize: 14,
                      color: Colors.grey[600],
                    ),
                  ),
                ],
              ),
            ),
            if (isSelected)
              const Icon(Icons.check_circle,
                  color: AppColours.brownLight, size: 28),
          ],
        ),
      ),
    );
  }

  Future<void> _applyLanguage() async {
    setState(() => _isApplying = true);

    final newLocale = Locale(_selectedLanguage);
    await context.setLocale(newLocale);

    if (!mounted) return;

    // Set locale for all cubits
    final locale = _selectedLanguage;
    context.read<ProductsCubit>().setLocale(locale);
    context.read<CategoriesCubit>().setLocale(locale);
    context.read<CartCubit>().setLocale(locale);
    context.read<FavoritesCubit>().setLocale(locale);
    context.read<HomeSlidersCubit>().setLocale(locale);

    // Reset all cubits (this will reload data with new locale)
    context.read<ProductsCubit>().reset();
    context.read<CategoriesCubit>().reset();
    context.read<HomeSlidersCubit>().reset();

    // Reset user data if authenticated
    final authState = context.read<AuthCubit>().state;
    if (authState is AuthAuthenticated) {
      context.read<FavoritesCubit>().reset();
      context.read<CartCubit>().reset();
    }

    // Navigate to home
    if (mounted) {
      context.go('/home');
    }
  }
}
