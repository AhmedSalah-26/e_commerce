import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';

import '../../domain/entities/banner_entity.dart';

class BannerLinkTypeSelector extends StatelessWidget {
  final BannerLinkType selectedType;
  final ValueChanged<BannerLinkType> onChanged;

  const BannerLinkTypeSelector({
    super.key,
    required this.selectedType,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    return SegmentedButton<BannerLinkType>(
      segments: [
        ButtonSegment(
          value: BannerLinkType.none,
          label: Text('none'.tr()),
        ),
        ButtonSegment(
          value: BannerLinkType.product,
          label: Text('product'.tr()),
        ),
        ButtonSegment(
          value: BannerLinkType.category,
          label: Text('category'.tr()),
        ),
        ButtonSegment(
          value: BannerLinkType.offers,
          label: Text('offers'.tr()),
        ),
      ],
      selected: {selectedType},
      onSelectionChanged: (set) => onChanged(set.first),
    );
  }
}
