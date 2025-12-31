import 'dart:ui' as ui;
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:easy_localization/easy_localization.dart';
import '../../../../core/di/injection_container.dart';
import '../../../auth/presentation/cubit/auth_cubit.dart';
import '../../../auth/presentation/cubit/auth_state.dart';
import '../cubit/inventory_insights_cubit.dart';
import '../widgets/inventory_insights/inventory_summary_cards.dart';
import '../widgets/inventory_insights/inventory_alerts_section.dart';
import '../widgets/inventory_insights/inventory_product_list.dart';

class MerchantInventoryInsightsPage extends StatelessWidget {
  const MerchantInventoryInsightsPage({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => sl<InventoryInsightsCubit>(),
      child: const _InventoryInsightsView(),
    );
  }
}

class _InventoryInsightsView extends StatefulWidget {
  const _InventoryInsightsView();

  @override
  State<_InventoryInsightsView> createState() => _InventoryInsightsViewState();
}

class _InventoryInsightsViewState extends State<_InventoryInsightsView> {
  @override
  void initState() {
    super.initState();
    _loadData();
  }

  void _loadData() {
    final authState = context.read<AuthCubit>().state;
    if (authState is AuthAuthenticated) {
      context.read<InventoryInsightsCubit>().loadInsights(authState.user.id);
    }
  }

  @override
  Widget build(BuildContext context) {
    final isRtl = context.locale.languageCode == 'ar';
    final theme = Theme.of(context);

    return Directionality(
      textDirection: isRtl ? ui.TextDirection.rtl : ui.TextDirection.ltr,
      child: Scaffold(
        backgroundColor: theme.scaffoldBackgroundColor,
        appBar: AppBar(
          backgroundColor: theme.colorScheme.surface,
          elevation: 0,
          leading: IconButton(
            icon: Icon(Icons.arrow_back, color: theme.colorScheme.primary),
            onPressed: () => Navigator.pop(context),
          ),
          title: Text(
            isRtl ? 'تحليلات المخزون' : 'Inventory Analytics',
            style: theme.textTheme.titleLarge?.copyWith(
              fontWeight: FontWeight.w600,
              color: theme.colorScheme.primary,
            ),
          ),
          centerTitle: true,
        ),
        body: BlocBuilder<InventoryInsightsCubit, InventoryInsightsState>(
          builder: (context, state) {
            if (state is InventoryInsightsLoading) {
              return const Center(child: CircularProgressIndicator());
            }

            if (state is InventoryInsightsError) {
              return Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(Icons.error_outline,
                        size: 64, color: theme.colorScheme.error),
                    const SizedBox(height: 16),
                    Text(state.message),
                    const SizedBox(height: 16),
                    ElevatedButton(
                      onPressed: _loadData,
                      child: Text(isRtl ? 'إعادة المحاولة' : 'Retry'),
                    ),
                  ],
                ),
              );
            }

            if (state is InventoryInsightsLoaded) {
              return RefreshIndicator(
                onRefresh: () =>
                    context.read<InventoryInsightsCubit>().refresh(),
                child: CustomScrollView(
                  slivers: [
                    SliverToBoxAdapter(
                      child: Padding(
                        padding: const EdgeInsets.all(16),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            InventorySummaryCards(
                              summary: state.summary,
                              isRtl: isRtl,
                            ),
                            const SizedBox(height: 20),
                            InventoryAlertsSection(
                              summary: state.summary,
                              isRtl: isRtl,
                              onFilterTap: (filter) {
                                context
                                    .read<InventoryInsightsCubit>()
                                    .filterProducts(filter);
                              },
                              currentFilter: state.currentFilter,
                            ),
                            const SizedBox(height: 20),
                            Text(
                              isRtl ? 'تفاصيل المنتجات' : 'Product Details',
                              style: TextStyle(
                                fontSize: 18,
                                fontWeight: FontWeight.bold,
                                color: theme.colorScheme.onSurface,
                              ),
                            ),
                            const SizedBox(height: 12),
                          ],
                        ),
                      ),
                    ),
                    InventoryProductList(
                      products: state.products,
                      isRtl: isRtl,
                    ),
                    const SliverToBoxAdapter(
                      child: SizedBox(height: 20),
                    ),
                  ],
                ),
              );
            }

            return const SizedBox.shrink();
          },
        ),
      ),
    );
  }
}
