# Supabase — the shared backend

Single source of truth for products, prices, orders, subscriptions, deliveries and
payments. The website (`web/`) and the Flutter app (`app/`) both connect to **this
same project**.

## One-time setup (owner)

1. Create a project at <https://supabase.com> (free tier is enough to start).
2. Install the CLI and link:
   ```bash
   npm i -g supabase        # or: npx supabase ...
   supabase login
   supabase link --project-ref <your-project-ref>
   ```
3. Apply the schema and seed:
   ```bash
   supabase db push                       # runs migrations/0001_init.sql
   psql "$SUPABASE_DB_URL" -f supabase/seed.sql   # or paste seed.sql in the SQL editor
   ```
   *(No Docker locally? Paste `migrations/0001_init.sql` then `seed.sql` straight
   into Dashboard ▸ SQL Editor.)*
4. **Auth ▸ Providers ▸ Phone** — enable, and connect an SMS provider
   (MSG91 or Twilio). Until then, enable **Email** OTP so login works.
5. **Database ▸ Extensions** — enable `pg_cron`, then run the two commented lines
   at the bottom of `0001_init.sql` to schedule `generate_deliveries`.
6. **Edge Functions**
   ```bash
   supabase functions deploy on-order-created
   ```
   Set secrets: `NOTIFY_EMAIL`, `RESEND_API_KEY`, `RESEND_FROM`, and (optional)
   `GOOGLE_SHEET_URL` = the legacy Apps Script `/exec` URL for parallel logging.
   Then Dashboard ▸ Database ▸ Webhooks ▸ create one on `orders` / INSERT →
   Edge Function `on-order-created`.
7. Fill real values in `site_settings` (`wa_number`, `upi_vpa`, `upi_name`).
8. Make yourself staff:
   ```sql
   insert into staff (profile_id) select id from auth.users where phone = '<your number>';
   ```

## Keys the clients need

| Where | Key |
|---|---|
| `web/.env` | `PUBLIC_SUPABASE_URL`, `PUBLIC_SUPABASE_ANON_KEY` |
| `app/lib/config.dart` | same URL + anon key |

The anon key is safe to ship — RLS is what protects the data.

## Files

| File | Purpose |
|---|---|
| `migrations/0001_init.sql` | tables, RLS, `create_order()` RPC, `generate_deliveries()` |
| `seed.sql` | products + `site_settings` (⚠ placeholder prices/number) |
| `functions/on-order-created/` | emails the farm on a new order; optional Sheet mirror |
