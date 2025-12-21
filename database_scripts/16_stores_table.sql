-- Create stores table for merchant store information
-- Run this in Supabase SQL Editor

-- Create stores table
CREATE TABLE IF NOT EXISTS stores (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    merchant_id UUID NOT NULL REFERENCES profiles(id) ON DELETE CASCADE,
    name TEXT NOT NULL,
    description TEXT,
    address TEXT,
    phone TEXT,
    created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
    updated_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
    UNIQUE(merchant_id)
);

-- Create index for faster lookups
CREATE INDEX IF NOT EXISTS idx_stores_merchant_id ON stores(merchant_id);

-- Enable RLS
ALTER TABLE stores ENABLE ROW LEVEL SECURITY;

-- RLS Policies

-- Anyone can read store info (for product details)
CREATE POLICY "Anyone can view stores"
    ON stores FOR SELECT
    USING (true);

-- Merchants can insert their own store
CREATE POLICY "Merchants can create their store"
    ON stores FOR INSERT
    WITH CHECK (auth.uid() = merchant_id);

-- Merchants can update their own store
CREATE POLICY "Merchants can update their store"
    ON stores FOR UPDATE
    USING (auth.uid() = merchant_id)
    WITH CHECK (auth.uid() = merchant_id);

-- Merchants can delete their own store
CREATE POLICY "Merchants can delete their store"
    ON stores FOR DELETE
    USING (auth.uid() = merchant_id);

-- Create function to auto-update updated_at
CREATE OR REPLACE FUNCTION update_stores_updated_at()
RETURNS TRIGGER AS $$
BEGIN
    NEW.updated_at = NOW();
    RETURN NEW;
END;
$$ LANGUAGE plpgsql;

-- Create trigger for updated_at
DROP TRIGGER IF EXISTS stores_updated_at_trigger ON stores;
CREATE TRIGGER stores_updated_at_trigger
    BEFORE UPDATE ON stores
    FOR EACH ROW
    EXECUTE FUNCTION update_stores_updated_at();

-- Grant permissions
GRANT ALL ON stores TO authenticated;
GRANT SELECT ON stores TO anon;
