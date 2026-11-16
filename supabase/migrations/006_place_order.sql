-- 006 — place_order RPC.
--
-- The ONLY path that may create an order. RLS grants clients no INSERT on
-- orders or order_items, so a client cannot forge a total, a price, or a
-- status. Prices and stock are re-read here, server-side; anything the client
-- sends about money is ignored.
--
-- items shape: [{"medicine_id": "<uuid>", "quantity": 2}, ...]

begin;

create or replace function public.place_order(
  items jsonb,
  address_id uuid
)
returns table (order_id uuid, total numeric, status text)
language plpgsql
security definer
set search_path = public
as $$
declare
  uid          text := auth.jwt() ->> 'sub';
  new_order_id uuid;
  running_total numeric(12,2) := 0;
  needs_rx     boolean := false;
  new_status   text;
  item         jsonb;
  med          record;
  qty          int;
begin
  if uid is null then
    raise exception 'not authenticated' using errcode = '28000';
  end if;

  if items is null or jsonb_typeof(items) <> 'array' or jsonb_array_length(items) = 0 then
    raise exception 'cart is empty' using errcode = '22023';
  end if;

  -- The address must exist and belong to the caller.
  if not exists (
    select 1 from public.addresses a
    where a.id = place_order.address_id and a.user_id = uid
  ) then
    raise exception 'address % does not belong to the caller', place_order.address_id
      using errcode = '42501';
  end if;

  insert into public.orders (user_id, address_id, status, total_amount)
  values (uid, place_order.address_id, 'placed', 0)
  returning id into new_order_id;

  for item in select * from jsonb_array_elements(items)
  loop
    qty := coalesce((item ->> 'quantity')::int, 0);
    if qty <= 0 then
      raise exception 'quantity must be positive' using errcode = '22023';
    end if;

    -- FOR UPDATE: serialises concurrent checkouts of the same medicine so two
    -- buyers cannot both pass the stock check on the last unit.
    select m.id, m.name, m.discounted_price, m.mrp, m.stock_qty,
           m.prescription_required
      into med
      from public.medicines m
     where m.id = (item ->> 'medicine_id')::uuid
     for update;

    if not found then
      raise exception 'medicine % not found', item ->> 'medicine_id'
        using errcode = '23503';
    end if;

    if coalesce(med.stock_qty, 0) < qty then
      raise exception '% is out of stock (% left, % requested)',
        med.name, coalesce(med.stock_qty, 0), qty using errcode = '23514';
    end if;

    -- Server-side price. Whatever the client thought the price was is ignored.
    insert into public.order_items (order_id, medicine_id, quantity, price_at_order)
    values (new_order_id, med.id, qty, coalesce(med.discounted_price, med.mrp))
    on conflict (order_id, medicine_id)
    do update set quantity = public.order_items.quantity + excluded.quantity;

    update public.medicines
       set stock_qty = stock_qty - qty
     where id = med.id;

    running_total := running_total + (coalesce(med.discounted_price, med.mrp) * qty);
    needs_rx := needs_rx or coalesce(med.prescription_required, false);
  end loop;

  -- An Rx item parks the order until a prescription is uploaded and reviewed.
  new_status := case when needs_rx then 'awaiting_rx' else 'placed' end;

  update public.orders
     set total_amount = running_total,
         requires_prescription = needs_rx,
         status = new_status,
         updated_at = now()
   where id = new_order_id;

  return query select new_order_id, running_total, new_status;
end;
$$;

revoke all on function public.place_order(jsonb, uuid) from public, anon;
grant execute on function public.place_order(jsonb, uuid) to authenticated;

commit;
