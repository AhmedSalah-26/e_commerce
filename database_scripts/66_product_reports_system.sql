-- =====================================================
-- Product Reports System
-- =====================================================

-- Create product_reports table
CREATE TABLE IF NOT EXISTS public.product_reports (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  product_id UUID NOT NULL REFERENCES public.products(id) ON DELETE CASCADE,
  user_id UUID NOT NULL REFERENCES auth.users(id) ON DELETE CASCADE,
  reason TEXT NOT NULL,
  description TEXT,
  status TEXT NOT NULL DEFAULT 'pending' CHECK (status IN ('pending', 'reviewed', 'resolved', 'rejected')),
  admin_response TEXT,
  admin_id UUID REFERENCES auth.users(id),
  created_at TIMESTAMPTZ DEFAULT NOW(),
  updated_at TIMESTAMPTZ DEFAULT NOW(),
  resolved_at TIMESTAMPTZ
);

-- Create indexes
CREATE INDEX IF NOT EXISTS idx_product_reports_product_id ON public.product_reports(product_id);
CREATE INDEX IF NOT EXISTS idx_product_reports_user_id ON public.product_reports(user_id);
CREATE INDEX IF NOT EXISTS idx_product_reports_status ON public.product_reports(status);
CREATE INDEX IF NOT EXISTS idx_product_reports_created_at ON public.product_reports(created_at DESC);

-- Enable RLS
ALTER TABLE public.product_reports ENABLE ROW LEVEL SECURITY;

-- RLS Policies
-- Users can view their own reports
CREATE POLICY "Users can view own reports"
  ON public.product_reports FOR SELECT
  USING (user_id = auth.uid());

-- Users can create reports
CREATE POLICY "Users can create reports"
  ON public.product_reports FOR INSERT
  WITH CHECK (user_id = auth.uid());

-- Admins can view all reports
CREATE POLICY "Admins can view all reports"
  ON public.product_reports FOR SELECT
  USING (is_admin());

-- Admins can update reports
CREATE POLICY "Admins can update reports"
  ON public.product_reports FOR UPDATE
  USING (is_admin());

-- Function to get user reports with product info
CREATE OR REPLACE FUNCTION get_user_product_reports(p_user_id UUID)
RETURNS TABLE (
  id UUID,
  product_id UUID,
  product_name TEXT,
  product_image TEXT,
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
$$ LANGUAGE plpgsql SECURITY DEFINER;

-- Function to get all reports for admin with product and user info
CREATE OR REPLACE FUNCTION get_admin_product_reports(
  p_status TEXT DEFAULT NULL,
  p_limit INTEGER DEFAULT 50,
  p_offset INTEGER DEFAULT 0
)
RETURNS TABLE (
  id UUID,
  product_id UUID,
  product_name TEXT,
  product_image TEXT,
  merchant_id UUID,
  merchant_name TEXT,
  user_id UUID,
  user_name TEXT,
  user_email TEXT,
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
  FROM public.product_reports pr
  WHERE (p_status IS NULL OR pr.status = p_status);

  RETURN QUERY
  SELECT 
    pr.id,
    pr.product_id,
    COALESCE(p.name_ar, p.name_en, 'منتج محذوف') as product_name,
    p.images[1] as product_image,
    p.merchant_id,
    COALESCE(s.name, mp.name, 'تاجر غير معروف') as merchant_name,
    pr.user_id,
    COALESCE(u.name, 'مستخدم') as user_name,
    u.email as user_email,
    pr.reason,
    pr.description,
    pr.status,
    pr.admin_response,
    pr.admin_id,
    COALESCE(a.name, 'أدمن') as admin_name,
    pr.created_at,
    pr.resolved_at,
    v_total as total_count
  FROM public.product_reports pr
  LEFT JOIN public.products p ON p.id = pr.product_id
  LEFT JOIN public.stores s ON s.merchant_id = p.merchant_id
  LEFT JOIN public.profiles mp ON mp.id = p.merchant_id
  LEFT JOIN public.profiles u ON u.id = pr.user_id
  LEFT JOIN public.profiles a ON a.id = pr.admin_id
  WHERE (p_status IS NULL OR pr.status = p_status)
  ORDER BY 
    CASE pr.status 
      WHEN 'pending' THEN 0 
      WHEN 'reviewed' THEN 1 
      ELSE 2 
    END,
    pr.created_at DESC
  LIMIT p_limit
  OFFSET p_offset;
END;
$$ LANGUAGE plpgsql SECURITY DEFINER;

-- Function to respond to a report (admin only)
CREATE OR REPLACE FUNCTION respond_to_product_report(
  p_report_id UUID,
  p_status TEXT,
  p_admin_response TEXT,
  p_suspend_product BOOLEAN DEFAULT FALSE,
  p_suspension_reason TEXT DEFAULT NULL
)
RETURNS BOOLEAN AS $$
DECLARE
  v_product_id UUID;
BEGIN
  -- Check if admin
  IF NOT is_admin() THEN
    RAISE EXCEPTION 'Unauthorized';
  END IF;

  -- Get product_id
  SELECT product_id INTO v_product_id
  FROM public.product_reports
  WHERE id = p_report_id;

  -- Update report
  UPDATE public.product_reports
  SET 
    status = p_status,
    admin_response = p_admin_response,
    admin_id = auth.uid(),
    updated_at = NOW(),
    resolved_at = CASE WHEN p_status IN ('resolved', 'rejected') THEN NOW() ELSE NULL END
  WHERE id = p_report_id;

  -- Suspend product if requested
  IF p_suspend_product AND v_product_id IS NOT NULL THEN
    UPDATE public.products
    SET 
      is_suspended = true,
      suspension_reason = COALESCE(p_suspension_reason, 'تم الإيقاف بسبب بلاغات المستخدمين')
    WHERE id = v_product_id;
  END IF;

  RETURN TRUE;
END;
$$ LANGUAGE plpgsql SECURITY DEFINER;

-- Grant permissions
GRANT EXECUTE ON FUNCTION get_user_product_reports(UUID) TO authenticated;
GRANT EXECUTE ON FUNCTION get_admin_product_reports(TEXT, INTEGER, INTEGER) TO authenticated;
GRANT EXECUTE ON FUNCTION respond_to_product_report(UUID, TEXT, TEXT, BOOLEAN, TEXT) TO authenticated;
