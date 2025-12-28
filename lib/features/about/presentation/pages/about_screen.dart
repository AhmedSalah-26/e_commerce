import 'dart:ui' as ui;
import 'package:flutter/material.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:package_info_plus/package_info_plus.dart';
import '../../../../Core/Theme/app_text_style.dart';
import '../widgets/about_widgets.dart';

class AboutScreen extends StatefulWidget {
  const AboutScreen({super.key});

  @override
  State<AboutScreen> createState() => _AboutScreenState();
}

class _AboutScreenState extends State<AboutScreen> {
  String appVersion = '1.0.0';
  String buildNumber = '1';

  @override
  void initState() {
    super.initState();
    _getAppVersion();
  }

  Future<void> _getAppVersion() async {
    try {
      final packageInfo = await PackageInfo.fromPlatform();
      setState(() {
        appVersion = packageInfo.version;
        buildNumber = packageInfo.buildNumber;
      });
    } catch (e) {
      // Keep default values
    }
  }

  @override
  Widget build(BuildContext context) {
    final isRtl = context.locale.languageCode == 'ar';
    final theme = Theme.of(context);

    return Directionality(
      textDirection: isRtl ? ui.TextDirection.rtl : ui.TextDirection.ltr,
      child: Scaffold(
        backgroundColor: theme.scaffoldBackgroundColor,
        appBar: AppBar(
          backgroundColor: theme.scaffoldBackgroundColor,
          leading: IconButton(
            icon: Icon(Icons.arrow_back, color: theme.colorScheme.primary),
            onPressed: () => Navigator.pop(context),
          ),
          title: Text(
            isRtl ? 'عن التطبيق' : 'About the App',
            style: AppTextStyle.semiBold_20_dark_brown.copyWith(
              color: theme.colorScheme.primary,
            ),
          ),
          centerTitle: true,
        ),
        body: SafeArea(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                const SizedBox(height: 24),
                // App Logo and Name
                Container(
                  padding: const EdgeInsets.all(24),
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      colors: [
                        theme.colorScheme.primary,
                        theme.colorScheme.primary.withValues(alpha: 0.7),
                      ],
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                    ),
                    borderRadius: BorderRadius.circular(20),
                    boxShadow: [
                      BoxShadow(
                        color: theme.colorScheme.primary.withValues(alpha: 0.3),
                        blurRadius: 10,
                        offset: const Offset(0, 4),
                      ),
                    ],
                  ),
                  child: Column(
                    children: [
                      const Icon(
                        Icons.store,
                        size: 80,
                        color: Colors.white,
                      ),
                      const SizedBox(height: 16),
                      Text(
                        'about_store_name'.tr(),
                        style: const TextStyle(
                          fontSize: 26,
                          fontWeight: FontWeight.w600,
                          color: Colors.white,
                          fontFamily: 'Changa',
                        ),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        '${'about_version'.tr()}: $appVersion',
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 14,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        'Build: $buildNumber',
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 12,
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 32),
                // App Description
                AboutSectionCard(
                  icon: Icons.info_outline,
                  title: 'about_app_title'.tr(),
                  child: Text(
                    'about_description'.tr(),
                    style: AppTextStyle.normal_14_greyDark.copyWith(
                      color: theme.colorScheme.onSurface.withValues(alpha: 0.7),
                    ),
                    textAlign: TextAlign.justify,
                  ),
                ),
                const SizedBox(height: 24),
                // Features Section
                AboutSectionCard(
                  icon: Icons.star_outline,
                  title: 'about_features'.tr(),
                  child: Column(
                    children: [
                      AboutFeatureItem(
                        icon: Icons.inventory_2_outlined,
                        text: 'about_feature_1'.tr(),
                      ),
                      AboutFeatureItem(
                        icon: Icons.security_outlined,
                        text: 'about_feature_2'.tr(),
                      ),
                      AboutFeatureItem(
                        icon: Icons.local_shipping_outlined,
                        text: 'about_feature_3'.tr(),
                      ),
                      AboutFeatureItem(
                        icon: Icons.support_agent_outlined,
                        text: 'about_feature_4'.tr(),
                      ),
                      AboutFeatureItem(
                        icon: Icons.favorite_outline,
                        text: 'about_feature_5'.tr(),
                      ),
                      AboutFeatureItem(
                        icon: Icons.star_rate_outlined,
                        text: isRtl
                            ? 'نظام تقييمات ومراجعات المنتجات'
                            : 'Product ratings and reviews system',
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 24),
                // Company Info
                AboutSectionCard(
                  icon: Icons.business_outlined,
                  title: 'about_developer'.tr(),
                  child: Column(
                    children: [
                      AboutInfoRow(
                        icon: Icons.business,
                        label: isRtl ? 'اسم الشركة' : 'Company Name',
                        value: 'about_company_name'.tr(),
                      ),
                      const SizedBox(height: 12),
                      AboutInfoRow(
                        icon: Icons.email_outlined,
                        label: 'contact_email'.tr(),
                        value: 'support_email'.tr(),
                      ),
                      const SizedBox(height: 12),
                      AboutInfoRow(
                        icon: Icons.phone_outlined,
                        label: 'contact_phone'.tr(),
                        value: 'support_phone'.tr(),
                      ),
                      const SizedBox(height: 12),
                      AboutInfoRow(
                        icon: Icons.location_on_outlined,
                        label: isRtl ? 'الموقع' : 'Location',
                        value: 'about_location'.tr(),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 32),
                // Footer
                Text(
                  'about_copyright'.tr(),
                  style: AppTextStyle.normal_12_greyDark.copyWith(
                    color: theme.colorScheme.onSurface.withValues(alpha: 0.6),
                  ),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 8),
                Text(
                  'about_rights_reserved'.tr(),
                  style: AppTextStyle.normal_12_greyDark.copyWith(
                    color: theme.colorScheme.onSurface.withValues(alpha: 0.6),
                  ),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 24),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
