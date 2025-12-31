-- Fix get_discounted_products_sorted to include all required fields
-- This ensures discount badge appears correctly in Best Deals and Flash Sale sections

DROP FUNCTION IF EXISTS public.get_discounted_products_sorted(INTEGER, INTEGER);

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
  review_count INTEGER,
  is_active BOOLEAN,
  is_featured BOOLEAN,
  is_flash_sale BOOLEAN,
  flash_sale_start TIMESTAMPTZ,
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
    COALESCE(p.review_count, 0)::INTEGER as review_count,
    p.is_active,
    COALESCE(p.is_featured, false) as is_featured,
    COALESCE(p.is_flash_sale, false) as is_flash_sale,
    p.flash_sale_start,
    p.flash_sale_end,
    p.created_at,
    COALESCE(p.is_suspended, false) as is_suspended,
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

-- Test the function
SELECT id, name_ar, discount_price, discount_percentage, is_flash_sale, flash_sale_start, flash_sale_end
FROM get_discounted_products_sorted(5, 0);
