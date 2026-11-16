-- 003 — Row Level Security.
--
-- Currently every table is readable with the anon publishable key. That is
-- harmless while they are empty and becomes a PII breach the moment real
-- orders and addresses exist. Run this BEFORE seeding.
--
-- Firebase identity arrives in the JWT `sub` claim.

begin;

create or replace function public.current_uid() returns text
language sql stable as $$ select auth.jwt() ->> 'sub' $$;

create or replace function public.is_staff() returns boolean
language sql stable security definer set search_path = public as $$
  select exists (
    select 1 from public.profiles
    where id = auth.jwt() ->> 'sub' and role in ('doctor','admin')
  )
$$;

-- 1. Public catalogue: read-only to everyone, writable only by service role.
alter table public.medicines  enable row level security;
alter table public.categories enable row level security;
alter table public.pharmacies enable row level security;
alter table public.salts      enable row level security;

drop policy if exists medicines_read  on public.medicines;
drop policy if exists categories_read on public.categories;
drop policy if exists pharmacies_read on public.pharmacies;
drop policy if exists salts_read      on public.salts;

create policy medicines_read  on public.medicines  for select using (true);
create policy categories_read on public.categories for select using (true);
create policy pharmacies_read on public.pharmacies for select using (true);
create policy salts_read      on public.salts      for select using (true);

-- 2. Profiles --------------------------------------------------------------
alter table public.profiles enable row level security;

create policy profiles_select_own on public.profiles
  for select using (id = public.current_uid() or public.is_staff());
create policy profiles_insert_own on public.profiles
  for insert with check (id = public.current_uid());
create policy profiles_update_own on public.profiles
  for update using (id = public.current_uid())
              with check (id = public.current_uid());

-- 3. Addresses -------------------------------------------------------------
alter table public.addresses enable row level security;

create policy addresses_own on public.addresses
  for all using (user_id = public.current_uid())
          with check (user_id = public.current_uid());

-- 4. Orders ----------------------------------------------------------------
-- No client INSERT/UPDATE: orders are created by the place_order RPC and
-- advanced by staff/webhooks, so totals and status cannot be forged.
alter table public.orders enable row level security;

create policy orders_select_own on public.orders
  for select using (user_id = public.current_uid() or public.is_staff());
create policy orders_update_staff on public.orders
  for update using (public.is_staff()) with check (public.is_staff());

-- 5. Order items -----------------------------------------------------------
alter table public.order_items enable row level security;

create policy order_items_select on public.order_items
  for select using (
    exists (
      select 1 from public.orders o
      where o.id = order_items.order_id
        and (o.user_id = public.current_uid() or public.is_staff())
    )
  );

-- 6. Prescriptions ---------------------------------------------------------
alter table public.prescriptions enable row level security;

create policy prescriptions_select on public.prescriptions
  for select using (user_id = public.current_uid() or public.is_staff());
create policy prescriptions_insert_own on public.prescriptions
  for insert with check (user_id = public.current_uid());
create policy prescriptions_review_staff on public.prescriptions
  for update using (public.is_staff()) with check (public.is_staff());

-- 7. Payments --------------------------------------------------------------
-- Read-only to the owner. All writes go through the Edge Functions using the
-- service role key, so a client can never mark its own order paid.
alter table public.payments enable row level security;

create policy payments_select_own on public.payments
  for select using (user_id = public.current_uid() or public.is_staff());

-- 8. Delivery --------------------------------------------------------------
alter table public.order_delivery   enable row level security;
alter table public.delivery_agents  enable row level security;

create policy order_delivery_select on public.order_delivery
  for select using (
    exists (
      select 1 from public.orders o
      where o.id = order_delivery.order_id
        and (o.user_id = public.current_uid() or public.is_staff())
    )
  );

-- Agent contact details are visible only while delivering that user's order.
create policy delivery_agents_select on public.delivery_agents
  for select using (
    exists (
      select 1
      from public.order_delivery od
      join public.orders o on o.id = od.order_id
      where od.agent_id = delivery_agents.id
        and (o.user_id = public.current_uid() or public.is_staff())
    )
  );

commit;
