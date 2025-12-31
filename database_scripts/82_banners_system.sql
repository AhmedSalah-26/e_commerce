-- =============================================
-- Banners Management System
-- =============================================

-- Create banners table
CREATE TABLE IF NOT EXISTS public.banners (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    title_ar TEXT NOT NULL,
    title_en TEXT,
    image_url TEXT NOT NULL,
    link_type TEXT NOT NULL DEFAULT 'none', -- 'none', 'product', 'category', 'url', 'offers'
    link_value TEXT, -- product_id, category_id, url, or offer type
    sort_order INTEGER NOT NULL DEFAULT 0,
    is_active BOOLEAN NOT NULL DEFAULT true,
    start_date TIMESTAMPTZ,
    end_date TIMESTAMPTZ,
    created_at TIMESTAMPTZ NOT NULL DEFAULT NOW(),
    updated_at TIMESTAMPTZ NOT NULL DEFAULT NOW()
);

-- Create index for active banners
CREATE INDEX IF NOT EXISTS idx_banners_active ON public.banners(is_active, sort_order);

-- Enable RLS
ALTER TABLE public.banners ENABLE ROW LEVEL SECURITY;

-- Policy: Everyone can read active banners
CREATE POLICY "Anyone can read active banners"
    ON public.banners
    FOR SELECT
    USING (
        is_active = true
        AND (start_date IS NULL OR start_date <= NOW())
        AND (end_date IS NULL OR end_date >= NOW())
    );

-- Policy: Admins can do everything
CREATE POLICY "Admins can manage banners"
    ON public.banners
    FOR ALL
    USING (
        EXISTS (
            SELECT 1 FROM public.profiles
            WHERE id = auth.uid() AND role = 'admin'
        )
    )
    WITH CHECK (
        EXISTS (
            SELECT 1 FROM public.profiles
            WHERE id = auth.uid() AND role = 'admin'
        )
    );

