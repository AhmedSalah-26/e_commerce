-- =====================================================
-- Review Reports System
-- =====================================================

-- Create review_reports table
CREATE TABLE IF NOT EXISTS public.review_reports (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  review_id UUID REFERENCES public.reviews(id) ON DELETE SET NULL,
  user_id UUID NOT NULL REFERENCES auth.users(id) ON DELETE CASCADE,
  reason TEXT NOT NULL,
  description TEXT,
  status TEXT NOT NULL DEFAULT 'pending' CHECK (status IN ('pending', 'reviewed', 'resolved', 'rejected')),
  admin_response TEXT,
  admin_id UUID REFERENCES auth.users(id),
  -- Store review data for when review is deleted
  cached_reviewer_id UUID,
  cached_reviewer_name TEXT,
  cached_review_comment TEXT,
  cached_review_rating INTEGER,
  cached_product_id UUID,
  cached_product_name TEXT,
  created_at TIMESTAMPTZ DEFAULT NOW(),
  updated_at TIMESTAMPTZ DEFAULT NOW(),
  resolved_at TIMESTAMPTZ
);

-- Create indexes
CREATE INDEX IF NOT EXISTS idx_review_reports_review_id ON public.review_reports(review_id);
CREATE INDEX IF NOT EXISTS idx_review_reports_user_id ON public.review_reports(user_id);
CREATE INDEX IF NOT EXISTS idx_review_reports_status ON public.review_reports(status);
CREATE INDEX IF NOT EXISTS idx_review_reports_created_at ON public.review_reports(created_at DESC);

-- Enable RLS
ALTER TABLE public.review_reports ENABLE ROW LEVEL SECURITY;

-- RLS Policies
-- Users can view their own reports
CREATE POLICY "Users can view own review reports"
  ON public.review_reports FOR SELECT
  USING (user_id = auth.uid());

-- Users can create reports
CREATE POLICY "Users can create review reports"
  ON public.review_reports FOR INSERT
  WITH CHECK (user_id = auth.uid());

-- Admins can view all reports
CREATE POLICY "Admins can view all review reports"
  ON public.review_reports FOR SELECT
  USING (is_admin());

-- Admins can update reports
CREATE POLICY "Admins can update review reports"
  ON public.review_reports FOR UPDATE
  USING (is_admin());

-- Function to get user review reports
CREATE OR REPLACE FUNCTION get_user_review_reports(p_user_id UUID)
RETURNS TABLE (
  id UUID,
  review_id UUID,
  reviewer_name TEXT,
  review_comment TEXT,
  review_rating INTEGER,
  product_name TEXT,
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
    rr.id,
    rr.review_id,
    COALESCE(p.name, 'مستخدم') as reviewer_name,
    r.comment as review_comment,
    r.rating as review_rating,
    COALESCE(pr.name_ar, pr.name_en, 'منتج محذوف') as product_name,
    rr.reason,
    rr.description,
    rr.status,
    rr.admin_response,
    rr.created_at,
    rr.resolved_at
  FROM public.review_reports rr
  LEFT JOIN public.reviews r ON r.id = rr.review_id
  LEFT JOIN public.profiles p ON p.id = r.user_id
  LEFT JOIN public.products pr ON pr.id = r.product_id
  WHERE rr.user_id = p_user_id
  ORDER BY rr.created_at DESC;
END;
$$ LANGUAGE plpgsql SECURITY DEFINER;

-- Function to get all review reports for admin
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
  -- Get total count
  SELECT COUNT(*) INTO v_total
  FROM public.review_reports rr
  WHERE (p_status IS NULL OR rr.status = p_status);

  RETURN QUERY
  SELECT 
    rr.id,
    rr.review_id,
    r.user_id as reviewer_id,
    COALESCE(reviewer.name, 'مستخدم محذوف') as reviewer_name,
    reviewer.email as reviewer_email,
    COALESCE(r.comment, 'تعليق محذوف') as review_comment,
    COALESCE(r.rating, 0) as review_rating,
    r.product_id,
    COALESCE(p.name_ar, p.name_en, 'منتج محذوف') as product_name,
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
  LEFT JOIN public.profiles reviewer ON reviewer.id = r.user_id
  LEFT JOIN public.products p ON p.id = r.product_id
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

-- Function to respond to a review report (admin only)
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
BEGIN
  -- Check if admin
  IF NOT is_admin() THEN
    RAISE EXCEPTION 'Unauthorized';
  END IF;

  -- Get review_id and reviewer_id
  SELECT rr.review_id, r.user_id INTO v_review_id, v_reviewer_id
  FROM public.review_reports rr
  LEFT JOIN public.reviews r ON r.id = rr.review_id
  WHERE rr.id = p_report_id;

  -- Update report
  UPDATE public.review_reports
  SET 
    status = p_status,
    admin_response = p_admin_response,
    admin_id = auth.uid(),
    updated_at = NOW(),
    resolved_at = CASE WHEN p_status IN ('resolved', 'rejected') THEN NOW() ELSE NULL END
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

-- Grant permissions
GRANT EXECUTE ON FUNCTION get_user_review_reports(UUID) TO authenticated;
GRANT EXECUTE ON FUNCTION get_admin_review_reports(TEXT, INTEGER, INTEGER) TO authenticated;
GRANT EXECUTE ON FUNCTION respond_to_review_report(UUID, TEXT, TEXT, BOOLEAN, BOOLEAN) TO authenticated;
