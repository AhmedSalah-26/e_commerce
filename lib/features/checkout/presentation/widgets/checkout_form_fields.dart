import 'dart:ui' as ui;
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';

class CheckoutFormFields extends StatelessWidget {
  final TextEditingController addressController;
  final TextEditingController nameController;
  final TextEditingController phoneController;
  final TextEditingController notesController;

  const CheckoutFormFields({
    super.key,
    required this.addressController,
    required this.nameController,
    required this.phoneController,
    required this.notesController,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildSectionTitle('delivery_address'.tr(), theme),
        const SizedBox(height: 12),
        _buildTextField(
          controller: addressController,
          hint: 'delivery_address_hint'.tr(),
          icon: Icons.location_on_outlined,
          maxLines: 3,
          theme: theme,
          validator: (value) {
            if (value == null || value.isEmpty) {
              return 'field_required'.tr();
            }
            return null;
          },
        ),
        const SizedBox(height: 16),
        _buildSectionTitle('customer_name'.tr(), theme),
        const SizedBox(height: 12),
        _buildTextField(
          controller: nameController,
          hint: 'customer_name'.tr(),
          icon: Icons.person_outlined,
          theme: theme,
          validator: (value) {
            if (value == null || value.isEmpty) {
              return 'field_required'.tr();
            }
            return null;
          },
        ),
        const SizedBox(height: 16),
        _buildSectionTitle('customer_phone'.tr(), theme),
        const SizedBox(height: 12),
        _buildTextField(
          controller: phoneController,
          hint: 'customer_phone'.tr(),
          icon: Icons.phone_outlined,
          keyboardType: TextInputType.phone,
          textDirection: ui.TextDirection.ltr,
          theme: theme,
          validator: (value) {
            if (value == null || value.isEmpty) {
              return 'field_required'.tr();
            }
            return null;
          },
        ),
        const SizedBox(height: 16),
        _buildSectionTitle('${'order_notes'.tr()} (${'optional'.tr()})', theme),
        const SizedBox(height: 12),
        _buildTextField(
          controller: notesController,
          hint: 'order_notes_hint'.tr(),
          icon: Icons.note_outlined,
          maxLines: 2,
          theme: theme,
        ),
      ],
    );
  }

  Widget _buildSectionTitle(String title, ThemeData theme) {
    return Text(
      title,
      style: TextStyle(
        fontSize: 18,
        fontWeight: FontWeight.bold,
        color: theme.colorScheme.primary,
      ),
    );
  }

  Widget _buildTextField({
    required TextEditingController controller,
    String? hint,
    required IconData icon,
    int maxLines = 1,
    TextInputType? keyboardType,
    ui.TextDirection? textDirection,
    String? Function(String?)? validator,
    required ThemeData theme,
  }) {
    return TextFormField(
      controller: controller,
      maxLines: maxLines,
      keyboardType: keyboardType,
      textDirection: textDirection,
      decoration: InputDecoration(
        hintText: hint,
        prefixIcon: Icon(icon, color: theme.colorScheme.primary),
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: theme.colorScheme.primary, width: 2),
        ),
      ),
      validator: validator,
    );
  }
}
