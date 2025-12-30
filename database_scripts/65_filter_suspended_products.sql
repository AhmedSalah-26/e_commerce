-- =====================================================
-- Filter suspended products from discounted products RPC
-- =====================================================

-- Drop and recreate the function to filter suspended products
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
