import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';

class AddressField extends StatelessWidget {
  final TextEditingController controller;

  const AddressField({
    super.key,
    required this.controller,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return TextFormField(
      controller: controller,
      maxLines: 2,
      decoration: InputDecoration(
        hintText: 'delivery_address_hint'.tr(),
        prefixIcon: Icon(Icons.home_outlined,
            color: theme.colorScheme.primary.withValues(alpha: 0.7)),
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(
              color: theme.colorScheme.outline.withValues(alpha: 0.3)),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: theme.colorScheme.primary, width: 1.5),
        ),
        contentPadding:
            const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      ),
      validator: (value) =>
          (value == null || value.isEmpty) ? 'field_required'.tr() : null,
    );
  }
}
