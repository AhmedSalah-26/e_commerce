import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../cubit/admin_cubit.dart';
import '../cubit/admin_state.dart';

class AdminReportsTab extends StatelessWidget {
  final bool isRtl;
  const AdminReportsTab({super.key, required this.isRtl});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isMobile = MediaQuery.of(context).size.width < 600;

    return BlocBuilder<AdminCubit, AdminState>(
      builder: (context, state) {
        if (state is AdminLoaded) {
          return SingleChildScrollView(
            padding: EdgeInsets.all(isMobile ? 16 : 24),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  isRtl ? 'التقارير والإحصائيات' : 'Reports & Analytics',
                  style: theme.textTheme.titleLarge
                      ?.copyWith(fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 24),
                _buildReportCard(
                  theme,
                  isMobile,
                  icon: Icons.people,
                  title: isRtl ? 'إجمالي العملاء' : 'Total Customers',
                  value: '${state.stats.totalCustomers}',
                  color: Colors.blue,
                ),
                _buildReportCard(
                  theme,
                  isMobile,
                  icon: Icons.store,
                  title: isRtl ? 'إجمالي التجار' : 'Total Merchants',
                  value: '${state.stats.totalMerchants}',
                  color: Colors.purple,
                ),
                _buildReportCard(
                  theme,
                  isMobile,
                  icon: Icons.inventory,
                  title: isRtl ? 'إجمالي المنتجات' : 'Total Products',
                  value: '${state.stats.totalProducts}',
                  subtitle:
                      '${state.stats.activeProducts} ${isRtl ? 'نشط' : 'active'}',
                  color: Colors.green,
                ),
                _buildReportCard(
                  theme,
                  isMobile,
                  icon: Icons.receipt_long,
                  title: isRtl ? 'إجمالي الطلبات' : 'Total Orders',
                  value: '${state.stats.totalOrders}',
                  subtitle:
                      '${state.stats.pendingOrders} ${isRtl ? 'معلق' : 'pending'}',
                  color: Colors.orange,
                ),
                _buildReportCard(
                  theme,
                  isMobile,
                  icon: Icons.attach_money,
                  title: isRtl ? 'إجمالي الإيرادات' : 'Total Revenue',
                  value:
                      '${state.stats.totalRevenue.toStringAsFixed(0)} ${isRtl ? 'ج.م' : 'EGP'}',
                  color: Colors.teal,
                ),
                _buildReportCard(
                  theme,
                  isMobile,
                  icon: Icons.today,
                  title: isRtl ? 'طلبات اليوم' : 'Today Orders',
                  value: '${state.stats.todayOrders}',
                  subtitle:
                      '${state.stats.todayRevenue.toStringAsFixed(0)} ${isRtl ? 'ج.م' : 'EGP'}',
                  color: Colors.indigo,
                ),
              ],
            ),
          );
        }

        if (state is AdminLoading) {
          return const Center(child: CircularProgressIndicator());
        }

        return Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(Icons.analytics, size: 64, color: Colors.grey),
              const SizedBox(height: 16),
              Text(isRtl ? 'جاري تحميل التقارير...' : 'Loading reports...'),
              const SizedBox(height: 16),
              ElevatedButton(
                onPressed: () => context.read<AdminCubit>().loadDashboard(),
                child: Text(isRtl ? 'تحديث' : 'Refresh'),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildReportCard(
    ThemeData theme,
    bool isMobile, {
    required IconData icon,
    required String title,
    required String value,
    String? subtitle,
    required Color color,
  }) {
    return Card(
      margin: EdgeInsets.only(bottom: isMobile ? 12 : 16),
      child: Padding(
        padding: EdgeInsets.all(isMobile ? 16 : 20),
        child: Row(
          children: [
            Container(
              padding: EdgeInsets.all(isMobile ? 12 : 16),
              decoration: BoxDecoration(
                color: color.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Icon(icon, color: color, size: isMobile ? 28 : 32),
            ),
            SizedBox(width: isMobile ? 16 : 20),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: TextStyle(
                      fontSize: isMobile ? 13 : 14,
                      color: theme.colorScheme.onSurface.withValues(alpha: 0.7),
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    value,
                    style: TextStyle(
                      fontSize: isMobile ? 22 : 28,
                      fontWeight: FontWeight.bold,
                      color: theme.colorScheme.onSurface,
                    ),
                  ),
                  if (subtitle != null) ...[
                    const SizedBox(height: 2),
                    Text(
                      subtitle,
                      style: TextStyle(
                        fontSize: isMobile ? 11 : 12,
                        color: color,
                      ),
                    ),
                  ],
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
