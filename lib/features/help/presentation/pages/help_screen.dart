import 'dart:ui' as ui;
import 'package:flutter/material.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:url_launcher/url_launcher.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../Core/Theme/app_text_style.dart';

class HelpScreen extends StatelessWidget {
  const HelpScreen({super.key});

  Future<void> _launchEmail() async {
    final Uri emailUri = Uri(
      scheme: 'mailto',
      path: 'support@mystore-eg.com',
      query: 'subject=استفسار عن التطبيق',
    );
    if (await canLaunchUrl(emailUri)) {
      await launchUrl(emailUri);
    }
  }

  Future<void> _launchPhone() async {
    final Uri phoneUri = Uri(scheme: 'tel', path: '+201234567890');
    if (await canLaunchUrl(phoneUri)) {
      await launchUrl(phoneUri);
    }
  }

  Future<void> _launchWhatsApp() async {
    final Uri whatsappUri = Uri.parse('https://wa.me/201234567890');
    if (await canLaunchUrl(whatsappUri)) {
      await launchUrl(whatsappUri, mode: LaunchMode.externalApplication);
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
          title: Text(
            isRtl ? 'المساعدة والدعم' : 'Help & Support',
            style: const TextStyle(
              fontFamily: 'Changa',
            ),
          ),
          backgroundColor: AppColours.primary,
          foregroundColor: Colors.white,
          elevation: 0,
        ),
        body: SafeArea(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const SizedBox(height: 16),
                // Header section
                Container(
                  width: double.infinity,
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
                    borderRadius: BorderRadius.circular(16),
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
                        Icons.support_agent,
                        size: 64,
                        color: Colors.white,
                      ),
                      const SizedBox(height: 16),
                      Text(
                        isRtl ? 'كيف يمكننا مساعدتك؟' : 'How can we help you?',
                        style: AppTextStyle.semiBold_22_white,
                        textAlign: TextAlign.center,
                      ),
                      const SizedBox(height: 8),
                      Text(
                        isRtl
                            ? 'نحن هنا لمساعدتك في أي وقت'
                            : 'We are here to help you anytime',
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 14,
                        ),
                        textAlign: TextAlign.center,
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 32),
                // Contact Section
                Text(
                  isRtl ? 'اتصل بنا' : 'Contact Us',
                  style: AppTextStyle.semiBold_20_dark_brown,
                ),
                const SizedBox(height: 16),
                _buildContactCard(
                  icon: Icons.email_outlined,
                  title: isRtl ? 'البريد الإلكتروني' : 'Email',
                  subtitle: 'support@mystore-eg.com',
                  onTap: _launchEmail,
                ),
                const SizedBox(height: 12),
                _buildContactCard(
                  icon: Icons.phone_outlined,
                  title: isRtl ? 'الهاتف' : 'Phone',
                  subtitle: '+20 123 456 7890',
                  onTap: _launchPhone,
                ),
                const SizedBox(height: 12),
                _buildContactCard(
                  icon: Icons.chat_outlined,
                  title: isRtl ? 'واتساب' : 'WhatsApp',
                  subtitle: isRtl
                      ? 'تواصل معنا عبر واتساب'
                      : 'Chat with us on WhatsApp',
                  onTap: _launchWhatsApp,
                ),
                const SizedBox(height: 32),
                // Working Hours
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(20),
                  decoration: BoxDecoration(
                    color: AppColours.greyLighter,
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(
                      color: AppColours.greyLight,
                      width: 1,
                    ),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          const Icon(
                            Icons.access_time,
                            color: AppColours.primary,
                            size: 24,
                          ),
                          const SizedBox(width: 12),
                          Text(
                            isRtl ? 'ساعات العمل' : 'Working Hours',
                            style: AppTextStyle.semiBold_18_white.copyWith(
                              color: AppColours.primary,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 16),
                      _buildWorkingHourRow(
                        isRtl ? 'السبت - الخميس' : 'Saturday - Thursday',
                        isRtl ? '9:00 ص - 6:00 م' : '9:00 AM - 6:00 PM',
                      ),
                      const SizedBox(height: 8),
                      _buildWorkingHourRow(
                        isRtl ? 'الجمعة' : 'Friday',
                        isRtl ? 'مغلق' : 'Closed',
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 32),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildContactCard({
    required IconData icon,
    required String title,
    required String subtitle,
    required VoidCallback onTap,
  }) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: AppColours.greyLight,
          width: 1.5,
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withValues(alpha: 0.1),
            blurRadius: 4,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(12),
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: AppColours.primary.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Icon(
                    icon,
                    color: AppColours.primary,
                    size: 28,
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        title,
                        style: AppTextStyle.semiBold_16_dark_brown,
                      ),
                      const SizedBox(height: 4),
                      Text(
                        subtitle,
                        style: AppTextStyle.normal_14_greyDark,
                      ),
                    ],
                  ),
                ),
                const Icon(
                  Icons.arrow_forward_ios,
                  color: AppColours.greyMedium,
                  size: 18,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildWorkingHourRow(String day, String hours) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          day,
          style: AppTextStyle.normal_14_greyDark,
        ),
        Text(
          hours,
          style: AppTextStyle.semiBold_16_dark_brown,
        ),
      ],
    );
  }
}
