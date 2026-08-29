# QuickMed — Feature Build Plan

Category-wise medicines, search, prescription review, place order, track order,
online payment, order history.

Model: **single pharmacy**. Customer uploads a prescription, in-house doctors
review it, the pharmacy hands stock to a delivery agent, agent delivers.

---

## 1. The blocker: your schema cannot store a Firebase user

| Column | Type today | Firebase gives |
|---|---|---|
| `users.id` | `uuid` | `BBE1OzLJG9cos6003X9jVYYahzJ3` — 28-char base62 |
| `orders.user_id` | `uuid` | same |
| `addresses.user_id` | `uuid` | same |

`auth.jwt() ->> 'sub'` returns text that will never cast to `uuid`. Every RLS
policy and the `place_order` RPC fail at the type level. Separately, the app
queries `profiles` while the database has `users` — *that* is the PGRST205
404, not a missing table.

**Every table has 0 rows**, so this is one migration today and a data migration
with live orders later. Fix it first.

`supabase/migrations/001_reconcile_firebase_identity.sql` renames `users` ->
`profiles`, retypes the owner columns to `text`, adds the columns
`UserProfile` already expects (`kota_area`, `address_detail`), and adds the
foreign keys that could not previously exist because the types disagreed.

### Also true right now

- Every table is readable with the anon publishable key — RLS is off. Harmless
  while empty; a PII breach once `orders` and `addresses` hold real data.
  `003_rls.sql` closes it. Run before seeding.
- Every medicine in the app comes from `_localFallbackMedicines` in
  `medicine_service.dart`, not Supabase. The `#QM1021..#QM1024` order history
  is likewise hardcoded in `profile_screen.dart`.
- `live_tracking_repository.dart` queries `active_deliveries`, which does not
  exist. Your real tables are `order_delivery` + `delivery_agents`.
  `002_features.sql` adds a **view** named `active_deliveries` aliasing
  `current_lat/current_lng` to `last_latitude/last_longitude`, so the existing
  Dart keeps working untouched.

---

## 2. Migrations — run in order

```
supabase/migrations/001_reconcile_firebase_identity.sql
supabase/migrations/002_features.sql
supabase/migrations/003_rls.sql
```

`002` adds `categories` (+ `medicines.category_id`), the order-status
lifecycle, `prescriptions`, `payments`, a `profiles.role` flag for your
doctors, and the `active_deliveries` view.

Order lifecycle encoded as a CHECK constraint:

```
placed -> awaiting_rx -> under_review -> approved -> preparing
       -> assigned -> out_for_delivery -> delivered
       (rejected | cancelled)
```

Then, still required from the auth work: register Firebase as a Supabase
third-party auth provider (Authentication -> Sign In / Providers -> Third Party
Auth -> Firebase, project `quickmed-fb84a`). Without it every authenticated
query returns `PGRST301` no matter how correct the policies are.

---

## 3. Payment provider — recommendation

**Razorpay.** Reasons specific to your stack and flow:

- Official, maintained Flutter plugin (`razorpay_flutter`).
- UPI, cards, netbanking, wallets — UPI is non-negotiable for Indian users.
- Plain REST, so a Supabase Edge Function (Deno) integrates with no SDK.
- **Authorise-then-capture**, which matters more than anything else here:
  your doctors review *before* dispatch. Authorise at checkout, capture only
  on `approved`, void on `rejected`. Without it you take money and then run
  refunds for every rejected prescription.

Alternatives: Cashfree is comparable and slightly cheaper. PhonePe PG is
UPI-strong but the Flutter SDK is weaker. Stripe is a poor fit for Indian
domestic payments under current RBI rules — skip it.

**Start KYC today.** Online pharmacy is a *restricted category* for Indian
gateways: expect to supply your drug licence (Form 20/21) and possibly a
separate underwriting review. Test keys work instantly, so build against test
mode — but live approval is measured in days-to-weeks, not hours, and it is
the one item on this list you cannot compress by working harder.

---

## 4. Prompts

Run in order; each assumes the previous landed.

### Prompt 0 — Seed the catalogue

```
Seed the QuickMed Supabase catalogue.

State: migrations 001-003 have run. `medicines`, `salts`, `pharmacies` exist
and are EMPTY. `categories` has 6 rows. Single-pharmacy model.

Schema (real):
  medicines(id uuid pk, name text, salt_id uuid, manufacturer text,
            mrp numeric, discounted_price numeric, stock_qty int4,
            prescription_required bool, pharmacy_id uuid,
            category_id uuid, created_at timestamptz)
  salts(id uuid pk, name text, created_at)
  pharmacies(id uuid pk, name text, address text, city text, created_at)

Source of truth for shape: `_localFallbackMedicines` in
lib/services/medicine_service.dart — real UUIDs, MRP, discounted price,
manufacturer, salt_id.

Tasks:
1. Write ONE idempotent file `supabase/seed/001_catalogue.sql`:
   - one pharmacy row (the single pharmacy), used as every medicine's pharmacy_id
   - all salts referenced by any medicine's salt_id
   - every medicine from _localFallbackMedicines, preserving their exact UUIDs
   - enough additional realistic Indian medicines that EACH of the 6 categories
     has 4-5 entries, with sensible mrp/discounted_price/stock_qty
   - set prescription_required = true on a realistic subset (antibiotics etc.)
2. Use `insert ... on conflict (id) do nothing` throughout so re-runs are safe.
3. Output the file only. Do NOT execute it against the database.

Constraints: no Dart changes in this prompt.
```

