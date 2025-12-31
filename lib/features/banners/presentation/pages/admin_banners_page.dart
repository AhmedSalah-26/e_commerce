import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:cached_network_image/cached_network_image.dart';

import '../../../../core/di/injection_container.dart';
import '../../data/datasources/banner_remote_datasource.dart';
import '../../domain/entities/banner_entity.dart';
import '../cubit/admin_banners_cubit.dart';
import '../widgets/banner_form_sheet.dart';

class AdminBannersPage extends StatelessWidget {
  const AdminBannersPage({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) =>
          AdminBannersCubit(sl<BannerRemoteDatasource>())..loadBanners(),
      child: const _AdminBannersView(),
    );
  }
}

class _AdminBannersView extends StatelessWidget {
  const _AdminBannersView();

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      appBar: AppBar(
        title: Text('banners_management'.tr()),
        centerTitle: true,
        actions: [
          IconButton(
            icon: const Icon(Icons.add),
            onPressed: () => _showBannerForm(context),
          ),
        ],
      ),
      body: BlocConsumer<AdminBannersCubit, AdminBannersState>(
        listener: (context, state) {
          if (state is AdminBannerSaved) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text(state.message),
                backgroundColor: Colors.green,
              ),
            );
          } else if (state is AdminBannersError) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text(state.message),
                backgroundColor: Colors.red,
              ),
            );
          }
        },
        builder: (context, state) {
          if (state is AdminBannersLoading) {
            return const Center(child: CircularProgressIndicator());
          }

          if (state is AdminBannersLoaded) {
            if (state.banners.isEmpty) {
              return Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(Icons.image_not_supported,
                        size: 80, color: theme.colorScheme.outline),
                    const SizedBox(height: 16),
                    Text('no_banners'.tr(), style: theme.textTheme.titleMedium),
                    const SizedBox(height: 16),
                    ElevatedButton.icon(
                      onPressed: () => _showBannerForm(context),
                      icon: const Icon(Icons.add),
                      label: Text('add_banner'.tr()),
                    ),
                  ],
                ),
              );
            }

            return RefreshIndicator(
              onRefresh: () => context.read<AdminBannersCubit>().loadBanners(),
              child: ReorderableListView.builder(
                padding: const EdgeInsets.all(16),
                itemCount: state.banners.length,
                onReorder: (oldIndex, newIndex) {
                  // TODO: Implement reorder
                },
                itemBuilder: (context, index) {
                  final banner = state.banners[index];
                  return _BannerCard(
                    key: ValueKey(banner.id),
                    banner: banner,
                    onEdit: () => _showBannerForm(context, banner: banner),
                    onDelete: () => _confirmDelete(context, banner),
                    onToggle: () => context
                        .read<AdminBannersCubit>()
                        .toggleBanner(banner.id),
                  );
                },
              ),
            );
          }

          if (state is AdminBannersError) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.error_outline,
                      size: 60, color: theme.colorScheme.error),
                  const SizedBox(height: 16),
                  Text(state.message),
                  const SizedBox(height: 16),
                  ElevatedButton(
                    onPressed: () =>
                        context.read<AdminBannersCubit>().loadBanners(),
                    child: Text('retry'.tr()),
                  ),
                ],
              ),
            );
          }

          return const SizedBox.shrink();
        },
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => _showBannerForm(context),
        child: const Icon(Icons.add),
      ),
    );
  }

  void _showBannerForm(BuildContext context, {BannerEntity? banner}) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => BlocProvider.value(
        value: context.read<AdminBannersCubit>(),
        child: BannerFormSheet(banner: banner),
      ),
    );
  }

  void _confirmDelete(BuildContext context, BannerEntity banner) {
    showDialog(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: Text('delete_banner'.tr()),
        content: Text('delete_banner_confirm'.tr()),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(dialogContext),
            child: Text('cancel'.tr()),
          ),
          TextButton(
            onPressed: () {
              Navigator.pop(dialogContext);
              context
                  .read<AdminBannersCubit>()
                  .deleteBanner(banner.id, banner.imageUrl);
            },
            style: TextButton.styleFrom(foregroundColor: Colors.red),
            child: Text('delete'.tr()),
          ),
        ],
      ),
    );
  }
}

