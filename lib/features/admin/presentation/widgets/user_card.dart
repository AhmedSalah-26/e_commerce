import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

class UserCard extends StatelessWidget {
  final Map<String, dynamic> user;
  final bool isRtl;
  final bool isMobile;
  final VoidCallback onTap;
  final Function(String action) onAction;

  const UserCard({
    super.key,
    required this.user,
    required this.isRtl,
    required this.isMobile,
    required this.onTap,
    required this.onAction,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isActive = user['is_active'] ?? true;
    final isBanned = _isUserBanned();
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
        leading: _buildAvatar(theme, name, isBanned),
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
            Text(email,
                style: TextStyle(fontSize: isMobile ? 11 : 12),
                maxLines: 1,
                overflow: TextOverflow.ellipsis),
            if (isBanned)
              Text(_getBanStatusText(),
                  style: const TextStyle(fontSize: 10, color: Colors.red)),
          ],
        ),
        trailing: _buildTrailing(context, isActive, isBanned),
        onTap: onTap,
      ),
    );
  }

  Widget _buildAvatar(ThemeData theme, String name, bool isBanned) {
    return Stack(
      children: [
        CircleAvatar(
          radius: isMobile ? 18 : 22,
          backgroundColor: isBanned ? Colors.red : theme.colorScheme.primary,
          child: Text(
            name.isNotEmpty ? name[0].toUpperCase() : 'U',
            style: TextStyle(color: Colors.white, fontSize: isMobile ? 14 : 16),
          ),
        ),
        if (isBanned)
          Positioned(
            right: 0,
            bottom: 0,
            child: Container(
              padding: const EdgeInsets.all(2),
              decoration: const BoxDecoration(
                  color: Colors.red, shape: BoxShape.circle),
              child: const Icon(Icons.block, size: 12, color: Colors.white),
            ),
          ),
      ],
    );
  }

  Widget _buildTrailing(BuildContext context, bool isActive, bool isBanned) {
    final theme = Theme.of(context);
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        if (!isMobile) _buildStatusChip(isActive, isBanned),
        PopupMenuButton<String>(
          icon: Icon(
            Icons.more_vert,
            color: isBanned
                ? Colors.red
                : isMobile
                    ? (isActive ? Colors.green : Colors.orange)
                    : theme.colorScheme.onSurface,
          ),
          itemBuilder: (_) => _buildMenuItems(isActive, isBanned),
          onSelected: onAction,
        ),
      ],
    );
  }

  Widget _buildStatusChip(bool isActive, bool isBanned) {
    final color =
        isBanned ? Colors.red : (isActive ? Colors.green : Colors.orange);
    final text = isBanned
        ? (isRtl ? 'محظور' : 'Banned')
        : isActive
            ? (isRtl ? 'نشط' : 'Active')
            : (isRtl ? 'معطل' : 'Inactive');

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Text(text, style: TextStyle(color: color, fontSize: 12)),
    );
  }

  List<PopupMenuEntry<String>> _buildMenuItems(bool isActive, bool isBanned) {
    final isAdmin = user['role'] == 'admin';
    return [
      _menuItem('details', Icons.info_outline, isRtl ? 'التفاصيل' : 'Details'),
      _menuItem('copy_id', Icons.copy, isRtl ? 'نسخ ID' : 'Copy ID'),
      _menuItem('copy_email', Icons.email_outlined,
          isRtl ? 'نسخ الإيميل' : 'Copy Email'),
      const PopupMenuDivider(),
      _menuItem(
        'toggle',
        isActive ? Icons.visibility_off : Icons.visibility,
        isActive
            ? (isRtl ? 'تعطيل مؤقت' : 'Deactivate')
            : (isRtl ? 'تفعيل' : 'Activate'),
        Colors.orange,
      ),
      if (!isAdmin) ...[
        const PopupMenuDivider(),
        if (isBanned)
          _menuItem('unban', Icons.lock_open, isRtl ? 'إلغاء الحظر' : 'Unban',
              Colors.green)
        else ...[
          _menuItem('ban_24h', Icons.timer,
              isRtl ? 'حظر 24 ساعة' : 'Ban 24 hours', Colors.red),
          _menuItem('ban_7d', Icons.date_range,
              isRtl ? 'حظر 7 أيام' : 'Ban 7 days', Colors.red),
          _menuItem('ban_30d', Icons.calendar_month,
              isRtl ? 'حظر 30 يوم' : 'Ban 30 days', Colors.red),
          _menuItem('ban_forever', Icons.block,
              isRtl ? 'حظر نهائي' : 'Ban permanently', Colors.red, true),
        ],
      ],
    ];
  }

  PopupMenuItem<String> _menuItem(String value, IconData icon, String text,
      [Color? color, bool bold = false]) {
    return PopupMenuItem(
      value: value,
      child: Row(
        children: [
          Icon(icon, size: 18, color: color),
          const SizedBox(width: 8),
          Text(text,
              style: TextStyle(
                  color: color, fontWeight: bold ? FontWeight.bold : null)),
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
