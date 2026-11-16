-- 004 — Full-text + fuzzy medicine search.
-- Run after 002 (needs medicines.category_id) and 003 (RLS).

begin;

create extension if not exists pg_trgm;

-- Weighted search document. Cannot include the salt name: a generated column
-- may only reference its own row, and salt lives in another table. The RPC
-- joins salts instead.
alter table public.medicines
  add column if not exists search_doc tsvector
  generated always as (
    setweight(to_tsvector('simple', coalesce(name, '')), 'A') ||
    setweight(to_tsvector('simple', coalesce(manufacturer, '')), 'B')
  ) stored;

create index if not exists medicines_search_doc_idx
  on public.medicines using gin (search_doc);

-- Trigram index for typo tolerance ("paracetmol" -> "Paracetamol").
create index if not exists medicines_name_trgm_idx
  on public.medicines using gin (name gin_trgm_ops);

-- SECURITY INVOKER so the catalogue's RLS still applies to the caller.
create or replace function public.search_medicines(
  q text,
  limit_count int default 20
)
returns setof public.medicines
language sql
stable
security invoker
set search_path = public
as $$
  select m.*
  from public.medicines m
  left join public.salts s on s.id = m.salt_id
  where
    length(btrim(coalesce(q, ''))) > 0
    and (
      m.search_doc @@ websearch_to_tsquery('simple', q)
      or m.name ilike '%' || q || '%'
      or m.manufacturer ilike '%' || q || '%'
      or s.name ilike '%' || q || '%'
      or similarity(m.name, q) > 0.25
    )
  order by
    ts_rank(m.search_doc, websearch_to_tsquery('simple', q)) desc,
    similarity(m.name, q) desc,
    m.name asc
  limit greatest(1, least(coalesce(limit_count, 20), 100));
$$;

grant execute on function public.search_medicines(text, int) to anon, authenticated;

commit;
