-- Seed 001 — catalogue for the single QuickMed pharmacy.
--
-- Idempotent: safe to re-run. Requires migrations 001-003 first (needs
-- medicines.category_id and the six category rows).
--
-- Categories match the six tiles already hardcoded on landing_screen.dart,
-- so the screen looks unchanged once it becomes data-driven.
--
-- The four medicines carrying explicit UUIDs are the ones referenced by
-- `_localFallbackMedicines` in lib/services/medicine_service.dart — keeping
-- their ids identical means the fallback and the live catalogue agree.

begin;

-- 1. The pharmacy ----------------------------------------------------------
insert into public.pharmacies (id, name, address, city) values
  ('d28cf21f-6baa-5562-9ff4-db7ddfe0c00b', 'QuickMed Pharmacy', 'Talwandi, Kota', 'Kota')
on conflict (id) do nothing;

-- 2. Salts -----------------------------------------------------------------
insert into public.salts (id, name) values
  ('240eef85-dd97-440d-891d-88b8b4aab5f5', 'Paracetamol'),
  ('0d07351a-7fe8-4645-a536-11075e091309', 'Cetirizine'),
  ('cf7c25c7-1897-477a-bab1-07d5379cdd53', 'Pantoprazole'),
  ('8b753625-a9a4-5ceb-a760-7458791471a9', 'Amoxicillin + Clavulanic Acid'),
  ('ffd3e349-b074-5eac-a3fb-1e72203466be', 'Cetyl Alcohol + Glycerin'),
  ('c4e32e93-2c64-568e-b2a5-7c8145551a84', 'Clotrimazole'),
  ('412c62f8-447f-53d3-a7e8-f12e38720ae8', 'Betamethasone + Neomycin'),
  ('e488bc17-c183-57c4-bde6-1a8cc92f1001', 'Urea + Lactic Acid'),
  ('8719aa5d-e3df-506e-af94-957e6b20ecac', 'Neem + Turmeric Extract'),
  ('18a26f2a-9836-5103-8990-f247ce1c0fa8', 'Ginseng + Multivitamin'),
  ('8de4f30f-cadc-5dec-b779-92aa2681b74f', 'Calcium + Vitamin D3'),
  ('5600a418-6596-566c-bc52-d2eb95775031', 'Multivitamin + Zinc'),
  ('0dfec1f7-806c-5aa3-aae0-b593ff573e38', 'Vitamin B-Complex'),
  ('f6f2e73f-abf4-5714-b262-368415ab56b9', 'Whey Protein Isolate'),
  ('de1d692d-5caf-58ff-8552-5ca10eb4b117', 'Baby Emollient Blend'),
  ('1e25ccf2-cbdd-5e16-b3e1-e5d99616885d', 'Infant Milk Formula'),
  ('5a9345f8-8403-5a90-8b80-927cf86e94cf', 'Herbal Digestive Blend'),
  ('26ec1242-0157-5af5-ba79-aff13f7c54a6', 'Absorbent Polymer Core'),
  ('6e9b699c-5846-5123-8df3-4b6f8595afc2', 'Benzocaine Lubricant'),
  ('78846688-a42e-5fca-94fe-88c3bd1a00a5', 'Natural Rubber Latex'),
  ('d01ffc02-f3ac-5ee8-b27a-0f35be896d12', 'Levonorgestrel'),
  ('775b7a95-3d71-5956-8845-641297ee7128', 'hCG Immunoassay Strip'),
  ('ff796885-b533-5c64-a380-4e6918c285f7', 'Lactic Acid + Tea Tree Oil'),
  ('6e02d8e2-e9f1-54fd-8877-d2a688f380f9', 'Praziquantel + Pyrantel'),
  ('c41ed6d1-ab09-5e41-86a0-d31f9f330fde', 'Herbal Antimicrobial Blend'),
  ('d545c12b-0e84-54fc-9da1-2e5c864c15ef', 'Balanced Canine Nutrition'),
  ('b920bf72-8193-5a78-a3ab-6471925900f9', 'Fipronil'),
  ('e4c0483b-5546-5093-8977-d2218de956c0', 'Feline Vitamin Complex')
