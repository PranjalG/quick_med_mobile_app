-- 009 — Prescription review by in-house doctors.
--
-- Approving must move BOTH the prescription and its order, together. Doing it
-- as two client round-trips risks an approved prescription attached to an
-- order still sitting in under_review — so it is one transactional RPC.
--
-- Payment capture hooks in at the marked point: money is authorised at
-- checkout and captured only here, once a doctor approves.

begin;

create or replace function public.review_prescription(
  prescription_id uuid,
  approve boolean,
  notes text default null
)
returns table (order_id uuid, order_status text, prescription_status text)
language plpgsql
security definer
set search_path = public
as $$
declare
  uid       text := auth.jwt() ->> 'sub';
  rx        record;
  new_rx    text;
  new_order text;
begin
  if uid is null then
    raise exception 'not authenticated' using errcode = '28000';
  end if;

  if not public.is_staff() then
    raise exception 'only doctors may review prescriptions' using errcode = '42501';
  end if;

  select p.id, p.order_id, p.status
    into rx
    from public.prescriptions p
   where p.id = review_prescription.prescription_id
   for update;

  if not found then
    raise exception 'prescription % not found', review_prescription.prescription_id
      using errcode = '23503';
  end if;

  if rx.status <> 'pending_review' then
    raise exception 'prescription already %', rx.status using errcode = '23505';
  end if;

  new_rx    := case when approve then 'approved' else 'rejected' end;
  new_order := case when approve then 'approved' else 'rejected' end;

  update public.prescriptions
     set status       = new_rx,
         reviewed_by  = uid,
         reviewed_at  = now(),
         review_notes = notes
   where id = rx.id;

  update public.orders
     set status     = new_order,
         updated_at = now()
   where id = rx.order_id;

  -- PAYMENT INTEGRATION POINT (Prompt 7):
  --   approve -> capture the Razorpay authorisation, then set 'preparing'
  --   reject  -> void the authorisation
  -- Left out here so review works before payments exist.

  return query select rx.order_id, new_order, new_rx;
end;
$$;

revoke all on function public.review_prescription(uuid, boolean, text) from public, anon;
grant execute on function public.review_prescription(uuid, boolean, text) to authenticated;

-- Staff need to read the queue with its order and medicine names attached.
drop policy if exists prescriptions_select on public.prescriptions;
create policy prescriptions_select on public.prescriptions
  for select using (user_id = public.current_uid() or public.is_staff());

commit;
