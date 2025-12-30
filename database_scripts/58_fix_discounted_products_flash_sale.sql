-- Fix get_discounted_products_sorted to include flash sale fields
-- Run this to ensure flash sale badge appears in "Best Deals" section

DROP FUNCTION IF EXISTS get_discounted_products_sorted(integer, integer);

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
    ROUND(((p.price - p.discount_price) / p.price * 100)::DECIMAL, 2) as discount_percentage,
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
    -- Flash sales first
    CASE WHEN p.is_flash_sale = true 
         AND p.flash_sale_start <= NOW() 
         AND p.flash_sale_end > NOW() 
         THEN 0 ELSE 1 END,
    -- Then by discount percentage
    ((p.price - p.discount_price) / p.price) DESC
  LIMIT p_limit
  OFFSET p_offset;
END;
$$;

-- Grant permissions
GRANT EXECUTE ON FUNCTION get_discounted_products_sorted(INTEGER, INTEGER) TO authenticated, anon;

-- Test the function
SELECT id, name_ar, discount_percentage, is_flash_sale, flash_sale_start, flash_sale_end
FROM get_discounted_products_sorted(10, 0);
