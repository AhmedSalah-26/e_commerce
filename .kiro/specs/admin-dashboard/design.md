# Admin Dashboard - Design

## Database Changes Required

### 1. Add is_admin field to profiles table
```sql
ALTER TABLE profiles ADD COLUMN is_admin BOOLEAN DEFAULT FALSE;
```

### 2. Admin Statistics View (Optional - for performance)
```sql
CREATE VIEW admin_dashboard_stats AS
SELECT 
  (SELECT COUNT(*) FROM profiles WHERE is_merchant = false AND is_admin = false) as total_customers,
  (SELECT COUNT(*) FROM profiles WHERE is_merchant = true) as total_merchants,
  (SELECT COUNT(*) FROM products WHERE is_active = true) as active_products,
  (SELECT COUNT(*) FROM orders WHERE status = 'pending') as pending_orders,
  (SELECT COALESCE(SUM(total), 0) FROM orders WHERE status = 'delivered') as total_revenue;
```

## UI Design

### Layout (Desktop)
```
┌─────────────────────────────────────────────────────────┐
│ Header (Logo, Search, Notifications, Profile)           │
├──────────┬──────────────────────────────────────────────┤
│          │                                              │
│ Sidebar  │  Main Content Area                           │
│          │                                              │
│ - Home   │  ┌─────────┐ ┌─────────┐ ┌─────────┐        │
│ - Users  │  │ Stats 1 │ │ Stats 2 │ │ Stats 3 │        │
│ - Orders │  └─────────┘ └─────────┘ └─────────┘        │
│ - Products│                                             │
│ - Categories│ ┌─────────────────────────────────┐      │
│ - Coupons│   │ Chart / Table                    │      │
│ - Shipping│  │                                  │      │
│ - Reports│   └─────────────────────────────────┘      │
│ - Settings│                                            │
│          │                                              │
└──────────┴──────────────────────────────────────────────┘
```

### Layout (Mobile)
```
┌─────────────────────┐
│ Header (☰ Menu)     │
├─────────────────────┤
│                     │
│  Main Content       │
│                     │
│  Stats Cards        │
│  (Scrollable)       │
│                     │
│  Table/List         │
│                     │
└─────────────────────┘
```

## State Management

### AdminCubit States
- AdminInitial
- AdminLoading
- AdminLoaded (stats, recentOrders, topProducts)
- AdminError

### AdminUsersCubit States
- UsersInitial
- UsersLoading
- UsersLoaded (users, filters)
- UsersError

## Navigation
- Use GoRouter with nested routes
- /admin - Dashboard home
- /admin/users - Users management
- /admin/orders - Orders management
- /admin/products - Products management
- /admin/categories - Categories management
- /admin/coupons - Coupons management
- /admin/shipping - Shipping management
- /admin/reports - Reports
- /admin/settings - Settings
