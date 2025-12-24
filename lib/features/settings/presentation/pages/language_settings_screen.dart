import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_phoenix/flutter_phoenix.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/theme/app_colors.dart';

class LanguageSettingsScreen extends StatefulWidget {
  const LanguageSettingsScreen({super.key});

  @override
  State<LanguageSettingsScreen> createState() => _LanguageSettingsScreenState();
}

class _LanguageSettingsScreenState extends State<LanguageSettingsScreen> {
  late String _selectedLanguage;

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
                onPressed: hasChanges ? _applyLanguage : null,
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColours.brownLight,
                  foregroundColor: Colors.white,
                  disabledBackgroundColor: Colors.grey[300],
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                child: Text(
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
    final newLocale = Locale(_selectedLanguage);
    await context.setLocale(newLocale);

    // Restart app with Phoenix
    if (mounted) {
      Phoenix.rebirth(context);
    }
  }
}