### Prompt 1 — Category-wise medicines

```
Show medicines grouped by category on the landing/home screen, from Supabase.

Existing: lib/services/medicine_service.dart (has `.from('medicines').select()`
plus the `_localFallbackMedicines` constant), lib/models/medicine_model.dart
(`Medicine.fromJson` maps name/salt_id/manufacturer/mrp/discounted_price/
prescription_required), lib/blocs/home_bloc/, lib/blocs/landing_screen_bloc/,
lib/screens/landing_screen.dart, lib/screens/home_screen.dart.

Tasks:
1. `Category` model (id, slug, name, iconAsset, sortOrder).
2. Extend MedicineService:
   - fetchCategories()
   - fetchCatalogue() -> Map<Category, List<Medicine>>, ONE query using
     PostgREST embedding (`select=*,categories(*)`), grouped client-side.
     Do not issue one query per category.
   - Add `stockQty` and `categoryId` to the Medicine model.
3. Extend the EXISTING home BLoC with a CatalogueLoaded state — do not add a
   parallel state-management system.
4. Horizontally-scrolling row per category, "See all" per row.
5. Keep the fallback list for offline, but debugPrint loudly when it is used —
   we mistook fallback data for live data once already.
6. Show an out-of-stock treatment when stock_qty <= 0.

Constraints: colours/spacing/type from AppColors, AppTheme, AppSpacing only —
no raw Color literals, no inline GoogleFonts. flutter analyze must stay clean.
Do not touch lib/features/auth/repository/ or lib/features/auth/bloc/.
```

### Prompt 2 — Search

```
Implement medicine search with Postgres full-text search.

Existing: lib/screens/search_screen.dart (UI shell).

Tasks:
1. Migration `supabase/migrations/004_search.sql`:
   - generated tsvector column on medicines over name + manufacturer,
     plus the joined salt name
   - GIN index
   - enable pg_trgm and add a trigram index on medicines.name for typo tolerance
   - function `search_medicines(q text, limit_count int default 20)`
     returning ranked rows; STABLE, SECURITY INVOKER so RLS still applies
2. MedicineService.searchMedicines(String query) calling the RPC.
3. Debounce 300ms in the cubit/BLoC, not the widget. Cancel in-flight requests
   when a newer query arrives.
4. Explicit states: idle/empty query, searching, no results, error — each with
   a real empty-state widget, not a bare spinner.

Constraints: theme tokens only; flutter analyze clean; no new dependencies.
```

### Prompt 3 — Cart, prescription upload, place order

```
Implement cart, prescription upload, and order placement.

Existing: lib/screens/cart/ (cart_screen, cart_item_card, quantity_selector).
Tables: orders, order_items(order_id, medicine_id composite PK, quantity,
price_at_order), prescriptions, addresses.

Tasks:
1. Cart is LOCAL only — a CartCubit persisted with hydrated_bloc (already in
   pubspec). No cart table.
2. Supabase Storage bucket `prescriptions`, private, with policies allowing a
   user to upload to `{uid}/...` and read only their own; staff read all.
3. Migration `005_place_order.sql` — RPC `place_order(items jsonb, address_id uuid)`:
   - SECURITY DEFINER, caller = auth.jwt() ->> 'sub'
   - re-reads each medicine's discounted_price and stock_qty SERVER-SIDE.
     Never trust a price or total sent by the client.
   - fails if any item is out of stock
   - sets requires_prescription = true if any item has prescription_required
   - initial status: 'awaiting_rx' when a prescription is required, else 'placed'
   - inserts orders + order_items in one transaction, decrements stock_qty
   - returns the new order id and the server-computed total
   RLS grants clients no INSERT on orders/order_items — the RPC is the only path.
4. OrderService.placeOrder(...) calling the RPC; wire the checkout button.
5. If requires_prescription: prompt upload (camera or gallery), insert a
   `prescriptions` row, move the order to 'under_review'.
6. Handle: empty cart, out of stock, no address on file, upload failure,
   network failure.

Constraints: theme tokens only; flutter analyze clean.
```

### Prompt 4 — Order history

