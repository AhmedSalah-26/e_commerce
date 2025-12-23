-- Add address column to stores table
ALTER TABLE stores 
ADD COLUMN IF NOT EXISTS address TEXT;

-- Create index for faster lookups
CREATE INDEX IF NOT EXISTS idx_stores_merchant_id 
ON stores(merchant_id);
