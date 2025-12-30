-- =====================================================
-- PERFORMANCE OPTIMIZATIONS
-- Fix complexity issues in SQL functions
-- =====================================================

-- =====================================================
-- 1. OPTIMIZE get_available_coupons (O(n×u) → O(n+u))
-- Using CTE instead of subquery per row
-- =====================================================
DROP FUNCTION IF EXISTS get_available_coupons(UUID, DECIMAL, UUID);

CREATE OR REPLACE FUNCTION get_available_coupons(
    p_user_id UUID,
    p_order_amount DECIMAL DEFAULT 0,
    p_store_id UUID DEFAULT NULL
)
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
    end_date TIMESTAMPTZ,
    is_applicable BOOLEAN,
    reason_ar TEXT,
    reason_en TEXT
)
LANGUAGE plpgsql
SECURITY DEFINER
SET search_path = public
AS $$
BEGIN
    RETURN QUERY
    WITH user_coupon_usage AS (
        -- Pre-calculate user's usage count per coupon (runs once)
        SELECT cu.coupon_id, COUNT(*)::INTEGER as usage_count 
        FROM coupon_usages cu
        WHERE cu.user_id = p_user_id 
        GROUP BY cu.coupon_id
    )
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
        c.end_date,
        CASE 
            WHEN c.min_order_amount > p_order_amount THEN false
            WHEN c.store_id IS NOT NULL AND c.store_id != p_store_id THEN false
            WHEN c.usage_limit IS NOT NULL AND c.usage_count >= c.usage_limit THEN false
            WHEN COALESCE(ucu.usage_count, 0) >= c.usage_limit_per_user THEN false
            ELSE true
        END AS is_applicable,
        CASE 
            WHEN c.min_order_amount > p_order_amount THEN 'الحد الأدنى للطلب ' || c.min_order_amount || ' ج.م'
            WHEN c.store_id IS NOT NULL AND c.store_id != p_store_id THEN 'خاص بمتجر آخر'
            WHEN c.usage_limit IS NOT NULL AND c.usage_count >= c.usage_limit THEN 'تم استنفاد الكوبون'
            WHEN COALESCE(ucu.usage_count, 0) >= c.usage_limit_per_user THEN 'تم استخدامه مسبقاً'
            ELSE NULL
        END AS reason_ar,
        CASE 
            WHEN c.min_order_amount > p_order_amount THEN 'Minimum order ' || c.min_order_amount || ' EGP'
            WHEN c.store_id IS NOT NULL AND c.store_id != p_store_id THEN 'For another store'
            WHEN c.usage_limit IS NOT NULL AND c.usage_count >= c.usage_limit THEN 'Coupon exhausted'
            WHEN COALESCE(ucu.usage_count, 0) >= c.usage_limit_per_user THEN 'Already used'
            ELSE NULL
        END AS reason_en
    FROM coupons c
    LEFT JOIN user_coupon_usage ucu ON ucu.coupon_id = c.id
    WHERE c.is_active = true
    AND c.start_date <= NOW()
    AND (c.end_date IS NULL OR c.end_date > NOW())
    AND (c.store_id IS NULL OR c.store_id = p_store_id)
    ORDER BY is_applicable DESC, c.discount_value DESC;
END;
$$;

GRANT EXECUTE ON FUNCTION get_available_coupons(UUID, DECIMAL, UUID) TO authenticated;

-- =====================================================
-- 2. OPTIMIZE get_discounted_products_sorted
-- Add proper index usage hints
-- =====================================================
DROP FUNCTION IF EXISTS get_discounted_products_sorted(INTEGER, INTEGER);

