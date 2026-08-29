// Captures or voids a Razorpay authorisation after a doctor's decision.
//
// Called when review_prescription approves (capture) or rejects (void).
// Staff-only: it moves money.

import { createClient } from "https://esm.sh/@supabase/supabase-js@2";
import {
  corsHeaders,
  razorpayAuthHeader,
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

    const { order_id, action } = await req.json();
    if (!order_id || !["capture", "void"].includes(action)) {
      return json({ error: "order_id and action (capture|void) required" }, 400);
    }

    const admin = createClient(
      Deno.env.get("SUPABASE_URL")!,
      Deno.env.get("SUPABASE_SERVICE_ROLE_KEY")!,
    );

    // Only doctors and admins may move money.
    const { data: profile } = await admin
      .from("profiles")
      .select("role")
      .eq("id", uid)
      .maybeSingle();

    if (!profile || !["doctor", "admin"].includes(profile.role)) {
      return json({ error: "forbidden" }, 403);
    }

    const { data: payment } = await admin
      .from("payments")
      .select("id, provider_payment_id, amount_paise, status")
      .eq("order_id", order_id)
      .in("status", ["authorized"])
      .maybeSingle();

    if (!payment?.provider_payment_id) {
      return json({ error: "no authorised payment for this order" }, 404);
    }

    if (action === "capture") {
      const res = await fetch(
        `https://api.razorpay.com/v1/payments/${payment.provider_payment_id}/capture`,
        {
          method: "POST",
          headers: {
            Authorization: razorpayAuthHeader(),
            "Content-Type": "application/json",
          },
          // Amount is re-sent from OUR record, not from the request.
          body: JSON.stringify({
            amount: payment.amount_paise,
            currency: "INR",
          }),
        },
      );

      if (!res.ok) {
        console.error("capture failed", res.status, await res.text());
        return json({ error: "capture was refused" }, 502);
      }

      await admin
        .from("payments")
        .update({ status: "captured", updated_at: new Date().toISOString() })
        .eq("id", payment.id);

      await admin
        .from("orders")
        .update({ status: "preparing", updated_at: new Date().toISOString() })
        .eq("id", order_id);

      return json({ status: "captured" });
    }

    // Void: an uncaptured Razorpay authorisation is released automatically
    // after ~5 days. Recording it as voided is what makes our books agree.
    await admin
      .from("payments")
      .update({ status: "voided", updated_at: new Date().toISOString() })
      .eq("id", payment.id);

    return json({ status: "voided" });
  } catch (err) {
    console.error(err);
    return json({ error: "unexpected error" }, 500);
  }
});
