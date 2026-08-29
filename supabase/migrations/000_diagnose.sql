-- 000 — Diagnostic only. Changes nothing. Run this and paste the output.
-- Uses pg_catalog rather than information_schema, which hides constraints
-- whose referenced table lives in a schema you don't own (e.g. auth.users).

select
  con.conname                          as constraint_name,
  src_ns.nspname || '.' || src.relname as on_table,
  tgt_ns.nspname || '.' || tgt.relname as references_table,
  pg_get_constraintdef(con.oid)        as definition
from pg_constraint con
join pg_class src         on src.oid = con.conrelid
join pg_namespace src_ns  on src_ns.oid = src.relnamespace
left join pg_class tgt        on tgt.oid = con.confrelid
left join pg_namespace tgt_ns on tgt_ns.oid = tgt.relnamespace
where con.contype = 'f'
  and (src_ns.nspname = 'public' or tgt_ns.nspname = 'public')
order by on_table, constraint_name;
