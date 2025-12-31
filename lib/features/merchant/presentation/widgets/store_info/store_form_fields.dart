import 'package:flutter/material.dart';

class StoreFormFields extends StatelessWidget {
  final TextEditingController nameController;
  final TextEditingController phoneController;
  final TextEditingController addressController;
  final TextEditingController descController;
  final bool isRtl;

  const StoreFormFields({
    super.key,
    required this.nameController,
    required this.phoneController,
    required this.addressController,
    required this.descController,
    required this.isRtl,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        TextField(
          controller: nameController,
          decoration: InputDecoration(
            labelText: isRtl ? 'اسم المتجر *' : 'Store Name *',
            prefixIcon: const Icon(Icons.store_outlined),
            border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
          ),
        ),
        const SizedBox(height: 12),
        TextField(
          controller: phoneController,
          keyboardType: TextInputType.phone,
          decoration: InputDecoration(
            labelText: isRtl ? 'رقم المتجر' : 'Store Phone',
            prefixIcon: const Icon(Icons.phone_outlined),
            border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
          ),
        ),
        const SizedBox(height: 12),
        TextField(
          controller: addressController,
          decoration: InputDecoration(
            labelText: isRtl ? 'عنوان المتجر' : 'Store Address',
            prefixIcon: const Icon(Icons.location_on_outlined),
            border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
          ),
        ),
        const SizedBox(height: 12),
        TextField(
          controller: descController,
          maxLines: 3,
          decoration: InputDecoration(
            labelText: isRtl ? 'وصف المتجر' : 'Store Description',
            prefixIcon: const Icon(Icons.description_outlined),
            border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
          ),
        ),
      ],
    );
  }
}
