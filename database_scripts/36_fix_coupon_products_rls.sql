-- ============================================================
-- إصلاح صلاحيات جداول الكوبونات + دعم الفئات
-- Fix RLS policies for coupon tables + category support
-- ============================================================

-- ============================================================
-- 1. إصلاح RLS لجدول coupons
-- ============================================================
DROP POLICY IF EXISTS "Anyone can view active coupons" ON coupons;
DROP POLICY IF EXISTS "Merchants can manage their coupons" ON coupons;

ALTER TABLE coupons ENABLE ROW LEVEL SECURITY;

-- السماح للجميع بقراءة الكوبونات النشطة
CREATE POLICY "Anyone can view active coupons"
ON coupons FOR SELECT
USING (
    is_active = true 
    AND start_date <= NOW() 
    AND (end_date IS NULL OR end_date > NOW())
);

-- السماح للتجار بإدارة كوبوناتهم
CREATE POLICY "Merchants can manage their coupons"
ON coupons FOR ALL
USING (
    store_id IN (SELECT id FROM stores WHERE merchant_id = auth.uid())
);

-- ============================================================
-- 2. إصلاح RLS لجدول coupon_products
-- ============================================================
DROP POLICY IF EXISTS "Merchants can manage coupon products" ON coupon_products;
DROP POLICY IF EXISTS "Anyone can view coupon products" ON coupon_products;

ALTER TABLE coupon_products ENABLE ROW LEVEL SECURITY;

-- السماح للتجار بإدارة منتجات كوبوناتهم
CREATE POLICY "Merchants can manage coupon products"
ON coupon_products FOR ALL
USING (
    coupon_id IN (
        SELECT c.id FROM coupons c
        WHERE c.store_id IN (SELECT id FROM stores WHERE merchant_id = auth.uid())
    )
);

-- السماح للجميع بقراءة منتجات الكوبونات
CREATE POLICY "Anyone can view coupon products"
ON coupon_products FOR SELECT
USING (true);

-- ============================================================
-- 3. إصلاح RLS لجدول coupon_categories
-- ============================================================
DROP POLICY IF EXISTS "Merchants can manage coupon categories" ON coupon_categories;
DROP POLICY IF EXISTS "Anyone can view coupon categories" ON coupon_categories;

ALTER TABLE coupon_categories ENABLE ROW LEVEL SECURITY;

-- السماح للتجار بإدارة فئات كوبوناتهم
CREATE POLICY "Merchants can manage coupon categories"
ON coupon_categories FOR ALL
USING (
    coupon_id IN (
        SELECT c.id FROM coupons c
        WHERE c.store_id IN (SELECT id FROM stores WHERE merchant_id = auth.uid())
    )
);

-- السماح للجميع بقراءة فئات الكوبونات
CREATE POLICY "Anyone can view coupon categories"
ON coupon_categories FOR SELECT
USING (true);

-- ============================================================
-- 4. إصلاح RLS لجدول coupon_usages
-- ============================================================
DROP POLICY IF EXISTS "Users can view their coupon usages" ON coupon_usages;
DROP POLICY IF EXISTS "Users can insert coupon usages" ON coupon_usages;

ALTER TABLE coupon_usages ENABLE ROW LEVEL SECURITY;

-- السماح للمستخدمين بقراءة استخداماتهم
CREATE POLICY "Users can view their coupon usages"
ON coupon_usages FOR SELECT
USING (user_id = auth.uid());

-- السماح بإضافة استخدامات (للـ functions)
CREATE POLICY "Allow insert coupon usages"
ON coupon_usages FOR INSERT
WITH CHECK (true);

-- ============================================================
-- 5. منح الصلاحيات
-- ============================================================
GRANT SELECT, INSERT, UPDATE, DELETE ON coupons TO authenticated;
GRANT SELECT, INSERT, UPDATE, DELETE ON coupon_products TO authenticated;
GRANT SELECT, INSERT, UPDATE, DELETE ON coupon_categories TO authenticated;
GRANT SELECT, INSERT ON coupon_usages TO authenticated;
