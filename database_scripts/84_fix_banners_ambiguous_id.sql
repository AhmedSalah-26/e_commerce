-- =============================================
-- Fix ambiguous "id" column in banners functions
-- =============================================

-- Drop existing functions first
DROP FUNCTION IF EXISTS public.get_active_banners(TEXT);
DROP FUNCTION IF EXISTS public.admin_get_all_banners();

-- Function to get active banners
CREATE OR REPLACE FUNCTION public.get_active_banners(p_locale TEXT DEFAULT 'ar')
RETURNS TABLE (
    banner_id UUID,
    title TEXT,
    image_url TEXT,
    link_type TEXT,
    link_value TEXT,
    sort_order INTEGER
)
LANGUAGE plpgsql
SECURITY DEFINER
SET search_path = public
AS $$
BEGIN
    RETURN QUERY
    SELECT 
        b.id AS banner_id,
        CASE WHEN p_locale = 'en' AND b.title_en IS NOT NULL THEN b.title_en ELSE b.title_ar END AS title,
        b.image_url,
        b.link_type,
        b.link_value,
        b.sort_order
    FROM public.banners b
    WHERE b.is_active = true
        AND (b.start_date IS NULL OR b.start_date <= NOW())
        AND (b.end_date IS NULL OR b.end_date >= NOW())
    ORDER BY b.sort_order ASC, b.created_at DESC;
END;
$$;

-- Function to get all banners for admin
CREATE OR REPLACE FUNCTION public.admin_get_all_banners()
RETURNS TABLE (
    banner_id UUID,
    title_ar TEXT,
    title_en TEXT,
    image_url TEXT,
    link_type TEXT,
    link_value TEXT,
    sort_order INTEGER,
    is_active BOOLEAN,
    start_date TIMESTAMPTZ,
    end_date TIMESTAMPTZ,
    created_at TIMESTAMPTZ,
    updated_at TIMESTAMPTZ
)
LANGUAGE plpgsql
SECURITY DEFINER
SET search_path = public
AS $$
BEGIN
    -- Check if user is admin
    IF NOT EXISTS (
        SELECT 1 FROM public.profiles
        WHERE id = auth.uid() AND role = 'admin'
    ) THEN
        RAISE EXCEPTION 'Access denied: Admin only';
    END IF;

    RETURN QUERY
    SELECT 
        b.id AS banner_id,
        b.title_ar,
        b.title_en,
        b.image_url,
        b.link_type,
        b.link_value,
        b.sort_order,
        b.is_active,
        b.start_date,
        b.end_date,
        b.created_at,
        b.updated_at
    FROM public.banners b
    ORDER BY b.sort_order ASC, b.created_at DESC;
END;
$$;

-- Grant execute permissions
GRANT EXECUTE ON FUNCTION public.get_active_banners(TEXT) TO authenticated, anon;
GRANT EXECUTE ON FUNCTION public.admin_get_all_banners() TO authenticated;
