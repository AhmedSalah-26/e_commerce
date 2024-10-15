import 'package:flutter/material.dart';
import '../../../Core/Theme/app_colors.dart';
import '../../../Core/Theme/app_text_style.dart';

class SettingsScreen extends StatefulWidget {
  @override
  _SettingsScreenState createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  bool _isExpanded = false; // Track the expansion state

  @override
  Widget build(BuildContext context) {
    return Directionality(
      textDirection: TextDirection.rtl, // Right-to-left for Arabic language
      child: Scaffold(
        backgroundColor: AppColours.white,
        body: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              SizedBox(height: 40,),
              Text('تخصيص التطبيق', style: AppTextStyle.semiBold_16_dark_brown.copyWith(fontSize: 24,color: AppColours.primaryColor),),
              SizedBox(height: 16),
              _buildExpandableSettingItem('تغيير اللغة', Icons.language, ['العربية', 'English', 'Français']),
              _buildSettingItem('إشعارات', Icons.notifications),
              _buildSettingItem('الحساب', Icons.account_circle),
              _buildSettingItem('مساعدة', Icons.help),
              _buildSettingItem('تسجيل الخروج', Icons.logout),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildSettingItem(String title, IconData icon) {
    return Card(
      color: AppColours.white,
      margin: EdgeInsets.symmetric(vertical: 8.0),
      child: ListTile(
        leading: Icon(icon, color: AppColours.brownMedium),
        title: Text(title, style: AppTextStyle.normal_16_brownLight),
        trailing: Icon(Icons.arrow_forward_ios, color: AppColours.greyDark),
        contentPadding: EdgeInsets.symmetric(horizontal: 16.0),
        onTap: () {
          // Handle item tap
        },
      ),
    );
  }

  Widget _buildExpandableSettingItem(String title, IconData icon, List<String> options) {
    return Card(
      color: AppColours.white,
      margin: EdgeInsets.symmetric(vertical: 8.0),
      shape: RoundedRectangleBorder(
        side: BorderSide(
          color: _isExpanded ? AppColours.greyLighter : Colors.transparent, // Black border when expanded
          width: 1.0,
        ),
        borderRadius: BorderRadius.circular(10),
      ),
      child: ExpansionTile(


        leading: Icon(icon, color: AppColours.brownMedium),
        title: Text(title, style: AppTextStyle.normal_16_brownLight),
        onExpansionChanged: (expanded) {
          setState(() {
            _isExpanded = expanded; // Update the expansion state
          });
        },
        children: options.map((option) {
          return ListTile(
            title: Text(option, style: AppTextStyle.normal_16_brownLight),
            onTap: () {
              // Handle option tap
            },
          );
        }).toList(),
      ),
    );
  }
}
