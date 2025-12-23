import 'dart:ui' as ui;
import 'package:flutter/material.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:package_info_plus/package_info_plus.dart';
import '../../../../core/theme/app_colors.dart';
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

    return Directionality(
      textDirection: isRtl ? ui.TextDirection.rtl : ui.TextDirection.ltr,
      child: Scaffold(
        backgroundColor: AppColours.white,
        appBar: AppBar(
          backgroundColor: Colors.white,
          elevation: 0,
          leading: IconButton(
            icon: const Icon(Icons.arrow_back, color: AppColours.brownMedium),
            onPressed: () => Navigator.pop(context),
          ),
          title: Text(
            isRtl ? 'عن التطبيق' : 'About the App',
            style: AppTextStyle.semiBold_20_dark_brown.copyWith(
              color: AppColours.brownMedium,
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
                    gradient: const LinearGradient(
                      colors: [
                        AppColours.primary,
                        AppColours.brownLight,
                      ],
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                    ),
                    borderRadius: BorderRadius.circular(20),
                    boxShadow: [
                      BoxShadow(
                        color: AppColours.primary.withValues(alpha: 0.3),
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
                        isRtl ? 'متجري' : 'My Store',
                        style: AppTextStyle.semiBold_26_white,
                      ),
                      const SizedBox(height: 8),
                      Text(
                        '${isRtl ? 'الإصدار' : 'Version'}: $appVersion',
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
                  title: isRtl ? 'عن التطبيق' : 'About the App',
                  child: Text(
                    isRtl
                        ? 'متجري هو منصة تسوق إلكترونية مصرية متكاملة تربط بين العملاء والتجار. نوفر تجربة تسوق سلسة وآمنة مع مجموعة واسعة من المنتجات عالية الجودة بأسعار تنافسية. نسعى لتوفير أفضل خدمة عملاء وتجربة مستخدم مميزة.'
                        : 'My Store is an integrated Egyptian e-commerce platform connecting customers with merchants. We provide a seamless and secure shopping experience with a wide range of high-quality products at competitive prices. We strive to provide the best customer service and exceptional user experience.',
                    style: AppTextStyle.normal_14_greyDark,
                    textAlign: TextAlign.justify,
                  ),
                ),
                const SizedBox(height: 24),
                // Features Section
                AboutSectionCard(
                  icon: Icons.star_outline,
                  title: isRtl ? 'المميزات الرئيسية' : 'Key Features',
                  child: Column(
                    children: [
                      AboutFeatureItem(
                        icon: Icons.inventory_2_outlined,
                        text: isRtl
                            ? 'تصفح آلاف المنتجات من مختلف الفئات'
                            : 'Browse thousands of products from various categories',
                      ),
                      AboutFeatureItem(
                        icon: Icons.security_outlined,
                        text: isRtl
                            ? 'نظام دفع آمن عند الاستلام'
                            : 'Secure cash on delivery payment system',
                      ),
                      AboutFeatureItem(
                        icon: Icons.local_shipping_outlined,
                        text: isRtl
                            ? 'تتبع فوري لحالة طلباتك'
                            : 'Real-time order tracking',
                      ),
                      AboutFeatureItem(
                        icon: Icons.support_agent_outlined,
                        text: isRtl
                            ? 'دعم فني متاح طوال الأسبوع'
                            : 'Technical support available all week',
                      ),
                      AboutFeatureItem(
                        icon: Icons.favorite_outline,
                        text: isRtl
                            ? 'قائمة المفضلة لحفظ منتجاتك'
                            : 'Favorites list to save your products',
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
                  title: isRtl ? 'معلومات الشركة' : 'Company Information',
                  child: Column(
                    children: [
                      AboutInfoRow(
                        icon: Icons.business,
                        label: isRtl ? 'اسم الشركة' : 'Company Name',
                        value: 'My Store Egypt',
                      ),
                      const SizedBox(height: 12),
                      AboutInfoRow(
                        icon: Icons.email_outlined,
                        label: isRtl ? 'البريد الإلكتروني' : 'Email',
                        value: 'info@mystore-eg.com',
                      ),
                      const SizedBox(height: 12),
                      AboutInfoRow(
                        icon: Icons.phone_outlined,
                        label: isRtl ? 'الهاتف' : 'Phone',
                        value: '+20 123 456 7890',
                      ),
                      const SizedBox(height: 12),
                      AboutInfoRow(
                        icon: Icons.location_on_outlined,
                        label: isRtl ? 'الموقع' : 'Location',
                        value: isRtl ? 'القاهرة، مصر' : 'Cairo, Egypt',
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 32),
                // Footer
                Text(
                  '© 2024 ${isRtl ? 'متجري' : 'My Store'}',
                  style: AppTextStyle.normal_12_greyDark,
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 8),
                Text(
                  isRtl ? 'جميع الحقوق محفوظة' : 'All rights reserved',
                  style: AppTextStyle.normal_12_greyDark,
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
