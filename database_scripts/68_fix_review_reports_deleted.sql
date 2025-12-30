-- =====================================================
-- Fix Review Reports - Keep reports when review is deleted
-- =====================================================

-- Add cached columns to store review data before deletion
ALTER TABLE public.review_reports 
ADD COLUMN IF NOT EXISTS cached_reviewer_id UUID,
ADD COLUMN IF NOT EXISTS cached_reviewer_name TEXT,
ADD COLUMN IF NOT EXISTS cached_review_comment TEXT,
ADD COLUMN IF NOT EXISTS cached_review_rating INTEGER,
ADD COLUMN IF NOT EXISTS cached_product_id UUID,
ADD COLUMN IF NOT EXISTS cached_product_name TEXT;

-- Change foreign key from CASCADE to SET NULL
ALTER TABLE public.review_reports 
DROP CONSTRAINT IF EXISTS review_reports_review_id_fkey;

ALTER TABLE public.review_reports 
ADD CONSTRAINT review_reports_review_id_fkey 
FOREIGN KEY (review_id) REFERENCES public.reviews(id) ON DELETE SET NULL;

-- Update get_admin_review_reports to use cached data when review is deleted
CREATE OR REPLACE FUNCTION get_admin_review_reports(
  p_status TEXT DEFAULT NULL,
  p_limit INTEGER DEFAULT 50,
  p_offset INTEGER DEFAULT 0
)
RETURNS TABLE (
  id UUID,
  review_id UUID,
  reviewer_id UUID,
  reviewer_name TEXT,
  reviewer_email TEXT,
  review_comment TEXT,
  review_rating INTEGER,
  product_id UUID,
  product_name TEXT,
  reporter_id UUID,
  reporter_name TEXT,
  reporter_email TEXT,
  reason TEXT,
  description TEXT,
  status TEXT,
  admin_response TEXT,
  admin_id UUID,
  admin_name TEXT,
  created_at TIMESTAMPTZ,
  resolved_at TIMESTAMPTZ,
  total_count BIGINT
) AS $$
DECLARE
  v_total BIGINT;
BEGIN
  SELECT COUNT(*) INTO v_total
  FROM public.review_reports rr
  WHERE (p_status IS NULL OR rr.status = p_status);

  RETURN QUERY
  SELECT 
    rr.id,
    rr.review_id,
    COALESCE(r.user_id, rr.cached_reviewer_id) as reviewer_id,
    COALESCE(reviewer.name, rr.cached_reviewer_name, 'مستخدم محذوف') as reviewer_name,
    reviewer.email as reviewer_email,
    COALESCE(r.comment, rr.cached_review_comment, 'تعليق محذوف') as review_comment,
    COALESCE(r.rating, rr.cached_review_rating, 0) as review_rating,
    COALESCE(r.product_id, rr.cached_product_id) as product_id,
    COALESCE(p.name_ar, p.name_en, rr.cached_product_name, 'منتج محذوف') as product_name,
    rr.user_id as reporter_id,
    COALESCE(reporter.name, 'مستخدم') as reporter_name,
    reporter.email as reporter_email,
    rr.reason,
    rr.description,
    rr.status,
    rr.admin_response,
    rr.admin_id,
    COALESCE(admin_user.name, 'أدمن') as admin_name,
    rr.created_at,
    rr.resolved_at,
    v_total as total_count
  FROM public.review_reports rr
  LEFT JOIN public.reviews r ON r.id = rr.review_id
  LEFT JOIN public.profiles reviewer ON reviewer.id = COALESCE(r.user_id, rr.cached_reviewer_id)
  LEFT JOIN public.products p ON p.id = COALESCE(r.product_id, rr.cached_product_id)
  LEFT JOIN public.profiles reporter ON reporter.id = rr.user_id
  LEFT JOIN public.profiles admin_user ON admin_user.id = rr.admin_id
  WHERE (p_status IS NULL OR rr.status = p_status)
  ORDER BY 
    CASE rr.status 
      WHEN 'pending' THEN 0 
      WHEN 'reviewed' THEN 1 
      ELSE 2 
    END,
    rr.created_at DESC
  LIMIT p_limit
  OFFSET p_offset;
END;
$$ LANGUAGE plpgsql SECURITY DEFINER;

-- Update respond function to cache data before deleting review
CREATE OR REPLACE FUNCTION respond_to_review_report(
  p_report_id UUID,
  p_status TEXT,
  p_admin_response TEXT,
  p_delete_review BOOLEAN DEFAULT FALSE,
  p_ban_reviewer BOOLEAN DEFAULT FALSE
)
RETURNS BOOLEAN AS $$
DECLARE
  v_review_id UUID;
  v_reviewer_id UUID;
  v_review_comment TEXT;
  v_review_rating INTEGER;
  v_product_id UUID;
  v_product_name TEXT;
  v_reviewer_name TEXT;
BEGIN
  IF NOT is_admin() THEN
    RAISE EXCEPTION 'Unauthorized';
  END IF;

  -- Get review data before potential deletion
  SELECT 
    rr.review_id, 
    r.user_id,
    r.comment,
    r.rating,
    r.product_id,
    COALESCE(p.name_ar, p.name_en),
    prof.name
  INTO 
    v_review_id, 
    v_reviewer_id,
    v_review_comment,
    v_review_rating,
    v_product_id,
    v_product_name,
    v_reviewer_name
  FROM public.review_reports rr
  LEFT JOIN public.reviews r ON r.id = rr.review_id
  LEFT JOIN public.products p ON p.id = r.product_id
  LEFT JOIN public.profiles prof ON prof.id = r.user_id
  WHERE rr.id = p_report_id;

  -- Cache review data and update report
  UPDATE public.review_reports
  SET 
    status = p_status,
    admin_response = p_admin_response,
    admin_id = auth.uid(),
    updated_at = NOW(),
    resolved_at = CASE WHEN p_status IN ('resolved', 'rejected') THEN NOW() ELSE NULL END,
    cached_reviewer_id = COALESCE(cached_reviewer_id, v_reviewer_id),
    cached_reviewer_name = COALESCE(cached_reviewer_name, v_reviewer_name),
    cached_review_comment = COALESCE(cached_review_comment, v_review_comment),
    cached_review_rating = COALESCE(cached_review_rating, v_review_rating),
    cached_product_id = COALESCE(cached_product_id, v_product_id),
    cached_product_name = COALESCE(cached_product_name, v_product_name)
  WHERE id = p_report_id;

  -- Delete review if requested
  IF p_delete_review AND v_review_id IS NOT NULL THEN
    DELETE FROM public.reviews WHERE id = v_review_id;
  END IF;

  -- Ban reviewer if requested
  IF p_ban_reviewer AND v_reviewer_id IS NOT NULL THEN
    UPDATE public.profiles
    SET 
      is_banned = true,
      ban_reason = 'تم الحظر بسبب تعليقات مسيئة'
    WHERE id = v_reviewer_id;
  END IF;

  RETURN TRUE;
END;
$$ LANGUAGE plpgsql SECURITY DEFINER;
