import 'package:flutter/material.dart';
import 'package:easy_localization/easy_localization.dart';

class ProfileFormFields extends StatelessWidget {
  final String email;
  final TextEditingController nameController;
  final TextEditingController phoneController;
  final bool isRtl;

  const ProfileFormFields({
    super.key,
    required this.email,
    required this.nameController,
    required this.phoneController,
    required this.isRtl,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        _buildEmailField(context),
        const SizedBox(height: 12),
        _buildNameField(context),
        const SizedBox(height: 12),
        _buildPhoneField(context),
      ],
    );
  }

  Widget _buildEmailField(BuildContext context) {
    final theme = Theme.of(context);
    return TextField(
      controller: TextEditingController(text: email),
      readOnly: true,
      style: TextStyle(color: theme.colorScheme.onSurface),
      decoration: InputDecoration(
        labelText: 'email'.tr(),
        prefixIcon: Icon(Icons.email_outlined,
            color: theme.colorScheme.onSurface.withValues(alpha: 0.6)),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
        ),
        filled: true,
        fillColor: theme.colorScheme.onSurface.withValues(alpha: 0.05),
      ),
    );
  }

  Widget _buildNameField(BuildContext context) {
    final theme = Theme.of(context);
    return TextField(
      controller: nameController,
      style: TextStyle(color: theme.colorScheme.onSurface),
      decoration: InputDecoration(
        labelText: 'full_name'.tr(),
        prefixIcon: Icon(Icons.person_outline,
            color: theme.colorScheme.onSurface.withValues(alpha: 0.6)),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
        ),
      ),
    );
  }

  Widget _buildPhoneField(BuildContext context) {
    final theme = Theme.of(context);
    return TextField(
      controller: phoneController,
      keyboardType: TextInputType.phone,
      style: TextStyle(color: theme.colorScheme.onSurface),
      decoration: InputDecoration(
        labelText: 'phone'.tr(),
        prefixIcon: Icon(Icons.phone_outlined,
            color: theme.colorScheme.onSurface.withValues(alpha: 0.6)),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
        ),
      ),
    );
  }
}
