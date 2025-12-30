-- Fix get_user_product_reports to return user_id
DROP FUNCTION IF EXISTS get_user_product_reports(UUID);

CREATE OR REPLACE FUNCTION get_user_product_reports(p_user_id UUID)
RETURNS TABLE (
  id UUID,
  product_id UUID,
  product_name TEXT,
  product_image TEXT,
  user_id UUID,
  reason TEXT,
  description TEXT,
  status TEXT,
  admin_response TEXT,
  created_at TIMESTAMPTZ,
  resolved_at TIMESTAMPTZ
) AS $$
BEGIN
  RETURN QUERY
  SELECT 
    pr.id,
    pr.product_id,
    COALESCE(p.name_ar, p.name_en, 'منتج محذوف') as product_name,
    p.images[1] as product_image,
    pr.user_id,
    pr.reason,
    pr.description,
    pr.status,
    pr.admin_response,
    pr.created_at,
    pr.resolved_at
  FROM public.product_reports pr
  LEFT JOIN public.products p ON p.id = pr.product_id
  WHERE pr.user_id = p_user_id
  ORDER BY pr.created_at DESC;
END;
$$ LANGUAGE plpgsql SECURITY DEFINER SET search_path = public;

GRANT EXECUTE ON FUNCTION get_user_product_reports(UUID) TO authenticated;