CREATE OR REPLACE FUNCTION get_discounted_products_sorted(
  p_limit INT DEFAULT 20,
  p_offset INT DEFAULT 0
)
RETURNS TABLE (
  id UUID,
  name_ar TEXT,
  name_en TEXT,
  description_ar TEXT,
  description_en TEXT,
  price DECIMAL,
  discount_price DECIMAL,
  images TEXT[],
  category_id UUID,
  stock INT,
  rating DECIMAL,
  rating_count INT,
  is_active BOOLEAN,
  is_featured BOOLEAN,
  merchant_id UUID,
  created_at TIMESTAMPTZ,
  discount_percentage DECIMAL,
  is_flash_sale BOOLEAN,
  flash_sale_start TIMESTAMPTZ,
  flash_sale_end TIMESTAMPTZ
)
LANGUAGE plpgsql
SECURITY DEFINER
SET search_path = public
AS $$
BEGIN
  RETURN QUERY
  SELECT 
    p.id,
    p.name_ar,
    p.name_en,
    p.description_ar,
    p.description_en,
    p.price,
    p.discount_price,
    p.images,
    p.category_id,
    p.stock,
    p.rating,
    p.rating_count,
    p.is_active,
    p.is_featured,
    p.merchant_id,
    p.created_at,
    ROUND(((p.price - p.discount_price) / NULLIF(p.price, 0) * 100)::DECIMAL, 2) as discount_percentage,
    COALESCE(p.is_flash_sale, false) as is_flash_sale,
    p.flash_sale_start,
    p.flash_sale_end
  FROM products p
  WHERE p.is_active = true
    AND p.discount_price IS NOT NULL
    AND p.price > 0
    AND p.discount_price > 0
    AND p.discount_price < p.price
  ORDER BY 
    -- Flash sales first (active ones only)
    CASE WHEN p.is_flash_sale = true 
         AND p.flash_sale_start <= NOW() 
         AND p.flash_sale_end > NOW() 
         THEN 0 ELSE 1 END,
    -- Then by discount percentage (pre-calculated would be better)
    ((p.price - p.discount_price) / NULLIF(p.price, 0)) DESC
  LIMIT p_limit
  OFFSET p_offset;
END;
$$;

GRANT EXECUTE ON FUNCTION get_discounted_products_sorted(INTEGER, INTEGER) TO authenticated, anon;

-- =====================================================
-- 3. ADD MISSING INDEXES FOR BETTER PERFORMANCE
-- =====================================================

-- Index for coupon usages lookup (used in get_available_coupons)
CREATE INDEX IF NOT EXISTS idx_coupon_usages_user_coupon 
ON coupon_usages(user_id, coupon_id);

-- Index for flash sale products
CREATE INDEX IF NOT EXISTS idx_products_flash_sale_active 
ON products(is_flash_sale, flash_sale_start, flash_sale_end) 
WHERE is_active = true AND is_flash_sale = true;

-- Index for discounted products sorting
CREATE INDEX IF NOT EXISTS idx_products_discount_sort 
ON products(is_active, discount_price, price) 
WHERE is_active = true AND discount_price IS NOT NULL;

-- Index for order items by order
CREATE INDEX IF NOT EXISTS idx_order_items_order_id 
ON order_items(order_id);

-- Index for orders by parent
CREATE INDEX IF NOT EXISTS idx_orders_parent_merchant 
ON orders(parent_order_id, merchant_id);

-- =====================================================
-- 4. OPTIMIZE validate_coupon (reduce array operations)
-- =====================================================
DROP FUNCTION IF EXISTS validate_coupon(VARCHAR, UUID, DECIMAL, UUID[], UUID);

CREATE OR REPLACE FUNCTION validate_coupon(
    p_coupon_code VARCHAR,
    p_user_id UUID,
    p_order_amount DECIMAL,
    p_product_ids UUID[] DEFAULT NULL,
    p_store_id UUID DEFAULT NULL
)
RETURNS JSON
LANGUAGE plpgsql
SECURITY DEFINER
SET search_path = public
AS $$
DECLARE
    v_coupon RECORD;
    v_user_usage_count INTEGER;
    v_discount_amount DECIMAL;
    v_applicable_amount DECIMAL;
    v_has_matching_products BOOLEAN;
