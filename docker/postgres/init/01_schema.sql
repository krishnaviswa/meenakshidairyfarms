-- Meenakshi Dairy Farms — local Postgres (no Supabase auth).
-- Database `meenakshi` is created by POSTGRES_DB before this file runs.

create extension if not exists pgcrypto;

create table products (
  id                   uuid primary key default gen_random_uuid(),
  key                  text not null unique check (key in ('cow', 'buffalo')),
  name_en              text not null,
  name_hi              text not null,
  name_ta              text not null,
  breed_en             text not null,
  breed_hi             text not null,
  breed_ta             text not null,
  tagline_en           text not null default '',
  tagline_hi           text not null default '',
  tagline_ta           text not null default '',
  bullets              jsonb not null default '{"en":[],"hi":[],"ta":[]}',
  price_per_litre      numeric(6,2) not null check (price_per_litre >= 0),
  price_per_half_litre numeric(6,2) not null check (price_per_half_litre >= 0),
  unit                 text not null default 'litre',
  active               boolean not null default true,
  sort                 int not null default 0,
  updated_at           timestamptz not null default now()
);

create table site_settings (
  key   text primary key,
  value text not null
);

create table usps (
  id      serial primary key,
  sort    int not null default 0,
  title_en text not null,
  title_hi text not null,
  title_ta text not null
);

create table orders (
  id            uuid primary key default gen_random_uuid(),
  ref           text not null unique,
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
  channel       text not null default 'web' check (channel in ('web', 'app', 'whatsapp')),
  language      text not null default 'en' check (language in ('en', 'hi', 'ta')),
  status        text not null default 'pending'
                check (status in ('pending', 'confirmed', 'delivered', 'cancelled')),
  created_at    timestamptz not null default now()
);

create index orders_created_idx on orders (created_at desc);
create index orders_phone_idx on orders (phone);
