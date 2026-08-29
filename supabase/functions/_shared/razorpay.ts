// Shared Razorpay helpers.
//
// The key SECRET never leaves the server. It lives in Supabase secrets and is
// read from the environment here; it must never be shipped in the Flutter app.

export const RAZORPAY_KEY_ID = Deno.env.get("RAZORPAY_KEY_ID") ?? "";
export const RAZORPAY_KEY_SECRET = Deno.env.get("RAZORPAY_KEY_SECRET") ?? "";
export const RAZORPAY_WEBHOOK_SECRET =
  Deno.env.get("RAZORPAY_WEBHOOK_SECRET") ?? "";

export function razorpayAuthHeader(): string {
  return "Basic " + btoa(`${RAZORPAY_KEY_ID}:${RAZORPAY_KEY_SECRET}`);
}

/// Verifies a Razorpay webhook signature.
///
/// Uses timingSafeEqual: a plain === leaks, through response timing, how much
/// of a forged signature was correct, which is enough to forge one.
export async function verifyWebhookSignature(
  rawBody: string,
  signature: string,
): Promise<boolean> {
  if (!RAZORPAY_WEBHOOK_SECRET || !signature) return false;

  const key = await crypto.subtle.importKey(
    "raw",
    new TextEncoder().encode(RAZORPAY_WEBHOOK_SECRET),
    { name: "HMAC", hash: "SHA-256" },
    false,
    ["sign"],
  );
  const mac = await crypto.subtle.sign(
    "HMAC",
    key,
    new TextEncoder().encode(rawBody),
  );
  const expected = [...new Uint8Array(mac)]
    .map((b) => b.toString(16).padStart(2, "0"))
    .join("");

  if (expected.length !== signature.length) return false;
  let diff = 0;
  for (let i = 0; i < expected.length; i++) {
    diff |= expected.charCodeAt(i) ^ signature.charCodeAt(i);
  }
  return diff === 0;
}

/// Firebase UID from the caller's JWT.
///
/// Signature verification is Supabase's job — the request only reaches this
/// function with a token it already accepted, via the third-party auth
/// provider registration.
export function subjectFromAuthHeader(header: string | null): string | null {
  if (!header?.startsWith("Bearer ")) return null;
  try {
    const payload = header.slice(7).split(".")[1];
    const json = atob(payload.replace(/-/g, "+").replace(/_/g, "/"));
    return JSON.parse(json).sub ?? null;
  } catch {
    return null;
  }
}

export const corsHeaders = {
  "Access-Control-Allow-Origin": "*",
  "Access-Control-Allow-Headers":
    "authorization, x-client-info, apikey, content-type",
};
