-- KrishiSetu Supabase schema (Restoration version)
-- Derived from 001_schema.sql with auth.users registration trigger omitted
-- (profile creation is handled post-auth to prevent signup blocking errors).
-- Run this once in Supabase Dashboard -> SQL Editor.
-- Uses Supabase Auth as the source of truth; never store passwords here.
create extension if not exists pgcrypto;

create table if not exists public.profiles (
  id uuid primary key references auth.users (id) on delete cascade,
  role text not null check (role in ('farmer', 'buyer')),
  full_name text not null default '',
  mobile text not null default '',
  profile jsonb not null default '{}'::jsonb,
  tutorial_completed boolean not null default false,
  created_at timestamptz not null default now(),
  updated_at timestamptz not null default now()
);

create table if not exists public.user_app_state (
  user_id uuid primary key references auth.users (id) on delete cascade,
  state jsonb not null default '{}'::jsonb,
  updated_at timestamptz not null default now()
);

create table if not exists public.crop_lots (
  id uuid primary key default gen_random_uuid (),
  user_id uuid not null references auth.users (id) on delete cascade,
  crop text not null,
  variety text,
  quantity_qtl numeric not null check (quantity_qtl > 0),
  grade text,
  harvest_date date,
  location text,
  metadata jsonb not null default '{}'::jsonb,
  created_at timestamptz not null default now(),
  updated_at timestamptz not null default now()
);

create table if not exists public.offers (
  id uuid primary key default gen_random_uuid (),
  lot_id uuid references public.crop_lots (id) on delete set null,
  buyer_id uuid references auth.users (id) on delete set null,
  seller_id uuid references auth.users (id) on delete set null,
  price_per_qtl numeric not null check (price_per_qtl > 0),
  quantity_qtl numeric not null check (quantity_qtl > 0),
  status text not null default 'pending',
  terms jsonb not null default '{}'::jsonb,
  created_at timestamptz not null default now(),
  updated_at timestamptz not null default now()
);

create table if not exists public.transactions (
  id uuid primary key default gen_random_uuid (),
  offer_id uuid references public.offers (id) on delete set null,
  buyer_id uuid references auth.users (id) on delete set null,
  seller_id uuid references auth.users (id) on delete set null,
  status text not null default 'offer_accepted',
  amount numeric,
  timeline jsonb not null default '[]'::jsonb,
  created_at timestamptz not null default now(),
  updated_at timestamptz not null default now()
);

create table if not exists public.saved_schemes (
  id uuid primary key default gen_random_uuid (),
  user_id uuid not null references auth.users (id) on delete cascade,
  scheme_name text not null,
  notes text,
  application_status text default 'saved',
  created_at timestamptz not null default now(),
  updated_at timestamptz not null default now(),
  unique (user_id, scheme_name)
);

create table if not exists public.support_tickets (
  id uuid primary key default gen_random_uuid (),
  user_id uuid not null references auth.users (id) on delete cascade,
  category text not null,
  subject text not null,
  message text not null,
  status text not null default 'open',
  created_at timestamptz not null default now(),
  updated_at timestamptz not null default now()
);

create table if not exists public.market_price_snapshots (
  id uuid primary key default gen_random_uuid (),
  crop text not null,
  state text,
  district text,
  market text,
  variety text,
  grade text,
  arrival_date date,
  min_price numeric,
  modal_price numeric,
  max_price numeric,
  source text not null default 'data.gov.in',
  observed_at timestamptz not null default now()
);

create index if not exists idx_crop_lots_user on public.crop_lots (user_id);

create index if not exists idx_offers_seller on public.offers (seller_id);

create index if not exists idx_offers_buyer on public.offers (buyer_id);

create index if not exists idx_transactions_seller on public.transactions (seller_id);

create index if not exists idx_transactions_buyer on public.transactions (buyer_id);

create index if not exists idx_saved_schemes_user on public.saved_schemes (user_id);

create index if not exists idx_support_tickets_user on public.support_tickets (user_id);

create index if not exists idx_market_price_crop_date on public.market_price_snapshots (crop, observed_at desc);

