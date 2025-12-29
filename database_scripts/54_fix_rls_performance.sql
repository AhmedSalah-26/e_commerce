-- =====================================================
-- FIX RLS PERFORMANCE ISSUES
-- 1. Fix auth.uid() calls to use (select auth.uid())
-- 2. Consolidate multiple permissive policies
-- 3. Drop duplicate indexes
-- =====================================================

-- =====================================================
-- PART 1: UPDATE HELPER FUNCTIONS TO USE SUBQUERY
-- =====================================================

-- Update is_merchant function
CREATE OR REPLACE FUNCTION is_merchant()
RETURNS BOOLEAN AS $$
BEGIN
  RETURN EXISTS (
    SELECT 1 FROM profiles 
    WHERE id = (SELECT auth.uid()) AND role = 'merchant'
  );
END;
$$ LANGUAGE plpgsql SECURITY DEFINER STABLE;

-- Update is_admin function
CREATE OR REPLACE FUNCTION is_admin()
RETURNS BOOLEAN AS $$
BEGIN
  RETURN EXISTS (
    SELECT 1 FROM profiles 
    WHERE id = (SELECT auth.uid()) 
    AND role = 'admin'
  );
END;
$$ LANGUAGE plpgsql SECURITY DEFINER STABLE;

-- =====================================================
-- PART 2: FIX CART_ITEMS RLS POLICIES
-- =====================================================
DROP POLICY IF EXISTS "Users can view own cart items" ON cart_items;
DROP POLICY IF EXISTS "Users can insert own cart items" ON cart_items;
DROP POLICY IF EXISTS "Users can update own cart items" ON cart_items;
DROP POLICY IF EXISTS "Users can delete own cart items" ON cart_items;

CREATE POLICY "Users can view own cart items" ON cart_items
  FOR SELECT USING ((SELECT auth.uid()) = user_id);

CREATE POLICY "Users can insert own cart items" ON cart_items
  FOR INSERT WITH CHECK ((SELECT auth.uid()) = user_id);

CREATE POLICY "Users can update own cart items" ON cart_items
  FOR UPDATE USING ((SELECT auth.uid()) = user_id);

CREATE POLICY "Users can delete own cart items" ON cart_items
  FOR DELETE USING ((SELECT auth.uid()) = user_id);

-- =====================================================
-- PART 3: FIX ORDERS RLS POLICIES (CONSOLIDATED)
-- =====================================================
DROP POLICY IF EXISTS "Customers can view own orders" ON orders;
DROP POLICY IF EXISTS "Merchants can view all orders" ON orders;
DROP POLICY IF EXISTS "Admin can view all orders" ON orders;
DROP POLICY IF EXISTS "Customers can create own orders" ON orders;
DROP POLICY IF EXISTS "Merchants can update orders" ON orders;
DROP POLICY IF EXISTS "Customers can update own pending orders" ON orders;
DROP POLICY IF EXISTS "Admin can update all orders" ON orders;

-- Consolidated SELECT policy
CREATE POLICY "Orders select policy" ON orders
  FOR SELECT USING (
    (SELECT auth.uid()) = user_id 
    OR is_merchant() 
    OR is_admin()
  );

-- INSERT policy
CREATE POLICY "Orders insert policy" ON orders
  FOR INSERT WITH CHECK ((SELECT auth.uid()) = user_id);

-- Consolidated UPDATE policy
CREATE POLICY "Orders update policy" ON orders
  FOR UPDATE USING (
    is_merchant() 
    OR is_admin() 
    OR ((SELECT auth.uid()) = user_id AND status = 'pending')
  );

-- =====================================================
-- PART 4: FIX ORDER_ITEMS RLS POLICIES (CONSOLIDATED)
-- =====================================================
DROP POLICY IF EXISTS "Users can view own order items" ON order_items;
DROP POLICY IF EXISTS "Merchants can view all order items" ON order_items;
DROP POLICY IF EXISTS "Users can insert own order items" ON order_items;

