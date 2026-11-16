// Razorpay webhook — the SOLE source of truth for payment state.
//
// A client-side success callback is not proof of payment: it can be replayed,
// spoofed, or simply lost when the app is killed mid-redirect. Order state
// moves here, after the HMAC signature verifies, or it does not move.

import { createClient } from "https://esm.sh/@supabase/supabase-js@2";
import { verifyWebhookSignature } from "../_shared/razorpay.ts";

Deno.serve(async (req) => {
  if (req.method !== "POST") {
    return new Response("method not allowed", { status: 405 });
  }

  // Read the RAW body: re-serialising JSON changes the bytes and the HMAC.
  const rawBody = await req.text();
  const signature = req.headers.get("x-razorpay-signature");

  if (!await verifyWebhookSignature(rawBody, signature ?? "")) {
    console.warn("rejected webhook with bad signature");
    return new Response("invalid signature", { status: 401 });
  }

  let event: Record<string, unknown>;
  try {
    event = JSON.parse(rawBody);
  } catch {
    return new Response("bad payload", { status: 400 });
  }

  const admin = createClient(
    Deno.env.get("SUPABASE_URL")!,
    Deno.env.get("SUPABASE_SERVICE_ROLE_KEY")!,
  );

  const kind = event.event as string;
  const entity = (event.payload as any)?.payment?.entity;
  const providerOrderId = entity?.order_id as string | undefined;
  const providerPaymentId = entity?.id as string | undefined;

  if (!providerOrderId) {
    // Not a payment event we handle. 200 so Razorpay stops retrying.
    return new Response("ignored", { status: 200 });
  }

  const nextStatus =
    kind === "payment.authorized"
      ? "authorized"
      : kind === "payment.captured"
      ? "captured"
      : kind === "payment.failed"
      ? "failed"
      : null;

  if (!nextStatus) return new Response("ignored", { status: 200 });

  const { data: payment } = await admin
    .from("payments")
    .select("id, order_id, status")
    .eq("provider_order_id", providerOrderId)
    .maybeSingle();

  if (!payment) {
    console.warn("webhook for unknown provider_order_id", providerOrderId);
    return new Response("unknown order", { status: 200 });
  }

  // Idempotency: Razorpay retries, and events can arrive out of order.
  // Never walk a captured payment backwards to authorized.
  const rank: Record<string, number> = {
    created: 0,
    failed: 1,
    authorized: 2,
    captured: 3,
    refunded: 4,
    voided: 4,
  };
  if ((rank[nextStatus] ?? 0) <= (rank[payment.status] ?? 0)) {
    return new Response("already applied", { status: 200 });
  }

  await admin
    .from("payments")
    .update({
      status: nextStatus,
      provider_payment_id: providerPaymentId,
      updated_at: new Date().toISOString(),
    })
    .eq("id", payment.id);

  // A failed payment returns the order to a payable state. Authorised and
  // captured deliberately do NOT advance the order: a doctor still has to
  // approve any prescription before the pharmacy prepares it.
  if (nextStatus === "failed") {
    await admin
      .from("orders")
      .update({ status: "placed", updated_at: new Date().toISOString() })
      .eq("id", payment.order_id);
  }

  return new Response("ok", { status: 200 });
});
