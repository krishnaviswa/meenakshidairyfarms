-- Meenakshi Dairy Farms — initial schema
-- Products & site settings are world-readable. Everything tied to a customer is
-- locked to that customer by RLS (profile_id = auth.uid()). Farm staff are listed
-- in `staff` and bypass the per-customer policies.

create extension if not exists pgcrypto;

-- ---------------------------------------------------------------------------
-- reference data (public read)
-- ---------------------------------------------------------------------------

create table products (
  id              uuid primary key default gen_random_uuid(),
  key             text not null unique check (key in ('cow', 'buffalo')),
  name_en         text not null,
  name_hi         text not null,
  name_ta         text not null,
  breed_en        text not null,
  breed_hi        text not null,
  breed_ta        text not null,
  price_per_litre numeric(6,2) not null check (price_per_litre >= 0),
  unit            text not null default 'litre',
  active          boolean not null default true,
  sort            int not null default 0,
  updated_at      timestamptz not null default now()
);

create table site_settings (
  key   text primary key,
  value text not null
);
comment on table site_settings is
  'wa_number (digits, country code, no +), upi_vpa, upi_name, google_sheet_url (optional, cutover only)';

-- ---------------------------------------------------------------------------
-- people
-- ---------------------------------------------------------------------------

create table profiles (
  id         uuid primary key references auth.users(id) on delete cascade,
  name       text,
  phone      text,
  created_at timestamptz not null default now()
);

create table staff (
  profile_id uuid primary key references profiles(id) on delete cascade,
  role       text not null default 'admin' check (role in ('admin', 'delivery'))
);

create table addresses (
  id         uuid primary key default gen_random_uuid(),
  profile_id uuid not null references profiles(id) on delete cascade,
  line1      text not null,
  area       text default '',
  pincode    text default '',
  label      text default 'Home',
  is_default boolean not null default false,
  created_at timestamptz not null default now()
);
create index addresses_profile_idx on addresses(profile_id);

-- ---------------------------------------------------------------------------
-- subscriptions
-- ---------------------------------------------------------------------------

create table subscriptions (
  id         uuid primary key default gen_random_uuid(),
  profile_id uuid not null references profiles(id) on delete cascade,
  address_id uuid references addresses(id) on delete set null,
  status     text not null default 'active' check (status in ('active', 'paused', 'cancelled')),
  frequency  text not null default 'daily' check (frequency in ('daily', 'alt', 'once')),
  start_date date not null default current_date,
  pause_from date,
  pause_to   date,
  created_at timestamptz not null default now(),
  updated_at timestamptz not null default now()
);
create index subscriptions_profile_idx on subscriptions(profile_id);

create table subscription_items (
  id              uuid primary key default gen_random_uuid(),
  subscription_id uuid not null references subscriptions(id) on delete cascade,
  product_id      uuid not null references products(id),
  litres          numeric(5,2) not null check (litres > 0),
  unique (subscription_id, product_id)
);

create table subscription_skips (
  id              uuid primary key default gen_random_uuid(),
  subscription_id uuid not null references subscriptions(id) on delete cascade,
  skip_date       date not null,
  unique (subscription_id, skip_date)
);

-- ---------------------------------------------------------------------------
-- orders (one-time + a snapshot of every subscription start; also WhatsApp)
-- ---------------------------------------------------------------------------

create table orders (
  id            uuid primary key default gen_random_uuid(),
  ref           text not null unique,
  profile_id    uuid references profiles(id) on delete set null,
  name          text not null,
  phone         text not null,
  address_line1 text not null,
  area          text default '',
  pincode       text default '',
  items         jsonb not null,
  total         numeric(8,2) not null,
  frequency     text not null check (frequency in ('daily', 'alt', 'once')),
  start_date    date,
  notes         text default '',
  channel       text not null check (channel in ('web', 'app', 'whatsapp')),
  language      text not null default 'en' check (language in ('en', 'hi', 'ta')),
  status        text not null default 'pending'
                check (status in ('pending', 'confirmed', 'delivered', 'cancelled')),
  created_at    timestamptz not null default now()
);
create index orders_profile_idx on orders(profile_id);
create index orders_created_idx on orders(created_at desc);

