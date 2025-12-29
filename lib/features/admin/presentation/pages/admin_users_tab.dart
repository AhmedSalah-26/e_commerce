import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
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
    final isMobile = MediaQuery.of(context).size.width < 600;

    return Column(
      children: [
        _buildHeader(theme, isMobile),
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
            children: [
              _buildUsersList(isMobile),
              _buildUsersList(isMobile),
              _buildUsersList(isMobile),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildHeader(ThemeData theme, bool isMobile) {
    return Padding(
      padding: EdgeInsets.all(isMobile ? 12 : 16),
      child: TextField(
        controller: _searchController,
        decoration: InputDecoration(
          hintText: widget.isRtl ? 'بحث...' : 'Search...',
          prefixIcon: const Icon(Icons.search),
          border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
          contentPadding: const EdgeInsets.symmetric(horizontal: 16),
          isDense: isMobile,
        ),
        onSubmitted: (_) {
          final roles = ['customer', 'merchant', 'admin'];
          _loadUsers(roles[_tabController.index]);
        },
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
          return Center(child: Text(state.message));
        }
        if (state is AdminUsersLoaded) {
          if (state.users.isEmpty) {
            return Center(
              child: Text(widget.isRtl ? 'لا يوجد مستخدمين' : 'No users found'),
            );
          }
          return ListView.builder(
            padding: EdgeInsets.all(isMobile ? 12 : 16),
            itemCount: state.users.length,
            itemBuilder: (context, index) =>
                _buildUserCard(state.users[index], isMobile),
          );
        }
        return const SizedBox.shrink();
      },
    );
  }

  Widget _buildUserCard(Map<String, dynamic> user, bool isMobile) {
    final theme = Theme.of(context);
    final isActive = user['is_active'] ?? true;
    final isBanned = _isUserBanned(user);
    final name = user['name'] ?? 'Unknown';
    final email = user['email'] ?? '';

    return Card(
      margin: EdgeInsets.only(bottom: isMobile ? 8 : 12),
      color: isBanned ? Colors.red.withValues(alpha: 0.05) : null,
      child: ListTile(
        dense: isMobile,
        contentPadding: EdgeInsets.symmetric(
          horizontal: isMobile ? 12 : 16,
          vertical: isMobile ? 4 : 8,
        ),
        leading: Stack(
          children: [
            CircleAvatar(
              radius: isMobile ? 18 : 22,
              backgroundColor:
                  isBanned ? Colors.red : theme.colorScheme.primary,
              child: Text(
                name.isNotEmpty ? name[0].toUpperCase() : 'U',
                style: TextStyle(
                    color: Colors.white, fontSize: isMobile ? 14 : 16),
              ),
            ),
            if (isBanned)
              Positioned(
                right: 0,
                bottom: 0,
                child: Container(
                  padding: const EdgeInsets.all(2),
                  decoration: const BoxDecoration(
                    color: Colors.red,
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(Icons.block, size: 12, color: Colors.white),
                ),
              ),
          ],
        ),
        title: Text(
          name,
          style: TextStyle(
            fontSize: isMobile ? 13 : 14,
            decoration: isBanned ? TextDecoration.lineThrough : null,
          ),
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
        ),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              email,
              style: TextStyle(fontSize: isMobile ? 11 : 12),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
            if (isBanned)
              Text(
                _getBanStatusText(user),
                style: const TextStyle(fontSize: 10, color: Colors.red),
              ),
          ],
        ),
        trailing: _buildTrailing(user, isActive, isBanned, isMobile),
        onTap: () => _showUserDetails(user),
      ),
    );
  }

  bool _isUserBanned(Map<String, dynamic> user) {
    final bannedUntil = user['banned_until'];
    if (bannedUntil == null) return false;
    final banDate = DateTime.tryParse(bannedUntil);
    if (banDate == null) return false;
    return banDate.isAfter(DateTime.now());
  }

  String _getBanStatusText(Map<String, dynamic> user) {
    final bannedUntil = user['banned_until'];
    if (bannedUntil == null) return '';
    final banDate = DateTime.tryParse(bannedUntil);
    if (banDate == null) return '';

    final diff = banDate.difference(DateTime.now());
    if (diff.inDays > 365 * 10) {
      return widget.isRtl ? 'محظور نهائياً' : 'Permanently banned';
    } else if (diff.inDays > 0) {
      return widget.isRtl
          ? 'محظور لـ ${diff.inDays} يوم'
          : 'Banned for ${diff.inDays} days';
    } else if (diff.inHours > 0) {
      return widget.isRtl
          ? 'محظور لـ ${diff.inHours} ساعة'
          : 'Banned for ${diff.inHours} hours';
    }
    return '';
  }

  Widget _buildTrailing(
      Map<String, dynamic> user, bool isActive, bool isBanned, bool isMobile) {
    final theme = Theme.of(context);
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        if (!isMobile)
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
            decoration: BoxDecoration(
              color: isBanned
                  ? Colors.red.withValues(alpha: 0.1)
                  : isActive
                      ? Colors.green.withValues(alpha: 0.1)
                      : Colors.orange.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Text(
              isBanned
                  ? (widget.isRtl ? 'محظور' : 'Banned')
                  : isActive
                      ? (widget.isRtl ? 'نشط' : 'Active')
                      : (widget.isRtl ? 'معطل' : 'Inactive'),
              style: TextStyle(
                color: isBanned
                    ? Colors.red
                    : isActive
                        ? Colors.green
                        : Colors.orange,
                fontSize: 12,
              ),
            ),
          ),
        PopupMenuButton<String>(
          icon: Icon(
            Icons.more_vert,
            color: isBanned
                ? Colors.red
                : isMobile
                    ? (isActive ? Colors.green : Colors.orange)
                    : theme.colorScheme.onSurface,
          ),
          itemBuilder: (context) => _buildMenuItems(user, isActive, isBanned),
          onSelected: (value) => _handleAction(value, user, isActive, isBanned),
        ),
      ],
    );
  }

  List<PopupMenuEntry<String>> _buildMenuItems(
      Map<String, dynamic> user, bool isActive, bool isBanned) {
    final isAdmin = user['role'] == 'admin';

    return [
      PopupMenuItem(
        value: 'details',
        child: Row(
          children: [
            const Icon(Icons.info_outline, size: 18),
            const SizedBox(width: 8),
            Text(widget.isRtl ? 'التفاصيل' : 'Details'),
          ],
        ),
      ),
      PopupMenuItem(
        value: 'copy_id',
        child: Row(
          children: [
            const Icon(Icons.copy, size: 18),
            const SizedBox(width: 8),
            Text(widget.isRtl ? 'نسخ ID' : 'Copy ID'),
          ],
        ),
      ),
      PopupMenuItem(
        value: 'copy_email',
        child: Row(
          children: [
            const Icon(Icons.email_outlined, size: 18),
            const SizedBox(width: 8),
            Text(widget.isRtl ? 'نسخ الإيميل' : 'Copy Email'),
          ],
        ),
      ),
      const PopupMenuDivider(),
      // Toggle active (simple deactivation)
      PopupMenuItem(
        value: 'toggle',
        child: Row(
          children: [
            Icon(
              isActive ? Icons.visibility_off : Icons.visibility,
              size: 18,
              color: Colors.orange,
            ),
            const SizedBox(width: 8),
            Text(
              isActive
                  ? (widget.isRtl ? 'تعطيل مؤقت' : 'Deactivate')
                  : (widget.isRtl ? 'تفعيل' : 'Activate'),
              style: const TextStyle(color: Colors.orange),
            ),
          ],
        ),
      ),
      // Ban options (only for non-admins)
      if (!isAdmin) ...[
        const PopupMenuDivider(),
        if (isBanned)
          PopupMenuItem(
            value: 'unban',
            child: Row(
              children: [
                const Icon(Icons.lock_open, size: 18, color: Colors.green),
                const SizedBox(width: 8),
                Text(
                  widget.isRtl ? 'إلغاء الحظر' : 'Unban',
                  style: const TextStyle(color: Colors.green),
                ),
              ],
            ),
          )
        else ...[
          PopupMenuItem(
            value: 'ban_24h',
            child: Row(
              children: [
                const Icon(Icons.timer, size: 18, color: Colors.red),
                const SizedBox(width: 8),
                Text(
                  widget.isRtl ? 'حظر 24 ساعة' : 'Ban 24 hours',
                  style: const TextStyle(color: Colors.red),
                ),
              ],
            ),
          ),
          PopupMenuItem(
            value: 'ban_7d',
            child: Row(
              children: [
                const Icon(Icons.date_range, size: 18, color: Colors.red),
                const SizedBox(width: 8),
                Text(
                  widget.isRtl ? 'حظر 7 أيام' : 'Ban 7 days',
                  style: const TextStyle(color: Colors.red),
                ),
              ],
            ),
          ),
          PopupMenuItem(
            value: 'ban_30d',
            child: Row(
              children: [
                const Icon(Icons.calendar_month, size: 18, color: Colors.red),
                const SizedBox(width: 8),
                Text(
                  widget.isRtl ? 'حظر 30 يوم' : 'Ban 30 days',
                  style: const TextStyle(color: Colors.red),
                ),
              ],
            ),
          ),
          PopupMenuItem(
            value: 'ban_forever',
            child: Row(
              children: [
                const Icon(Icons.block, size: 18, color: Colors.red),
                const SizedBox(width: 8),
                Text(
                  widget.isRtl ? 'حظر نهائي' : 'Ban permanently',
                  style: const TextStyle(
                      color: Colors.red, fontWeight: FontWeight.bold),
                ),
              ],
            ),
          ),
        ],
      ],
    ];
  }

  Future<void> _handleAction(String value, Map<String, dynamic> user,
      bool isActive, bool isBanned) async {
    final cubit = context.read<AdminCubit>();
    final userId = user['id'];

    switch (value) {
      case 'toggle':
        final success = await cubit.toggleUserStatus(userId, !isActive);
        if (success && mounted) {
          _reloadUsers();
          _showSnackBar(widget.isRtl ? 'تم التحديث' : 'Updated', Colors.green);
        }
        break;
      case 'unban':
        final result = await cubit.unbanUser(userId);
        if (result != null && mounted) {
          _reloadUsers();
          _showSnackBar(
              widget.isRtl ? 'تم إلغاء الحظر' : 'User unbanned', Colors.green);
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
      case 'copy_id':
        await Clipboard.setData(ClipboardData(text: userId ?? ''));
        if (mounted) {
          _showSnackBar(widget.isRtl ? 'تم نسخ ID' : 'ID Copied', Colors.blue);
        }
        break;
      case 'copy_email':
        await Clipboard.setData(ClipboardData(text: user['email'] ?? ''));
        if (mounted) {
          _showSnackBar(
              widget.isRtl ? 'تم نسخ الإيميل' : 'Email Copied', Colors.blue);
        }
        break;
      case 'details':
        _showUserDetails(user);
        break;
    }
  }

  Future<void> _confirmAndBan(
      String userId, String duration, String durationText) async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: Row(
          children: [
            const Icon(Icons.warning, color: Colors.red),
            const SizedBox(width: 8),
            Text(widget.isRtl ? 'تأكيد الحظر' : 'Confirm Ban'),
          ],
        ),
        content: Text(
          widget.isRtl
              ? 'هل تريد حظر هذا المستخدم لمدة $durationText؟\n\nالمستخدم لن يستطيع تسجيل الدخول.'
              : 'Ban this user for $durationText?\n\nUser will not be able to login.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: Text(widget.isRtl ? 'إلغاء' : 'Cancel'),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
            onPressed: () => Navigator.pop(context, true),
            child: Text(
              widget.isRtl ? 'حظر' : 'Ban',
              style: const TextStyle(color: Colors.white),
            ),
          ),
        ],
      ),
    );

    if (confirm == true && mounted) {
      final result = await context.read<AdminCubit>().banUser(userId, duration);
      if (result != null && mounted) {
        _reloadUsers();
        _showSnackBar(
            widget.isRtl ? 'تم حظر المستخدم' : 'User banned', Colors.red);
      }
    }
  }

  void _reloadUsers() {
    final roles = ['customer', 'merchant', 'admin'];
    _loadUsers(roles[_tabController.index]);
  }

  void _showSnackBar(String message, Color color) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(message), backgroundColor: color),
    );
  }

  void _showUserDetails(Map<String, dynamic> user) {
    final theme = Theme.of(context);
    final isActive = user['is_active'] ?? true;
    final isBanned = _isUserBanned(user);

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (ctx) => Container(
        height: MediaQuery.of(context).size.height * 0.65,
        decoration: BoxDecoration(
          color: theme.colorScheme.surface,
          borderRadius: const BorderRadius.vertical(top: Radius.circular(20)),
        ),
        child: Column(
          children: [
            Container(
              margin: const EdgeInsets.only(top: 12),
              width: 40,
              height: 4,
              decoration: BoxDecoration(
                color: theme.colorScheme.outline.withValues(alpha: 0.3),
                borderRadius: BorderRadius.circular(2),
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(16),
              child: Row(
                children: [
                  CircleAvatar(
                    radius: 30,
                    backgroundColor:
                        isBanned ? Colors.red : theme.colorScheme.primary,
                    child: Text(
                      (user['name'] ?? 'U')[0].toUpperCase(),
                      style: const TextStyle(color: Colors.white, fontSize: 24),
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          user['name'] ?? 'Unknown',
                          style: theme.textTheme.titleLarge
                              ?.copyWith(fontWeight: FontWeight.bold),
                        ),
                        const SizedBox(height: 4),
                        Row(
                          children: [
                            _buildStatusChip(
                              isBanned
                                  ? (widget.isRtl ? 'محظور' : 'Banned')
                                  : isActive
                                      ? (widget.isRtl ? 'نشط' : 'Active')
                                      : (widget.isRtl ? 'معطل' : 'Inactive'),
                              isBanned
                                  ? Colors.red
                                  : isActive
                                      ? Colors.green
                                      : Colors.orange,
                            ),
                            const SizedBox(width: 8),
                            _buildStatusChip(
                              user['role'] ?? 'customer',
                              Colors.blue,
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                  IconButton(
                    icon: const Icon(Icons.close),
                    onPressed: () => Navigator.pop(ctx),
                  ),
                ],
              ),
            ),
            if (isBanned)
              Container(
                margin: const EdgeInsets.symmetric(horizontal: 16),
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: Colors.red.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Row(
                  children: [
                    const Icon(Icons.block, color: Colors.red),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        _getBanStatusText(user),
                        style: const TextStyle(color: Colors.red),
                      ),
                    ),
                  ],
                ),
              ),
            const Divider(),
            Expanded(
              child: ListView(
                padding: const EdgeInsets.all(16),
                children: [
                  _buildDetailItem(widget.isRtl ? 'الإيميل' : 'Email',
                      user['email'] ?? '', Icons.email),
                  _buildDetailItem(widget.isRtl ? 'الهاتف' : 'Phone',
                      user['phone'] ?? '-', Icons.phone),
                  _buildDetailItem(widget.isRtl ? 'الدور' : 'Role',
                      user['role'] ?? '-', Icons.badge),
                  _buildDetailItem('ID', user['id'] ?? '', Icons.fingerprint),
                  _buildDetailItem(
                    widget.isRtl ? 'تاريخ التسجيل' : 'Created',
                    user['created_at'] != null
                        ? DateTime.parse(user['created_at'])
                            .toString()
                            .substring(0, 10)
                        : '-',
                    Icons.calendar_today,
                  ),
                  if (user['banned_until'] != null)
                    _buildDetailItem(
                      widget.isRtl ? 'محظور حتى' : 'Banned until',
                      DateTime.tryParse(user['banned_until'])
                              ?.toString()
                              .substring(0, 16) ??
                          '-',
                      Icons.block,
                    ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildStatusChip(String text, Color color) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Text(
        text,
        style: TextStyle(color: color, fontSize: 12),
      ),
    );
  }

  Widget _buildDetailItem(String label, String value, IconData icon) {
    final theme = Theme.of(context);
    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: Row(
        children: [
          Icon(icon, size: 20, color: theme.colorScheme.primary),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  label,
                  style: TextStyle(
                    fontSize: 12,
                    color: theme.colorScheme.onSurface.withValues(alpha: 0.6),
                  ),
                ),
                Text(value, style: const TextStyle(fontSize: 14)),
              ],
            ),
          ),
          IconButton(
            icon: const Icon(Icons.copy, size: 18),
            onPressed: () async {
              await Clipboard.setData(ClipboardData(text: value));
              if (mounted) {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(content: Text(widget.isRtl ? 'تم النسخ' : 'Copied')),
                );
              }
            },
          ),
        ],
      ),
    );
  }
}
