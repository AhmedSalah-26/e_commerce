# Admin Dashboard - Implementation Tasks

## Phase 1: Core Structure ✅ In Progress

### Task 1.1: Database Setup
- [ ] Add is_admin column to profiles
- [ ] Create admin user in database

### Task 1.2: Domain Layer
- [x] Create AdminStatsEntity
- [x] Create AdminRepository interface

### Task 1.3: Data Layer
- [x] Create AdminStatsModel
- [x] Create AdminRemoteDatasource
- [x] Create AdminRepositoryImpl

### Task 1.4: Presentation Layer - Cubit
- [x] Create AdminCubit
- [x] Create AdminState

### Task 1.5: Presentation Layer - Pages
- [x] Create AdminDashboardPage (main layout)
- [x] Create AdminSidebar
- [x] Create AdminHeader
- [x] Create AdminHomeTab (statistics)

### Task 1.6: Routing
- [x] Add admin routes to GoRouter
- [x] Add admin role check

### Task 1.7: DI Setup
- [x] Register admin dependencies

---

## Phase 2: Users Management (Next)

### Task 2.1: Domain
- [ ] Create UserManagementEntity
- [ ] Add methods to AdminRepository

### Task 2.2: Data
- [ ] Implement user management in datasource

### Task 2.3: Presentation
- [ ] Create AdminUsersCubit
- [ ] Create AdminUsersTab
- [ ] Create UserDetailsDialog

---

## Phase 3-6: Future Tasks
(To be detailed when Phase 2 is complete)
