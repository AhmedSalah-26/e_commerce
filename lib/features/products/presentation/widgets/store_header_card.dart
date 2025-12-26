import 'package:auto_size_text/auto_size_text.dart';
import 'package:flutter/material.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_text_style.dart';

class StoreHeaderCard extends StatelessWidget {
  final String? storeName;
  final String? storeAddress;
  final String? storePhone;
  final String? storeLogo;

  const StoreHeaderCard({
    super.key,
    this.storeName,
    this.storeAddress,
    this.storePhone,
    this.storeLogo,
  });

  @override
  Widget build(BuildContext context) {
    final displayName = storeName ?? '';
    final initial = displayName.isNotEmpty ? displayName[0].toUpperCase() : 'S';

    return Container(
      margin: const EdgeInsets.fromLTRB(16, 8, 16, 8),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: AppColours.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.05),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        children: [
          // Store Logo/Avatar
          _buildStoreLogo(initial),
          const SizedBox(width: 12),
          // Store Info
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                _buildStoreName(displayName),
                if (_hasContactInfo) ...[
                  const SizedBox(height: 4),
                  _buildContactInfo(),
                ],
              ],
            ),
          ),
        ],
      ),
    );
  }

  bool get _hasContactInfo =>
      (storeAddress != null && storeAddress!.isNotEmpty) ||
      (storePhone != null && storePhone!.isNotEmpty);

  Widget _buildStoreLogo(String initial) {
    return Container(
      width: 50,
      height: 50,
      decoration: BoxDecoration(
        gradient: storeLogo == null
            ? const LinearGradient(
                colors: [AppColours.brownLight, AppColours.primaryColor],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              )
            : null,
        borderRadius: BorderRadius.circular(25),
        image: storeLogo != null
            ? DecorationImage(
                image: NetworkImage(storeLogo!),
                fit: BoxFit.cover,
              )
            : null,
      ),
      child: storeLogo == null
          ? Center(
              child: Text(
                initial,
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                ),
              ),
            )
          : null,
    );
  }

  Widget _buildStoreName(String displayName) {
    return Row(
      children: [
        Flexible(
          child: AutoSizeText(
            displayName,
            style: AppTextStyle.semiBold_16_dark_brown,
            maxLines: 1,
            minFontSize: 10,
            overflow: TextOverflow.ellipsis,
          ),
        ),
        const SizedBox(width: 4),
        const Icon(Icons.verified, color: Colors.blue, size: 16),
      ],
    );
  }

  Widget _buildContactInfo() {
    return Row(
      children: [
        if (storeAddress != null && storeAddress!.isNotEmpty) ...[
          const Icon(Icons.location_on_outlined,
              size: 12, color: AppColours.greyDark),
          const SizedBox(width: 2),
          Flexible(
            child: AutoSizeText(
              storeAddress!,
              style: AppTextStyle.normal_12_greyDark,
              maxLines: 1,
              minFontSize: 8,
              overflow: TextOverflow.ellipsis,
            ),
          ),
        ],
        if (storePhone != null && storePhone!.isNotEmpty) ...[
          if (storeAddress != null && storeAddress!.isNotEmpty)
            const Text(' • ', style: TextStyle(color: AppColours.greyDark)),
          const Icon(Icons.phone_outlined,
              size: 12, color: AppColours.greyDark),
          const SizedBox(width: 2),
          AutoSizeText(
            storePhone!,
            style: AppTextStyle.normal_12_greyDark,
            maxLines: 1,
            minFontSize: 8,
          ),
        ],
      ],
    );
  }
}
