# Implementation Plan

## Phase 1: Project Setup & Core Infrastructure

- [x] 1. Setup project dependencies and Supabase configuration

























  - [x] 1.1 Add required dependencies to pubspec.yaml (supabase_flutter, flutter_bloc, dartz, equatable, get_it)











    - _Requirements: 9.1, 10.1_

  - [x] 1.2 Create Supabase service class in `lib/core/services/supabase_service.dart`












    - _Requirements: 9.5_
  - [ ] 1.3 Setup dependency injection with get_it in `lib/core/di/injection_container.dart`
    - _Requirements: 9.1_
  - [ ] 1.4 Update main.dart to initialize Supabase and DI
    - _Requirements: 9.1_

- [ ] 2. Create database scripts folder
  - [ ] 2.1 Create `database_scripts/01_create_tables.sql` with all table definitions
    - _Requirements: 8.1, 8.2, 8.3_
  - [ ] 2.2 Create `database_scripts/02_rls_policies.sql` with Row Level Security policies
    - _Requirements: 8.4_



  - [ ] 2.3 Create `database_scripts/03_functions.sql` with helper functions
    - _Requirements: 8.1_


- [ ] 3. Setup core error handling and utilities
  - [ ] 3.1 Create failure classes in `lib/core/errors/failures.dart`
    - _Requirements: 9.2_
  - [ ] 3.2 Create exceptions classes in `lib/core/errors/exceptions.dart`
    - _Requirements: 9.2_

## Phase 2: Authentication Feature

- [ ] 4. Implement Auth data layer
  - [ ] 4.1 Create UserModel in `lib/features/auth/data/models/user_model.dart`
    - _Requirements: 1.2_
  - [ ] 4.2 Create AuthRemoteDataSource in `lib/features/auth/data/datasources/auth_remote_datasource.dart`
    - _Requirements: 1.2, 1.3, 1.6_
  - [ ] 4.3 Create AuthRepositoryImpl in `lib/features/auth/data/repositories/auth_repository_impl.dart`
    - _Requirements: 1.2, 1.3, 1.6_

- [ ] 5. Implement Auth domain layer
  - [ ] 5.1 Create UserEntity in `lib/features/auth/domain/entities/user_entity.dart`
    - _Requirements: 1.2_
  - [ ] 5.2 Create AuthRepository interface in `lib/features/auth/domain/repositories/auth_repository.dart`
    - _Requirements: 9.3_
  - [ ] 5.3 Create SignIn, SignUp, SignOut, GetCurrentUser use cases
    - _Requirements: 1.2, 1.3, 1.5, 1.6_

- [ ] 6. Implement Auth presentation layer
  - [ ] 6.1 Create AuthCubit and AuthState in `lib/features/auth/presentation/cubit/`
    - _Requirements: 10.2, 10.3_
  - [ ] 6.2 Create LoginPage with role selection UI
    - _Requirements: 1.1, 1.4_
  - [ ] 6.3 Create RegisterPage with role selection
    - _Requirements: 1.1, 1.2_
  - [ ] 6.4 Update routing to handle role-based navigation
    - _Requirements: 1.3, 1.5_
  - [ ]* 6.5 Write property test for role-based registration
    - **Property 1: Role-based Registration Consistency**
    - **Validates: Requirements 1.2**
  - [ ]* 6.6 Write property test for role-based dashboard routing
    - **Property 2: Role-based Dashboard Routing**
    - **Validates: Requirements 1.3, 1.5**

- [ ] 7. Checkpoint - Ensure all tests pass
  - Ensure all tests pass, ask the user if questions arise.

## Phase 3: Products Feature

- [ ] 8. Implement Products data layer
  - [ ] 8.1 Create ProductModel in `lib/features/products/data/models/product_model.dart`
    - _Requirements: 2.3_
  - [ ]* 8.2 Write property test for ProductModel serialization round-trip
    - **Property 14: Product Model Serialization Round-Trip**
    - **Validates: Requirements 2.3, 6.4**
  - [x] 8.3 Create ProductRemoteDataSource in `lib/features/products/data/datasources/`

    - _Requirements: 2.1, 2.2_

  - [ ] 8.4 Create ProductRepositoryImpl
    - _Requirements: 2.1, 2.2, 9.5_

