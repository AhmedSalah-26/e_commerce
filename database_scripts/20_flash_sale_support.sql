-- Add flash sale columns to products table
ALTER TABLE products
ADD COLUMN IF NOT EXISTS is_flash_sale BOOLEAN DEFAULT FALSE,
ADD COLUMN IF NOT EXISTS flash_sale_start TIMESTAMPTZ,
ADD COLUMN IF NOT EXISTS flash_sale_end TIMESTAMPTZ;

-- Create index for flash sale queries
CREATE INDEX IF NOT EXISTS idx_products_flash_sale 
ON products (is_flash_sale, flash_sale_end) 
WHERE is_flash_sale = TRUE;

-- Function to check if flash sale is active
CREATE OR REPLACE FUNCTION is_flash_sale_active(
  p_is_flash_sale BOOLEAN,
  p_flash_sale_start TIMESTAMPTZ,
  p_flash_sale_end TIMESTAMPTZ
) RETURNS BOOLEAN AS $$
BEGIN
  IF p_is_flash_sale IS NOT TRUE THEN
    RETURN FALSE;
  END IF;
  
  IF p_flash_sale_start IS NULL OR p_flash_sale_end IS NULL THEN
    RETURN FALSE;
  END IF;
  
  RETURN NOW() >= p_flash_sale_start AND NOW() <= p_flash_sale_end;
END;
$$ LANGUAGE plpgsql;

-- Function to clean up expired flash sales (removes discount when flash sale ends)
CREATE OR REPLACE FUNCTION cleanup_expired_flash_sales()
RETURNS void AS $$
BEGIN
  UPDATE products
  SET 
    is_flash_sale = FALSE,
    flash_sale_start = NULL,
    flash_sale_end = NULL,
    discount_price = NULL
  WHERE 
    is_flash_sale = TRUE 
    AND flash_sale_end IS NOT NULL 
    AND flash_sale_end < NOW();
END;
$$ LANGUAGE plpgsql;

-- Create a trigger function to auto-cleanup on any product query
CREATE OR REPLACE FUNCTION trigger_cleanup_flash_sales()
RETURNS TRIGGER AS $$
BEGIN
  -- Check if this specific product's flash sale has expired
  IF NEW.is_flash_sale = TRUE AND NEW.flash_sale_end IS NOT NULL AND NEW.flash_sale_end < NOW() THEN
    NEW.is_flash_sale := FALSE;
    NEW.flash_sale_start := NULL;
    NEW.flash_sale_end := NULL;
    NEW.discount_price := NULL;
  END IF;
  RETURN NEW;
END;
$$ LANGUAGE plpgsql;

-- Create trigger on UPDATE to auto-cleanup
DROP TRIGGER IF EXISTS cleanup_flash_sale_on_update ON products;
CREATE TRIGGER cleanup_flash_sale_on_update
  BEFORE UPDATE ON products
  FOR EACH ROW
  EXECUTE FUNCTION trigger_cleanup_flash_sales();

-- Schedule periodic cleanup using pg_cron (if available)
-- Run every hour to clean up expired flash sales
-- SELECT cron.schedule('cleanup-flash-sales', '0 * * * *', 'SELECT cleanup_expired_flash_sales()');

-- Comment for documentation
COMMENT ON COLUMN products.is_flash_sale IS 'Whether this product has a flash sale';
COMMENT ON COLUMN products.flash_sale_start IS 'Flash sale start date/time';
COMMENT ON COLUMN products.flash_sale_end IS 'Flash sale end date/time';
COMMENT ON FUNCTION cleanup_expired_flash_sales() IS 'Removes discount from products when flash sale expires';
