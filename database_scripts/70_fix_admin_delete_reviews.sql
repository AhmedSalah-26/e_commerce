-- =====================================================
-- Fix: Allow admin to delete reviews via RLS policy
-- =====================================================

-- Add policy for admin to delete any review
DROP POLICY IF EXISTS "Admin can delete any review" ON reviews;
CREATE POLICY "Admin can delete any review" ON reviews
  FOR DELETE TO authenticated
  USING (is_admin());

-- Also update the respond function to use SECURITY DEFINER properly
-- The function needs to bypass RLS, so we set it to run as the definer
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
  -- Check if admin
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

  -- Delete review if requested (now admin has permission via RLS policy)
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

-- Grant execute permission
GRANT EXECUTE ON FUNCTION respond_to_review_report(UUID, TEXT, TEXT, BOOLEAN, BOOLEAN) TO authenticated;