- [-] 9. Implement Products domain layer

  - [x] 9.1 Create ProductEntity in `lib/features/products/domain/entities/`

    - _Requirements: 2.3_

  - [x] 9.2 Create ProductRepository interface

    - _Requirements: 9.3_
  - [ ] 9.3 Create GetProducts, GetProductsByCategory use cases
    - _Requirements: 2.1, 2.2_

- [-] 10. Implement Products presentation layer



  - [ ] 10.1 Create ProductsCubit and states
    - _Requirements: 10.2, 10.3_
  - [ ] 10.2 Refactor HomeScreen to use ProductsCubit
    - _Requirements: 2.1, 2.4, 2.5_
  - [ ] 10.3 Update product grid to display from Supabase
    - _Requirements: 2.1, 2.3_
  - [ ]* 10.4 Write property test for category filtering
    - **Property 4: Category Filtering Correctness**
    - **Validates: Requirements 2.2**

## Phase 4: Categories Feature

- [-] 11. Implement Categories feature


  - [x] 11.1 Create CategoryModel and CategoryEntity

    - _Requirements: 7.1_

  - [x] 11.2 Create CategoryRemoteDataSource

    - _Requirements: 7.1, 7.2, 7.3, 7.4_

  - [ ] 11.3 Create CategoryRepositoryImpl
    - _Requirements: 9.5_
  - [ ] 11.4 Create CategoriesCubit
    - _Requirements: 10.2_
  - [ ] 11.5 Update category row to fetch from Supabase
    - _Requirements: 7.1_
  - [ ]* 11.6 Write property test for category deletion protection
    - **Property 13: Category Deletion Protection**
    - **Validates: Requirements 7.5**

- [ ] 12. Checkpoint - Ensure all tests pass
  - Ensure all tests pass, ask the user if questions arise.






## Phase 5: Cart Feature

- [ ] 13. Implement Cart data layer
  - [ ] 13.1 Create CartItemModel in `lib/features/cart/data/models/`
    - _Requirements: 3.1_
  - [ ] 13.2 Create CartRemoteDataSource with Supabase operations
    - _Requirements: 3.1, 3.2, 3.3, 3.5_
  - [ ] 13.3 Create CartRepositoryImpl
    - _Requirements: 9.5_

- [ ] 14. Implement Cart domain layer
  - [ ] 14.1 Create CartItemEntity
    - _Requirements: 3.4_
  - [ ] 14.2 Create CartRepository interface
    - _Requirements: 9.3_
  - [ ] 14.3 Create AddToCart, UpdateQuantity, RemoveFromCart, GetCartItems use cases
    - _Requirements: 3.1, 3.2, 3.3, 3.4_

- [ ] 15. Implement Cart presentation layer
  - [ ] 15.1 Create CartCubit with real-time subscription
    - _Requirements: 3.5, 10.2_
  - [ ] 15.2 Refactor CartScreen to use CartCubit
    - _Requirements: 3.4_
  - [ ] 15.3 Implement cart total calculation in Cubit
    - _Requirements: 3.2, 3.4_
  - [ ]* 15.4 Write property test for cart total calculation
    - **Property 5: Cart Total Calculation**
    - **Validates: Requirements 3.2, 3.4**
  - [-]* 15.5 Write property test for cart item removal on zero quantity




    - **Property 6: Cart Item Removal on Zero Quantity**

    - **Validates: Requirements 3.3**
  - [ ]* 15.6 Write property test for cart-database sync
    - **Property 7: Cart-Database Sync**
    - **Validates: Requirements 3.1, 3.5**

## Phase 6: Orders Feature

