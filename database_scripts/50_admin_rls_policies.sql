-- =====================================================
-- Admin RLS Policies
-- Safe approach: Using security definer function
-- =====================================================

-- Step 1: Create a security definer function to check admin role
-- This avoids infinite recursion by not querying profiles directly in policies
CREATE OR REPLACE FUNCTION is_admin()
RETURNS BOOLEAN AS $$
BEGIN
  RETURN EXISTS (
    SELECT 1 FROM profiles 
    WHERE id = auth.uid() 
    AND role = 'admin'
  );
END;
$$ LANGUAGE plpgsql SECURITY DEFINER STABLE;

-- Step 2: Grant execute permission
GRANT EXECUTE ON FUNCTION is_admin() TO authenticated;

-- =====================================================
-- PROFILES POLICIES FOR ADMIN
-- =====================================================
-- Admin can view all profiles
DROP POLICY IF EXISTS "Admin can view all profiles" ON profiles;
CREATE POLICY "Admin can view all profiles" ON profiles
  FOR SELECT USING (
    auth.uid() = id  -- User can see own profile
    OR is_admin()    -- Admin can see all
  );

-- Admin can update all profiles
DROP POLICY IF EXISTS "Admin can update all profiles" ON profiles;
CREATE POLICY "Admin can update all profiles" ON profiles
  FOR UPDATE USING (
    auth.uid() = id  -- User can update own profile
    OR is_admin()    -- Admin can update all
  );

-- =====================================================
-- ORDERS POLICIES FOR ADMIN
-- =====================================================
DROP POLICY IF EXISTS "Admin can view all orders" ON orders;
CREATE POLICY "Admin can view all orders" ON orders
  FOR SELECT USING (is_admin());

DROP POLICY IF EXISTS "Admin can update all orders" ON orders;
CREATE POLICY "Admin can update all orders" ON orders
  FOR UPDATE USING (is_admin());

-- =====================================================
-- PRODUCTS POLICIES FOR ADMIN
-- =====================================================
DROP POLICY IF EXISTS "Admin can view all products" ON products;
CREATE POLICY "Admin can view all products" ON products
  FOR SELECT USING (true); -- Products are public anyway

DROP POLICY IF EXISTS "Admin can manage all products" ON products;
CREATE POLICY "Admin can manage all products" ON products
  FOR ALL USING (is_admin());

-- =====================================================
-- CATEGORIES POLICIES FOR ADMIN
-- =====================================================
DROP POLICY IF EXISTS "Admin can manage categories" ON categories;
CREATE POLICY "Admin can manage categories" ON categories
  FOR ALL USING (is_admin());

-- =====================================================
-- MERCHANT SHIPPING PRICES POLICIES FOR ADMIN
-- =====================================================
DROP POLICY IF EXISTS "Admin can view all shipping prices" ON merchant_shipping_prices;
CREATE POLICY "Admin can view all shipping prices" ON merchant_shipping_prices
  FOR SELECT USING (is_admin() OR merchant_id = auth.uid());

DROP POLICY IF EXISTS "Admin can manage all shipping prices" ON merchant_shipping_prices;
CREATE POLICY "Admin can manage all shipping prices" ON merchant_shipping_prices
  FOR ALL USING (is_admin());

-- =====================================================
-- COUPONS POLICIES FOR ADMIN
-- =====================================================
DROP POLICY IF EXISTS "Admin can manage all coupons" ON coupons;
CREATE POLICY "Admin can manage all coupons" ON coupons
  FOR ALL USING (is_admin());

-- =====================================================
-- VERIFICATION
-- =====================================================
-- Test the function (run after setting your user as admin)
-- SELECT is_admin();

-- Check your role
-- SELECT id, email, role FROM profiles WHERE id = auth.uid();