-- Consolidated SELECT policy
CREATE POLICY "Order items select policy" ON order_items
  FOR SELECT USING (
    EXISTS (
      SELECT 1 FROM orders 
      WHERE orders.id = order_items.order_id 
      AND orders.user_id = (SELECT auth.uid())
    )
    OR is_merchant()
  );

-- INSERT policy
CREATE POLICY "Order items insert policy" ON order_items
  FOR INSERT WITH CHECK (
    EXISTS (
      SELECT 1 FROM orders 
      WHERE orders.id = order_items.order_id 
      AND orders.user_id = (SELECT auth.uid())
    )
  );

-- =====================================================
-- PART 5: FIX PROFILES RLS POLICIES (CONSOLIDATED)
-- =====================================================
DROP POLICY IF EXISTS "Users can view own profile" ON profiles;
DROP POLICY IF EXISTS "Users can update own profile" ON profiles;
DROP POLICY IF EXISTS "Users can insert own profile" ON profiles;
DROP POLICY IF EXISTS "Enable insert for authenticated users only" ON profiles;
DROP POLICY IF EXISTS "Merchants can view all profiles" ON profiles;
DROP POLICY IF EXISTS "Admin can view all profiles" ON profiles;
DROP POLICY IF EXISTS "Admin can update all profiles" ON profiles;

-- Consolidated SELECT policy
CREATE POLICY "Profiles select policy" ON profiles
  FOR SELECT USING (
    (SELECT auth.uid()) = id 
    OR is_merchant() 
    OR is_admin()
  );

-- Consolidated UPDATE policy
CREATE POLICY "Profiles update policy" ON profiles
  FOR UPDATE USING (
    (SELECT auth.uid()) = id 
    OR is_admin()
  );

-- INSERT policy
CREATE POLICY "Profiles insert policy" ON profiles
  FOR INSERT WITH CHECK ((SELECT auth.uid()) = id);

-- =====================================================
-- PART 6: FIX FAVORITES RLS POLICIES
-- =====================================================
DROP POLICY IF EXISTS "Users can view own favorites" ON favorites;
DROP POLICY IF EXISTS "Users can add to own favorites" ON favorites;
DROP POLICY IF EXISTS "Users can remove from own favorites" ON favorites;

CREATE POLICY "Users can view own favorites" ON favorites
  FOR SELECT USING ((SELECT auth.uid()) = user_id);

CREATE POLICY "Users can add to own favorites" ON favorites
  FOR INSERT WITH CHECK ((SELECT auth.uid()) = user_id);

CREATE POLICY "Users can remove from own favorites" ON favorites
  FOR DELETE USING ((SELECT auth.uid()) = user_id);

-- =====================================================
-- PART 7: FIX REVIEWS RLS POLICIES
-- =====================================================
DROP POLICY IF EXISTS "Authenticated users can create reviews" ON reviews;
DROP POLICY IF EXISTS "Users can update own reviews" ON reviews;
DROP POLICY IF EXISTS "Users can delete own reviews" ON reviews;

CREATE POLICY "Authenticated users can create reviews" ON reviews
  FOR INSERT TO authenticated
  WITH CHECK ((SELECT auth.uid()) = user_id);

CREATE POLICY "Users can update own reviews" ON reviews
  FOR UPDATE TO authenticated
  USING ((SELECT auth.uid()) = user_id)
  WITH CHECK ((SELECT auth.uid()) = user_id);

CREATE POLICY "Users can delete own reviews" ON reviews
  FOR DELETE TO authenticated
  USING ((SELECT auth.uid()) = user_id);


-- =====================================================
-- PART 8: FIX STORES RLS POLICIES
-- =====================================================
DROP POLICY IF EXISTS "Merchants can create their store" ON stores;
DROP POLICY IF EXISTS "Merchants can update their store" ON stores;
DROP POLICY IF EXISTS "Merchants can delete their store" ON stores;

CREATE POLICY "Merchants can create their store" ON stores
  FOR INSERT WITH CHECK ((SELECT auth.uid()) = merchant_id);

