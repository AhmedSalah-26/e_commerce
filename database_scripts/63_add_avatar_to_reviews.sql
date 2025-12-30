-- Update get_product_reviews function to include avatar_url

-- First drop the existing function
DROP FUNCTION IF EXISTS public.get_product_reviews(UUID);

-- Recreate with avatar_url
CREATE OR REPLACE FUNCTION public.get_product_reviews(p_product_id UUID)
RETURNS TABLE (
  id UUID,
  product_id UUID,
  user_id UUID,
  user_name TEXT,
  user_avatar_url TEXT,
  rating INTEGER,
  comment TEXT,
  created_at TIMESTAMP WITH TIME ZONE
) AS $$
BEGIN
  RETURN QUERY
  SELECT 
    r.id,
    r.product_id,
    r.user_id,
    COALESCE(p.name, 'مستخدم') as user_name,
    p.avatar_url as user_avatar_url,
    r.rating,
    r.comment,
    r.created_at
  FROM public.reviews r
  LEFT JOIN public.profiles p ON r.user_id = p.id
  WHERE r.product_id = p_product_id
  ORDER BY r.created_at DESC;
END;
$$ LANGUAGE plpgsql SECURITY DEFINER SET search_path = '';

-- Grant permissions
GRANT EXECUTE ON FUNCTION public.get_product_reviews(UUID) TO authenticated, anon;
