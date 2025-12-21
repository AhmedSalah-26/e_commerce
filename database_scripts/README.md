# Database Migration Scripts

Run these scripts in order in your Supabase SQL Editor:

## Initial Setup
1. `01_create_tables.sql` - Create all database tables
2. `02_rls_policies.sql` - Set up Row Level Security policies
3. `03_functions.sql` - Create database functions
4. `04_seed_data.sql` - Add initial seed data
5. `05_fix_profile_policy.sql` - Fix profile policies
6. `06_favorites_table.sql` - Add favorites functionality
7. `07_add_english_columns.sql` - Add English language support
8. `08_remove_single_name_columns.sql` - Clean up old columns
9. `09_fix_order_function.sql` - Fix order creation function
10. `10_reviews_table.sql` - Add reviews functionality
11. `11_fix_product_ratings.sql` - Fix product ratings
12. `12_reset_ratings.sql` - Reset ratings (if needed)

## Merchant Dashboard Support (NEW)
13. `13_add_merchant_support.sql` - **IMPORTANT: Run this to enable merchant features**

This script adds:
- `merchant_id` column to products table
- `merchant_id` column to orders table
- Indexes for better query performance

After running this script, you can:
- Assign products to specific merchants
- Filter products by merchant in the dashboard
- Track which merchant each order belongs to

## Notes
- Make sure to run scripts in order
- Check for any errors after each script
- The merchant support script (13) is required for the merchant dashboard to work properly
