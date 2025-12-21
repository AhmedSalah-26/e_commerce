-- =====================================================
-- GOVERNORATES & SHIPPING PRICES SYSTEM
-- Normalized design for shipping cost management
-- =====================================================

-- =====================================================
-- 1. GOVERNORATES TABLE (المحافظات)
-- =====================================================
CREATE TABLE IF NOT EXISTS governorates (
  id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
  name_ar TEXT NOT NULL,
  name_en TEXT NOT NULL,
  is_active BOOLEAN DEFAULT true,
  sort_order INTEGER DEFAULT 0,
  created_at TIMESTAMPTZ DEFAULT NOW()
);

-- Create index for active governorates
CREATE INDEX IF NOT EXISTS idx_governorates_active ON governorates(is_active);
CREATE INDEX IF NOT EXISTS idx_governorates_sort ON governorates(sort_order);

-- =====================================================
-- 2. MERCHANT SHIPPING PRICES TABLE (أسعار الشحن للتجار)
-- =====================================================
CREATE TABLE IF NOT EXISTS merchant_shipping_prices (
  id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
  merchant_id UUID REFERENCES profiles(id) ON DELETE CASCADE NOT NULL,
  governorate_id UUID REFERENCES governorates(id) ON DELETE CASCADE NOT NULL,
  price DECIMAL(10,2) NOT NULL CHECK (price >= 0),
  is_active BOOLEAN DEFAULT true,
  created_at TIMESTAMPTZ DEFAULT NOW(),
  updated_at TIMESTAMPTZ DEFAULT NOW(),
  UNIQUE(merchant_id, governorate_id)
);

-- Create indexes
CREATE INDEX IF NOT EXISTS idx_shipping_merchant ON merchant_shipping_prices(merchant_id);
CREATE INDEX IF NOT EXISTS idx_shipping_governorate ON merchant_shipping_prices(governorate_id);

-- =====================================================
-- 3. ADD GOVERNORATE TO PROFILES (للعملاء)
-- =====================================================
ALTER TABLE profiles 
ADD COLUMN IF NOT EXISTS governorate_id UUID REFERENCES governorates(id);

-- =====================================================
-- 4. ADD GOVERNORATE TO ORDERS
-- =====================================================
ALTER TABLE orders 
ADD COLUMN IF NOT EXISTS governorate_id UUID REFERENCES governorates(id);

-- =====================================================
-- 5. TRIGGER FOR UPDATED_AT
-- =====================================================
CREATE TRIGGER update_merchant_shipping_prices_updated_at
  BEFORE UPDATE ON merchant_shipping_prices
  FOR EACH ROW EXECUTE FUNCTION update_updated_at_column();

-- =====================================================
-- 6. RLS POLICIES
-- =====================================================

-- Enable RLS
ALTER TABLE governorates ENABLE ROW LEVEL SECURITY;
ALTER TABLE merchant_shipping_prices ENABLE ROW LEVEL SECURITY;

-- Governorates: Everyone can read active governorates
CREATE POLICY "Anyone can view active governorates"
  ON governorates FOR SELECT
  USING (is_active = true);

-- Merchant Shipping Prices: Merchants can manage their own prices
CREATE POLICY "Merchants can view their shipping prices"
  ON merchant_shipping_prices FOR SELECT
  USING (
    merchant_id = auth.uid() OR
    EXISTS (SELECT 1 FROM profiles WHERE id = auth.uid())
  );

CREATE POLICY "Merchants can insert their shipping prices"
  ON merchant_shipping_prices FOR INSERT
  WITH CHECK (merchant_id = auth.uid());

CREATE POLICY "Merchants can update their shipping prices"
  ON merchant_shipping_prices FOR UPDATE
  USING (merchant_id = auth.uid());

CREATE POLICY "Merchants can delete their shipping prices"
  ON merchant_shipping_prices FOR DELETE
  USING (merchant_id = auth.uid());

-- =====================================================
-- 7. SEED DATA - Egyptian Governorates (27 محافظة)
-- =====================================================
INSERT INTO governorates (name_ar, name_en, sort_order) VALUES
  ('القاهرة', 'Cairo', 1),
  ('الجيزة', 'Giza', 2),
  ('الإسكندرية', 'Alexandria', 3),
  ('الدقهلية', 'Dakahlia', 4),
  ('البحر الأحمر', 'Red Sea', 5),
  ('البحيرة', 'Beheira', 6),
  ('الفيوم', 'Fayoum', 7),
  ('الغربية', 'Gharbia', 8),
  ('الإسماعيلية', 'Ismailia', 9),
  ('المنوفية', 'Menofia', 10),
  ('المنيا', 'Minya', 11),
  ('القليوبية', 'Qalyubia', 12),
  ('الوادي الجديد', 'New Valley', 13),
  ('السويس', 'Suez', 14),
  ('أسوان', 'Aswan', 15),
  ('أسيوط', 'Asyut', 16),
  ('بني سويف', 'Beni Suef', 17),
  ('بورسعيد', 'Port Said', 18),
  ('دمياط', 'Damietta', 19),
  ('الشرقية', 'Sharqia', 20),
  ('جنوب سيناء', 'South Sinai', 21),
  ('كفر الشيخ', 'Kafr El Sheikh', 22),
  ('مطروح', 'Matrouh', 23),
  ('الأقصر', 'Luxor', 24),
  ('قنا', 'Qena', 25),
  ('شمال سيناء', 'North Sinai', 26),
  ('سوهاج', 'Sohag', 27)
ON CONFLICT DO NOTHING;

-- =====================================================
-- 8. FUNCTION: Get shipping price for order
-- =====================================================
CREATE OR REPLACE FUNCTION get_shipping_price(
  p_merchant_id UUID,
  p_governorate_id UUID
)
RETURNS DECIMAL AS $$
DECLARE
  v_price DECIMAL;
BEGIN
  SELECT price INTO v_price
  FROM merchant_shipping_prices
  WHERE merchant_id = p_merchant_id
    AND governorate_id = p_governorate_id
    AND is_active = true;
  
  -- Return 0 if no price found (free shipping or not configured)
  RETURN COALESCE(v_price, 0);
END;
$$ LANGUAGE plpgsql;