-- Function to get active banners
CREATE OR REPLACE FUNCTION public.get_active_banners(p_locale TEXT DEFAULT 'ar')
RETURNS TABLE (
    id UUID,
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
        b.id,
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
    id UUID,
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
        b.id,
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

-- Function to create banner
CREATE OR REPLACE FUNCTION public.admin_create_banner(
    p_title_ar TEXT,
    p_title_en TEXT DEFAULT NULL,
    p_image_url TEXT DEFAULT NULL,
    p_link_type TEXT DEFAULT 'none',
    p_link_value TEXT DEFAULT NULL,
    p_sort_order INTEGER DEFAULT 0,
    p_is_active BOOLEAN DEFAULT true,
    p_start_date TIMESTAMPTZ DEFAULT NULL,
    p_end_date TIMESTAMPTZ DEFAULT NULL
)
RETURNS UUID
LANGUAGE plpgsql
SECURITY DEFINER
SET search_path = public
AS $$
DECLARE
    v_banner_id UUID;
BEGIN
    -- Check if user is admin
    IF NOT EXISTS (
        SELECT 1 FROM public.profiles
        WHERE id = auth.uid() AND role = 'admin'
    ) THEN
        RAISE EXCEPTION 'Access denied: Admin only';
    END IF;

    INSERT INTO public.banners (
        title_ar, title_en, image_url, link_type, link_value,
        sort_order, is_active, start_date, end_date
    ) VALUES (
        p_title_ar, p_title_en, p_image_url, p_link_type, p_link_value,
        p_sort_order, p_is_active, p_start_date, p_end_date
    )
    RETURNING id INTO v_banner_id;

    RETURN v_banner_id;
END;
$$;

-- Function to update banner
CREATE OR REPLACE FUNCTION public.admin_update_banner(
    p_banner_id UUID,
    p_title_ar TEXT DEFAULT NULL,
    p_title_en TEXT DEFAULT NULL,
    p_image_url TEXT DEFAULT NULL,
    p_link_type TEXT DEFAULT NULL,
    p_link_value TEXT DEFAULT NULL,
    p_sort_order INTEGER DEFAULT NULL,
    p_is_active BOOLEAN DEFAULT NULL,
    p_start_date TIMESTAMPTZ DEFAULT NULL,
    p_end_date TIMESTAMPTZ DEFAULT NULL
)
RETURNS BOOLEAN
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

    UPDATE public.banners
    SET
        title_ar = COALESCE(p_title_ar, title_ar),
        title_en = COALESCE(p_title_en, title_en),
        image_url = COALESCE(p_image_url, image_url),
        link_type = COALESCE(p_link_type, link_type),
        link_value = COALESCE(p_link_value, link_value),
        sort_order = COALESCE(p_sort_order, sort_order),
        is_active = COALESCE(p_is_active, is_active),
        start_date = COALESCE(p_start_date, start_date),
        end_date = COALESCE(p_end_date, end_date),
        updated_at = NOW()
    WHERE id = p_banner_id;

    RETURN FOUND;
END;
$$;

-- Function to delete banner
CREATE OR REPLACE FUNCTION public.admin_delete_banner(p_banner_id UUID)
RETURNS BOOLEAN
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

    DELETE FROM public.banners WHERE id = p_banner_id;
    RETURN FOUND;
END;
$$;

-- Function to toggle banner status
CREATE OR REPLACE FUNCTION public.admin_toggle_banner(p_banner_id UUID)
RETURNS BOOLEAN
LANGUAGE plpgsql
SECURITY DEFINER
SET search_path = public
AS $$
DECLARE
    v_new_status BOOLEAN;
BEGIN
    -- Check if user is admin
    IF NOT EXISTS (
        SELECT 1 FROM public.profiles
        WHERE id = auth.uid() AND role = 'admin'
    ) THEN
        RAISE EXCEPTION 'Access denied: Admin only';
    END IF;

    UPDATE public.banners
    SET is_active = NOT is_active, updated_at = NOW()
    WHERE id = p_banner_id
    RETURNING is_active INTO v_new_status;

    RETURN v_new_status;
END;
$$;

-- Create storage bucket for banners if not exists
INSERT INTO storage.buckets (id, name, public)
VALUES ('banners', 'banners', true)
ON CONFLICT (id) DO NOTHING;

-- Storage policies for banners bucket
CREATE POLICY "Anyone can view banners"
    ON storage.objects FOR SELECT
    USING (bucket_id = 'banners');

CREATE POLICY "Admins can upload banners"
    ON storage.objects FOR INSERT
    WITH CHECK (
        bucket_id = 'banners'
        AND EXISTS (
            SELECT 1 FROM public.profiles
            WHERE id = auth.uid() AND role = 'admin'
        )
    );

CREATE POLICY "Admins can update banners"
    ON storage.objects FOR UPDATE
    USING (
        bucket_id = 'banners'
        AND EXISTS (
            SELECT 1 FROM public.profiles
            WHERE id = auth.uid() AND role = 'admin'
        )
    );

CREATE POLICY "Admins can delete banners"
    ON storage.objects FOR DELETE
    USING (
        bucket_id = 'banners'
        AND EXISTS (
            SELECT 1 FROM public.profiles
            WHERE id = auth.uid() AND role = 'admin'
        )
    );

-- Grant execute permissions
GRANT EXECUTE ON FUNCTION public.get_active_banners(TEXT) TO authenticated, anon;
GRANT EXECUTE ON FUNCTION public.admin_get_all_banners() TO authenticated;
GRANT EXECUTE ON FUNCTION public.admin_create_banner(TEXT, TEXT, TEXT, TEXT, TEXT, INTEGER, BOOLEAN, TIMESTAMPTZ, TIMESTAMPTZ) TO authenticated;
GRANT EXECUTE ON FUNCTION public.admin_update_banner(UUID, TEXT, TEXT, TEXT, TEXT, TEXT, INTEGER, BOOLEAN, TIMESTAMPTZ, TIMESTAMPTZ) TO authenticated;
GRANT EXECUTE ON FUNCTION public.admin_delete_banner(UUID) TO authenticated;
GRANT EXECUTE ON FUNCTION public.admin_toggle_banner(UUID) TO authenticated;