- [ ] 16. Implement Orders data layer
  - [ ] 16.1 Create OrderModel and OrderItemModel
    - _Requirements: 4.1, 5.2_
  - [ ] 16.2 Create OrderRemoteDataSource
    - _Requirements: 4.1, 4.2, 4.5, 5.1, 5.3_
  - [x] 16.3 Create OrderRepositoryImpl

    - _Requirements: 9.5_

- [ ] 17. Implement Orders domain layer
  - [ ] 17.1 Create OrderEntity and OrderItemEntity
    - _Requirements: 5.2_
  - [ ] 17.2 Create OrderRepository interface
    - _Requirements: 9.3_
  - [ ] 17.3 Create CreateOrder, GetOrders, UpdateOrderStatus use cases
    - _Requirements: 4.1, 4.5, 5.3_

- [ ] 18. Implement Orders presentation layer
  - [ ] 18.1 Create OrdersCubit with real-time subscription for merchant
    - _Requirements: 5.4, 10.2_
  - [ ] 18.2 Create CheckoutPage for customers
    - _Requirements: 4.1, 4.3_
  - [ ] 18.3 Create OrderHistoryPage for customers
    - _Requirements: 4.5_
  - [ ]* 18.4 Write property test for order creation stock decrement
    - **Property 8: Order Creation Stock Decrement**
    - **Validates: Requirements 4.2**
  - [ ]* 18.5 Write property test for order creation cart clearing
    - **Property 9: Order Creation Cart Clearing**
    - **Validates: Requirements 4.3**
  - [ ]* 18.6 Write property test for order status persistence
    - **Property 10: Order Status Persistence**
    - **Validates: Requirements 5.3**

- [ ] 19. Checkpoint - Ensure all tests pass
  - Ensure all tests pass, ask the user if questions arise.

## Phase 7: Merchant Dashboard

- [ ] 20. Create Merchant Dashboard structure
  - [ ] 20.1 Create MerchantDashboardPage with bottom navigation
    - _Requirements: 5.1, 6.1, 7.1_
  - [ ] 20.2 Create MerchantOrdersPage
    - _Requirements: 5.1, 5.2, 5.3_
  - [ ] 20.3 Create order status update functionality
    - _Requirements: 5.3_

- [ ] 21. Implement Inventory Management
  - [ ] 21.1 Create InventoryCubit
    - _Requirements: 6.1, 6.2, 10.2_
  - [ ] 21.2 Create InventoryPage showing all products with stock
    - _Requirements: 6.1_
  - [ ] 21.3 Create stock update functionality
    - _Requirements: 6.2, 6.3_
  - [ ] 21.4 Create AddProductPage for merchants
    - _Requirements: 6.4_
  - [ ] 21.5 Create EditProductPage for merchants
    - _Requirements: 6.5_
  - [ ]* 21.6 Write property test for inventory stock update persistence
    - **Property 11: Inventory Stock Update Persistence**
    - **Validates: Requirements 6.2**
  - [ ]* 21.7 Write property test for out of stock marking
    - **Property 12: Out of Stock Marking**
    - **Validates: Requirements 6.3**

- [ ] 22. Implement Categories Management for Merchant
  - [ ] 22.1 Create CategoriesManagementPage
    - _Requirements: 7.1_
  - [ ] 22.2 Create AddCategoryPage
    - _Requirements: 7.2_
  - [ ] 22.3 Create EditCategoryPage
    - _Requirements: 7.3_
  - [ ] 22.4 Implement category deletion with product check
    - _Requirements: 7.4, 7.5_

## Phase 8: Final Integration & Cleanup

- [ ] 23. Wire everything together
  - [ ] 23.1 Register all Cubits in dependency injection
    - _Requirements: 9.1_
  - [ ] 23.2 Update app routing for all new pages
    - _Requirements: 1.3_
  - [ ] 23.3 Remove old Provider-based code
    - _Requirements: 10.1_
  - [ ] 23.4 Clean up unused imports and files
    - _Requirements: 9.1_

- [ ] 24. Final Checkpoint - Ensure all tests pass
  - Ensure all tests pass, ask the user if questions arise.
