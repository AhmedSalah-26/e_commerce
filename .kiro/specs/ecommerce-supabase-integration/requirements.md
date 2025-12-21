# Requirements Document

## Introduction

تحويل تطبيق E-Commerce من نسخة UI بسيطة إلى تطبيق كامل يعمل مع Supabase كـ backend، باستخدام Clean Architecture و Cubit لإدارة الحالة. التطبيق يدعم نوعين من المستخدمين (تاجر/عميل) مع لوحة تحكم للتاجر لإدارة الأوردرات والمخزون.

## Glossary

- **Supabase**: منصة Backend-as-a-Service مفتوحة المصدر توفر قاعدة بيانات PostgreSQL و Authentication و Storage
- **Clean Architecture**: نمط معماري يفصل الكود إلى طبقات (Data, Domain, Presentation)
- **Cubit**: مكتبة لإدارة الحالة من BLoC ecosystem أبسط من BLoC التقليدي
- **Merchant (تاجر)**: مستخدم يدير المنتجات والأوردرات والمخزون
- **Customer (عميل)**: مستخدم يتصفح المنتجات ويقوم بالشراء
- **Order**: طلب شراء يحتوي على منتجات وكميات وحالة
- **Inventory**: المخزون المتاح من كل منتج
- **Category**: تصنيف المنتجات

## Requirements

### Requirement 1: Authentication System

**User Story:** As a user, I want to register and login with my role (merchant or customer), so that I can access features specific to my role.

#### Acceptance Criteria

1. WHEN a user opens the app for the first time THEN the System SHALL display a login/register screen with role selection (merchant/customer)
2. WHEN a user registers with valid email, password, and role THEN the System SHALL create an account in Supabase Auth and store user profile with role
3. WHEN a user logs in with valid credentials THEN the System SHALL authenticate via Supabase and redirect to appropriate dashboard based on role
4. WHEN a user provides invalid credentials THEN the System SHALL display an error message and maintain the login screen
5. WHEN a logged-in user opens the app THEN the System SHALL restore the session and redirect to appropriate dashboard
6. WHEN a user logs out THEN the System SHALL clear the session and redirect to login screen

### Requirement 2: Customer Product Browsing

**User Story:** As a customer, I want to browse products by category, so that I can find items I want to purchase.

#### Acceptance Criteria

1. WHEN a customer opens the home screen THEN the System SHALL fetch and display products from Supabase database
2. WHEN a customer selects a category THEN the System SHALL filter and display products belonging to that category
3. WHEN a customer views a product THEN the System SHALL display product details including name, description, price, images, rating, and available stock
4. WHEN products are loading THEN the System SHALL display a loading indicator
5. WHEN product fetch fails THEN the System SHALL display an error message with retry option

### Requirement 3: Shopping Cart Management

**User Story:** As a customer, I want to manage my shopping cart, so that I can prepare my order before checkout.

#### Acceptance Criteria

1. WHEN a customer adds a product to cart THEN the System SHALL store the cart item in Supabase and update the local cart state
2. WHEN a customer increases item quantity THEN the System SHALL update the quantity in Supabase and recalculate totals
3. WHEN a customer decreases item quantity to zero THEN the System SHALL remove the item from cart in Supabase
4. WHEN a customer views cart THEN the System SHALL display all cart items with quantities and calculated total
5. WHEN a customer's cart is modified THEN the System SHALL sync changes with Supabase in real-time

### Requirement 4: Order Placement

**User Story:** As a customer, I want to place an order from my cart, so that I can purchase the products I selected.

#### Acceptance Criteria

1. WHEN a customer confirms checkout THEN the System SHALL create an order record in Supabase with status "pending"
2. WHEN an order is created THEN the System SHALL decrease product stock quantities in Supabase
3. WHEN an order is created THEN the System SHALL clear the customer's cart
4. WHEN order creation fails THEN the System SHALL display an error message and maintain cart state
5. WHEN a customer views order history THEN the System SHALL fetch and display all orders for that customer from Supabase