-- Keep updated_at current.
create or replace function public.set_krishisetu_updated_at () returns trigger language plpgsql as $$
begin new.updated_at = now(); return new; end; $$;

drop trigger if exists profiles_updated_at on public.profiles;

create trigger profiles_updated_at before
update on public.profiles for each row
execute procedure public.set_krishisetu_updated_at ();

drop trigger if exists user_app_state_updated_at on public.user_app_state;

create trigger user_app_state_updated_at before
update on public.user_app_state for each row
execute procedure public.set_krishisetu_updated_at ();

-- RLS: users can only access their own private records.
alter table public.profiles enable row level security;

alter table public.user_app_state enable row level security;

alter table public.crop_lots enable row level security;

alter table public.offers enable row level security;

alter table public.transactions enable row level security;

alter table public.saved_schemes enable row level security;

alter table public.support_tickets enable row level security;

create policy "profiles_select_own" on public.profiles for
select
  using (auth.uid () = id);

create policy "profiles_insert_own" on public.profiles for insert
with
  check (auth.uid () = id);

create policy "profiles_update_own" on public.profiles
for update
  using (auth.uid () = id)
with
  check (auth.uid () = id);

create policy "app_state_select_own" on public.user_app_state for
select
  using (auth.uid () = user_id);

create policy "app_state_insert_own" on public.user_app_state for insert
with
  check (auth.uid () = user_id);

create policy "app_state_update_own" on public.user_app_state
for update
  using (auth.uid () = user_id)
with
  check (auth.uid () = user_id);

create policy "lots_select_own" on public.crop_lots for
select
  using (auth.uid () = user_id);

create policy "lots_insert_own" on public.crop_lots for insert
with
  check (auth.uid () = user_id);

create policy "lots_update_own" on public.crop_lots
for update
  using (auth.uid () = user_id)
with
  check (auth.uid () = user_id);

create policy "lots_delete_own" on public.crop_lots for delete using (auth.uid () = user_id);

create policy "offers_participants_select" on public.offers for
select
  using (
    auth.uid () = buyer_id
    or auth.uid () = seller_id
  );

create policy "offers_buyer_insert" on public.offers for insert
with
  check (auth.uid () = buyer_id);

create policy "offers_participant_update" on public.offers
for update
  using (
    auth.uid () = buyer_id
    or auth.uid () = seller_id
  )
with
  check (
    auth.uid () = buyer_id
    or auth.uid () = seller_id
  );

create policy "transactions_participants_select" on public.transactions for
select
  using (
    auth.uid () = buyer_id
    or auth.uid () = seller_id
  );

create policy "transactions_participant_insert" on public.transactions for insert
with
  check (
    auth.uid () = buyer_id
    or auth.uid () = seller_id
  );

create policy "transactions_participant_update" on public.transactions
for update
  using (
    auth.uid () = buyer_id
    or auth.uid () = seller_id
  )
with
  check (
    auth.uid () = buyer_id
    or auth.uid () = seller_id
  );

create policy "saved_schemes_own" on public.saved_schemes for all using (auth.uid () = user_id)
with
  check (auth.uid () = user_id);

create policy "support_tickets_own" on public.support_tickets for all using (auth.uid () = user_id)
with
  check (auth.uid () = user_id);

-- Market price snapshots can be publicly read by authenticated users; only a trusted backend should insert/update them.
alter table public.market_price_snapshots enable row level security;

create policy "market_prices_authenticated_read" on public.market_price_snapshots for
select
  using (auth.role () = 'authenticated');

-- Grants for the browser role. RLS remains the security boundary.
grant
select
,
  insert,
update on public.profiles to authenticated;

grant
select
,
  insert,
update on public.user_app_state to authenticated;

grant
select
,
  insert,
update,
delete on public.crop_lots to authenticated;

grant
select
,
  insert,
update on public.offers to authenticated;

grant
select
,
  insert,
update on public.transactions to authenticated;

grant
select
,
  insert,
update,
delete on public.saved_schemes to authenticated;

grant
select
,
  insert,
update,
delete on public.support_tickets to authenticated;

grant
select
  on public.market_price_snapshots to authenticated;

