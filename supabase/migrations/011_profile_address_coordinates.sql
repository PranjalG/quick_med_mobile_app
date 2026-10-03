-- 011 — GPS coordinates on profile + delivery addresses.

begin;

alter table public.profiles
  add column if not exists address_latitude  double precision,
  add column if not exists address_longitude double precision;

alter table public.addresses
  add column if not exists latitude  double precision,
  add column if not exists longitude double precision;

create or replace function public.ensure_delivery_address()
returns uuid
language plpgsql
security definer
set search_path = public
as $$
declare
  uid           text := auth.jwt() ->> 'sub';
  addr_id       uuid;
  detail        text;
  area          text;
  resolved_line text;
  lat           double precision;
  lng           double precision;
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

  select p.address_detail,
         p.kota_area,
         p.address_latitude,
         p.address_longitude
    into detail, area, lat, lng
    from public.profiles p
   where p.id = uid;

  detail := coalesce(trim(detail), '');
  area := coalesce(trim(area), '');
  resolved_line := array_to_string(
    array_remove(array[detail, area], ''),
    ', '
  );

  if addr_id is not null then
    if resolved_line <> '' or lat is not null or lng is not null then
      update public.addresses
         set full_address = case
               when resolved_line <> '' then resolved_line
               else full_address
             end,
             label = coalesce(label, 'Home'),
             latitude = lat,
             longitude = lng
       where id = addr_id and user_id = uid;
    end if;
    return addr_id;
  end if;

  if resolved_line = '' then
    raise exception 'add a delivery address to your profile before ordering'
      using errcode = '22023';
  end if;

  if lat is null or lng is null then
    raise exception 'add delivery location coordinates to your profile before ordering'
      using errcode = '22023';
  end if;

  insert into public.addresses (user_id, label, full_address, latitude, longitude)
  values (uid, 'Home', resolved_line, lat, lng)
  returning id into addr_id;

  return addr_id;
end;
$$;

revoke all on function public.ensure_delivery_address() from public, anon;
grant execute on function public.ensure_delivery_address() to authenticated;

commit;
