import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../cubit/admin_cubit.dart';
import '../cubit/admin_state.dart';
import '../widgets/user_card.dart';
import '../widgets/user_details_sheet.dart';
import '../widgets/merchant_coupons_sheet.dart';
import '../widgets/admin_error_widget.dart';

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
  final _scrollController = ScrollController();
  final _roles = ['customer', 'merchant', 'admin'];
  String? _currentSearch;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
    _tabController.addListener(() {
      if (!_tabController.indexIsChanging) _loadUsers();
    });
    _scrollController.addListener(_onScroll);
    _loadUsers();
  }

  @override
  void dispose() {
    _tabController.dispose();
    _searchController.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  void _onScroll() {
    if (_scrollController.position.pixels >=
        _scrollController.position.maxScrollExtent - 200) {
      _loadMoreUsers();
    }
  }

  void _loadUsers() {
    _currentSearch =
        _searchController.text.isEmpty ? null : _searchController.text;
    context.read<AdminCubit>().loadUsers(
          role: _roles[_tabController.index],
          search: _currentSearch,
        );
  }

  void _loadMoreUsers() {
    context.read<AdminCubit>().loadUsers(
          role: _roles[_tabController.index],
          search: _currentSearch,
          loadMore: true,
        );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isMobile = MediaQuery.of(context).size.width < 600;

    return Column(
      children: [
        _buildSearchBar(isMobile),
        TabBar(
          controller: _tabController,
          labelColor: theme.colorScheme.primary,
          labelStyle: TextStyle(fontSize: isMobile ? 12 : 14),
          tabs: [
            Tab(text: widget.isRtl ? 'العملاء' : 'Customers'),
            Tab(text: widget.isRtl ? 'التجار' : 'Merchants'),
            Tab(text: widget.isRtl ? 'المسؤولين' : 'Admins'),
          ],
        ),
        Expanded(
          child: TabBarView(
            controller: _tabController,
            children: List.generate(3, (_) => _buildUsersList(isMobile)),
          ),
        ),
      ],
    );
  }

  Widget _buildSearchBar(bool isMobile) {
    return Padding(
      padding: EdgeInsets.all(isMobile ? 12 : 16),
      child: TextField(
        controller: _searchController,
        decoration: InputDecoration(
          hintText: widget.isRtl
              ? 'بحث بالاسم، الإيميل، الهاتف أو ID...'
              : 'Search by name, email, phone or ID...',
          prefixIcon: const Icon(Icons.search),
          border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
          isDense: isMobile,
        ),
        onSubmitted: (_) => _loadUsers(),
      ),
    );
  }

  Widget _buildUsersList(bool isMobile) {
    return BlocBuilder<AdminCubit, AdminState>(
      builder: (context, state) {
        if (state is AdminUsersLoading) {
          return const Center(child: CircularProgressIndicator());
        }
        if (state is AdminError) {
          return AdminErrorWidget(
            message: state.message,
            isRtl: widget.isRtl,
            onRetry: _loadUsers,
          );
        }
        if (state is AdminUsersLoaded) {
          if (state.users.isEmpty) {
            return Center(
                child: Text(widget.isRtl ? 'لا يوجد مستخدمين' : 'No users'));
          }
          return ListView.builder(
            controller: _scrollController,
            padding: EdgeInsets.all(isMobile ? 12 : 16),
            itemCount: state.users.length + (state.hasMore ? 1 : 0),
            itemBuilder: (_, i) {
              if (i >= state.users.length) {
                return const Padding(
                  padding: EdgeInsets.all(16),
                  child: Center(child: CircularProgressIndicator()),
                );
              }
              return UserCard(
                user: state.users[i],
                isRtl: widget.isRtl,
                isMobile: isMobile,
                onTap: () => _showUserDetails(state.users[i]),
                onAction: (action) => _handleAction(action, state.users[i]),
              );
            },
          );
        }
        return const SizedBox.shrink();
      },
    );
  }

  Future<void> _handleAction(String action, Map<String, dynamic> user) async {
    final cubit = context.read<AdminCubit>();
    final userId = user['id'];
    final isActive = user['is_active'] ?? true;

    switch (action) {
      case 'details':
        _showUserDetails(user);
        break;
      case 'copy_id':
        await Clipboard.setData(ClipboardData(text: userId ?? ''));
        if (mounted) {
          _showSnack(widget.isRtl ? 'تم نسخ ID' : 'ID Copied', Colors.blue);
        }
        break;
      case 'copy_email':
        await Clipboard.setData(ClipboardData(text: user['email'] ?? ''));
        if (mounted) {
          _showSnack(
              widget.isRtl ? 'تم نسخ الإيميل' : 'Email Copied', Colors.blue);
        }
        break;
      case 'coupons':
        _showMerchantCoupons(user);
        break;
      case 'toggle':
        final ok = await cubit.toggleUserStatus(userId, !isActive);
        if (ok && mounted) {
          _loadUsers();
          _showSnack(widget.isRtl ? 'تم التحديث' : 'Updated', Colors.green);
        }
        break;
      case 'unban':
        final result = await cubit.unbanUser(userId);
        if (result != null && mounted) {
          _loadUsers();
          _showSnack(
              widget.isRtl ? 'تم إلغاء الحظر' : 'Unbanned', Colors.green);
        }
        break;
      case 'ban_24h':
        await _confirmAndBan(
            userId, '24h', widget.isRtl ? '24 ساعة' : '24 hours');
        break;
      case 'ban_7d':
        await _confirmAndBan(userId, '7d', widget.isRtl ? '7 أيام' : '7 days');
        break;
      case 'ban_30d':
        await _confirmAndBan(
            userId, '30d', widget.isRtl ? '30 يوم' : '30 days');
        break;
      case 'ban_forever':
        await _confirmAndBan(
            userId, 'forever', widget.isRtl ? 'نهائياً' : 'permanently');
        break;
    }
  }

  Future<void> _confirmAndBan(
      String userId, String duration, String text) async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Row(
          children: [
            const Icon(Icons.warning, color: Colors.red),
            const SizedBox(width: 8),
            Text(widget.isRtl ? 'تأكيد الحظر' : 'Confirm Ban'),
          ],
        ),
        content: Text(
          widget.isRtl
              ? 'هل تريد حظر هذا المستخدم لمدة $text؟'
              : 'Ban this user for $text?',
        ),
        actions: [
          TextButton(
              onPressed: () => Navigator.pop(ctx, false),
              child: Text(widget.isRtl ? 'إلغاء' : 'Cancel')),
          ElevatedButton(
            style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
            onPressed: () => Navigator.pop(ctx, true),
            child: Text(widget.isRtl ? 'حظر' : 'Ban',
                style: const TextStyle(color: Colors.white)),
          ),
        ],
      ),
    );

    if (confirm == true && mounted) {
      final result = await context.read<AdminCubit>().banUser(userId, duration);
      if (result != null && mounted) {
        _loadUsers();
        _showSnack(
            widget.isRtl ? 'تم حظر المستخدم' : 'User banned', Colors.red);
      }
    }
  }

  void _showUserDetails(Map<String, dynamic> user) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => UserDetailsSheet(user: user, isRtl: widget.isRtl),
    );
  }

  void _showMerchantCoupons(Map<String, dynamic> user) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => BlocProvider.value(
        value: context.read<AdminCubit>(),
        child: MerchantCouponsSheet(
          merchantId: user['id'],
          merchantName: user['name'] ?? 'Unknown',
          isRtl: widget.isRtl,
        ),
      ),
    );
  }

  void _showSnack(String msg, Color color) {
    ScaffoldMessenger.of(context)
        .showSnackBar(SnackBar(content: Text(msg), backgroundColor: color));
  }
}
