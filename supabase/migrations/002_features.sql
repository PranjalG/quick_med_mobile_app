-- 002 — Categories, prescription review, payments, delivery view.
-- Run after 001.

begin;

-- 1. Categories ------------------------------------------------------------
create table if not exists public.categories (
  id         uuid primary key default gen_random_uuid(),
  slug       text unique not null,
  name       text not null,
  icon_asset text,
  sort_order int  not null default 0,
  created_at timestamptz not null default now()
);

alter table public.medicines
  add column if not exists category_id uuid references public.categories(id);

create index if not exists medicines_category_idx on public.medicines(category_id);

insert into public.categories (slug, name, icon_asset, sort_order) values
  ('skincare',          'Skincare',          'assets/icons/skincare.svg',         1),
  ('health_nutrition',  'Health & Nutrition','assets/icons/fitness.svg',          2),
  ('baby_care',         'Baby Care',         'assets/icons/baby_care.svg',        3),
  ('general_medicine',  'General Medicine',  'assets/icons/capsules.svg',         4),
  ('sexual_wellness',   'Sexual Wellness',   'assets/icons/sexual_wellness.svg',  5),
  ('pet_care',          'Pet Care',          'assets/icons/pet_care.svg',         6)
on conflict (slug) do nothing;

-- 2. Order lifecycle -------------------------------------------------------
-- Matches the real flow: customer orders -> doctors review any prescription
-- -> pharmacy prepares -> agent delivers.
alter table public.orders
  alter column status set default 'placed',
  add column if not exists requires_prescription boolean not null default false,
  add column if not exists updated_at timestamptz not null default now();

alter table public.orders
  drop constraint if exists orders_status_check;
alter table public.orders
  add constraint orders_status_check check (status in (
    'placed',            -- created, awaiting payment authorisation
    'awaiting_rx',       -- Rx item present, customer must upload
    'under_review',      -- doctors reviewing the uploaded prescription
    'approved',          -- doctors cleared it; safe to capture payment
    'rejected',          -- doctors refused; refund/void authorisation
    'preparing',         -- pharmacy assembling the order
    'assigned',          -- handed to a delivery agent
    'out_for_delivery',
    'delivered',
    'cancelled'
  ));

-- 3. Prescriptions ---------------------------------------------------------
create table if not exists public.prescriptions (
  id           uuid primary key default gen_random_uuid(),
  user_id      text not null references public.profiles(id) on delete cascade,
  order_id     uuid references public.orders(id) on delete cascade,
  storage_path text not null,           -- object path in the `prescriptions` bucket
  status       text not null default 'pending_review'
               check (status in ('pending_review','approved','rejected')),
  reviewed_by  text,                    -- reviewing doctor's profile id
  review_notes text,
  reviewed_at  timestamptz,
  created_at   timestamptz not null default now()
);
create index if not exists prescriptions_order_idx on public.prescriptions(order_id);
create index if not exists prescriptions_status_idx on public.prescriptions(status);

-- Staff flag so doctors can read the review queue without a separate system.
alter table public.profiles
  add column if not exists role text not null default 'customer'
  check (role in ('customer','doctor','admin'));

-- 4. Payments --------------------------------------------------------------
create table if not exists public.payments (
  id                  uuid primary key default gen_random_uuid(),
  order_id            uuid not null references public.orders(id) on delete cascade,
  user_id             text not null references public.profiles(id),
  provider            text not null default 'razorpay',
  provider_order_id   text,
  provider_payment_id text,
  amount_paise        bigint not null check (amount_paise > 0),
  currency            text not null default 'INR',
  status              text not null default 'created'
                      check (status in ('created','authorized','captured','failed','refunded','voided')),
  created_at          timestamptz not null default now(),
  updated_at          timestamptz not null default now()
);
create index if not exists payments_order_idx on public.payments(order_id);
create unique index if not exists payments_provider_order_idx
  on public.payments(provider_order_id) where provider_order_id is not null;

-- 5. active_deliveries view ------------------------------------------------
-- lib/services/live_tracking_repository.dart already selects
-- `last_latitude, last_longitude` from `active_deliveries` filtered by
-- order_id. Your real tables are order_delivery + delivery_agents, so expose
-- a view with the column names the existing code expects — no Dart change.
create or replace view public.active_deliveries
with (security_invoker = true) as
select
  od.order_id,
  da.id           as agent_id,
  da.name         as rider_name,
  da.phone        as rider_phone,
  da.vehicle_type as vehicle_type,
  da.current_lat  as last_latitude,
  da.current_lng  as last_longitude,
  o.status        as status
from public.order_delivery od
join public.delivery_agents da on da.id = od.agent_id
join public.orders o           on o.id  = od.order_id;

commit;
