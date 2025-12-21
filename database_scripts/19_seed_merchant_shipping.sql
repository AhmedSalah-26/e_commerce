-- =====================================================
-- SEED SHIPPING PRICES FOR MERCHANT "زهره"
-- merchant_id: e7ab5369-e6c3-450f-bd6b-1cdcc7008440
-- =====================================================

-- First, get governorate IDs and insert shipping prices
-- You can adjust the prices as needed

INSERT INTO merchant_shipping_prices (merchant_id, governorate_id, price)
SELECT 
  'e7ab5369-e6c3-450f-bd6b-1cdcc7008440'::uuid,
  id,
  CASE name_ar
    -- القاهرة والجيزة - أسعار منخفضة (قريبة)
    WHEN 'القاهرة' THEN 30
    WHEN 'الجيزة' THEN 30
    WHEN 'القليوبية' THEN 35
    
    -- الدلتا - أسعار متوسطة
    WHEN 'الدقهلية' THEN 25  -- ميت غمر في الدقهلية
    WHEN 'الغربية' THEN 35
    WHEN 'المنوفية' THEN 35
    WHEN 'الشرقية' THEN 35
    WHEN 'البحيرة' THEN 40
    WHEN 'كفر الشيخ' THEN 40
    WHEN 'دمياط' THEN 40
    
    -- القناة
    WHEN 'الإسماعيلية' THEN 45
    WHEN 'بورسعيد' THEN 45
    WHEN 'السويس' THEN 45
    
    -- الإسكندرية ومطروح
    WHEN 'الإسكندرية' THEN 45
    WHEN 'مطروح' THEN 60
    
    -- الصعيد - أسعار أعلى
    WHEN 'الفيوم' THEN 45
    WHEN 'بني سويف' THEN 50
    WHEN 'المنيا' THEN 55
    WHEN 'أسيوط' THEN 60
    WHEN 'سوهاج' THEN 65
    WHEN 'قنا' THEN 70
    WHEN 'الأقصر' THEN 75
    WHEN 'أسوان' THEN 80
    
    -- البحر الأحمر وسيناء - أسعار مرتفعة
    WHEN 'البحر الأحمر' THEN 70
    WHEN 'جنوب سيناء' THEN 80
    WHEN 'شمال سيناء' THEN 75
    
    -- الوادي الجديد - الأبعد
    WHEN 'الوادي الجديد' THEN 90
    
    ELSE 50  -- Default price
  END
FROM governorates
WHERE is_active = true
ON CONFLICT (merchant_id, governorate_id) 
DO UPDATE SET price = EXCLUDED.price, updated_at = NOW();

-- Verify the inserted data
SELECT 
  g.name_ar as governorate,
  msp.price as shipping_price
FROM merchant_shipping_prices msp
JOIN governorates g ON g.id = msp.governorate_id
WHERE msp.merchant_id = 'e7ab5369-e6c3-450f-bd6b-1cdcc7008440'
ORDER BY msp.price;
