-- =====================================================
-- ADMIN PERFORMANCE OPTIMIZATIONS
-- Move heavy aggregations to database
-- =====================================================

-- =====================================================
-- 1. GET ADMIN STATS IN SINGLE QUERY
-- Replaces 9 separate queries with 1
-- =====================================================
DROP FUNCTION IF EXISTS get_admin_stats(TIMESTAMPTZ, TIMESTAMPTZ);

CREATE OR REPLACE FUNCTION get_admin_stats(
  p_from_date TIMESTAMPTZ DEFAULT NULL,
  p_to_date TIMESTAMPTZ DEFAULT NULL
)
RETURNS JSON
LANGUAGE plpgsql
SECURITY DEFINER
SET search_path = public
AS $$
DECLARE
  v_result JSON;
  v_start_of_day TIMESTAMPTZ;
BEGIN
  v_start_of_day := date_trunc('day', NOW());
  
  SELECT json_build_object(
    'total_customers', (SELECT COUNT(*) FROM profiles WHERE role = 'customer'),
    'total_merchants', (SELECT COUNT(*) FROM profiles WHERE role = 'merchant'),
    'total_products', (SELECT COUNT(*) FROM products),
    'active_products', (SELECT COUNT(*) FROM products WHERE is_active = true),
    'total_orders', (
      SELECT COUNT(*) FROM orders 
      WHERE (p_from_date IS NULL OR created_at >= p_from_date)
      AND (p_to_date IS NULL OR created_at <= p_to_date)
    ),
    'pending_orders', (
      SELECT COUNT(*) FROM orders 
      WHERE status = 'pending'
      AND (p_from_date IS NULL OR created_at >= p_from_date)
      AND (p_to_date IS NULL OR created_at <= p_to_date)
    ),
    'today_orders', (SELECT COUNT(*) FROM orders WHERE created_at >= v_start_of_day),
    'total_revenue', (
      SELECT COALESCE(SUM(total), 0) FROM orders 
      WHERE status = 'delivered'
      AND (p_from_date IS NULL OR created_at >= p_from_date)
      AND (p_to_date IS NULL OR created_at <= p_to_date)
    ),
    'today_revenue', (
      SELECT COALESCE(SUM(total), 0) FROM orders 
      WHERE status = 'delivered' AND created_at >= v_start_of_day
    )
  ) INTO v_result;
  
  RETURN v_result;
END;
$$;

GRANT EXECUTE ON FUNCTION get_admin_stats(TIMESTAMPTZ, TIMESTAMPTZ) TO authenticated;

-- =====================================================
-- 2. GET TOP SELLING MERCHANTS (Database-side aggregation)
-- Replaces O(n²) Dart code with O(n) SQL
-- =====================================================
DROP FUNCTION IF EXISTS get_top_selling_merchants(INTEGER);

CREATE OR REPLACE FUNCTION get_top_selling_merchants(p_limit INTEGER DEFAULT 20)
RETURNS TABLE (
  merchant_id UUID,
  name TEXT,
  email TEXT,
  total_sales DECIMAL,
  order_count BIGINT
)
LANGUAGE plpgsql
SECURITY DEFINER
SET search_path = public
AS $$
BEGIN
  RETURN QUERY
  SELECT 
    p.merchant_id,
    pr.name,
    pr.email,
    SUM(o.total)::DECIMAL as total_sales,
    COUNT(DISTINCT o.id) as order_count
  FROM orders o
  JOIN order_items oi ON oi.order_id = o.id
  JOIN products p ON p.id = oi.product_id
  JOIN profiles pr ON pr.id = p.merchant_id
  WHERE o.status = 'delivered'
  AND p.merchant_id IS NOT NULL
  GROUP BY p.merchant_id, pr.name, pr.email
  ORDER BY total_sales DESC
  LIMIT p_limit;
END;
$$;

GRANT EXECUTE ON FUNCTION get_top_selling_merchants(INTEGER) TO authenticated;

-- =====================================================
-- 3. GET TOP ORDERING CUSTOMERS (Database-side aggregation)
-- =====================================================
DROP FUNCTION IF EXISTS get_top_ordering_customers(INTEGER);

CREATE OR REPLACE FUNCTION get_top_ordering_customers(p_limit INTEGER DEFAULT 20)
RETURNS TABLE (
  user_id UUID,
  name TEXT,
  email TEXT,
  phone TEXT,
  total_spent DECIMAL,
  order_count BIGINT,
  delivered_count BIGINT
)
LANGUAGE plpgsql
SECURITY DEFINER
SET search_path = public
AS $$
BEGIN
  RETURN QUERY
  SELECT 
    o.user_id,
    p.name,
    p.email,
    p.phone,
    SUM(CASE WHEN o.status = 'delivered' THEN o.total ELSE 0 END)::DECIMAL as total_spent,
    COUNT(*) as order_count,
    COUNT(*) FILTER (WHERE o.status = 'delivered') as delivered_count
  FROM orders o
  JOIN profiles p ON p.id = o.user_id
  GROUP BY o.user_id, p.name, p.email, p.phone
  ORDER BY order_count DESC
  LIMIT p_limit;