```
Replace the hardcoded order history with real data.

lib/screens/profile/profile_screen.dart currently renders a HARDCODED list
(#QM1021..#QM1024, all "Paracetamol 650mg, Vitamin C, Zinc Syrup", Rs 349.00,
28 Jun 2026). None of it is real.

Tasks:
1. Order and OrderItem models matching the real schema (orders.total_amount,
   order_items.price_at_order, composite PK order_id+medicine_id).
2. OrderService.fetchOrders() — orders with embedded order_items and medicine
   names in one query, newest first, paginated 20 at a time.
3. OrdersCubit with loading / loaded / empty / error states.
4. Replace the hardcoded list; real empty state for a user with no orders.
5. Order detail view: items, quantities, price_at_order, status timeline,
   delivery address, prescription status if applicable.
6. Human-readable status labels for all 10 lifecycle states.

Constraints: theme tokens only; flutter analyze clean. The "Order History"
heading colour was just fixed — do not reintroduce AppColors.primary as a
foreground colour on white (it is a pale mint tint, ~1.15:1 on white).
```

### Prompt 5 — Doctor prescription review

```
Build the in-house prescription review queue.

Context: profiles.role is one of customer|doctor|admin. RLS already lets staff
read all prescriptions and orders, and update prescriptions.

Tasks:
1. Route `/review`, visible only when the signed-in profile has role
   doctor or admin. Hide it entirely for customers.
2. Queue of prescriptions with status pending_review, oldest first, showing
   the order's items and the uploaded image (signed URL from the private
   bucket — never a public URL).
3. Approve / reject with notes. Approving sets prescriptions.status='approved',
   reviewed_by, reviewed_at, and moves the order to 'approved'. Rejecting sets
   'rejected' on both.
4. Do this transactionally in an RPC, not two client round-trips.
5. Approving must also trigger payment capture (see Prompt 7) — leave a clearly
   marked integration point.

Constraints: theme tokens only; flutter analyze clean.
```

### Prompt 6 — Order tracking

```
Implement order tracking.

Existing: lib/screens/tracking/live_tracking_screen.dart,
lib/services/live_tracking_repository.dart (already selects last_latitude,
last_longitude from `active_deliveries` by order_id),
lib/blocs/live_tracking_cubit/.

`active_deliveries` is now a VIEW over order_delivery + delivery_agents with
those exact column aliases, so the repository should work unchanged — verify.

Tasks:
1. Status timeline driven by orders.status across the 10 lifecycle states.
2. Supabase Realtime subscription on the order row so status changes push;
   do not poll.
3. Show agent name/phone/vehicle once assigned (RLS exposes them only while
   that agent is delivering this user's order).
4. No rider app exists yet, so add a DEBUG-ONLY simulator that advances an
   order preparing -> assigned -> out_for_delivery -> delivered on a timer,
   and interpolates agent coordinates, so the flow is demonstrable.
5. Handle: no delivery record yet, delivered/cancelled orders, Realtime drop
   and reconnect.

Constraints: theme tokens only; flutter analyze clean; simulator must be
compiled out of release builds (kDebugMode).
```

### Prompt 7 — Razorpay, authorise-then-capture

```
Integrate Razorpay in TEST MODE, using authorise-then-capture.

Why capture is deferred: doctors review prescriptions before dispatch. Money is
authorised at checkout and captured only once the order reaches 'approved';
a rejected prescription voids the authorisation instead of triggering a refund.

Tasks:
1. Add `razorpay_flutter`. This is the one prompt where a new dependency is
   expected.
2. Edge Function `create-razorpay-order`:
   - verifies the caller owns the order
   - computes amount_paise SERVER-SIDE from orders.total_amount
   - creates a Razorpay order with payment_capture = 0 (manual capture)
   - inserts a payments row, status 'created'
   - returns provider_order_id
   The Razorpay key_secret NEVER reaches the Flutter app — Supabase secrets only.
3. Client opens checkout with the returned provider_order_id.
4. Edge Function `razorpay-webhook`:
   - verifies the HMAC signature before trusting anything
   - authorized -> payments.status='authorized'
   - captured  -> 'captured'
   - failed    -> 'failed', order back to a payable state
   The webhook is the sole source of truth. A client callback must never mark
   an order paid.
5. Edge Function `capture-payment`, called when a doctor approves: captures the
   authorisation, sets payments.status='captured', order -> 'preparing'.
   On rejection, void the authorisation and set 'voided'.
6. Handle: user cancels, payment fails, webhook arrives before the client
   callback, duplicate webhooks (idempotency on provider_payment_id).

Constraints: test keys only, never committed. flutter analyze clean.
```

---

## 5. Sequencing

Migrations 001-003, then Firebase third-party auth, then Prompt 0. Nothing
below that line works until an authenticated user resolves through
`auth.jwt() ->> 'sub'`.

Prompts 0-2 give you a browsable, searchable catalogue with real data — the
biggest visible change per hour. Prompts 3-4 give a working order. Prompt 5
is small but gates dispatch. Prompt 6 is demonstrable with the simulator.

Prompt 7 is the one that cannot finish today, and not for engineering reasons:
Razorpay live keys need KYC on a restricted category. Build against test mode,
treat go-live as a separate milestone, and start the KYC paperwork now so it
runs in parallel with everything else.
