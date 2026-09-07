-- Seed data for Meenakshi Dairy Farms.
--
-- ⚠ PRICES AND SETTINGS BELOW ARE PLACEHOLDERS — confirm with the owner:
--   * legacy site/index.html used ₹85 (cow) / ₹90 (buffalo)
--   * flyer A showed ₹80 / ₹90 ; flyer B showed ₹70 / ₹80
--   * legacy code WhatsApp number: 919791836836 ; flyer number: 9087282939
--   * legacy UPI VPA was a placeholder ("abc123@icici")

insert into products (key, name_en, name_hi, name_ta,
                      breed_en, breed_hi, breed_ta,
                      price_per_litre, sort)
values
  ('cow',
   'A2 Cow Milk',       'A2 गाय का दूध',   'A2 பசும் பால்',
   'Sahiwal breed',     'साहीवाल नस्ल',     'சிவால் இனம்',
   85.00, 1),
  ('buffalo',
   'A2 Buffalo Milk',   'A2 भैंस का दूध',  'A2 எருமை பால்',
   'Murrah breed',      'मुर्रा नस्ल',      'முர்ரா இனம்',
   90.00, 2)
on conflict (key) do update set
  name_en = excluded.name_en, name_hi = excluded.name_hi, name_ta = excluded.name_ta,
  breed_en = excluded.breed_en, breed_hi = excluded.breed_hi, breed_ta = excluded.breed_ta,
  price_per_litre = excluded.price_per_litre, sort = excluded.sort, updated_at = now();

insert into site_settings (key, value) values
  ('wa_number', '919791836836'),
  ('upi_vpa',   ''),
  ('upi_name',  'Meenakshi Dairy Farms'),
  ('google_sheet_url', '')
on conflict (key) do nothing;