CREATE POLICY "Merchants can update their store" ON stores
  FOR UPDATE 
  USING ((SELECT auth.uid()) = merchant_id)
  WITH CHECK ((SELECT auth.uid()) = merchant_id);

CREATE POLICY "Merchants can delete their store" ON stores
  FOR DELETE USING ((SELECT auth.uid()) = merchant_id);

-- =====================================================
-- PART 9: FIX MERCHANT_SHIPPING_PRICES RLS (CONSOLIDATED)
-- =====================================================
DROP POLICY IF EXISTS "Merchants can view their shipping prices" ON merchant_shipping_prices;
DROP POLICY IF EXISTS "Merchants can insert their shipping prices" ON merchant_shipping_prices;
DROP POLICY IF EXISTS "Merchants can update their shipping prices" ON merchant_shipping_prices;
DROP POLICY IF EXISTS "Merchants can delete their shipping prices" ON merchant_shipping_prices;
DROP POLICY IF EXISTS "Admin can view all shipping prices" ON merchant_shipping_prices;
DROP POLICY IF EXISTS "Admin can manage all shipping prices" ON merchant_shipping_prices;

-- Consolidated SELECT policy
CREATE POLICY "Shipping prices select policy" ON merchant_shipping_prices
  FOR SELECT USING (
    merchant_id = (SELECT auth.uid()) 
    OR is_admin()
    OR EXISTS (SELECT 1 FROM profiles WHERE id = (SELECT auth.uid()))
  );

-- Consolidated INSERT policy
CREATE POLICY "Shipping prices insert policy" ON merchant_shipping_prices
  FOR INSERT WITH CHECK (
    merchant_id = (SELECT auth.uid()) 
    OR is_admin()
  );

-- Consolidated UPDATE policy
CREATE POLICY "Shipping prices update policy" ON merchant_shipping_prices
  FOR UPDATE USING (
    merchant_id = (SELECT auth.uid()) 
    OR is_admin()
  );

-- Consolidated DELETE policy
CREATE POLICY "Shipping prices delete policy" ON merchant_shipping_prices
  FOR DELETE USING (
    merchant_id = (SELECT auth.uid()) 
    OR is_admin()
  );

-- =====================================================
-- PART 10: FIX PARENT_ORDERS RLS POLICIES (CONSOLIDATED)
-- =====================================================
DROP POLICY IF EXISTS "Users can view own parent orders" ON parent_orders;
DROP POLICY IF EXISTS "Users can create own parent orders" ON parent_orders;
DROP POLICY IF EXISTS "Merchants can view parent orders of their orders" ON parent_orders;

-- Consolidated SELECT policy
CREATE POLICY "Parent orders select policy" ON parent_orders
  FOR SELECT USING (
    (SELECT auth.uid()) = user_id 
    OR EXISTS (
      SELECT 1 FROM orders 
      WHERE orders.parent_order_id = parent_orders.id 
      AND orders.merchant_id = (SELECT auth.uid())
    )
  );

-- INSERT policy
CREATE POLICY "Parent orders insert policy" ON parent_orders
  FOR INSERT WITH CHECK ((SELECT auth.uid()) = user_id);

-- =====================================================
-- PART 11: FIX PRODUCTS RLS POLICIES (CONSOLIDATED)
-- =====================================================
DROP POLICY IF EXISTS "Anyone can view active products" ON products;
DROP POLICY IF EXISTS "Merchants can view all products" ON products;
DROP POLICY IF EXISTS "Merchants can insert products" ON products;
DROP POLICY IF EXISTS "Merchants can update products" ON products;
DROP POLICY IF EXISTS "Merchants can delete products" ON products;
DROP POLICY IF EXISTS "Admin can view all products" ON products;
DROP POLICY IF EXISTS "Admin can manage all products" ON products;
DROP POLICY IF EXISTS "Admin can suspend products" ON products;
DROP POLICY IF EXISTS "Allow flash sale cleanup" ON products;
DROP POLICY IF EXISTS "Users can view products in their orders" ON products;

