-- =====================================================
-- Order Priority & Enhanced Admin Control
-- =====================================================

-- Add priority column to orders
ALTER TABLE orders 
ADD COLUMN IF NOT EXISTS priority TEXT DEFAULT 'normal' 
CHECK (priority IN ('low', 'normal', 'high', 'urgent'));

-- Add admin notes column
ALTER TABLE orders 
ADD COLUMN IF NOT EXISTS admin_notes TEXT;

-- Add closed status support (reopen after close)
-- Update status check if exists
ALTER TABLE orders DROP CONSTRAINT IF EXISTS orders_status_check;
ALTER TABLE orders ADD CONSTRAINT orders_status_check 
CHECK (status IN ('pending', 'processing', 'shipped', 'delivered', 'cancelled', 'closed', 'refunded'));

-- Index for priority
CREATE INDEX IF NOT EXISTS idx_orders_priority ON orders(priority);

-- =====================================================
-- Comments
-- =====================================================
COMMENT ON COLUMN orders.priority IS 'Order priority: low, normal, high, urgent';
COMMENT ON COLUMN orders.admin_notes IS 'Internal admin notes about the order';
