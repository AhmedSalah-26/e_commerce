-- Row Level Security (RLS) Policies
-- Run this script after 01_create_tables.sql

-- =====================================================
-- ENABLE RLS ON ALL TABLES
-- =====================================================
ALTER TABLE profiles ENABLE ROW LEVEL SECURITY;
ALTER TABLE categories ENABLE ROW LEVEL SECURITY;
ALTER TABLE products ENABLE ROW LEVEL SECURITY;
ALTER TABLE cart_items ENABLE ROW LEVEL SECURITY;
ALTER TABLE orders ENABLE ROW LEVEL SECURITY;
ALTER TABLE order_items ENABLE ROW LEVEL SECURITY;

-- =====================================================
-- HELPER FUNCTION: Check if user is merchant
-- =====================================================
CREATE OR REPLACE FUNCTION is_merchant()
RETURNS BOOLEAN AS $$
BEGIN
  RETURN EXISTS (
    SELECT 1 FROM profiles 
    WHERE id = auth.uid() AND role = 'merchant'
  );
END;
$$ LANGUAGE plpgsql SECURITY DEFINER;

-- =====================================================
-- PROFILES POLICIES
-- =====================================================
-- Users can view their own profile
CREATE POLICY "Users can view own profile"
  ON profiles FOR SELECT
  USING (auth.uid() = id);

-- Users can update their own profile
CREATE POLICY "Users can update own profile"
  ON profiles FOR UPDATE
  USING (auth.uid() = id);

-- Allow insert during registration
-- This allows the user to create their own profile after signup
CREATE POLICY "Enable insert for authenticated users only"
  ON profiles FOR INSERT
  WITH CHECK (auth.uid() = id);

-- Allow service role to insert profiles (for triggers)
-- Note: Run this in Supabase SQL Editor if needed:
-- CREATE POLICY "Service role can insert profiles"
--   ON profiles FOR INSERT
--   TO service_role
--   WITH CHECK (true);

-- Merchants can view all profiles (for order management)
CREATE POLICY "Merchants can view all profiles"
  ON profiles FOR SELECT
  USING (is_merchant());

-- =====================================================
-- CATEGORIES POLICIES
-- =====================================================
-- Everyone can view active categories
CREATE POLICY "Anyone can view active categories"
  ON categories FOR SELECT
  USING (is_active = true);

-- Merchants can view all categories
CREATE POLICY "Merchants can view all categories"
  ON categories FOR SELECT
  USING (is_merchant());

-- Only merchants can insert categories
CREATE POLICY "Merchants can insert categories"
  ON categories FOR INSERT
  WITH CHECK (is_merchant());

-- Only merchants can update categories
CREATE POLICY "Merchants can update categories"
  ON categories FOR UPDATE
  USING (is_merchant());

-- Only merchants can delete categories
CREATE POLICY "Merchants can delete categories"
  ON categories FOR DELETE
  USING (is_merchant());

-- =====================================================
-- PRODUCTS POLICIES
-- =====================================================
-- Everyone can view active products
CREATE POLICY "Anyone can view active products"
  ON products FOR SELECT
  USING (is_active = true);

-- Merchants can view all products
CREATE POLICY "Merchants can view all products"
  ON products FOR SELECT
  USING (is_merchant());

-- Only merchants can insert products
CREATE POLICY "Merchants can insert products"
  ON products FOR INSERT
  WITH CHECK (is_merchant());

-- Only merchants can update products
CREATE POLICY "Merchants can update products"
  ON products FOR UPDATE
  USING (is_merchant());

-- Only merchants can delete products
CREATE POLICY "Merchants can delete products"
  ON products FOR DELETE
  USING (is_merchant());

-- =====================================================
-- CART ITEMS POLICIES
-- =====================================================
-- Users can view their own cart items
CREATE POLICY "Users can view own cart items"
  ON cart_items FOR SELECT
  USING (auth.uid() = user_id);

-- Users can insert their own cart items
CREATE POLICY "Users can insert own cart items"
  ON cart_items FOR INSERT
  WITH CHECK (auth.uid() = user_id);

-- Users can update their own cart items
CREATE POLICY "Users can update own cart items"
  ON cart_items FOR UPDATE
  USING (auth.uid() = user_id);

-- Users can delete their own cart items
CREATE POLICY "Users can delete own cart items"
  ON cart_items FOR DELETE
  USING (auth.uid() = user_id);

-- =====================================================
-- ORDERS POLICIES
-- =====================================================
-- Customers can view their own orders
CREATE POLICY "Customers can view own orders"
  ON orders FOR SELECT
  USING (auth.uid() = user_id);

-- Merchants can view all orders
CREATE POLICY "Merchants can view all orders"
  ON orders FOR SELECT
  USING (is_merchant());

-- Customers can create their own orders
CREATE POLICY "Customers can create own orders"
  ON orders FOR INSERT
  WITH CHECK (auth.uid() = user_id);

-- Merchants can update any order (status changes)
CREATE POLICY "Merchants can update orders"
  ON orders FOR UPDATE
  USING (is_merchant());

-- Customers can update their own pending orders
CREATE POLICY "Customers can update own pending orders"
  ON orders FOR UPDATE
  USING (auth.uid() = user_id AND status = 'pending');

-- =====================================================
-- ORDER ITEMS POLICIES
-- =====================================================
-- Users can view order items for their orders
CREATE POLICY "Users can view own order items"
  ON order_items FOR SELECT
  USING (
    EXISTS (
      SELECT 1 FROM orders 
      WHERE orders.id = order_items.order_id 
      AND orders.user_id = auth.uid()
    )
  );

-- Merchants can view all order items
CREATE POLICY "Merchants can view all order items"
  ON order_items FOR SELECT
  USING (is_merchant());

-- Users can insert order items for their orders
CREATE POLICY "Users can insert own order items"
  ON order_items FOR INSERT
  WITH CHECK (
    EXISTS (
      SELECT 1 FROM orders 
      WHERE orders.id = order_items.order_id 
      AND orders.user_id = auth.uid()
    )
  );
