# Meenakshi Dairy Farms

Marketing website + customer app for a farm selling **A2 milk** from
**Sahiwal cows** and **Murrah buffaloes**, on one shared backend.

## Repo layout

| Path | What |
|---|---|
| `web/` | Astro marketing site — EN / HI / TA. Home, Our Milk, Our Farm, FAQ, Order, Account. Reads local Docker Postgres. |
| `app/` | Flutter customer app (Android / iOS) — same catalog + WhatsApp orders. Download APK/IPA from GitHub Actions artifacts. |
| `supabase/` | Postgres schema, RLS, Edge Functions, seed data — the single source of truth for products, orders, subscriptions. |
| `shared/` | `BRAND.md` design tokens · canonical `i18n/` strings · `schema/order.schema.json` order contract · build scripts. |
| `legacy/` | The original single-page `site/index.html` + `google-sheet-script.gs`, kept for reference during cutover. |

## Guiding rules

- **No personal phone number, email, or home address is rendered anywhere on the
  website.** The WhatsApp number lives only inside the `wa.me` link and in
  `supabase.site_settings`.
- Prices, the WhatsApp number and the UPI ID come from Postgres
  (`products` + `site_settings`) — never hardcoded in a page.
- The website and the Flutter app read and write the **same** Supabase project, so
  a change in one shows in the other.

## Quick start

```bash
# 1. Start local Postgres (new database: meenakshi, port 5433)
docker compose up -d db

# 2. Website
cd web
copy .env.example .env     # Windows: already points at localhost:5433
npm install
npm run dev                # http://localhost:4321
```

Prices, WhatsApp number and orders live in Postgres. If the database is down, the site still renders with the same fallback prices.

The website and the Flutter app share this **same** database when the API is reachable.

```bash
# 3. Flutter app
cd app && flutter pub get && flutter run
```

Phone installers: GitHub → Actions → **Android APK** or **iOS IPA** → Artifacts. Android APK installs directly. The iOS IPA is unsigned and needs AltStore / Sideloadly or an Apple Ad Hoc profile.
