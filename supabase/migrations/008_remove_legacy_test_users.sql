-- 008 — Remove the two pre-Firebase test users.
--
-- IRREVERSIBLE. Read before running.
--
-- These two profiles date from 2026-06-28 (identical timestamps — bulk seeded)
-- and belonged to Supabase Auth, via the users_id_fkey -> auth.users that
-- migration 001 dropped:
--
--   45d88730-db6a-4c2e-bca4-870eff50ab63  Pranjal Gaur  8949377630
--   15c2f6a4-6c48-46c3-b828-76f42f46ed84  Jaya Hada     7728883245
--
-- Their ids are uuid-shaped text. Firebase issues 28-char base62 ids, so
-- `auth.jwt() ->> 'sub'` can never match them: under RLS these rows are
-- invisible to every signed-in user, including their original owners. They
-- are inert either way — deleting is housekeeping, not a fix.
--
-- Delete order matters: orders_user_fk is ON DELETE RESTRICT, so orders must
-- go before profiles. addresses and order_items cascade on their own.

begin;

-- Delete their orders first (order_items and order_delivery cascade).
delete from public.orders
where user_id in (
  '45d88730-db6a-4c2e-bca4-870eff50ab63',
  '15c2f6a4-6c48-46c3-b828-76f42f46ed84'
);

-- Then the profiles (addresses cascade).
delete from public.profiles
where id in (
  '45d88730-db6a-4c2e-bca4-870eff50ab63',
  '15c2f6a4-6c48-46c3-b828-76f42f46ed84'
);

do $$
declare p int; o int; a int;
begin
  select count(*) into p from public.profiles;
  select count(*) into o from public.orders;
  select count(*) into a from public.addresses;
  raise notice 'remaining — profiles: %, orders: %, addresses: %', p, o, a;
end $$;

commit;
