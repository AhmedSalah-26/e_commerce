import 'package:auto_size_text/auto_size_text.dart';
import 'package:flutter/material.dart';
import '../../../../core/theme/app_text_style.dart';

class StoreHeaderCard extends StatelessWidget {
  final String? storeName;
  final String? storeDescription;
  final String? storeAddress;
  final String? storePhone;
  final String? storeLogo;

  const StoreHeaderCard({
    super.key,
    this.storeName,
    this.storeDescription,
    this.storeAddress,
    this.storePhone,
    this.storeLogo,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final displayName = storeName ?? '';
    final initial = displayName.isNotEmpty ? displayName[0].toUpperCase() : 'S';

    return Container(
      margin: const EdgeInsets.fromLTRB(16, 8, 16, 8),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: theme.colorScheme.surface,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: theme.colorScheme.outline),
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
          _buildStoreLogo(initial, theme),
          const SizedBox(width: 12),
          // Store Info
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                _buildStoreName(displayName, theme),
                if (storeDescription != null &&
                    storeDescription!.isNotEmpty) ...[
                  const SizedBox(height: 4),
                  AutoSizeText(
                    storeDescription!,
                    style: AppTextStyle.normal_12_greyDark.copyWith(
                      color: theme.colorScheme.onSurface.withValues(alpha: 0.6),
                    ),
                    maxLines: 2,
                    minFontSize: 10,
                    overflow: TextOverflow.ellipsis,
                  ),
                ],
                if (_hasContactInfo) ...[
                  const SizedBox(height: 4),
                  _buildContactInfo(theme),
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

  Widget _buildStoreLogo(String initial, ThemeData theme) {
    return Container(
      width: 50,
      height: 50,
      decoration: BoxDecoration(
        gradient: storeLogo == null
            ? LinearGradient(
                colors: [
                  theme.colorScheme.primary.withValues(alpha: 0.7),
                  theme.colorScheme.primary
                ],
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

  Widget _buildStoreName(String displayName, ThemeData theme) {
    return Row(
      children: [
        Flexible(
          child: AutoSizeText(
            displayName,
            style: AppTextStyle.semiBold_16_dark_brown.copyWith(
              color: theme.colorScheme.onSurface,
            ),
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

  Widget _buildContactInfo(ThemeData theme) {
    return Row(
      children: [
        if (storeAddress != null && storeAddress!.isNotEmpty) ...[
          Icon(Icons.location_on_outlined,
              size: 12,
              color: theme.colorScheme.onSurface.withValues(alpha: 0.6)),
          const SizedBox(width: 2),
          Flexible(
            child: AutoSizeText(
              storeAddress!,
              style: AppTextStyle.normal_12_greyDark.copyWith(
                color: theme.colorScheme.onSurface.withValues(alpha: 0.6),
              ),
              maxLines: 1,
              minFontSize: 8,
              overflow: TextOverflow.ellipsis,
            ),
          ),
        ],
        if (storePhone != null && storePhone!.isNotEmpty) ...[
          if (storeAddress != null && storeAddress!.isNotEmpty)
            Text(' • ',
                style: TextStyle(
                    color: theme.colorScheme.onSurface.withValues(alpha: 0.6))),
          Icon(Icons.phone_outlined,
              size: 12,
              color: theme.colorScheme.onSurface.withValues(alpha: 0.6)),
          const SizedBox(width: 2),
          AutoSizeText(
            storePhone!,
            style: AppTextStyle.normal_12_greyDark.copyWith(
              color: theme.colorScheme.onSurface.withValues(alpha: 0.6),
            ),
            maxLines: 1,
            minFontSize: 8,
          ),
        ],
      ],
    );
  }
}
