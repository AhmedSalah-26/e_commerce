import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

class UserDetailsSheet extends StatelessWidget {
  final Map<String, dynamic> user;
  final bool isRtl;

  const UserDetailsSheet({super.key, required this.user, required this.isRtl});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isActive = user['is_active'] ?? true;
    final isBanned = _isUserBanned();
    final name = user['name'] ?? 'Unknown';

    return Container(
      height: MediaQuery.of(context).size.height * 0.65,
      decoration: BoxDecoration(
        color: theme.colorScheme.surface,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(20)),
      ),
      child: Column(
        children: [
          _buildHandle(theme),
          _buildHeader(context, theme, name, isActive, isBanned),
          if (isBanned) _buildBanBanner(),
          const Divider(),
          Expanded(child: _buildDetails(context, theme)),
        ],
      ),
    );
  }

  Widget _buildHandle(ThemeData theme) {
    return Container(
      margin: const EdgeInsets.only(top: 12),
      width: 40,
      height: 4,
      decoration: BoxDecoration(
        color: theme.colorScheme.outline.withValues(alpha: 0.3),
        borderRadius: BorderRadius.circular(2),
      ),
    );
  }

  Widget _buildHeader(BuildContext context, ThemeData theme, String name,
      bool isActive, bool isBanned) {
    return Padding(
      padding: const EdgeInsets.all(16),
      child: Row(
        children: [
          CircleAvatar(
            radius: 30,
            backgroundColor: isBanned ? Colors.red : theme.colorScheme.primary,
            child: Text(name[0].toUpperCase(),
                style: const TextStyle(color: Colors.white, fontSize: 24)),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(name,
                    style: theme.textTheme.titleLarge
                        ?.copyWith(fontWeight: FontWeight.bold)),
                const SizedBox(height: 4),
                Row(
                  children: [
                    _statusChip(
                      isBanned
                          ? (isRtl ? 'محظور' : 'Banned')
                          : isActive
                              ? (isRtl ? 'نشط' : 'Active')
                              : (isRtl ? 'معطل' : 'Inactive'),
                      isBanned
                          ? Colors.red
                          : (isActive ? Colors.green : Colors.orange),
                    ),
                    const SizedBox(width: 8),
                    _statusChip(user['role'] ?? 'customer', Colors.blue),
                  ],
                ),
              ],
            ),
          ),
          IconButton(
              icon: const Icon(Icons.close),
              onPressed: () => Navigator.pop(context)),
        ],
      ),
    );
  }

  Widget _buildBanBanner() {
    return Container(
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
              child: Text(_getBanStatusText(),
                  style: const TextStyle(color: Colors.red))),
        ],
      ),
    );
  }

  Widget _buildDetails(BuildContext context, ThemeData theme) {
    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        _detailItem(context, theme, isRtl ? 'الإيميل' : 'Email',
            user['email'] ?? '', Icons.email),
        _detailItem(context, theme, isRtl ? 'الهاتف' : 'Phone',
            user['phone'] ?? '-', Icons.phone),
        _detailItem(context, theme, isRtl ? 'الدور' : 'Role',
            user['role'] ?? '-', Icons.badge),
        _detailItem(context, theme, 'ID', user['id'] ?? '', Icons.fingerprint),
        _detailItem(
          context,
          theme,
          isRtl ? 'تاريخ التسجيل' : 'Created',
          user['created_at'] != null
              ? DateTime.parse(user['created_at']).toString().substring(0, 10)
              : '-',
          Icons.calendar_today,
        ),
        if (user['banned_until'] != null)
          _detailItem(
            context,
            theme,
            isRtl ? 'محظور حتى' : 'Banned until',
            DateTime.tryParse(user['banned_until'])
                    ?.toString()
                    .substring(0, 16) ??
                '-',
            Icons.block,
          ),
      ],
    );
  }

  Widget _statusChip(String text, Color color) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Text(text, style: TextStyle(color: color, fontSize: 12)),
    );
  }

  Widget _detailItem(BuildContext context, ThemeData theme, String label,
      String value, IconData icon) {
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
                Text(label,
                    style: TextStyle(
                        fontSize: 12,
                        color: theme.colorScheme.onSurface
                            .withValues(alpha: 0.6))),
                Text(value, style: const TextStyle(fontSize: 14)),
              ],
            ),
          ),
          IconButton(
            icon: const Icon(Icons.copy, size: 18),
            onPressed: () {
              Clipboard.setData(ClipboardData(text: value));
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(content: Text(isRtl ? 'تم النسخ' : 'Copied')),
              );
            },
          ),
        ],
      ),
    );
  }

  bool _isUserBanned() {
    final bannedUntil = user['banned_until'];
    if (bannedUntil == null) return false;
    final banDate = DateTime.tryParse(bannedUntil);
    return banDate != null && banDate.isAfter(DateTime.now());
  }

  String _getBanStatusText() {
    final bannedUntil = user['banned_until'];
    if (bannedUntil == null) return '';
    final banDate = DateTime.tryParse(bannedUntil);
    if (banDate == null) return '';

    final diff = banDate.difference(DateTime.now());
    if (diff.inDays > 365 * 10) {
      return isRtl ? 'محظور نهائياً' : 'Permanently banned';
    } else if (diff.inDays > 0) {
      return isRtl
          ? 'محظور لـ ${diff.inDays} يوم'
          : 'Banned for ${diff.inDays} days';
    } else if (diff.inHours > 0) {
      return isRtl
          ? 'محظور لـ ${diff.inHours} ساعة'
          : 'Banned for ${diff.inHours} hours';
    }
    return '';
  }
}
