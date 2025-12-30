-- =====================================================
-- Filter out of stock products from all queries
-- Only show products with: is_active=true, is_suspended=false, stock > 0
-- =====================================================

-- 1. Update materialized view to exclude out of stock products
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
  CASE WHEN p.is_flash_sale = true 
       AND p.flash_sale_start <= NOW() 
       AND p.flash_sale_end > NOW() 
       THEN 0 ELSE 1 END as flash_priority
FROM products p
WHERE p.is_active = true
  AND (p.is_suspended IS NULL OR p.is_suspended = false)
  AND p.stock > 0
  AND p.discount_price IS NOT NULL
  AND p.price > 0
  AND p.discount_price > 0
  AND p.discount_price < p.price;

-- Recreate indexes
CREATE INDEX IF NOT EXISTS idx_mv_discounted_sort 
ON mv_discounted_products(flash_priority, discount_percentage DESC);

CREATE UNIQUE INDEX IF NOT EXISTS idx_mv_discounted_id 
ON mv_discounted_products(id);

-- Refresh the view
REFRESH MATERIALIZED VIEW mv_discounted_products;

-- Grant permissions
GRANT SELECT ON mv_discounted_products TO authenticated, anon;

-- 2. Update get_discounted_products_fast
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
  WHERE mv.is_active = true
    AND mv.stock > 0
  ORDER BY mv.flash_priority, mv.discount_percentage DESC
  LIMIT p_limit
  OFFSET p_offset;
END;
$$;

GRANT EXECUTE ON FUNCTION get_discounted_products_fast(INTEGER, INTEGER) TO authenticated, anon;

-- 3. Update get_discounted_products_sorted
CREATE OR REPLACE FUNCTION public.get_discounted_products_sorted(
  p_limit INTEGER DEFAULT 20,
  p_offset INTEGER DEFAULT 0
)
RETURNS TABLE (
  id UUID,
  name_ar TEXT,
  name_en TEXT,
  description_ar TEXT,
  description_en TEXT,
  price DECIMAL,
  discount_price DECIMAL,
  discount_percentage INTEGER,
  images TEXT[],
  category_id UUID,
  merchant_id UUID,
  stock INTEGER,
  rating DECIMAL,
  is_active BOOLEAN,
  flash_sale_end TIMESTAMPTZ,
  created_at TIMESTAMPTZ,
  is_suspended BOOLEAN,
  suspension_reason TEXT
) AS $$
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
    CASE 
      WHEN p.price > 0 AND p.discount_price IS NOT NULL 
      THEN ROUND(((p.price - p.discount_price) / p.price * 100))::INTEGER
      ELSE 0
    END as discount_percentage,
    p.images,
    p.category_id,
    p.merchant_id,
    p.stock,
    p.rating,
    p.is_active,
    p.flash_sale_end,
    p.created_at,
    p.is_suspended,
    p.suspension_reason
  FROM public.products p
  WHERE p.is_active = true
    AND (p.is_suspended IS NULL OR p.is_suspended = false)
    AND p.stock > 0
    AND p.discount_price IS NOT NULL
    AND p.discount_price < p.price
  ORDER BY 
    CASE WHEN p.flash_sale_end IS NOT NULL AND p.flash_sale_end > NOW() THEN 0 ELSE 1 END,
    ((p.price - p.discount_price) / p.price) DESC
  LIMIT p_limit
  OFFSET p_offset;
END;
$$ LANGUAGE plpgsql SECURITY DEFINER;

GRANT EXECUTE ON FUNCTION public.get_discounted_products_sorted(INTEGER, INTEGER) TO authenticated, anon;