on conflict (id) do nothing;

-- 3. Medicines -------------------------------------------------------------
-- Betnovate-N is seeded at stock_qty = 0 on purpose, to exercise the
-- out-of-stock path in the UI.
insert into public.medicines
  (id, name, salt_id, manufacturer, mrp, discounted_price, stock_qty,
   prescription_required, pharmacy_id, category_id) values
  ('c6e1de97-9dcd-42e3-b859-cb03aa2a0469', 'Dolo 650', '240eef85-dd97-440d-891d-88b8b4aab5f5', 'Micro Labs', 36.00, 32.00, 240, false, 'd28cf21f-6baa-5562-9ff4-db7ddfe0c00b',
   (select id from public.categories where slug = 'general_medicine')),
  ('b9cff14d-9161-4044-a12c-3e814e0a57fb', 'Calpol 650', '240eef85-dd97-440d-891d-88b8b4aab5f5', 'GSK', 30.00, 27.00, 200, false, 'd28cf21f-6baa-5562-9ff4-db7ddfe0c00b',
   (select id from public.categories where slug = 'general_medicine')),
  ('bb490884-6a68-493c-9a74-81851207a184', 'Cetrizine Generic', '0d07351a-7fe8-4645-a536-11075e091309', 'Local Pharma', 15.00, 12.00, 300, false, 'd28cf21f-6baa-5562-9ff4-db7ddfe0c00b',
   (select id from public.categories where slug = 'general_medicine')),
  ('483852cf-2962-4b6e-b800-bad280b86571', 'Pantocid 40', 'cf7c25c7-1897-477a-bab1-07d5379cdd53', 'Sun Pharma', 85.00, 78.00, 90, true, 'd28cf21f-6baa-5562-9ff4-db7ddfe0c00b',
   (select id from public.categories where slug = 'general_medicine')),
  ('afa2f2fb-2643-540c-bfd1-137ec26ab232', 'Augmentin 625 Duo', '8b753625-a9a4-5ceb-a760-7458791471a9', 'GSK', 205.00, 185.00, 48, true, 'd28cf21f-6baa-5562-9ff4-db7ddfe0c00b',
   (select id from public.categories where slug = 'general_medicine')),
  ('429d0bf2-8f8d-5699-9cf9-352196d9301c', 'Cetaphil Gentle Skin Cleanser 125ml', 'ffd3e349-b074-5eac-a3fb-1e72203466be', 'Galderma', 399.00, 359.00, 40, false, 'd28cf21f-6baa-5562-9ff4-db7ddfe0c00b',
   (select id from public.categories where slug = 'skincare')),
  ('f58b0463-e8ab-52a0-a85c-2099ff2c649e', 'Candid Dusting Powder 100g', 'c4e32e93-2c64-568e-b2a5-7c8145551a84', 'Glenmark', 118.00, 105.00, 85, false, 'd28cf21f-6baa-5562-9ff4-db7ddfe0c00b',
   (select id from public.categories where slug = 'skincare')),
  ('53705fb1-cd9f-5427-8722-88ea41d00d33', 'Betnovate-N Cream 20g', '412c62f8-447f-53d3-a7e8-f12e38720ae8', 'GSK', 42.00, 38.00, 0, true, 'd28cf21f-6baa-5562-9ff4-db7ddfe0c00b',
   (select id from public.categories where slug = 'skincare')),
  ('5819a5a3-a80d-54c7-bc3a-56f5890860df', 'Venusia Max Moisturizing Cream 150g', 'e488bc17-c183-57c4-bde6-1a8cc92f1001', 'Dr Reddy''s', 545.00, 489.00, 32, false, 'd28cf21f-6baa-5562-9ff4-db7ddfe0c00b',
   (select id from public.categories where slug = 'skincare')),
  ('b769a723-7d15-5de8-bebe-3dabfef507e2', 'Himalaya Purifying Neem Face Wash 150ml', '8719aa5d-e3df-506e-af94-957e6b20ecac', 'Himalaya', 190.00, 171.00, 96, false, 'd28cf21f-6baa-5562-9ff4-db7ddfe0c00b',
   (select id from public.categories where slug = 'skincare')),
  ('9e15c9b7-96d0-5347-a38d-c36845e50625', 'Revital H Capsules (30)', '18a26f2a-9836-5103-8990-f247ce1c0fa8', 'Sun Pharma', 315.00, 285.00, 70, false, 'd28cf21f-6baa-5562-9ff4-db7ddfe0c00b',
   (select id from public.categories where slug = 'health_nutrition')),
  ('70802693-4df3-5150-ab58-b5d66249c4df', 'Shelcal 500 (15 tabs)', '8de4f30f-cadc-5dec-b779-92aa2681b74f', 'Torrent', 125.00, 112.00, 130, false, 'd28cf21f-6baa-5562-9ff4-db7ddfe0c00b',
   (select id from public.categories where slug = 'health_nutrition')),
  ('3e6688af-e260-5214-b771-c0555a9cfb84', 'Zincovit Tablets (15)', '5600a418-6596-566c-bc52-d2eb95775031', 'Apex Labs', 105.00, 95.00, 145, false, 'd28cf21f-6baa-5562-9ff4-db7ddfe0c00b',
   (select id from public.categories where slug = 'health_nutrition')),
  ('8d2dfd66-73c0-5d8f-b4ef-e8d9fb008589', 'Neurobion Forte (30)', '0dfec1f7-806c-5aa3-aae0-b593ff573e38', 'Merck', 38.00, 34.00, 175, false, 'd28cf21f-6baa-5562-9ff4-db7ddfe0c00b',
   (select id from public.categories where slug = 'health_nutrition')),
  ('8827fe97-71be-508e-8198-a1eda40850c3', 'Optimum Nutrition Whey Protein 1kg', 'f6f2e73f-abf4-5714-b262-368415ab56b9', 'Optimum Nutrition', 3499.00, 3149.00, 12, false, 'd28cf21f-6baa-5562-9ff4-db7ddfe0c00b',
   (select id from public.categories where slug = 'health_nutrition')),
  ('e47972e4-c699-5262-8286-d5e7cfb2d405', 'Himalaya Baby Lotion 400ml', 'de1d692d-5caf-58ff-8552-5ca10eb4b117', 'Himalaya', 310.00, 279.00, 58, false, 'd28cf21f-6baa-5562-9ff4-db7ddfe0c00b',
   (select id from public.categories where slug = 'baby_care')),
  ('849d1a8a-71f8-5e3a-96de-bbfd637933fa', 'Dexolac Infant Formula Stage 1 400g', '1e25ccf2-cbdd-5e16-b3e1-e5d99616885d', 'Danone', 425.00, 389.00, 44, false, 'd28cf21f-6baa-5562-9ff4-db7ddfe0c00b',
   (select id from public.categories where slug = 'baby_care')),
  ('babe26e5-4062-5b2b-ac6f-de52de778203', 'Nan Pro 1 Infant Formula 400g', '1e25ccf2-cbdd-5e16-b3e1-e5d99616885d', 'Nestle', 780.00, 720.00, 26, false, 'd28cf21f-6baa-5562-9ff4-db7ddfe0c00b',
   (select id from public.categories where slug = 'baby_care')),
  ('15ec395d-c674-540b-b460-be65570840e0', 'Bonnisan Drops 30ml', '5a9345f8-8403-5a90-8b80-927cf86e94cf', 'Himalaya', 95.00, 86.00, 110, false, 'd28cf21f-6baa-5562-9ff4-db7ddfe0c00b',
   (select id from public.categories where slug = 'baby_care')),
  ('e70fd806-fbd3-5f78-93d3-96992d97ac87', 'MamyPoko Pants Extra Absorb M (32)', '26ec1242-0157-5af5-ba79-aff13f7c54a6', 'Unicharm', 699.00, 629.00, 38, false, 'd28cf21f-6baa-5562-9ff4-db7ddfe0c00b',
   (select id from public.categories where slug = 'baby_care')),
  ('7434c275-7316-523d-b500-a30337cd8a0d', 'Durex Extra Time Condoms (10)', '6e9b699c-5846-5123-8df3-4b6f8595afc2', 'Reckitt', 290.00, 261.00, 64, false, 'd28cf21f-6baa-5562-9ff4-db7ddfe0c00b',
   (select id from public.categories where slug = 'sexual_wellness')),
  ('e7bf9a8e-f600-5e4c-83b0-956d75abda5c', 'Manforce Condoms Chocolate (10)', '78846688-a42e-5fca-94fe-88c3bd1a00a5', 'Mankind', 150.00, 135.00, 88, false, 'd28cf21f-6baa-5562-9ff4-db7ddfe0c00b',
   (select id from public.categories where slug = 'sexual_wellness')),
  ('5b609f3d-2941-5a7c-9d0e-97e533e43d3f', 'i-Pill Emergency Contraceptive', 'd01ffc02-f3ac-5ee8-b27a-0f35be896d12', 'Piramal', 110.00, 99.00, 52, false, 'd28cf21f-6baa-5562-9ff4-db7ddfe0c00b',
   (select id from public.categories where slug = 'sexual_wellness')),
  ('bad2f630-2cd1-581b-9a4e-99a5249151b7', 'Prega News Pregnancy Test Kit', '775b7a95-3d71-5956-8845-641297ee7128', 'Mankind', 55.00, 50.00, 120, false, 'd28cf21f-6baa-5562-9ff4-db7ddfe0c00b',
   (select id from public.categories where slug = 'sexual_wellness')),
  ('6ed16dc9-f46e-5f51-bbbf-65cc51b713ee', 'Fourex Intimate Wash 100ml', 'ff796885-b533-5c64-a380-4e6918c285f7', 'Wet & Dry', 185.00, 166.00, 45, false, 'd28cf21f-6baa-5562-9ff4-db7ddfe0c00b',
   (select id from public.categories where slug = 'sexual_wellness')),
  ('64ac4fc5-fafd-5588-bb9b-bbe60fea277c', 'Drontal Plus Dewormer for Dogs (10)', '6e02d8e2-e9f1-54fd-8877-d2a688f380f9', 'Bayer', 450.00, 405.00, 30, false, 'd28cf21f-6baa-5562-9ff4-db7ddfe0c00b',
   (select id from public.categories where slug = 'pet_care')),
  ('8d0baf48-ebcc-52ec-b72d-b2abe1ecef38', 'Himalaya Erina EP Pet Shampoo 200ml', 'c41ed6d1-ab09-5e41-86a0-d31f9f330fde', 'Himalaya', 245.00, 220.00, 42, false, 'd28cf21f-6baa-5562-9ff4-db7ddfe0c00b',
   (select id from public.categories where slug = 'pet_care')),
  ('376c5892-8a74-5fb1-95ca-ca67a8d4843c', 'Pedigree Adult Dry Dog Food 1.2kg', 'd545c12b-0e84-54fc-9da1-2e5c864c15ef', 'Mars Petcare', 330.00, 297.00, 55, false, 'd28cf21f-6baa-5562-9ff4-db7ddfe0c00b',
   (select id from public.categories where slug = 'pet_care')),
  ('5f8a27d5-bbd5-5bcf-8974-b80b9f5d37f4', 'Sky-EC Pet Tick & Flea Spray 100ml', 'b920bf72-8193-5a78-a3ab-6471925900f9', 'Skyec', 390.00, 351.00, 28, false, 'd28cf21f-6baa-5562-9ff4-db7ddfe0c00b',
   (select id from public.categories where slug = 'pet_care')),
  ('ac69dd4e-4321-5e2f-89ae-21150bbc8cdd', 'Beaphar Cat Multivitamin Paste 100g', 'e4c0483b-5546-5093-8977-d2218de956c0', 'Beaphar', 520.00, 468.00, 18, false, 'd28cf21f-6baa-5562-9ff4-db7ddfe0c00b',
   (select id from public.categories where slug = 'pet_care'))
on conflict (id) do nothing;

commit;
