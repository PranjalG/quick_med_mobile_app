-- 007 — Private storage bucket for prescription images.
--
-- Images are keyed by folder: `{firebase_uid}/{order_id}-{ts}.jpg`. The
-- policies below compare that first path segment to the JWT `sub` claim, so a
-- customer can only ever write into, and read from, their own folder.
--
-- The bucket is NOT public. Viewing goes through a short-lived signed URL.

begin;

insert into storage.buckets (id, name, public, file_size_limit, allowed_mime_types)
values (
  'prescriptions',
  'prescriptions',
  false,
  10 * 1024 * 1024,                                  -- 10 MB
  array['image/jpeg', 'image/jpg', 'image/png', 'image/webp']
)
on conflict (id) do update
  set public             = excluded.public,
      file_size_limit    = excluded.file_size_limit,
      allowed_mime_types = excluded.allowed_mime_types;

drop policy if exists prescriptions_insert_own on storage.objects;
drop policy if exists prescriptions_select_own on storage.objects;
drop policy if exists prescriptions_update_own on storage.objects;
drop policy if exists prescriptions_staff_read on storage.objects;

-- A customer may upload only into their own folder.
create policy prescriptions_insert_own on storage.objects
  for insert to authenticated
  with check (
    bucket_id = 'prescriptions'
    and (storage.foldername(name))[1] = (auth.jwt() ->> 'sub')
  );

-- ...and read only their own.
create policy prescriptions_select_own on storage.objects
  for select to authenticated
  using (
    bucket_id = 'prescriptions'
    and (storage.foldername(name))[1] = (auth.jwt() ->> 'sub')
  );

-- Re-uploading over a rejected prescription.
create policy prescriptions_update_own on storage.objects
  for update to authenticated
  using (
    bucket_id = 'prescriptions'
    and (storage.foldername(name))[1] = (auth.jwt() ->> 'sub')
  );

-- Reviewing doctors read every prescription.
create policy prescriptions_staff_read on storage.objects
  for select to authenticated
  using (bucket_id = 'prescriptions' and public.is_staff());

commit;
