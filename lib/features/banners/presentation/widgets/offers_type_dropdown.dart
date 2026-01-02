import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';

class OffersTypeDropdown extends StatelessWidget {
  final String? value;
  final ValueChanged<String?> onChanged;

  const OffersTypeDropdown({
    super.key,
    this.value,
    required this.onChanged,
  });

  static const List<Map<String, String>> offerTypes = [
    {'value': 'flash-sale', 'label': 'فلاش سيل'},
    {'value': 'best-deals', 'label': 'أفضل العروض'},
    {'value': 'new-arrivals', 'label': 'وصل حديثاً'},
  ];

  @override
  Widget build(BuildContext context) {
    final validValue =
        offerTypes.any((t) => t['value'] == value) ? value : null;

    return DropdownButtonFormField<String>(
      // ignore: deprecated_member_use
      value: validValue,
      decoration: InputDecoration(
        labelText: 'offer_type'.tr(),
        border: const OutlineInputBorder(),
      ),
      hint: const Text('اختر نوع العرض'),
      items: offerTypes.map((type) {
        return DropdownMenuItem<String>(
          value: type['value'],
          child: Text(type['label']!),
        );
      }).toList(),
      onChanged: onChanged,
    );
  }
}
