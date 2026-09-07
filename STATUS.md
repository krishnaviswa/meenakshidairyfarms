# Build status

Plan: `can-this-be-in-partitioned-aurora.md`

## Done

### Phase 0 — shared foundations
- `README.md`, `.gitignore`, monorepo folders; legacy site moved to `legacy/`.
- `shared/BRAND.md` — colour + type tokens (from the old CSS).
- `shared/schema/order.schema.json` — canonical order shape (web + app + backend agree).
- `shared/i18n/{en,hi,ta}.json` — full trilingual copy: nav, marketing pages,
  order form, account, SEO. Translated, not machine output.
- `shared/scripts/json-to-arb.mjs` — turns the i18n JSON into Flutter `.arb`.
- `supabase/migrations/0001_init.sql` — products, profiles, addresses,
  subscriptions (+ items + skips), orders, deliveries, payments, staff; full RLS;
  `create_order()` RPC (only write open to anon); `generate_deliveries()` +
  a pg_cron line to schedule it.
- `supabase/seed.sql` — products + `site_settings` (⚠ placeholder prices/number).
- `supabase/functions/on-order-created/` — Edge Function: emails the farm on a new
  order, optional Google-Sheet mirror during cutover.
- `supabase/README.md` — owner setup steps.

### Phase 1 — marketing site (Astro, EN/HI/TA) — built & verified
- `web/` Astro 5 project. `npm run build` → 18 static pages + sitemap + robots.
- Pages: Home, Our Milk, Our Farm, FAQ (all three languages), served at `/`,
  `/hi/…`, `/ta/…`. Real translated HTML in each (good for SEO), `hreflang`
  alternates, canonical URLs, `LocalBusiness` + `FAQPage` JSON-LD.
- Shared header (nav, language switcher, dark-mode toggle), footer with **no phone
  / email / address** — only brand + tagline + a note explaining why.
- Content: Sahiwal + Murrah breed detail, A1/A2/BCM-7 explainer (honest — no
  disease claims), protein/fat/calcium table, farm practices, "good for every
  age". The flyers' "prevents early puberty" line is deliberately left out.
- Verified in the browser: all three languages render, nav + language switch +
  theme toggle work, mobile menu works, no console errors.

### Phase 2 (partial) — order form ported
- `web/src/pages/order.astro` — the old WhatsApp order form rebuilt in Astro:
  steppers, live estimate, validation, `wa.me` deep link, confirmation panel,
  UPI QR (hidden until a real VPA is set), "recent orders" from `localStorage`.
- `web/src/lib/qr.js` + `order.js` — QR generator and order model, ported.
- Verified: filling the form produces a schema-correct order object and opens
  the WhatsApp link.

## Needs the owner (blocks the rest)

1. **Real per-litre prices** (site had ₹85/₹90; flyers disagree) → `supabase/seed.sql` + `web/src/data/products.ts`.
2. **The one WhatsApp number** (code `919791836836` vs flyer `9087282939`).
3. **Real UPI VPA + payee name**.
4. **Supabase project** (free) — create it, share URL + anon key + a DB password.
5. **SMS provider** (MSG91 or Twilio) for phone-OTP login — or start on email OTP.
6. **Domain** + static host (Netlify / Cloudflare Pages).
7. **Farm photos?** — decides photography vs the current illustration/texture look.
8. Keep the Google Sheet running in parallel for ~1 month? (assumed yes)

## Next (after the above)

- **Phase 2 rest**: wire `order.astro` to call Supabase `create_order`; build
  `account.astro` (phone-OTP login, subscription create/pause/skip/resume,
  deliveries, payments) as a client island on the same Supabase project.
- **Phase 3**: `app/` Flutter — `supabase_flutter`, `go_router`, localisation from
  the shared i18n, same screens as the web account area, realtime sync.
- **Phase 4**: minimal `/admin` page for order/delivery/payment status.

## Run it

```bash
cd web && npm install && npm run dev      # http://localhost:4321  (or 4599 via the app preview)
npm run build                              # static output in web/dist
```
