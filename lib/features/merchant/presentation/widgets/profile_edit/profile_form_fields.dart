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
        _buildEmailField(),
        const SizedBox(height: 12),
        _buildNameField(),
        const SizedBox(height: 12),
        _buildPhoneField(),
      ],
    );
  }

  Widget _buildEmailField() {
    return TextField(
      controller: TextEditingController(text: email),
      readOnly: true,
      decoration: InputDecoration(
        labelText: 'email'.tr(),
        prefixIcon: const Icon(Icons.email_outlined),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
        ),
        filled: true,
        fillColor: Colors.grey.shade100,
      ),
    );
  }

  Widget _buildNameField() {
    return TextField(
      controller: nameController,
      decoration: InputDecoration(
        labelText: 'full_name'.tr(),
        prefixIcon: const Icon(Icons.person_outline),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
        ),
      ),
    );
  }

  Widget _buildPhoneField() {
    return TextField(
      controller: phoneController,
      keyboardType: TextInputType.phone,
      decoration: InputDecoration(
        labelText: 'phone'.tr(),
        prefixIcon: const Icon(Icons.phone_outlined),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
        ),
      ),
    );
  }
}
