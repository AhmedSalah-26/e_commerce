# Admin Dashboard - Requirements

## Overview
لوحة تحكم إدارية شاملة لتطبيق E-Commerce متعدد التجار

## Roles
1. **Admin** - إدارة كاملة للنظام
2. **Merchant** - إدارة متجره فقط (موجود حالياً)

## Priority Phases

### Phase 1: Core Admin Structure ⭐ (Current)
- [ ] Admin authentication & role check
- [ ] Admin dashboard layout (sidebar, header)
- [ ] Admin home with statistics
- [ ] Navigation structure

### Phase 2: Users Management
- [ ] Users list (customers, merchants, admins)
- [ ] User details view
- [ ] Activate/deactivate users
- [ ] Create new admin

### Phase 3: Orders Management (Admin View)
- [ ] All orders from all merchants
- [ ] Filter by merchant, status, date
- [ ] Order details view

### Phase 4: Products Management (Admin View)
- [ ] All products from all merchants
- [ ] Filter by merchant, category, status
- [ ] Activate/deactivate products

### Phase 5: Reports & Analytics
- [ ] Sales reports (daily/weekly/monthly)
- [ ] Top merchants report
- [ ] Top products report
- [ ] Export to PDF/Excel

### Phase 6: Settings
- [ ] App settings
- [ ] Payment settings
- [ ] Notification settings
- [ ] Terms & Privacy

## Technical Stack
- Flutter Web (responsive)
- Cubit for state management
- Supabase backend
- Clean Architecture

## File Structure
```
lib/features/admin/
├── data/
│   ├── datasources/
│   │   └── admin_remote_datasource.dart
│   ├── models/
│   │   └── admin_stats_model.dart
│   └── repositories/
│       └── admin_repository_impl.dart
├── domain/
│   ├── entities/
│   │   └── admin_stats_entity.dart
│   └── repositories/
│       └── admin_repository.dart
└── presentation/
    ├── cubit/
    │   ├── admin_cubit.dart
    │   └── admin_state.dart
    ├── pages/
    │   ├── admin_dashboard_page.dart
    │   ├── admin_home_tab.dart
    │   ├── admin_users_tab.dart
    │   ├── admin_orders_tab.dart
    │   ├── admin_products_tab.dart
    │   ├── admin_categories_tab.dart
    │   ├── admin_coupons_tab.dart
    │   ├── admin_shipping_tab.dart
    │   ├── admin_reports_tab.dart
    │   └── admin_settings_tab.dart
    └── widgets/
        ├── admin_sidebar.dart
        ├── admin_header.dart
        ├── stats_card.dart
        ├── data_table_widget.dart
        └── chart_widget.dart
```