BEGIN
    -- Find coupon (uses index on code)
    SELECT * INTO v_coupon
    FROM coupons
    WHERE code = UPPER(p_coupon_code)
    AND is_active = true;
    
    IF v_coupon IS NULL THEN
        RETURN json_build_object(
            'valid', false,
            'error_code', 'INVALID_CODE',
            'error_ar', 'كود الخصم غير صحيح',
            'error_en', 'Invalid coupon code'
        );
    END IF;
    
    -- Check start date
    IF v_coupon.start_date > NOW() THEN
        RETURN json_build_object(
            'valid', false,
            'error_code', 'NOT_STARTED',
            'error_ar', 'كود الخصم لم يبدأ بعد',
            'error_en', 'Coupon has not started yet'
        );
    END IF;
    
    -- Check end date
    IF v_coupon.end_date IS NOT NULL AND v_coupon.end_date < NOW() THEN
        RETURN json_build_object(
            'valid', false,
            'error_code', 'EXPIRED',
            'error_ar', 'كود الخصم منتهي الصلاحية',
            'error_en', 'Coupon has expired'
        );
    END IF;
    
    -- Check global usage limit
    IF v_coupon.usage_limit IS NOT NULL AND v_coupon.usage_count >= v_coupon.usage_limit THEN
        RETURN json_build_object(
            'valid', false,
            'error_code', 'USAGE_LIMIT_REACHED',
            'error_ar', 'تم استنفاد عدد مرات استخدام الكوبون',
            'error_en', 'Coupon usage limit reached'
        );
    END IF;
    
    -- Check user usage (single query with index)
    SELECT COUNT(*) INTO v_user_usage_count
    FROM coupon_usages
    WHERE coupon_id = v_coupon.id AND user_id = p_user_id;
    
    IF v_user_usage_count >= v_coupon.usage_limit_per_user THEN
        RETURN json_build_object(
            'valid', false,
            'error_code', 'USER_LIMIT_REACHED',
            'error_ar', 'لقد استخدمت هذا الكوبون من قبل',
            'error_en', 'You have already used this coupon'
        );
    END IF;
    
    -- Check minimum order
    IF p_order_amount < v_coupon.min_order_amount THEN
        RETURN json_build_object(
            'valid', false,
            'error_code', 'MIN_ORDER_NOT_MET',
            'error_ar', 'الحد الأدنى للطلب ' || v_coupon.min_order_amount || ' ج.م',
            'error_en', 'Minimum order amount is ' || v_coupon.min_order_amount || ' EGP'
        );
    END IF;
    
    -- Check store restriction
    IF v_coupon.store_id IS NOT NULL AND v_coupon.store_id != p_store_id THEN
        RETURN json_build_object(
            'valid', false,
            'error_code', 'MERCHANT_MISMATCH',
            'error_ar', 'هذا الكوبون خاص بمتجر آخر',
            'error_en', 'This coupon is for another store'
        );
    END IF;
    
    -- Check product-specific coupons (optimized with EXISTS)
    IF v_coupon.scope = 'products' THEN
        -- Check if coupon has linked products
        IF NOT EXISTS (SELECT 1 FROM coupon_products WHERE coupon_id = v_coupon.id LIMIT 1) THEN
            RETURN json_build_object(
                'valid', false,
                'error_code', 'NO_COUPON_PRODUCTS',
                'error_ar', 'الكوبون غير مرتبط بأي منتجات',
                'error_en', 'Coupon is not linked to any products'
            );
        END IF;
        
        -- Check if cart has matching products (optimized with EXISTS + ANY)
        IF p_product_ids IS NOT NULL AND array_length(p_product_ids, 1) > 0 THEN
            SELECT EXISTS (
                SELECT 1 FROM coupon_products cp
                WHERE cp.coupon_id = v_coupon.id
                AND cp.product_id = ANY(p_product_ids)
                LIMIT 1
            ) INTO v_has_matching_products;
            
            IF NOT v_has_matching_products THEN
                RETURN json_build_object(
                    'valid', false,
                    'error_code', 'NO_MATCHING_PRODUCTS',
                    'error_ar', 'السلة لا تحتوي على منتجات مشمولة بهذا الكوبون',
                    'error_en', 'Cart does not contain products covered by this coupon'
                );
            END IF;
        END IF;
    END IF;
    
    -- Calculate discount
    v_applicable_amount := p_order_amount;
    
    IF v_coupon.discount_type = 'percentage' THEN
        v_discount_amount := v_applicable_amount * (v_coupon.discount_value / 100);
        IF v_coupon.max_discount_amount IS NOT NULL AND v_discount_amount > v_coupon.max_discount_amount THEN
            v_discount_amount := v_coupon.max_discount_amount;
        END IF;
    ELSE
        v_discount_amount := LEAST(v_coupon.discount_value, v_applicable_amount);
    END IF;
    
    v_discount_amount := ROUND(v_discount_amount, 2);
    
    RETURN json_build_object(
        'valid', true,
        'coupon_id', v_coupon.id,
        'code', v_coupon.code,
        'name_ar', v_coupon.name_ar,
        'name_en', v_coupon.name_en,
        'discount_type', v_coupon.discount_type,
        'discount_value', v_coupon.discount_value,
        'discount_amount', v_discount_amount,
        'final_amount', p_order_amount - v_discount_amount,
        'scope', v_coupon.scope
    );
