-- Phone-OTP accounts + billing. No Postgres roles/RLS here — auth is enforced
-- in the Astro API layer (web/src/lib/auth.ts), same as the rest of this schema.

create table users (
  id            uuid primary key default gen_random_uuid(),
  phone         text not null unique,
  name          text,
  created_at    timestamptz not null default now(),
  last_login_at timestamptz
);

create table otp_codes (
  id          uuid primary key default gen_random_uuid(),
  phone       text not null,
  code        text not null,
  purpose     text not null default 'login' check (purpose in ('login')),
  expires_at  timestamptz not null,
  consumed_at timestamptz,
  attempts    int not null default 0,
  created_at  timestamptz not null default now()
);

create index otp_codes_phone_idx on otp_codes (phone, created_at desc);

alter table orders add column user_id uuid references users(id) on delete set null;
create index orders_user_idx on orders (user_id);

create table payments (
  id                uuid primary key default gen_random_uuid(),
  user_id           uuid not null references users(id) on delete cascade,
  order_id          uuid references orders(id) on delete set null,
  amount            numeric(10,2) not null check (amount >= 0),
  status            text not null default 'due' check (status in ('due', 'paid_self_reported')),
  self_reported_at  timestamptz,
  verified_by       uuid references users(id), -- reserved for a future staff-verification step
  verified_at       timestamptz,                -- reserved for a future staff-verification step
  created_at        timestamptz not null default now()
);

create index payments_user_idx on payments (user_id);
create index payments_order_idx on payments (order_id);