-- Consolidated SELECT policy (public products + merchant/admin access)
CREATE POLICY "Products select policy" ON products
  FOR SELECT USING (
    is_active = true 
    OR is_merchant() 
    OR is_admin()
    OR EXISTS (
      SELECT 1 FROM order_items oi
      JOIN orders o ON o.id = oi.order_id
      WHERE oi.product_id = products.id 
      AND o.user_id = (SELECT auth.uid())
    )
  );

-- Consolidated INSERT policy
CREATE POLICY "Products insert policy" ON products
  FOR INSERT WITH CHECK (is_merchant() OR is_admin());

-- Consolidated UPDATE policy
CREATE POLICY "Products update policy" ON products
  FOR UPDATE USING (is_merchant() OR is_admin());

-- Consolidated DELETE policy
CREATE POLICY "Products delete policy" ON products
  FOR DELETE USING (is_merchant() OR is_admin());

-- =====================================================
-- PART 12: FIX CATEGORIES RLS POLICIES (CONSOLIDATED)
-- =====================================================
DROP POLICY IF EXISTS "Anyone can view active categories" ON categories;
DROP POLICY IF EXISTS "Merchants can view all categories" ON categories;
DROP POLICY IF EXISTS "Merchants can insert categories" ON categories;
DROP POLICY IF EXISTS "Merchants can update categories" ON categories;
DROP POLICY IF EXISTS "Merchants can delete categories" ON categories;
DROP POLICY IF EXISTS "Admin can manage categories" ON categories;

-- Consolidated SELECT policy
CREATE POLICY "Categories select policy" ON categories
  FOR SELECT USING (is_active = true OR is_merchant() OR is_admin());

-- Consolidated INSERT policy
CREATE POLICY "Categories insert policy" ON categories
  FOR INSERT WITH CHECK (is_merchant() OR is_admin());

-- Consolidated UPDATE policy
CREATE POLICY "Categories update policy" ON categories
  FOR UPDATE USING (is_merchant() OR is_admin());

-- Consolidated DELETE policy
CREATE POLICY "Categories delete policy" ON categories
  FOR DELETE USING (is_merchant() OR is_admin());

-- =====================================================
-- PART 13: FIX COUPONS RLS POLICIES (CONSOLIDATED)
-- =====================================================
DROP POLICY IF EXISTS "Anyone can view active coupons" ON coupons;
DROP POLICY IF EXISTS "Anyone can view global coupons" ON coupons;
DROP POLICY IF EXISTS "Merchants can manage their coupons" ON coupons;
DROP POLICY IF EXISTS "Admin can manage all coupons" ON coupons;
DROP POLICY IF EXISTS "Authenticated users can create global coupons" ON coupons;
DROP POLICY IF EXISTS "Authenticated users can updaشte global coupons" ON coupons;
DROP POLICY IF EXISTS "Authenticated users can delete global coupons" ON coupons;

-- Consolidated SELECT policy
CREATE POLICY "Coupons select policy" ON coupons
  FOR SELECT USING (
    (is_active = true AND start_date <= NOW() AND (end_date IS NULL OR end_date > NOW()))
    OR store_id IS NULL
    OR store_id IN (SELECT id FROM stores WHERE merchant_id = (SELECT auth.uid()))
    OR is_admin()
  );

-- Consolidated INSERT policy
CREATE POLICY "Coupons insert policy" ON coupons
  FOR INSERT WITH CHECK (
    store_id IN (SELECT id FROM stores WHERE merchant_id = (SELECT auth.uid()))
    OR (store_id IS NULL AND (SELECT auth.uid()) IS NOT NULL)
    OR is_admin()
  );

-- Consolidated UPDATE policy
CREATE POLICY "Coupons update policy" ON coupons
  FOR UPDATE USING (
    store_id IN (SELECT id FROM stores WHERE merchant_id = (SELECT auth.uid()))
    OR (store_id IS NULL AND (SELECT auth.uid()) IS NOT NULL)
    OR is_admin()
  );

