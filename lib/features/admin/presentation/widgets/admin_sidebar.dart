import 'package:flutter/material.dart';

class AdminSidebar extends StatelessWidget {
  final int selectedIndex;
  final Function(int) onItemSelected;
  final bool isCollapsed;
  final VoidCallback onToggleCollapse;
  final bool isRtl;

  const AdminSidebar({
    super.key,
    required this.selectedIndex,
    required this.onItemSelected,
    this.isCollapsed = false,
    required this.onToggleCollapse,
    required this.isRtl,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final items = _getMenuItems(isRtl);

    return SafeArea(
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        width: isCollapsed ? 70 : 250,
        decoration: BoxDecoration(
          color: theme.colorScheme.surface,
          border: Border(
            right:
                isRtl ? BorderSide.none : BorderSide(color: theme.dividerColor),
            left:
                isRtl ? BorderSide(color: theme.dividerColor) : BorderSide.none,
          ),
        ),
        child: Column(
          children: [
            _buildHeader(theme),
            Expanded(
              child: ListView.builder(
                padding: const EdgeInsets.symmetric(vertical: 8),
                itemCount: items.length,
                itemBuilder: (context, index) => _buildMenuItem(
                  context,
                  items[index],
                  index,
                  theme,
                ),
              ),
            ),
            _buildCollapseButton(theme),
          ],
        ),
      ),
    );
  }

  Widget _buildHeader(ThemeData theme) {
    return Container(
      height: 64,
      padding: const EdgeInsets.symmetric(horizontal: 16),
      decoration: BoxDecoration(
        border: Border(bottom: BorderSide(color: theme.dividerColor)),
      ),
      child: Row(
        children: [
          Icon(Icons.admin_panel_settings,
              color: theme.colorScheme.primary, size: 28),
          if (!isCollapsed) ...[
            const SizedBox(width: 12),
            Text(
              isRtl ? 'لوحة التحكم' : 'Admin Panel',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: theme.colorScheme.primary,
              ),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildMenuItem(
    BuildContext context,
    _MenuItem item,
    int index,
    ThemeData theme,
  ) {
    final isSelected = selectedIndex == index;

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
      child: Material(
        color: isSelected
            ? theme.colorScheme.primary.withValues(alpha: 0.1)
            : Colors.transparent,
        borderRadius: BorderRadius.circular(8),
        child: InkWell(
          borderRadius: BorderRadius.circular(8),
          onTap: () => onItemSelected(index),
          child: Padding(
            padding: EdgeInsets.symmetric(
              horizontal: isCollapsed ? 12 : 16,
              vertical: 12,
            ),
            child: Row(
              children: [
                Icon(
                  item.icon,
                  color: isSelected
                      ? theme.colorScheme.primary
                      : theme.colorScheme.onSurface.withValues(alpha: 0.7),
                  size: 22,
                ),
                if (!isCollapsed) ...[
                  const SizedBox(width: 12),
                  Expanded(
                    child: Text(
                      item.title,
                      style: TextStyle(
                        color: isSelected
                            ? theme.colorScheme.primary
                            : theme.colorScheme.onSurface,
                        fontWeight:
                            isSelected ? FontWeight.w600 : FontWeight.normal,
                      ),
                    ),
                  ),
                ],
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildCollapseButton(ThemeData theme) {
    return Container(
      padding: const EdgeInsets.all(8),
      decoration: BoxDecoration(
        border: Border(top: BorderSide(color: theme.dividerColor)),
      ),
      child: IconButton(
        onPressed: onToggleCollapse,
        icon: Icon(
          isCollapsed
              ? (isRtl ? Icons.chevron_left : Icons.chevron_right)
              : (isRtl ? Icons.chevron_right : Icons.chevron_left),
        ),
      ),
    );
  }

  List<_MenuItem> _getMenuItems(bool isRtl) => [
        _MenuItem(Icons.dashboard, isRtl ? 'الرئيسية' : 'Dashboard'),
        _MenuItem(Icons.people, isRtl ? 'المستخدمين' : 'Users'),
        _MenuItem(Icons.receipt_long, isRtl ? 'الطلبات' : 'Orders'),
        _MenuItem(Icons.inventory, isRtl ? 'المنتجات' : 'Products'),
        _MenuItem(Icons.category, isRtl ? 'التصنيفات' : 'Categories'),
        _MenuItem(Icons.local_offer, isRtl ? 'الكوبونات' : 'Coupons'),
        _MenuItem(Icons.local_shipping, isRtl ? 'الشحن' : 'Shipping'),
        _MenuItem(Icons.analytics, isRtl ? 'التقارير' : 'Reports'),
        _MenuItem(Icons.settings, isRtl ? 'الإعدادات' : 'Settings'),
      ];
}

class _MenuItem {
  final IconData icon;
  final String title;
  _MenuItem(this.icon, this.title);
}