-- ---------------------------------------------------------------------------
-- deliveries (materialised nightly from active subscriptions)
-- ---------------------------------------------------------------------------

create table deliveries (
  id              uuid primary key default gen_random_uuid(),
  subscription_id uuid not null references subscriptions(id) on delete cascade,
  profile_id      uuid not null references profiles(id) on delete cascade,
  delivery_date   date not null,
  planned         jsonb not null,          -- [{key, litres, price_per_litre, amount}]
  amount          numeric(8,2) not null,
  status          text not null default 'planned'
                  check (status in ('planned', 'delivered', 'skipped')),
  delivered_at    timestamptz,
  unique (subscription_id, delivery_date)
);
create index deliveries_profile_date_idx on deliveries(profile_id, delivery_date desc);

-- ---------------------------------------------------------------------------
-- payments (monthly; farm marks paid — manual UPI for now)
-- ---------------------------------------------------------------------------

create table payments (
  id         uuid primary key default gen_random_uuid(),
  profile_id uuid not null references profiles(id) on delete cascade,
  period     text not null,               -- 'YYYY-MM'
  amount     numeric(10,2) not null,
  method     text not null default 'upi' check (method in ('upi', 'cash')),
  status     text not null default 'due' check (status in ('due', 'paid')),
  upi_ref    text,
  marked_by  uuid references profiles(id),
  created_at timestamptz not null default now(),
  unique (profile_id, period)
);
create index payments_profile_idx on payments(profile_id);

-- ---------------------------------------------------------------------------
-- helpers
-- ---------------------------------------------------------------------------

create or replace function is_staff()
returns boolean
language sql stable security definer set search_path = public
as $$ select exists (select 1 from staff where profile_id = auth.uid()) $$;

-- create a profile row automatically on signup
create or replace function handle_new_user()
returns trigger language plpgsql security definer set search_path = public
as $$
begin
  insert into profiles (id, phone) values (new.id, new.phone)
  on conflict (id) do nothing;
  return new;
end $$;

create trigger on_auth_user_created
  after insert on auth.users
  for each row execute function handle_new_user();

-- ---------------------------------------------------------------------------
-- create_order RPC — the only write path open to anonymous visitors
-- ---------------------------------------------------------------------------

create or replace function create_order(payload jsonb)
returns text
language plpgsql security definer set search_path = public
as $$
declare
  v_ref   text := payload->>'ref';
  v_items jsonb := payload->'items';
  v_total numeric;
begin
  if v_ref is null or v_ref !~ '^MDF-[0-9]{6}-[A-Z0-9]{4}$' then
    raise exception 'bad ref';
  end if;
  if v_items is null or jsonb_array_length(v_items) = 0 then
    raise exception 'no items';
  end if;

  -- recompute the total from current product prices; never trust the client's
  select coalesce(sum(
           round((i->>'litres')::numeric * p.price_per_litre)
         ), 0)
    into v_total
  from jsonb_array_elements(v_items) i
  join products p on p.key = i->>'key';

  insert into orders (ref, profile_id, name, phone, address_line1, area, pincode,
                      items, total, frequency, start_date, notes, channel, language)
  values (
    v_ref,
    auth.uid(),
    payload->>'name',
    payload->>'phone',
    payload->>'address_line1',
    coalesce(payload->>'area', ''),
    coalesce(payload->>'pincode', ''),
    v_items,
    v_total,
    payload->>'frequency',
    nullif(payload->>'start_date', '')::date,
    coalesce(payload->>'notes', ''),
    coalesce(payload->>'channel', 'web'),
    coalesce(payload->>'language', 'en')
  );

  return v_ref;
end $$;

revoke all on function create_order(jsonb) from public;
grant execute on function create_order(jsonb) to anon, authenticated;

-- ---------------------------------------------------------------------------
-- generate_deliveries — nightly materialisation of the next day's deliveries
-- ---------------------------------------------------------------------------

create or replace function generate_deliveries(target_date date default (current_date + 1))
returns int
language plpgsql security definer set search_path = public
as $$
declare
  v_count int := 0;
  s record;
  v_planned jsonb;
  v_amount numeric;