END;
$$;

GRANT EXECUTE ON FUNCTION validate_coupon(VARCHAR, UUID, DECIMAL, UUID[], UUID) TO authenticated;

-- =====================================================
-- 5. UPDATE STATISTICS
-- =====================================================
ANALYZE coupons;
ANALYZE coupon_usages;
ANALYZE coupon_products;
ANALYZE products;
ANALYZE orders;
ANALYZE order_items;


-- =====================================================
-- 6. FULL-TEXT SEARCH INDEX FOR PRODUCTS
-- Improves search from O(n) to O(log n)
-- =====================================================

-- Create GIN index for Arabic/English text search
CREATE INDEX IF NOT EXISTS idx_products_search_gin 
ON products USING gin(
  to_tsvector('simple', COALESCE(name_ar, '') || ' ' || COALESCE(name_en, ''))
);

-- Alternative: Trigram index for ILIKE queries (if pg_trgm extension is available)
-- This makes ILIKE %query% much faster
DO $$
BEGIN
  IF EXISTS (SELECT 1 FROM pg_extension WHERE extname = 'pg_trgm') THEN
    EXECUTE 'CREATE INDEX IF NOT EXISTS idx_products_name_ar_trgm ON products USING gin(name_ar gin_trgm_ops)';
    EXECUTE 'CREATE INDEX IF NOT EXISTS idx_products_name_en_trgm ON products USING gin(name_en gin_trgm_ops)';
    RAISE NOTICE 'Trigram indexes created successfully';
  ELSE
    RAISE NOTICE 'pg_trgm extension not available, skipping trigram indexes';
  END IF;
END $$;

-- =====================================================
-- 7. MATERIALIZED VIEW FOR DISCOUNTED PRODUCTS
-- Pre-calculates discount percentage for faster sorting
-- =====================================================

-- Drop if exists to recreate
DROP MATERIALIZED VIEW IF EXISTS mv_discounted_products;

CREATE MATERIALIZED VIEW mv_discounted_products AS
SELECT 
  p.id,
  p.name_ar,
  p.name_en,
  p.description_ar,
  p.description_en,
  p.price,
  p.discount_price,
  p.images,
  p.category_id,
  p.stock,
  p.rating,
  p.rating_count,
  p.is_active,
  p.is_featured,
  p.merchant_id,
  p.created_at,
  ROUND(((p.price - p.discount_price) / NULLIF(p.price, 0) * 100)::DECIMAL, 2) as discount_percentage,
  COALESCE(p.is_flash_sale, false) as is_flash_sale,
  p.flash_sale_start,
  p.flash_sale_end,
  -- Pre-calculate flash sale priority
  CASE WHEN p.is_flash_sale = true 
       AND p.flash_sale_start <= NOW() 
       AND p.flash_sale_end > NOW() 
       THEN 0 ELSE 1 END as flash_priority
