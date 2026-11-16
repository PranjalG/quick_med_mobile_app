-- 005 — Categorise pre-existing medicines, and report what else predates the seed.
--
-- WHY: `medicines`, `pharmacies` and `salts` already held rows created
-- 2026-06-28. RLS was enabled on them with no anon policy, so an anon-key
-- probe returned zero rows — indistinguishable from an empty table. The seed's
-- `on conflict (id) do nothing` therefore skipped the four pre-existing
-- medicines (Dolo 650, Calpol 650, Cetrizine Generic, Pantocid 40), leaving
-- their category_id NULL and hiding them from the catalogue screen.

begin;

-- 1. Any uncategorised medicine goes to General Medicine. ------------------
update public.medicines m
set category_id = (select id from public.categories where slug = 'general_medicine')
where m.category_id is null;

-- 2. Report the result. ----------------------------------------------------
do $$
declare
  uncategorised int;
  total         int;
begin
  select count(*) into uncategorised from public.medicines where category_id is null;
  select count(*) into total         from public.medicines;
  raise notice 'medicines: % total, % still uncategorised', total, uncategorised;
end $$;

commit;

-- 3. What else predates the seed? Read-only; check the output. -------------
select 'medicines'  as tbl, count(*) filter (where created_at < '2026-08-29') as pre_existing,
                            count(*) as total from public.medicines
union all
select 'pharmacies', count(*) filter (where created_at < '2026-08-29'), count(*) from public.pharmacies
union all
select 'salts',      count(*) filter (where created_at < '2026-08-29'), count(*) from public.salts
union all
select 'profiles',   count(*), count(*) from public.profiles
union all
select 'orders',     count(*), count(*) from public.orders
union all
select 'addresses',  count(*), count(*) from public.addresses;
