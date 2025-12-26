-- Add logo column to stores table and create storage bucket
-- Run this in Supabase SQL Editor

-- Add logo_url column to stores table
ALTER TABLE stores 
ADD COLUMN IF NOT EXISTS logo_url TEXT;

-- Create stores bucket for store logos
INSERT INTO storage.buckets (id, name, public)
VALUES ('stores', 'stores', true)
ON CONFLICT (id) DO NOTHING;

-- Allow public access to stores bucket
CREATE POLICY "Public Access to Store Logos"
ON storage.objects FOR SELECT
USING (bucket_id = 'stores');

-- Allow authenticated users to upload to stores bucket
CREATE POLICY "Authenticated users can upload store logos"
ON storage.objects FOR INSERT
WITH CHECK (
  bucket_id = 'stores' 
  AND auth.role() = 'authenticated'
);

-- Allow users to update their own store logos
CREATE POLICY "Users can update store logos"
ON storage.objects FOR UPDATE
USING (
  bucket_id = 'stores' 
  AND auth.role() = 'authenticated'
);

-- Allow users to delete their own store logos
CREATE POLICY "Users can delete store logos"
ON storage.objects FOR DELETE
USING (
  bucket_id = 'stores' 
  AND auth.role() = 'authenticated'
);