begin
  for s in
    select sub.id, sub.profile_id, sub.frequency, sub.start_date
    from subscriptions sub
    where sub.status = 'active'
      and sub.frequency in ('daily', 'alt')
      and sub.start_date <= target_date
      and not (target_date between coalesce(sub.pause_from, 'infinity'::date)
                               and coalesce(sub.pause_to,  '-infinity'::date))
      and not exists (
        select 1 from subscription_skips k
        where k.subscription_id = sub.id and k.skip_date = target_date
      )
  loop
    -- alternate-day: only on an even offset from start_date
    if s.frequency = 'alt'
       and ((target_date - s.start_date) % 2) <> 0 then
      continue;
    end if;

    select jsonb_agg(jsonb_build_object(
             'key', p.key,
             'litres', si.litres,
             'price_per_litre', p.price_per_litre,
             'amount', round(si.litres * p.price_per_litre))),
           coalesce(sum(round(si.litres * p.price_per_litre)), 0)
      into v_planned, v_amount
    from subscription_items si
    join products p on p.id = si.product_id
    where si.subscription_id = s.id;

    if v_planned is null then
      continue;
    end if;

    insert into deliveries (subscription_id, profile_id, delivery_date, planned, amount)
    values (s.id, s.profile_id, target_date, v_planned, v_amount)
    on conflict (subscription_id, delivery_date) do nothing;

    v_count := v_count + 1;
  end loop;

  return v_count;
end $$;

-- Schedule it (pg_cron must be enabled for the project — Dashboard ▸ Database ▸
-- Extensions ▸ pg_cron, or: create extension pg_cron;). Runs 20:00 UTC ≈ 01:30 IST.
-- create extension if not exists pg_cron;
-- select cron.schedule('generate-deliveries', '0 20 * * *',
--                      $$ select generate_deliveries(current_date + 1) $$);

-- ---------------------------------------------------------------------------
-- Row Level Security
-- ---------------------------------------------------------------------------

alter table products            enable row level security;
alter table site_settings       enable row level security;
alter table profiles            enable row level security;
alter table staff               enable row level security;
alter table addresses           enable row level security;
alter table subscriptions       enable row level security;
alter table subscription_items  enable row level security;
alter table subscription_skips  enable row level security;
alter table orders              enable row level security;
alter table deliveries          enable row level security;
alter table payments            enable row level security;

-- public reference data
create policy products_read      on products      for select using (true);
create policy settings_read      on site_settings for select using (true);

-- profiles: you, or staff
create policy profiles_self      on profiles for select using (id = auth.uid() or is_staff());
create policy profiles_update    on profiles for update using (id = auth.uid());
create policy staff_read         on staff    for select using (profile_id = auth.uid() or is_staff());

-- addresses
create policy addresses_own      on addresses for all
  using (profile_id = auth.uid() or is_staff())
  with check (profile_id = auth.uid());

-- subscriptions + children
create policy subs_own           on subscriptions for all
  using (profile_id = auth.uid() or is_staff())
  with check (profile_id = auth.uid());

create policy sub_items_own      on subscription_items for all
  using (exists (select 1 from subscriptions s
                 where s.id = subscription_id and (s.profile_id = auth.uid() or is_staff())))
  with check (exists (select 1 from subscriptions s
                 where s.id = subscription_id and s.profile_id = auth.uid()));

create policy sub_skips_own      on subscription_skips for all
  using (exists (select 1 from subscriptions s
                 where s.id = subscription_id and (s.profile_id = auth.uid() or is_staff())))
  with check (exists (select 1 from subscriptions s
                 where s.id = subscription_id and s.profile_id = auth.uid()));

-- orders: customers read their own; nobody writes directly (use create_order);
-- staff can read + update status
create policy orders_read_own    on orders for select using (profile_id = auth.uid() or is_staff());
create policy orders_staff_update on orders for update using (is_staff());

-- deliveries: read your own; staff update status
create policy deliveries_read    on deliveries for select using (profile_id = auth.uid() or is_staff());
create policy deliveries_staff   on deliveries for update using (is_staff());

-- payments: read your own; staff manage
create policy payments_read      on payments for select using (profile_id = auth.uid() or is_staff());
create policy payments_staff     on payments for all using (is_staff()) with check (is_staff());