END;
$$;

GRANT EXECUTE ON FUNCTION get_top_ordering_customers(INTEGER) TO authenticated;

-- =====================================================
-- 4. GET MERCHANTS CANCELLATION STATS
-- =====================================================
DROP FUNCTION IF EXISTS get_merchants_cancellation_stats(INTEGER);

CREATE OR REPLACE FUNCTION get_merchants_cancellation_stats(p_limit INTEGER DEFAULT 20)
RETURNS TABLE (
  merchant_id UUID,
  name TEXT,
  email TEXT,
  phone TEXT,
  total_orders BIGINT,
  cancelled_orders BIGINT,
  delivered_orders BIGINT,
  cancellation_rate DECIMAL,
  is_problematic BOOLEAN
)
LANGUAGE plpgsql
SECURITY DEFINER
SET search_path = public
AS $$
BEGIN
  RETURN QUERY
  SELECT 
    o.merchant_id,
    p.name,
    p.email,
    p.phone,
    COUNT(*) as total_orders,
    COUNT(*) FILTER (WHERE o.status = 'cancelled') as cancelled_orders,
    COUNT(*) FILTER (WHERE o.status = 'delivered') as delivered_orders,
    ROUND(
      (COUNT(*) FILTER (WHERE o.status = 'cancelled')::DECIMAL / NULLIF(COUNT(*), 0) * 100), 
      1
    ) as cancellation_rate,
    (COUNT(*) FILTER (WHERE o.status = 'cancelled') > COUNT(*) FILTER (WHERE o.status = 'delivered')
     AND COUNT(*) FILTER (WHERE o.status = 'cancelled') > 0) as is_problematic
  FROM orders o
  JOIN profiles p ON p.id = o.merchant_id
  WHERE o.merchant_id IS NOT NULL
  GROUP BY o.merchant_id, p.name, p.email, p.phone
  ORDER BY cancelled_orders DESC
  LIMIT p_limit;
END;
$$;

GRANT EXECUTE ON FUNCTION get_merchants_cancellation_stats(INTEGER) TO authenticated;

-- =====================================================
-- 5. INDEX FOR SUSPENDED PRODUCTS
-- =====================================================
CREATE INDEX IF NOT EXISTS idx_products_suspended 
ON products(is_suspended) 
WHERE is_suspended = true;

-- =====================================================
-- 6. GET MERCHANT COUPONS WITH STORE JOIN
-- Single query instead of 2
-- =====================================================
DROP FUNCTION IF EXISTS get_merchant_coupons_by_merchant_id(UUID);

CREATE OR REPLACE FUNCTION get_merchant_coupons_by_merchant_id(p_merchant_id UUID)
RETURNS TABLE (
  id UUID,
  code VARCHAR,
  name_ar VARCHAR,
  name_en VARCHAR,
  description_ar TEXT,
  description_en TEXT,
  discount_type VARCHAR,
  discount_value DECIMAL,
  max_discount_amount DECIMAL,
  min_order_amount DECIMAL,
  usage_limit INTEGER,
  usage_count INTEGER,
  usage_limit_per_user INTEGER,
  start_date TIMESTAMPTZ,
  end_date TIMESTAMPTZ,
  scope VARCHAR,
  is_active BOOLEAN,
  is_suspended BOOLEAN,
  suspension_reason TEXT,
  store_id UUID,
  created_at TIMESTAMPTZ
)
LANGUAGE plpgsql
SECURITY DEFINER
SET search_path = public
AS $$
BEGIN
  RETURN QUERY
  SELECT 
    c.id,
    c.code,
    c.name_ar,
    c.name_en,
    c.description_ar,
    c.description_en,
    c.discount_type,
    c.discount_value,
    c.max_discount_amount,
    c.min_order_amount,
    c.usage_limit,
    c.usage_count,
    c.usage_limit_per_user,
    c.start_date,
    c.end_date,
    c.scope,
    c.is_active,
    c.is_suspended,
    c.suspension_reason,
    c.store_id,
    c.created_at
  FROM coupons c
  JOIN stores s ON s.id = c.store_id
  WHERE s.merchant_id = p_merchant_id
  ORDER BY c.created_at DESC;
END;
$$;

GRANT EXECUTE ON FUNCTION get_merchant_coupons_by_merchant_id(UUID) TO authenticated;
