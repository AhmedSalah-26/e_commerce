-- Create storage buckets for images
-- Run this in Supabase SQL Editor

-- Create products bucket
INSERT INTO storage.buckets (id, name, public)
VALUES ('products', 'products', true)
ON CONFLICT (id) DO NOTHING;

-- Create categories bucket
INSERT INTO storage.buckets (id, name, public)
VALUES ('categories', 'categories', true)
ON CONFLICT (id) DO NOTHING;

-- Allow public access to products bucket
CREATE POLICY "Public Access to Products Images"
ON storage.objects FOR SELECT
USING (bucket_id = 'products');

-- Allow authenticated users to upload to products bucket
CREATE POLICY "Authenticated users can upload product images"
ON storage.objects FOR INSERT
WITH CHECK (
  bucket_id = 'products' 
  AND auth.role() = 'authenticated'
);

-- Allow users to update their own product images
CREATE POLICY "Users can update product images"
ON storage.objects FOR UPDATE
USING (
  bucket_id = 'products' 
  AND auth.role() = 'authenticated'
);

-- Allow users to delete their own product images
CREATE POLICY "Users can delete product images"
ON storage.objects FOR DELETE
USING (
  bucket_id = 'products' 
  AND auth.role() = 'authenticated'
);

-- Allow public access to categories bucket
CREATE POLICY "Public Access to Categories Images"
ON storage.objects FOR SELECT
USING (bucket_id = 'categories');

-- Allow authenticated users to upload to categories bucket
CREATE POLICY "Authenticated users can upload category images"
ON storage.objects FOR INSERT
WITH CHECK (
  bucket_id = 'categories' 
  AND auth.role() = 'authenticated'
);

-- Allow users to update category images
CREATE POLICY "Users can update category images"
ON storage.objects FOR UPDATE
USING (
  bucket_id = 'categories' 
  AND auth.role() = 'authenticated'
);

-- Allow users to delete category images
CREATE POLICY "Users can delete category images"
ON storage.objects FOR DELETE
USING (
  bucket_id = 'categories' 
  AND auth.role() = 'authenticated'
);
