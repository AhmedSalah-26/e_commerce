-- =============================================
-- Insert Sample Banners
-- =============================================

-- Insert sample banners using the existing slider images URLs
-- You need to upload these images to Supabase storage first, or use placeholder URLs

INSERT INTO public.banners (title_ar, title_en, image_url, link_type, link_value, sort_order, is_active)
VALUES 
    ('عروض زهرة التمور', 'Zahret Al-Tamoor Offers', 'https://picsum.photos/seed/banner1/800/350', 'offers', 'best-deals', 1, true),
    ('تمور فاخرة', 'Premium Dates', 'https://picsum.photos/seed/banner2/800/350', 'offers', 'flash-sale', 2, true),
    ('وصل حديثاً', 'New Arrivals', 'https://picsum.photos/seed/banner3/800/350', 'offers', 'new-arrivals', 3, true),
    ('تشكيلة متنوعة', 'Wide Selection', 'https://picsum.photos/seed/banner4/800/350', 'none', NULL, 4, true);

-- Verify insertion
SELECT * FROM public.banners ORDER BY sort_order;
