// Creates a Razorpay order for an existing QuickMed order.
//
// payment_capture = 0 (manual capture). Money is only AUTHORISED here; it is
// captured after a doctor approves the prescription, and voided if rejected.
// Capturing at checkout would mean refunding every rejected order.

import { createClient } from "https://esm.sh/@supabase/supabase-js@2";
import {
  corsHeaders,
  razorpayAuthHeader,
  RAZORPAY_KEY_ID,
  subjectFromAuthHeader,
} from "../_shared/razorpay.ts";

Deno.serve(async (req) => {
  if (req.method === "OPTIONS") {
    return new Response("ok", { headers: corsHeaders });
  }

  const json = (body: unknown, status = 200) =>
    new Response(JSON.stringify(body), {
      status,
      headers: { ...corsHeaders, "Content-Type": "application/json" },
    });

  try {
    const uid = subjectFromAuthHeader(req.headers.get("Authorization"));
    if (!uid) return json({ error: "unauthenticated" }, 401);

    const { order_id } = await req.json();
    if (!order_id) return json({ error: "order_id is required" }, 400);

    // Service role: this function is the trusted party, not the client.
    const admin = createClient(
      Deno.env.get("SUPABASE_URL")!,
      Deno.env.get("SUPABASE_SERVICE_ROLE_KEY")!,
    );

    const { data: order, error } = await admin
      .from("orders")
      .select("id, user_id, total_amount, status")
      .eq("id", order_id)
      .maybeSingle();

    if (error || !order) return json({ error: "order not found" }, 404);

    // Ownership is checked here, not trusted from the request body.
    if (order.user_id !== uid) return json({ error: "forbidden" }, 403);

    if (["delivered", "cancelled", "rejected"].includes(order.status)) {
      return json({ error: `order is ${order.status}` }, 409);
    }

    // Amount comes from the database, never from the client.
    const amountPaise = Math.round(Number(order.total_amount) * 100);
    if (!Number.isFinite(amountPaise) || amountPaise <= 0) {
      return json({ error: "order total is invalid" }, 409);
    }

    // Reuse an existing authorisation rather than creating a second one.
    const { data: existing } = await admin
      .from("payments")
      .select("provider_order_id, status")
      .eq("order_id", order_id)
      .in("status", ["created", "authorized"])
      .maybeSingle();

    if (existing?.provider_order_id) {
      return json({
        provider_order_id: existing.provider_order_id,
        amount_paise: amountPaise,
        key_id: RAZORPAY_KEY_ID,
        reused: true,
      });
    }

    const rzpRes = await fetch("https://api.razorpay.com/v1/orders", {
      method: "POST",
      headers: {
        Authorization: razorpayAuthHeader(),
        "Content-Type": "application/json",
      },
      body: JSON.stringify({
        amount: amountPaise,
        currency: "INR",
        receipt: order_id,
        payment_capture: 0, // manual capture — see header comment
        notes: { quickmed_order_id: order_id, firebase_uid: uid },
      }),
    });

    if (!rzpRes.ok) {
      const detail = await rzpRes.text();
      console.error("razorpay order create failed", rzpRes.status, detail);
      return json({ error: "payment provider rejected the request" }, 502);
    }

    const rzpOrder = await rzpRes.json();

    const { error: insertError } = await admin.from("payments").insert({
      order_id,
      user_id: uid,
      provider: "razorpay",
      provider_order_id: rzpOrder.id,
      amount_paise: amountPaise,
      currency: "INR",
      status: "created",
    });

    if (insertError) {
      console.error("payments insert failed", insertError);
      return json({ error: "could not record the payment" }, 500);
    }

    return json({
      provider_order_id: rzpOrder.id,
      amount_paise: amountPaise,
      key_id: RAZORPAY_KEY_ID,
    });
  } catch (err) {
    console.error(err);
    return json({ error: "unexpected error" }, 500);
  }
});
