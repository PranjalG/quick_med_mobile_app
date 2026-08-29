-- 001 — Reconcile the schema with Firebase authentication.
--
-- WHY: Firebase UIDs are 28-char base62 strings (e.g. BBE1OzLJG9cos6003X9jVYYahzJ3),
-- not UUIDs. Every owner column is `uuid`, so `auth.jwt() ->> 'sub'` can never
-- match one. The app also queries `profiles` while the database has `users` —
-- that mismatch is what returns PGRST205.
--
-- Exactly three foreign keys block the retype (confirmed via pg_catalog):
--
--   users_id_fkey           public.users.id       -> auth.users(id)
--   orders_user_id_fkey     public.orders.user_id -> users(id)
--   addresses_user_id_fkey  public.addresses.user_id -> users(id)
--
-- users_id_fkey is the default Supabase template, tying the profile row to a
-- Supabase Auth user. It is wrong here and could never have been satisfied:
-- you authenticate with Firebase, so your users never exist in auth.users.
--
-- Deliberately NOT touched, because their columns keep type uuid:
--   orders_address_id_fkey, order_items_*, order_delivery_*, medicines_*
--
-- SAFE TO RUN NOW: every affected table has 0 rows. Re-runnable.

begin;

-- 1. Drop only the three blocking FKs. -------------------------------------
-- Matched by column rather than by name, so a differently-named constraint is
-- still caught; scoped to the exact columns being retyped, so unrelated keys
-- (notably order_items -> orders) survive untouched.
do $$
declare r record;
begin
  for r in
    select con.conname as con, ns.nspname as sch, rel.relname as tbl
    from pg_constraint con
    join pg_class rel     on rel.oid = con.conrelid
    join pg_namespace ns  on ns.oid = rel.relnamespace
    where con.contype = 'f'
      and ns.nspname = 'public'
      and (
        (rel.relname in ('users','profiles')
           and 'id' = any (
             select a.attname from pg_attribute a
             where a.attrelid = con.conrelid and a.attnum = any(con.conkey)))
        or (rel.relname in ('orders','addresses')
           and 'user_id' = any (
             select a.attname from pg_attribute a
             where a.attrelid = con.conrelid and a.attnum = any(con.conkey)))
      )
  loop
    execute format('alter table %I.%I drop constraint %I', r.sch, r.tbl, r.con);
    raise notice 'dropped FK % on %.%', r.con, r.sch, r.tbl;
  end loop;
end $$;

-- 2. users -> profiles, Firebase UID as the key ----------------------------
do $$
begin
  if to_regclass('public.users') is not null
     and to_regclass('public.profiles') is null then
    alter table public.users rename to profiles;
  end if;
end $$;

alter table public.profiles
  alter column id drop default,
  alter column id type text using id::text;

alter table public.profiles
  add column if not exists kota_area      text not null default 'Kota',
  add column if not exists address_detail text not null default '',
  add column if not exists updated_at     timestamptz not null default now();

alter table public.profiles
  alter column name  set default '',
  alter column phone set default '',
  alter column email set default '';

-- 3. Owner columns follow the same type ------------------------------------
alter table public.orders    alter column user_id type text using user_id::text;
alter table public.addresses alter column user_id type text using user_id::text;

-- 4. Re-add the two owner FKs, now that the types agree --------------------
-- orders_address_id_fkey is NOT recreated here: it was never dropped.
do $$
begin
  if not exists (select 1 from pg_constraint where conname = 'orders_user_fk') then
    alter table public.orders
      add constraint orders_user_fk
      foreign key (user_id) references public.profiles(id) on delete restrict;
  end if;
  if not exists (select 1 from pg_constraint where conname = 'addresses_user_fk') then
    alter table public.addresses
      add constraint addresses_user_fk
      foreign key (user_id) references public.profiles(id) on delete cascade;
  end if;
end $$;

commit;