import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../cubit/admin_cubit.dart';
import '../cubit/admin_state.dart';

class AdminUsersTab extends StatefulWidget {
  final bool isRtl;

  const AdminUsersTab({super.key, required this.isRtl});

  @override
  State<AdminUsersTab> createState() => _AdminUsersTabState();
}

class _AdminUsersTabState extends State<AdminUsersTab>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;
  final _searchController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
    _tabController.addListener(_onTabChanged);
    _loadUsers('customer');
  }

  @override
  void dispose() {
    _tabController.dispose();
    _searchController.dispose();
    super.dispose();
  }

  void _onTabChanged() {
    if (!_tabController.indexIsChanging) {
      final roles = ['customer', 'merchant', 'admin'];
      _loadUsers(roles[_tabController.index]);
    }
  }

  void _loadUsers(String role) {
    context.read<AdminCubit>().loadUsers(
          role: role,
          search:
              _searchController.text.isEmpty ? null : _searchController.text,
        );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Column(
      children: [
        _buildHeader(theme),
        TabBar(
          controller: _tabController,
          labelColor: theme.colorScheme.primary,
          tabs: [
            Tab(text: widget.isRtl ? 'العملاء' : 'Customers'),
            Tab(text: widget.isRtl ? 'التجار' : 'Merchants'),
            Tab(text: widget.isRtl ? 'المسؤولين' : 'Admins'),
          ],
        ),
        Expanded(
          child: TabBarView(
            controller: _tabController,
            children: [
              _buildUsersList(),
              _buildUsersList(),
              _buildUsersList(),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildHeader(ThemeData theme) {
    return Padding(
      padding: const EdgeInsets.all(16),
      child: Row(
        children: [
          Expanded(
            child: TextField(
              controller: _searchController,
              decoration: InputDecoration(
                hintText: widget.isRtl ? 'بحث...' : 'Search...',
                prefixIcon: const Icon(Icons.search),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                contentPadding: const EdgeInsets.symmetric(horizontal: 16),
              ),
              onSubmitted: (_) {
                final roles = ['customer', 'merchant', 'admin'];
                _loadUsers(roles[_tabController.index]);
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildUsersList() {
    return BlocBuilder<AdminCubit, AdminState>(
      builder: (context, state) {
        if (state is AdminUsersLoading) {
          return const Center(child: CircularProgressIndicator());
        }

        if (state is AdminError) {
          return Center(child: Text(state.message));
        }

        if (state is AdminUsersLoaded) {
          if (state.users.isEmpty) {
            return Center(
              child: Text(widget.isRtl ? 'لا يوجد مستخدمين' : 'No users found'),
            );
          }

          return ListView.builder(
            padding: const EdgeInsets.all(16),
            itemCount: state.users.length,
            itemBuilder: (context, index) => _buildUserCard(state.users[index]),
          );
        }

        return const SizedBox.shrink();
      },
    );
  }

  Widget _buildUserCard(Map<String, dynamic> user) {
    final theme = Theme.of(context);
    final isActive = user['is_active'] ?? true;

    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      child: ListTile(
        leading: CircleAvatar(
          backgroundColor: theme.colorScheme.primary,
          child: Text(
            (user['full_name'] ?? 'U')[0].toUpperCase(),
            style: const TextStyle(color: Colors.white),
          ),
        ),
        title: Text(user['full_name'] ?? 'Unknown'),
        subtitle: Text(user['email'] ?? ''),
        trailing: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
              decoration: BoxDecoration(
                color: isActive
                    ? Colors.green.withValues(alpha: 0.1)
                    : Colors.red.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Text(
                isActive
                    ? (widget.isRtl ? 'نشط' : 'Active')
                    : (widget.isRtl ? 'معطل' : 'Inactive'),
                style: TextStyle(
                  color: isActive ? Colors.green : Colors.red,
                  fontSize: 12,
                ),
              ),
            ),
            const SizedBox(width: 8),
            PopupMenuButton<String>(
              itemBuilder: (context) => [
                PopupMenuItem(
                  value: 'toggle',
                  child: Text(isActive
                      ? (widget.isRtl ? 'تعطيل' : 'Deactivate')
                      : (widget.isRtl ? 'تفعيل' : 'Activate')),
                ),
                PopupMenuItem(
                  value: 'view',
                  child: Text(widget.isRtl ? 'عرض' : 'View'),
                ),
              ],
              onSelected: (value) async {
                if (value == 'toggle') {
                  final success = await context
                      .read<AdminCubit>()
                      .toggleUserStatus(user['id'], !isActive);
                  if (success) {
                    final roles = ['customer', 'merchant', 'admin'];
                    _loadUsers(roles[_tabController.index]);
                  }
                }
              },
            ),
          ],
        ),
      ),
    );
  }
}
