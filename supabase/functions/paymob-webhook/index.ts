// Paymob Webhook Handler
// This function receives payment notifications from Paymob and updates order status

import { serve } from "https://deno.land/std@0.168.0/http/server.ts"
import { createClient } from 'https://esm.sh/@supabase/supabase-js@2'

const corsHeaders = {
  'Access-Control-Allow-Origin': '*',
  'Access-Control-Allow-Headers': 'authorization, x-client-info, apikey, content-type',
}

serve(async (req) => {
  // Handle CORS preflight
  if (req.method === 'OPTIONS') {
    return new Response('ok', { headers: corsHeaders })
  }

  try {
    const body = await req.json()
    
    console.log('Paymob webhook received:', JSON.stringify(body, null, 2))

    // Extract payment data from Paymob callback
    const { obj } = body
    if (!obj) {
      return new Response(
        JSON.stringify({ error: 'Invalid payload' }),
        { status: 400, headers: { ...corsHeaders, 'Content-Type': 'application/json' } }
      )
    }

    const {
      id: transactionId,
      success,
      order: paymobOrder,
      amount_cents,
      currency,
    } = obj

    // Get order_id from merchant_order_id (we'll pass our order ID there)
    const orderId = paymobOrder?.merchant_order_id

    if (!orderId) {
      console.log('No order ID found in webhook')
      return new Response(
        JSON.stringify({ error: 'No order ID' }),
        { status: 400, headers: { ...corsHeaders, 'Content-Type': 'application/json' } }
      )
    }

    // Initialize Supabase client
    const supabaseUrl = Deno.env.get('SUPABASE_URL')!
    const supabaseKey = Deno.env.get('SUPABASE_SERVICE_ROLE_KEY')!
    const supabase = createClient(supabaseUrl, supabaseKey)

    // Determine payment status
    const paymentStatus = success ? 'paid' : 'failed'

    // Update order payment status
    const { error: updateError } = await supabase
      .from('orders')
      .update({
        payment_status: paymentStatus,
        payment_transaction_id: transactionId?.toString(),
        payment_amount: amount_cents ? amount_cents / 100 : null,
        payment_currency: currency,
        updated_at: new Date().toISOString(),
      })
      .eq('id', orderId)

    if (updateError) {
      console.error('Error updating order:', updateError)
      return new Response(
        JSON.stringify({ error: 'Failed to update order' }),
        { status: 500, headers: { ...corsHeaders, 'Content-Type': 'application/json' } }
      )
    }

    // Also update parent_orders if exists
    await supabase
      .from('parent_orders')
      .update({
        payment_status: paymentStatus,
        updated_at: new Date().toISOString(),
      })
      .eq('id', orderId)

    console.log(`Order ${orderId} payment status updated to: ${paymentStatus}`)

    return new Response(
      JSON.stringify({ success: true, orderId, paymentStatus }),
      { status: 200, headers: { ...corsHeaders, 'Content-Type': 'application/json' } }
    )

  } catch (error) {
    console.error('Webhook error:', error)
    return new Response(
      JSON.stringify({ error: error.message }),
      { status: 500, headers: { ...corsHeaders, 'Content-Type': 'application/json' } }
    )
  }
})