### Requirement 5: Merchant Dashboard - Orders Management

**User Story:** As a merchant, I want to view and manage orders, so that I can fulfill customer requests.

#### Acceptance Criteria

1. WHEN a merchant opens the dashboard THEN the System SHALL fetch and display all orders from Supabase
2. WHEN a merchant views an order THEN the System SHALL display order details including customer info, items, quantities, and total
3. WHEN a merchant updates order status THEN the System SHALL update the status in Supabase and reflect the change immediately
4. WHEN new orders arrive THEN the System SHALL update the orders list in real-time using Supabase subscriptions
5. WHEN orders are loading THEN the System SHALL display a loading indicator

### Requirement 6: Merchant Dashboard - Inventory Management

**User Story:** As a merchant, I want to manage product inventory, so that I can track stock levels and update quantities.

#### Acceptance Criteria

1. WHEN a merchant views inventory THEN the System SHALL display all products with current stock quantities from Supabase
2. WHEN a merchant updates product stock THEN the System SHALL update the quantity in Supabase database
3. WHEN stock quantity reaches zero THEN the System SHALL mark the product as "out of stock"
4. WHEN a merchant adds a new product THEN the System SHALL create the product record in Supabase with all details
5. WHEN a merchant edits product details THEN the System SHALL update the product record in Supabase

### Requirement 7: Merchant Dashboard - Categories Management

**User Story:** As a merchant, I want to manage product categories, so that I can organize products for customers.

#### Acceptance Criteria

1. WHEN a merchant views categories THEN the System SHALL display all categories from Supabase
2. WHEN a merchant creates a category THEN the System SHALL add the category to Supabase database
3. WHEN a merchant edits a category THEN the System SHALL update the category in Supabase
4. WHEN a merchant deletes a category with no products THEN the System SHALL remove the category from Supabase
5. WHEN a merchant attempts to delete a category with products THEN the System SHALL display a warning and prevent deletion

### Requirement 8: Database Scripts

**User Story:** As a developer, I want Supabase database scripts in a dedicated folder, so that I can set up the database schema easily.

#### Acceptance Criteria

1. WHEN setting up the project THEN the System SHALL provide SQL scripts in `database_scripts` folder for creating all required tables
2. WHEN running the scripts THEN the System SHALL create tables for users, products, categories, cart_items, and orders
3. WHEN tables are created THEN the System SHALL include proper foreign key relationships and indexes
4. WHEN tables are created THEN the System SHALL include Row Level Security (RLS) policies for data protection

### Requirement 9: Clean Architecture Structure

**User Story:** As a developer, I want the codebase organized with Clean Architecture, so that the code is maintainable and testable.

#### Acceptance Criteria

1. WHEN organizing code THEN the System SHALL separate each feature into data, domain, and presentation layers
2. WHEN implementing data layer THEN the System SHALL contain models, data sources, and repositories
3. WHEN implementing domain layer THEN the System SHALL contain entities, use cases, and repository interfaces
4. WHEN implementing presentation layer THEN the System SHALL contain Cubits, states, and UI widgets
5. WHEN implementing Supabase integration THEN the System SHALL use repository pattern to abstract data source

### Requirement 10: State Management Migration

**User Story:** As a developer, I want to migrate from Provider to Cubit, so that the app uses a more scalable state management solution.

#### Acceptance Criteria

1. WHEN migrating state management THEN the System SHALL replace Provider with flutter_bloc/Cubit
2. WHEN implementing Cubits THEN the System SHALL create separate Cubit for each feature (Auth, Products, Cart, Orders, Inventory)
3. WHEN Cubit emits state THEN the System SHALL update UI reactively using BlocBuilder or BlocConsumer
4. WHEN handling errors THEN the System SHALL emit error states that UI can display appropriately
