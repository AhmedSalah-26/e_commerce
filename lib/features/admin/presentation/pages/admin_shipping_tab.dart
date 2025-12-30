import 'dart:ui' as ui;
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:easy_localization/easy_localization.dart';
import '../../../../core/di/injection_container.dart';
import '../../../../core/shared_widgets/toast.dart';
import '../../../shipping/domain/entities/governorate_entity.dart';
import '../../../shipping/presentation/cubit/shipping_cubit.dart';
import '../../../merchant/presentation/widgets/shipping_dialog/shipping_prices_list.dart';
import '../../../merchant/presentation/widgets/shipping_dialog/shipping_dialogs.dart';
import '../cubit/admin_cubit.dart';
import '../cubit/admin_state.dart';

class AdminShippingTab extends StatefulWidget {
  final bool isRtl;
  const AdminShippingTab({super.key, required this.isRtl});

  @override
  State<AdminShippingTab> createState() => _AdminShippingTabState();
}

class _AdminShippingTabState extends State<AdminShippingTab> {
  final _searchController = TextEditingController();
  String? _selectedMerchantId;
  String? _selectedMerchantName;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _loadMerchants();
    });
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  void _loadMerchants({String? search}) {
    if (!mounted) return;
    context.read<AdminCubit>().loadUsers(role: 'merchant', search: search);
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isMobile = MediaQuery.of(context).size.width < 600;

    if (_selectedMerchantId != null) {
      return _buildMerchantShipping(theme, isMobile);
    }

    return _buildMerchantsList(theme, isMobile);
  }

  Widget _buildMerchantsList(ThemeData theme, bool isMobile) {
    return Column(
      children: [
        _buildHeader(theme, isMobile),
        _buildSearchBar(theme, isMobile),
        Expanded(child: _buildMerchantsContent(theme, isMobile)),
      ],
    );
  }

  Widget _buildHeader(ThemeData theme, bool isMobile) {
    return Padding(
      padding: EdgeInsets.all(isMobile ? 12 : 16),
      child: Center(
        child: Text(
          widget.isRtl ? 'إدارة الشحن' : 'Shipping Management',
          style: TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.w600,
            color: theme.colorScheme.primary,
          ),
        ),
      ),
    );
  }

  Widget _buildSearchBar(ThemeData theme, bool isMobile) {
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: isMobile ? 12 : 16),
      child: TextField(
        controller: _searchController,
        decoration: InputDecoration(
          hintText: widget.isRtl
              ? 'بحث بالاسم أو الإيميل...'
              : 'Search by name or email...',
          prefixIcon: const Icon(Icons.search),
          suffixIcon: _searchController.text.isNotEmpty
              ? IconButton(
                  icon: const Icon(Icons.clear),
                  onPressed: () {
                    _searchController.clear();
                    _loadMerchants();
                  },
                )
              : null,
          border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
          isDense: isMobile,
        ),
        onSubmitted: (value) =>
            _loadMerchants(search: value.isEmpty ? null : value),
      ),
    );
  }

  Widget _buildMerchantsContent(ThemeData theme, bool isMobile) {
    return BlocBuilder<AdminCubit, AdminState>(
      builder: (context, state) {
        if (state is AdminInitial || state is AdminUsersLoading) {
          return const Center(child: CircularProgressIndicator());
        }
        if (state is AdminError) {
          return Center(child: Text(state.message));
        }
        if (state is AdminUsersLoaded) {
          if (state.users.isEmpty) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.store_outlined,
                      size: 64,
                      color:
                          theme.colorScheme.onSurface.withValues(alpha: 0.3)),
                  const SizedBox(height: 16),
                  Text(
                    widget.isRtl ? 'لا يوجد تجار' : 'No merchants found',
                    style: theme.textTheme.titleMedium?.copyWith(
                      color: theme.colorScheme.onSurface.withValues(alpha: 0.6),
                    ),
                  ),
                ],
              ),
            );
          }

          return RefreshIndicator(
            onRefresh: () async => _loadMerchants(),
            child: ListView.builder(
              padding: EdgeInsets.all(isMobile ? 12 : 16),
              itemCount: state.users.length,
              itemBuilder: (context, index) =>
                  _buildMerchantCard(state.users[index], theme, isMobile),
            ),
          );
        }
        return const SizedBox.shrink();
      },
    );
  }

  Widget _buildMerchantCard(
      Map<String, dynamic> merchant, ThemeData theme, bool isMobile) {
    final name = merchant['name'] ?? 'Unknown';
    final email = merchant['email'] ?? '';
    final id = merchant['id'] ?? '';

    return Card(
      margin: EdgeInsets.only(bottom: isMobile ? 8 : 12),
      child: ListTile(
        contentPadding: EdgeInsets.all(isMobile ? 12 : 16),
        leading: CircleAvatar(
          radius: isMobile ? 22 : 26,
          backgroundColor: theme.colorScheme.primary,
          child: Text(
            name.isNotEmpty ? name[0].toUpperCase() : 'M',
            style: TextStyle(color: Colors.white, fontSize: isMobile ? 16 : 18),
          ),
        ),
        title: Text(
          name,
          style: TextStyle(
              fontWeight: FontWeight.w600, fontSize: isMobile ? 14 : 16),
        ),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(email, style: TextStyle(fontSize: isMobile ? 12 : 13)),
            Text(
              'ID: ${id.length > 8 ? id.substring(0, 8) : id}...',
              style: TextStyle(
                  fontSize: isMobile ? 10 : 11,
                  color: theme.colorScheme.onSurface.withValues(alpha: 0.5)),
            ),
          ],
        ),
        trailing: Icon(
          widget.isRtl ? Icons.chevron_left : Icons.chevron_right,
          color: theme.colorScheme.primary,
        ),
        onTap: () {
          setState(() {
            _selectedMerchantId = id;
            _selectedMerchantName = name;
          });
        },
      ),
    );
  }

  Widget _buildMerchantShipping(ThemeData theme, bool isMobile) {
    return BlocProvider(
      create: (_) =>
          sl<ShippingCubit>()..loadMerchantShippingPrices(_selectedMerchantId!),
      child: Directionality(
        textDirection:
            widget.isRtl ? ui.TextDirection.rtl : ui.TextDirection.ltr,
        child: Column(
          children: [
            _buildShippingHeader(theme, isMobile),
            Expanded(child: _buildShippingContent(theme)),
          ],
        ),
      ),
    );
  }

  Widget _buildShippingHeader(ThemeData theme, bool isMobile) {
    return Container(
      padding: EdgeInsets.all(isMobile ? 12 : 16),
      decoration: BoxDecoration(
        color: theme.colorScheme.surface,
        border: Border(bottom: BorderSide(color: theme.dividerColor)),
      ),
      child: Row(
        children: [
          IconButton(
            icon: const Icon(Icons.arrow_back),
            onPressed: () {
              setState(() {
                _selectedMerchantId = null;
                _selectedMerchantName = null;
              });
              _loadMerchants();
            },
          ),
          const SizedBox(width: 8),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  widget.isRtl ? 'أسعار الشحن' : 'Shipping Prices',
                  style: theme.textTheme.titleMedium
                      ?.copyWith(fontWeight: FontWeight.bold),
                ),
                Text(
                  _selectedMerchantName ?? '',
                  style: TextStyle(
                    fontSize: isMobile ? 12 : 13,
                    color: theme.colorScheme.onSurface.withValues(alpha: 0.6),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildShippingContent(ThemeData theme) {
    final locale = widget.isRtl ? 'ar' : 'en';

    return BlocBuilder<ShippingCubit, ShippingState>(
      builder: (context, state) {
        if (state is ShippingLoading) {
          return const Center(child: CircularProgressIndicator());
        }

        if (state is ShippingError) {
          return Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(state.message, style: const TextStyle(color: Colors.red)),
                const SizedBox(height: 16),
                ElevatedButton(
                  onPressed: () => context
                      .read<ShippingCubit>()
                      .loadMerchantShippingPrices(_selectedMerchantId!),
                  child: Text('retry'.tr()),
                ),
              ],
            ),
          );
        }

        if (state is MerchantShippingPricesLoaded) {
          return ShippingPricesList(
            governorates: state.governorates,
            prices: state.prices,
            locale: locale,
            onEditPrice: (gov, price) =>
                _showEditPriceDialog(context, gov, price, locale),
            onAddZone: () => _showAddShippingZoneDialog(
              context,
              state.governorates
                  .where(
                      (g) => !state.prices.any((p) => p.governorateId == g.id))
                  .toList(),
              locale,
            ),
          );
        }

        return Center(child: Text('no_shipping_prices'.tr()));
      },
    );
  }

  void _showAddShippingZoneDialog(
    BuildContext context,
    List<GovernorateEntity> availableGovernorates,
    String locale,
  ) {
    ShippingDialogs.showAddShippingZoneDialog(
      context,
      availableGovernorates,
      locale,
      (gov) => _showEditPriceDialog(context, gov, null, locale),
    );
  }

  void _showEditPriceDialog(
    BuildContext context,
    GovernorateEntity governorate,
    double? currentPrice,
    String locale,
  ) {
    ShippingDialogs.showEditPriceDialog(
      context,
      governorate,
      currentPrice,
      locale,
      onSave: (price) => _savePrice(context, governorate.id, price),
      onDelete: currentPrice != null
          ? () => _deletePrice(context, governorate.id)
          : null,
    );
  }

  void _savePrice(BuildContext context, String governorateId, double price) {
    context
        .read<ShippingCubit>()
        .setShippingPrice(_selectedMerchantId!, governorateId, price);
    Tost.showCustomToast(
      context,
      'shipping_price_updated'.tr(),
      backgroundColor: Colors.green,
      textColor: Colors.white,
    );
  }

  void _deletePrice(BuildContext context, String governorateId) {
    context
        .read<ShippingCubit>()
        .deleteShippingPrice(_selectedMerchantId!, governorateId);
    Tost.showCustomToast(
      context,
      'deleted'.tr(),
      backgroundColor: Colors.orange,
      textColor: Colors.white,
    );
  }
}
