import 'package:flutter/material.dart';

class CategoryFormFields extends StatelessWidget {
  final TextEditingController nameArController;
  final TextEditingController nameEnController;
  final TextEditingController descriptionController;
  final bool isActive;
  final ValueChanged<bool> onActiveChanged;
  final bool isRtl;

  const CategoryFormFields({
    super.key,
    required this.nameArController,
    required this.nameEnController,
    required this.descriptionController,
    required this.isActive,
    required this.onActiveChanged,
    required this.isRtl,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        TextFormField(
          controller: nameArController,
          decoration: InputDecoration(
            labelText: isRtl ? 'الاسم بالعربية' : 'Name (Arabic)',
            border: const OutlineInputBorder(),
          ),
          validator: (value) {
            if (value == null || value.isEmpty) {
              return isRtl ? 'الرجاء إدخال الاسم' : 'Please enter name';
            }
            return null;
          },
        ),
        const SizedBox(height: 12),
        TextFormField(
          controller: nameEnController,
          decoration: InputDecoration(
            labelText: isRtl ? 'الاسم بالإنجليزية' : 'Name (English)',
            border: const OutlineInputBorder(),
          ),
        ),
        const SizedBox(height: 12),
        TextFormField(
          controller: descriptionController,
          decoration: InputDecoration(
            labelText: isRtl ? 'الوصف' : 'Description',
            border: const OutlineInputBorder(),
          ),
          maxLines: 3,
        ),
        const SizedBox(height: 16),
        SwitchListTile(
          title: Text(isRtl ? 'نشط' : 'Active'),
          value: isActive,
          onChanged: onActiveChanged,
        ),
      ],
    );
  }
}