-- Consolidated DELETE policy
CREATE POLICY "Coupons delete policy" ON coupons
  FOR DELETE USING (
    store_id IN (SELECT id FROM stores WHERE merchant_id = (SELECT auth.uid()))
    OR (store_id IS NULL AND (SELECT auth.uid()) IS NOT NULL)
    OR is_admin()
  );

-- =====================================================
-- PART 14: FIX COUPON_USAGES RLS POLICIES
-- =====================================================
DROP POLICY IF EXISTS "Users can view their coupon usages" ON coupon_usages;

CREATE POLICY "Users can view their coupon usages" ON coupon_usages
  FOR SELECT USING (user_id = (SELECT auth.uid()));

-- =====================================================
-- PART 15: FIX COUPON_PRODUCTS RLS POLICIES (CONSOLIDATED)
-- =====================================================
DROP POLICY IF EXISTS "Anyone can view coupon products" ON coupon_products;
DROP POLICY IF EXISTS "Merchants can manage coupon products" ON coupon_products;

-- Consolidated SELECT policy
CREATE POLICY "Coupon products select policy" ON coupon_products
  FOR SELECT USING (
    EXISTS (
      SELECT 1 FROM coupons c 
      WHERE c.id = coupon_products.coupon_id 
      AND (
        c.store_id IN (SELECT id FROM stores WHERE merchant_id = (SELECT auth.uid()))
        OR c.store_id IS NULL
      )
    )
    OR TRUE  -- Anyone can view for validation
  );

-- INSERT/UPDATE/DELETE for merchants
CREATE POLICY "Coupon products manage policy" ON coupon_products
  FOR ALL USING (
    EXISTS (
      SELECT 1 FROM coupons c 
      WHERE c.id = coupon_products.coupon_id 
      AND c.store_id IN (SELECT id FROM stores WHERE merchant_id = (SELECT auth.uid()))
    )
  );

-- =====================================================
-- PART 16: FIX COUPON_CATEGORIES RLS POLICIES (CONSOLIDATED)
-- =====================================================
DROP POLICY IF EXISTS "Anyone can view coupon categories" ON coupon_categories;
DROP POLICY IF EXISTS "Merchants can manage coupon categories" ON coupon_categories;

-- Consolidated SELECT policy
CREATE POLICY "Coupon categories select policy" ON coupon_categories
  FOR SELECT USING (TRUE);  -- Anyone can view for validation

-- INSERT/UPDATE/DELETE for merchants
CREATE POLICY "Coupon categories manage policy" ON coupon_categories
  FOR ALL USING (
    EXISTS (
      SELECT 1 FROM coupons c 
      WHERE c.id = coupon_categories.coupon_id 
      AND c.store_id IN (SELECT id FROM stores WHERE merchant_id = (SELECT auth.uid()))
    )
  );

-- =====================================================
-- PART 17: DROP DUPLICATE INDEXES
-- =====================================================
DROP INDEX IF EXISTS idx_cart_items_user;
DROP INDEX IF EXISTS idx_favorites_product;
DROP INDEX IF EXISTS idx_favorites_user;
DROP INDEX IF EXISTS idx_products_category;
DROP INDEX IF EXISTS idx_products_merchant;

-- Keep these indexes (the ones with _id suffix):
-- idx_cart_items_user_id
-- idx_favorites_product_id
-- idx_favorites_user_id
-- idx_products_category_id
-- idx_products_merchant_id

-- =====================================================
-- VERIFICATION QUERIES (run separately to check)
-- =====================================================
-- Check for remaining auth_rls_initplan issues:
-- SELECT * FROM pg_policies WHERE polname LIKE '%auth.uid%';

-- Check for duplicate indexes:
-- SELECT indexname, indexdef FROM pg_indexes 
-- WHERE schemaname = 'public' 
-- ORDER BY tablename, indexname;