FROM products p
WHERE p.is_active = true
  AND p.discount_price IS NOT NULL
  AND p.price > 0
  AND p.discount_price > 0
  AND p.discount_price < p.price;

-- Create index on materialized view
CREATE INDEX IF NOT EXISTS idx_mv_discounted_sort 
ON mv_discounted_products(flash_priority, discount_percentage DESC);

-- Create unique index for concurrent refresh
CREATE UNIQUE INDEX IF NOT EXISTS idx_mv_discounted_id 
ON mv_discounted_products(id);

-- Function to refresh the materialized view
CREATE OR REPLACE FUNCTION refresh_discounted_products()
RETURNS void
LANGUAGE plpgsql
SECURITY DEFINER
SET search_path = public
AS $$
BEGIN
  REFRESH MATERIALIZED VIEW CONCURRENTLY mv_discounted_products;
END;
$$;

-- Grant permissions
GRANT SELECT ON mv_discounted_products TO authenticated, anon;
GRANT EXECUTE ON FUNCTION refresh_discounted_products() TO authenticated;

-- =====================================================
-- 8. OPTIMIZED VERSION USING MATERIALIZED VIEW
-- =====================================================

CREATE OR REPLACE FUNCTION get_discounted_products_fast(
  p_limit INT DEFAULT 20,
  p_offset INT DEFAULT 0
)
RETURNS TABLE (
  id UUID,
  name_ar TEXT,
  name_en TEXT,
  description_ar TEXT,
  description_en TEXT,
  price DECIMAL,
  discount_price DECIMAL,
  images TEXT[],
  category_id UUID,
  stock INT,
  rating DECIMAL,
  rating_count INT,
  is_active BOOLEAN,
  is_featured BOOLEAN,
  merchant_id UUID,
  created_at TIMESTAMPTZ,
  discount_percentage DECIMAL,
  is_flash_sale BOOLEAN,
  flash_sale_start TIMESTAMPTZ,
  flash_sale_end TIMESTAMPTZ
)
LANGUAGE plpgsql
SECURITY DEFINER
SET search_path = public
AS $$
BEGIN
  RETURN QUERY
  SELECT 
    mv.id,
    mv.name_ar,
    mv.name_en,
    mv.description_ar,
    mv.description_en,
    mv.price,
    mv.discount_price,
    mv.images,
    mv.category_id,
    mv.stock,
    mv.rating,
    mv.rating_count,
    mv.is_active,
    mv.is_featured,
    mv.merchant_id,
    mv.created_at,
    mv.discount_percentage,
    mv.is_flash_sale,
    mv.flash_sale_start,
    mv.flash_sale_end
  FROM mv_discounted_products mv
  ORDER BY mv.flash_priority, mv.discount_percentage DESC
  LIMIT p_limit
  OFFSET p_offset;
END;
$$;

GRANT EXECUTE ON FUNCTION get_discounted_products_fast(INTEGER, INTEGER) TO authenticated, anon;

-- =====================================================
-- 9. SCHEDULE MATERIALIZED VIEW REFRESH (if pg_cron available)
-- =====================================================

-- Uncomment if pg_cron extension is available:
-- SELECT cron.schedule('refresh-discounted-products', '*/5 * * * *', 'SELECT refresh_discounted_products()');

-- =====================================================
-- SUMMARY OF OPTIMIZATIONS
-- =====================================================
-- 1. get_available_coupons: O(n×u) → O(n+u) using CTE
-- 2. validate_coupon: Reduced array operations with EXISTS
-- 3. Added composite indexes for common queries
-- 4. Full-text search index for product search
-- 5. Materialized view for pre-calculated discount sorting
-- 6. get_discounted_products_fast: O(n log n) → O(1) with index
