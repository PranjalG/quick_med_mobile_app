-- 010 — Server-side default delivery address for checkout.
--
-- place_order checks addresses.user_id = auth.jwt() ->> 'sub'. Client-side
-- inserts using FirebaseAuth.instance.currentUser.uid can drift from the JWT
-- sub (stale token, legacy rows), which surfaces as SQLSTATE 42501. This RPC
-- always keys off the same JWT claim as place_order.

begin;

create or replace function public.ensure_delivery_address()
returns uuid
language plpgsql
security definer
set search_path = public
as $$
declare
  uid          text := auth.jwt() ->> 'sub';
  addr_id      uuid;
  detail        text;
  area          text;
  resolved_line text;
begin
  if uid is null then
    raise exception 'not authenticated' using errcode = '28000';
  end if;

  select a.id
    into addr_id
    from public.addresses a
   where a.user_id = uid
   order by a.created_at asc
   limit 1;

  select p.address_detail, p.kota_area
    into detail, area
    from public.profiles p
   where p.id = uid;

  detail := coalesce(trim(detail), '');
  area := coalesce(trim(area), '');
  resolved_line := array_to_string(
    array_remove(array[detail, area], ''),
    ', '
  );

  if addr_id is not null then
    if resolved_line <> '' then
      update public.addresses
         set full_address = resolved_line,
             label = coalesce(label, 'Home')
       where id = addr_id and user_id = uid;
    end if;
    return addr_id;
  end if;

  if resolved_line = '' then
    raise exception 'add a delivery address to your profile before ordering'
      using errcode = '22023';
  end if;

  insert into public.addresses (user_id, label, full_address)
  values (uid, 'Home', resolved_line)
  returning id into addr_id;

  return addr_id;
end;
$$;

revoke all on function public.ensure_delivery_address() from public, anon;
grant execute on function public.ensure_delivery_address() to authenticated;

commit;