class _BannerCard extends StatelessWidget {
  final BannerEntity banner;
  final VoidCallback onEdit;
  final VoidCallback onDelete;
  final VoidCallback onToggle;

  const _BannerCard({
    super.key,
    required this.banner,
    required this.onEdit,
    required this.onDelete,
    required this.onToggle,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      clipBehavior: Clip.antiAlias,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Banner image
          AspectRatio(
            aspectRatio: 16 / 7,
            child: banner.imageUrl.isNotEmpty
                ? CachedNetworkImage(
                    imageUrl: banner.imageUrl,
                    fit: BoxFit.cover,
                    placeholder: (_, __) => Container(
                      color: theme.colorScheme.surfaceContainerHighest,
                      child: const Center(child: CircularProgressIndicator()),
                    ),
                    errorWidget: (_, __, ___) => Container(
                      color: theme.colorScheme.surfaceContainerHighest,
                      child: const Icon(Icons.broken_image, size: 50),
                    ),
                  )
                : Container(
                    color: theme.colorScheme.surfaceContainerHighest,
                    child: const Icon(Icons.image, size: 50),
                  ),
          ),
          // Banner info
          Padding(
            padding: const EdgeInsets.all(12),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Expanded(
                      child: Text(
                        banner.titleAr,
                        style: theme.textTheme.titleMedium
                            ?.copyWith(fontWeight: FontWeight.bold),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                    // Status chip
                    Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 8, vertical: 4),
                      decoration: BoxDecoration(
                        color: banner.isActive
                            ? Colors.green.withValues(alpha: 0.2)
                            : Colors.red.withValues(alpha: 0.2),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Text(
                        banner.isActive ? 'active'.tr() : 'inactive'.tr(),
                        style: TextStyle(
                          fontSize: 12,
                          color: banner.isActive ? Colors.green : Colors.red,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 4),
                // Link type
                Row(
                  children: [
                    Icon(Icons.link,
                        size: 16, color: theme.colorScheme.outline),
                    const SizedBox(width: 4),
                    Text(
                      _getLinkTypeText(banner.linkType),
                      style: theme.textTheme.bodySmall
                          ?.copyWith(color: theme.colorScheme.outline),
                    ),
                    if (banner.linkValue != null) ...[
                      const SizedBox(width: 8),
                      Expanded(
                        child: Text(
                          banner.linkValue!,
                          style: theme.textTheme.bodySmall
                              ?.copyWith(color: theme.colorScheme.primary),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                    ],
                  ],
                ),
                const SizedBox(height: 8),
                // Actions
                Row(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    TextButton.icon(
                      onPressed: onToggle,
                      icon: Icon(
                        banner.isActive
                            ? Icons.visibility_off
                            : Icons.visibility,
                        size: 18,
                      ),
                      label: Text(banner.isActive
                          ? 'deactivate'.tr()
                          : 'activate'.tr()),
                    ),
                    TextButton.icon(
                      onPressed: onEdit,
                      icon: const Icon(Icons.edit, size: 18),
                      label: Text('edit'.tr()),
                    ),
                    TextButton.icon(
                      onPressed: onDelete,
                      icon: const Icon(Icons.delete, size: 18),
                      label: Text('delete'.tr()),
                      style: TextButton.styleFrom(foregroundColor: Colors.red),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  String _getLinkTypeText(BannerLinkType type) {
    switch (type) {
      case BannerLinkType.product:
        return 'منتج';
      case BannerLinkType.category:
        return 'قسم';
      case BannerLinkType.url:
        return 'رابط';
      case BannerLinkType.offers:
        return 'عروض';
      case BannerLinkType.none:
        return 'بدون رابط';
    }
  }
}
