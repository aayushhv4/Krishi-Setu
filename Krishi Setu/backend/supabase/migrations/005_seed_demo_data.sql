-- ============================================================================
-- STEP 0: DEMO AUTH USERS (must exist before profiles can reference them)
-- ============================================================================
insert into
  auth.users (
    id,
    email,
    created_at,
    updated_at,
    confirmation_sent_at,
    raw_app_meta_data,
    raw_user_meta_data,
    is_super_admin,
    encrypted_password,
    role,
    aud
  )
values
  (
    '11111111-1111-1111-1111-111111111111',
    'ramesh.patil@krishisetu.demo',
    NOW(),
    NOW(),
    NOW(),
    '{"provider":"email","providers":["email"]}'::jsonb,
    '{"full_name":"Ramesh Patil"}'::jsonb,
    false,
    '',
    'authenticated',
    'authenticated'
  ),
  (
    '11111111-1111-1111-1111-111111111112',
    'suresh.deshmukh@krishisetu.demo',
    NOW(),
    NOW(),
    NOW(),
    '{"provider":"email","providers":["email"]}'::jsonb,
    '{"full_name":"Suresh Deshmukh"}'::jsonb,
    false,
    '',
    'authenticated',
    'authenticated'
  ),
  (
    '22222222-2222-2222-2222-222222222222',
    'rajesh.gupta@agrofoods.demo',
    NOW(),
    NOW(),
    NOW(),
    '{"provider":"email","providers":["email"]}'::jsonb,
    '{"full_name":"Rajesh Gupta"}'::jsonb,
    false,
    '',
    'authenticated',
    'authenticated'
  ),
  (
    '22222222-2222-2222-2222-222222222223',
    'anita.mehta@freshcart.demo',
    NOW(),
    NOW(),
    NOW(),
    '{"provider":"email","providers":["email"]}'::jsonb,
    '{"full_name":"Anita Mehta"}'::jsonb,
    false,
    '',
    'authenticated',
    'authenticated'
  ),
  (
    '33333333-3333-3333-3333-333333333333',
    'vikas.shinde@kisanlogistics.demo',
    NOW(),
    NOW(),
    NOW(),
    '{"provider":"email","providers":["email"]}'::jsonb,
    '{"full_name":"Vikas Shinde"}'::jsonb,
    false,
    '',
    'authenticated',
    'authenticated'
  ),
  (
    '44444444-4444-4444-4444-444444444444',
    'sanjay.jadhav@mahacold.demo',
    NOW(),
    NOW(),
    NOW(),
    '{"provider":"email","providers":["email"]}'::jsonb,
    '{"full_name":"Sanjay Jadhav"}'::jsonb,
    false,
    '',
    'authenticated',
    'authenticated'
  ),
  (
    '99999999-9999-9999-9999-999999999999',
    'admin@krishisetu.gov.in.demo',
    NOW(),
    NOW(),
    NOW(),
    '{"provider":"email","providers":["email"]}'::jsonb,
    '{"full_name":"KrishiSetu Admin"}'::jsonb,
    false,
    '',
    'authenticated',
    'authenticated'
  )
on conflict (id) do update
set
  email = EXCLUDED.email,
  updated_at = NOW();

-- ============================================================================
-- STEP 1: EXTENSIONS
-- ============================================================================
create extension IF not exists "uuid-ossp";

create extension IF not exists "pgcrypto";

-- ============================================================================
-- STEP 2: ENUMS
-- ============================================================================
do $$ BEGIN
    CREATE TYPE public.user_role AS ENUM ('farmer','buyer','transporter','storage_partner','admin');
EXCEPTION WHEN duplicate_object THEN NULL; END $$;

do $$ BEGIN
    CREATE TYPE public.account_status AS ENUM ('active','inactive','suspended','pending_verification');
EXCEPTION WHEN duplicate_object THEN NULL; END $$;

do $$ BEGIN
    CREATE TYPE public.verification_status AS ENUM ('verified','unverified','pending','rejected');
EXCEPTION WHEN duplicate_object THEN NULL; END $$;

do $$ BEGIN
    CREATE TYPE public.trust_tier AS ENUM ('Bronze','Silver','Gold','Platinum');
EXCEPTION WHEN duplicate_object THEN NULL; END $$;

do $$ BEGIN
    CREATE TYPE public.crop_category AS ENUM ('vegetable','fruit','grain','oilseed','spice','cash_crop','pulses','fiber','plantation');
EXCEPTION WHEN duplicate_object THEN NULL; END $$;

do $$ BEGIN
    CREATE TYPE public.perishability_level AS ENUM ('low','medium','high','very_high');
EXCEPTION WHEN duplicate_object THEN NULL; END $$;

do $$ BEGIN
    CREATE TYPE public.lot_status AS ENUM ('draft','published','partially_sold','sold','expired','cancelled');
EXCEPTION WHEN duplicate_object THEN NULL; END $$;

do $$ BEGIN
    CREATE TYPE public.offer_status AS ENUM ('pending','accepted','rejected','counter_offered','withdrawn','expired');
EXCEPTION WHEN duplicate_object THEN NULL; END $$;

do $$ BEGIN
    CREATE TYPE public.order_status AS ENUM ('pending','confirmed','in_transit','delivered','completed','disputed','refunded','cancelled');
EXCEPTION WHEN duplicate_object THEN NULL; END $$;

do $$ BEGIN
    CREATE TYPE public.payment_status AS ENUM ('pending','escrow_held','marked_paid','released','refunded','failed');
EXCEPTION WHEN duplicate_object THEN NULL; END $$;

do $$ BEGIN
    CREATE TYPE public.transport_status AS ENUM ('pending','accepted','assigned','picked_up','in_transit','delivered','completed','cancelled');
EXCEPTION WHEN duplicate_object THEN NULL; END $$;

do $$ BEGIN
    CREATE TYPE public.delivery_status AS ENUM ('assigned','pickup_started','picked_up','in_transit','delivered','completed','failed');
EXCEPTION WHEN duplicate_object THEN NULL; END $$;

do $$ BEGIN
    CREATE TYPE public.vehicle_status AS ENUM ('available','on_trip','maintenance','inactive');
EXCEPTION WHEN duplicate_object THEN NULL; END $$;

do $$ BEGIN
    CREATE TYPE public.transporter_availability AS ENUM ('available','busy','offline');
EXCEPTION WHEN duplicate_object THEN NULL; END $$;

do $$ BEGIN
    CREATE TYPE public.storage_facility_status AS ENUM ('active','inactive','under_maintenance');
EXCEPTION WHEN duplicate_object THEN NULL; END $$;

do $$ BEGIN
    CREATE TYPE public.notification_type AS ENUM (
        'offer_received','offer_accepted','offer_rejected','order_confirmed',
        'order_completed','payment_released','transport_update','scheme_alert',
        'weather_alert','system'
    );
EXCEPTION WHEN duplicate_object THEN NULL; END $$;

do $$ BEGIN
    CREATE TYPE public.scheme_category AS ENUM (
        'crop insurance','infrastructure','credit','subsidy','training','market_linkage','equipment'
    );
EXCEPTION WHEN duplicate_object THEN NULL; END $$;

do $$ BEGIN
    CREATE TYPE public.central_or_state AS ENUM ('Central','State','Both');
EXCEPTION WHEN duplicate_object THEN NULL; END $$;

do $$ BEGIN
    CREATE TYPE public.data_status AS ENUM ('live','demo','demo_verified');
EXCEPTION WHEN duplicate_object THEN NULL; END $$;

do $$ BEGIN
    CREATE TYPE public.diagnosis_status AS ENUM ('processing','completed','failed');
EXCEPTION WHEN duplicate_object THEN NULL; END $$;

do $$ BEGIN
    CREATE TYPE public.inventory_status AS ENUM ('available','partially_allocated','fully_allocated','sold','expired');
EXCEPTION WHEN duplicate_object THEN NULL; END $$;

do $$ BEGIN
    CREATE TYPE public.image_type AS ENUM ('primary','secondary','certificate');
EXCEPTION WHEN duplicate_object THEN NULL; END $$;

do $$ BEGIN
    CREATE TYPE public.lot_event_type AS ENUM (
        'created','quality_checked','published','offer_received',
        'offer_accepted','picked_up','in_transit','delivered','sold'
    );
EXCEPTION WHEN duplicate_object THEN NULL; END $$;

do $$ BEGIN
    CREATE TYPE public.transaction_type AS ENUM ('order','transport','storage');
EXCEPTION WHEN duplicate_object THEN NULL; END $$;

-- ============================================================================
-- STEP 3: TABLES
-- ============================================================================
-- profiles
create table if not exists public.profiles (
  id UUID primary key references auth.users (id) on delete CASCADE,
  full_name TEXT not null,
  email TEXT unique,
  mobile TEXT,
  avatar_url TEXT,
  primary_role public.user_role not null default 'farmer',
  account_status public.account_status not null default 'pending_verification',
  verification_status public.verification_status not null default 'unverified',
  trust_score NUMERIC(5, 2) default 50.00 check (trust_score between 0 and 100),
  trust_tier public.trust_tier default 'Bronze',
  credit_points INTEGER default 0,
  language TEXT default 'en',
  preferred_language TEXT default 'en',
  address TEXT,
  village TEXT,
  district TEXT,
  state TEXT,
  pincode TEXT,
  latitude NUMERIC(9, 6),
  longitude NUMERIC(9, 6),
  created_at TIMESTAMPTZ default NOW(),
  updated_at TIMESTAMPTZ default NOW()
);

-- farmer_profiles
create table if not exists public.farmer_profiles (
  id BIGSERIAL primary key,
  profile_id UUID unique not null references public.profiles (id) on delete CASCADE,
  farm_name TEXT,
  farm_size_acres NUMERIC(8, 2),
  farming_type TEXT,
  fpo_name TEXT,
  preferred_market TEXT,
  irrigation_available BOOLEAN default false,
  storage_available BOOLEAN default false,
  years_of_farming INTEGER default 0,
  verification_details JSONB default '{}'::jsonb,
  created_at TIMESTAMPTZ default NOW(),
  updated_at TIMESTAMPTZ default NOW()
);

-- buyer_profiles
create table if not exists public.buyer_profiles (
  id BIGSERIAL primary key,
  profile_id UUID unique not null references public.profiles (id) on delete CASCADE,
  business_name TEXT,
  business_type TEXT,
  procurement_capacity TEXT,
  preferred_crops text[],
  preferred_locations text[],
  payment_terms TEXT,
  verification_info JSONB default '{}'::jsonb,
  created_at TIMESTAMPTZ default NOW(),
  updated_at TIMESTAMPTZ default NOW()
);

-- transporter_profiles
create table if not exists public.transporter_profiles (
  id BIGSERIAL primary key,
  profile_id UUID unique not null references public.profiles (id) on delete CASCADE,
  business_name TEXT,
  service_area text[],
  rating NUMERIC(3, 2) default 0.00 check (rating between 0 and 5),
  availability_status public.transporter_availability default 'available',
  created_at TIMESTAMPTZ default NOW(),
  updated_at TIMESTAMPTZ default NOW()
);

-- storage_partner_profiles
create table if not exists public.storage_partner_profiles (
  id BIGSERIAL primary key,
  profile_id UUID unique not null references public.profiles (id) on delete CASCADE,
  business_name TEXT,
  facility_type TEXT,
  created_at TIMESTAMPTZ default NOW(),
  updated_at TIMESTAMPTZ default NOW()
);

-- user_preferences
create table if not exists public.user_preferences (
  id BIGSERIAL primary key,
  user_id UUID unique not null references public.profiles (id) on delete CASCADE,
  language TEXT default 'en',
  notification_enabled BOOLEAN default true,
  whatsapp_alerts_enabled BOOLEAN default false,
  preferred_units TEXT default 'quintal',
  dark_mode BOOLEAN default false,
  created_at TIMESTAMPTZ default NOW(),
  updated_at TIMESTAMPTZ default NOW()
);

-- crops
create table if not exists public.crops (
  id UUID primary key default uuid_generate_v4 (),
  name TEXT not null,
  local_name TEXT,
  hindi_name TEXT,
  category public.crop_category not null,
  crop_type TEXT,
  common_varieties text[],
  unit TEXT default 'kg',
  perishability_level public.perishability_level default 'medium',
  typical_storage_days INTEGER default 30,
  optimal_storage_temperature TEXT,
  optimal_storage_humidity TEXT,
  created_at TIMESTAMPTZ default NOW()
);

-- storage_facilities
create table if not exists public.storage_facilities (
  id UUID primary key default uuid_generate_v4 (),
  owner_profile_id UUID not null references public.profiles (id) on delete CASCADE,
  facility_name TEXT not null,
  facility_type TEXT,
  location TEXT,
  district TEXT,
  state TEXT,
  pincode TEXT,
  latitude NUMERIC(9, 6),
  longitude NUMERIC(9, 6),
  total_capacity_kg NUMERIC(12, 2) default 0,
  available_capacity_kg NUMERIC(12, 2) default 0,
  supported_crops text[],
  temperature_controlled BOOLEAN default false,
  cold_storage BOOLEAN default false,
  price_per_kg_per_day NUMERIC(8, 4) default 0,
  rating NUMERIC(3, 2) default 0.00 check (rating between 0 and 5),
  verification_status public.verification_status default 'unverified',
  status public.storage_facility_status default 'active',
  created_at TIMESTAMPTZ default NOW(),
  updated_at TIMESTAMPTZ default NOW()
);

-- storage_bookings
create table if not exists public.storage_bookings (
  id UUID primary key default uuid_generate_v4 (),
  facility_id UUID not null references public.storage_facilities (id),
  farmer_id UUID not null references public.profiles (id),
  crop_id UUID references public.crops (id),
  quantity_kg NUMERIC(10, 2) not null,
  start_date DATE not null,
  end_date DATE not null,
  cost_per_kg_per_day NUMERIC(8, 4),
  total_cost NUMERIC(10, 2),
  status TEXT default 'pending',
  notes TEXT,
  created_at TIMESTAMPTZ default NOW(),
  updated_at TIMESTAMPTZ default NOW()
);

-- vehicles
create table if not exists public.vehicles (
  id UUID primary key default uuid_generate_v4 (),
  transporter_id UUID not null references public.profiles (id) on delete CASCADE,
  vehicle_type TEXT not null,
  registration_number TEXT unique not null,
  capacity_kg NUMERIC(10, 2),
  refrigeration_available BOOLEAN default false,
  service_area text[],
  status public.vehicle_status default 'available',
  created_at TIMESTAMPTZ default NOW(),
  updated_at TIMESTAMPTZ default NOW()
);

-- crop_inventory
create table if not exists public.crop_inventory (
  id UUID primary key default uuid_generate_v4 (),
  farmer_id UUID not null references public.profiles (id) on delete CASCADE,
  crop_id UUID not null references public.crops (id),
  variety TEXT,
  batch_code TEXT unique,
  quantity_kg NUMERIC(10, 2) not null,
  available_quantity_kg NUMERIC(10, 2) not null,
  quality_grade TEXT,
  moisture_percentage NUMERIC(5, 2),
  harvest_date DATE,
  freshness_score NUMERIC(5, 2) check (freshness_score between 0 and 100),
  freshness_status TEXT,
  storage_condition TEXT,
  storage_facility_id UUID references public.storage_facilities (id),
  shelf_life_estimate_days INTEGER,
  notes TEXT,
  image_url TEXT,
  status public.inventory_status default 'available',
  created_at TIMESTAMPTZ default NOW(),
  updated_at TIMESTAMPTZ default NOW()
);

-- produce_lots
create table if not exists public.produce_lots (
  id UUID primary key default uuid_generate_v4 (),
  farmer_id UUID not null references public.profiles (id) on delete CASCADE,
  inventory_id UUID references public.crop_inventory (id),
  crop_id UUID not null references public.crops (id),
  lot_code TEXT unique not null,
  variety TEXT,
  quantity_kg NUMERIC(10, 2) not null,
  available_quantity_kg NUMERIC(10, 2) not null,
  quality_grade TEXT,
  moisture_percentage NUMERIC(5, 2),
  harvest_date DATE,
  freshness_score NUMERIC(5, 2),
  storage_condition TEXT,
  asking_price_per_quintal NUMERIC(10, 2) not null,
  minimum_offer_price_per_quintal NUMERIC(10, 2),
  pickup_location TEXT,
  pickup_latitude NUMERIC(9, 6),
  pickup_longitude NUMERIC(9, 6),
  quality_notes TEXT,
  status public.lot_status default 'draft',
  published_at TIMESTAMPTZ,
  created_at TIMESTAMPTZ default NOW(),
  updated_at TIMESTAMPTZ default NOW()
);

-- produce_lot_images
create table if not exists public.produce_lot_images (
  id BIGSERIAL primary key,
  lot_id UUID not null references public.produce_lots (id) on delete CASCADE,
  storage_path TEXT,
  public_url TEXT not null,
  image_type public.image_type default 'secondary',
  uploaded_by UUID references public.profiles (id),
  created_at TIMESTAMPTZ default NOW()
);

-- lot_events
create table if not exists public.lot_events (
  id BIGSERIAL primary key,
  lot_id UUID not null references public.produce_lots (id) on delete CASCADE,
  event_type public.lot_event_type not null,
  description TEXT,
  location TEXT,
  actor_id UUID references public.profiles (id),
  metadata JSONB default '{}'::jsonb,
  created_at TIMESTAMPTZ default NOW()
);

-- buyer_offers
create table if not exists public.buyer_offers (
  id UUID primary key default uuid_generate_v4 (),
  lot_id UUID not null references public.produce_lots (id) on delete CASCADE,
  buyer_id UUID not null references public.profiles (id),
  offered_quantity_kg NUMERIC(10, 2) not null,
  offered_price_per_quintal NUMERIC(10, 2) not null,
  proposed_pickup_date DATE,
  proposed_delivery_date DATE,
  payment_terms TEXT,
  message TEXT,
  status public.offer_status default 'pending',
  parent_offer_id UUID references public.buyer_offers (id),
  counter_offer_number INTEGER default 0,
  expires_at TIMESTAMPTZ default NOW() + INTERVAL '48 hours',
  created_at TIMESTAMPTZ default NOW(),
  updated_at TIMESTAMPTZ default NOW()
);

-- orders
create table if not exists public.orders (
  id UUID primary key default uuid_generate_v4 (),
  order_number TEXT unique not null,
  buyer_id UUID not null references public.profiles (id),
  farmer_id UUID not null references public.profiles (id),
  accepted_offer_id UUID references public.buyer_offers (id),
  status public.order_status default 'pending',
  subtotal NUMERIC(12, 2) default 0,
  transport_cost NUMERIC(12, 2) default 0,
  storage_cost NUMERIC(12, 2) default 0,
  platform_fee NUMERIC(12, 2) default 0,
  total_amount NUMERIC(12, 2) default 0,
  payment_status public.payment_status default 'pending',
  payment_method TEXT,
  pickup_location TEXT,
  delivery_location TEXT,
  expected_delivery_date DATE,
  actual_delivery_date DATE,
  dispute_reason TEXT,
  created_at TIMESTAMPTZ default NOW(),
  updated_at TIMESTAMPTZ default NOW()
);

-- order_items
create table if not exists public.order_items (
  id BIGSERIAL primary key,
  order_id UUID not null references public.orders (id) on delete CASCADE,
  lot_id UUID references public.produce_lots (id),
  crop_id UUID references public.crops (id),
  quantity_kg NUMERIC(10, 2) not null,
  price_per_quintal NUMERIC(10, 2) not null,
  subtotal NUMERIC(12, 2) not null,
  created_at TIMESTAMPTZ default NOW()
);

-- transport_requests
create table if not exists public.transport_requests (
  id UUID primary key default uuid_generate_v4 (),
  order_id UUID not null references public.orders (id) on delete CASCADE,
  requested_by UUID not null references public.profiles (id),
  transporter_id UUID references public.profiles (id),
  pickup_location TEXT,
  pickup_latitude NUMERIC(9, 6),
  pickup_longitude NUMERIC(9, 6),
  destination_location TEXT,
  destination_latitude NUMERIC(9, 6),
  destination_longitude NUMERIC(9, 6),
  requested_date DATE,
  estimated_distance_km NUMERIC(8, 2),
  estimated_cost NUMERIC(10, 2),
  actual_cost NUMERIC(10, 2),
  status public.transport_status default 'pending',
  notes TEXT,
  created_at TIMESTAMPTZ default NOW(),
  updated_at TIMESTAMPTZ default NOW()
);

-- deliveries
create table if not exists public.deliveries (
  id UUID primary key default uuid_generate_v4 (),
  transport_request_id UUID not null references public.transport_requests (id) on delete CASCADE,
  vehicle_id UUID references public.vehicles (id),
  driver_name TEXT,
  driver_mobile TEXT,
  pickup_started_at TIMESTAMPTZ,
  picked_up_at TIMESTAMPTZ,
  in_transit_at TIMESTAMPTZ,
  delivered_at TIMESTAMPTZ,
  completed_at TIMESTAMPTZ,
  current_latitude NUMERIC(9, 6),
  current_longitude NUMERIC(9, 6),
  delivery_notes TEXT,
  proof_of_delivery_url TEXT,
  status public.delivery_status default 'assigned',
  created_at TIMESTAMPTZ default NOW(),
  updated_at TIMESTAMPTZ default NOW()
);

-- delivery_status_history
create table if not exists public.delivery_status_history (
  id BIGSERIAL primary key,
  delivery_id UUID not null references public.deliveries (id) on delete CASCADE,
  status public.delivery_status not null,
  latitude NUMERIC(9, 6),
  longitude NUMERIC(9, 6),
  notes TEXT,
  changed_by UUID references public.profiles (id),
  created_at TIMESTAMPTZ default NOW()
);

-- ratings
create table if not exists public.ratings (
  id BIGSERIAL primary key,
  transaction_type public.transaction_type not null,
  order_id UUID references public.orders (id),
  transport_request_id UUID references public.transport_requests (id),
  storage_booking_id UUID references public.storage_bookings (id),
  reviewer_id UUID not null references public.profiles (id),
  reviewee_id UUID not null references public.profiles (id),
  rating INTEGER not null check (rating between 1 and 5),
  review_text TEXT,
  created_at TIMESTAMPTZ default NOW(),
  constraint no_self_rating check (reviewer_id <> reviewee_id)
);

-- watchlists
create table if not exists public.watchlists (
  id BIGSERIAL primary key,
  user_id UUID not null references public.profiles (id) on delete CASCADE,
  lot_id UUID references public.produce_lots (id) on delete CASCADE,
  crop_id UUID references public.crops (id),
  created_at TIMESTAMPTZ default NOW(),
  unique (user_id, lot_id)
);

-- forward_contracts
create table if not exists public.forward_contracts (
  id UUID primary key default uuid_generate_v4 (),
  farmer_id UUID not null references public.profiles (id),
  buyer_id UUID not null references public.profiles (id),
  crop_id UUID not null references public.crops (id),
  quantity_kg NUMERIC(10, 2) not null,
  agreed_price_per_quintal NUMERIC(10, 2) not null,
  delivery_date DATE not null,
  terms TEXT,
  status TEXT default 'active',
  created_at TIMESTAMPTZ default NOW(),
  updated_at TIMESTAMPTZ default NOW()
);

-- mandi_prices
create table if not exists public.mandi_prices (
  id BIGSERIAL primary key,
  crop_id UUID not null references public.crops (id),
  market_name TEXT not null,
  market_code TEXT,
  district TEXT,
  state TEXT,
  min_price NUMERIC(10, 2),
  modal_price NUMERIC(10, 2),
  max_price NUMERIC(10, 2),
  unit TEXT default 'Quintal',
  price_date DATE not null,
  source TEXT default 'Agmarknet',
  data_status public.data_status default 'live',
  created_at TIMESTAMPTZ default NOW(),
  unique (crop_id, market_code, price_date)
);

-- government_schemes
create table if not exists public.government_schemes (
  id UUID primary key default uuid_generate_v4 (),
  name TEXT not null,
  short_description TEXT,
  full_description TEXT,
  category public.scheme_category,
  eligibility TEXT,
  benefits TEXT,
  documents_required text[],
  application_url TEXT,
  official_source TEXT,
  state TEXT,
  central_or_state public.central_or_state default 'Central',
  status TEXT default 'active',
  data_status public.data_status default 'live',
  created_at TIMESTAMPTZ default NOW(),
  updated_at TIMESTAMPTZ default NOW()
);

-- scheme_bookmarks
create table if not exists public.scheme_bookmarks (
  id BIGSERIAL primary key,
  user_id UUID not null references public.profiles (id) on delete CASCADE,
  scheme_id UUID not null references public.government_schemes (id) on delete CASCADE,
  created_at TIMESTAMPTZ default NOW(),
  unique (user_id, scheme_id)
);

-- notifications
create table if not exists public.notifications (
  id BIGSERIAL primary key,
  user_id UUID not null references public.profiles (id) on delete CASCADE,
  type public.notification_type not null,
  title TEXT not null,
  message TEXT,
  related_entity_type TEXT,
  related_entity_id UUID,
  is_read BOOLEAN default false,
  created_at TIMESTAMPTZ default NOW()
);

-- weather_observations
create table if not exists public.weather_observations (
  id BIGSERIAL primary key,
  location TEXT not null,
  latitude NUMERIC(9, 6),
  longitude NUMERIC(9, 6),
  observation_date DATE not null,
  temperature NUMERIC(5, 2),
  rainfall_mm NUMERIC(6, 2) default 0,
  humidity NUMERIC(5, 2),
  weather_condition TEXT,
  source TEXT,
  data_status public.data_status default 'live',
  created_at TIMESTAMPTZ default NOW()
);

-- ai_conversations
create table if not exists public.ai_conversations (
  id UUID primary key default uuid_generate_v4 (),
  user_id UUID not null references public.profiles (id) on delete CASCADE,
  title TEXT,
  context JSONB default '{}'::jsonb,
  ai_model TEXT default 'Gemini 2.5 Flash',
  created_at TIMESTAMPTZ default NOW(),
  updated_at TIMESTAMPTZ default NOW()
);

-- ai_messages
create table if not exists public.ai_messages (
  id BIGSERIAL primary key,
  conversation_id UUID not null references public.ai_conversations (id) on delete CASCADE,
  role TEXT not null check (role in ('user', 'model', 'system')),
  content TEXT not null,
  metadata JSONB default '{}'::jsonb,
  created_at TIMESTAMPTZ default NOW()
);

-- crop_diagnoses
create table if not exists public.crop_diagnoses (
  id UUID primary key default uuid_generate_v4 (),
  user_id UUID not null references public.profiles (id) on delete CASCADE,
  crop_id UUID references public.crops (id),
  inventory_id UUID references public.crop_inventory (id),
  image_url TEXT,
  diagnosis TEXT,
  detected_issue TEXT,
  confidence_score NUMERIC(5, 2) check (confidence_score between 0 and 100),
  severity TEXT,
  recommendations TEXT,
  ai_model TEXT,
  status public.diagnosis_status default 'processing',
  created_at TIMESTAMPTZ default NOW()
);

-- risk_simulations
create table if not exists public.risk_simulations (
  id UUID primary key default uuid_generate_v4 (),
  user_id UUID not null references public.profiles (id) on delete CASCADE,
  crop_id UUID references public.crops (id),
  inventory_id UUID references public.crop_inventory (id),
  quantity_kg NUMERIC(10, 2),
  scenario_name TEXT,
  assumed_price NUMERIC(10, 2),
  storage_cost NUMERIC(10, 2),
  transport_cost NUMERIC(10, 2),
  estimated_revenue NUMERIC(12, 2),
  estimated_cost NUMERIC(12, 2),
  estimated_profit NUMERIC(12, 2),
  weather_risk TEXT,
  spoilage_risk TEXT,
  overall_risk TEXT,
  assumptions JSONB default '{}'::jsonb,
  created_at TIMESTAMPTZ default NOW()
);

-- realisation_calculations
create table if not exists public.realisation_calculations (
  id UUID primary key default uuid_generate_v4 (),
  user_id UUID not null references public.profiles (id) on delete CASCADE,
  crop_id UUID references public.crops (id),
  quantity_kg NUMERIC(10, 2),
  channel_type TEXT,
  buyer_or_market_name TEXT,
  quoted_price_per_quintal NUMERIC(10, 2),
  logistics_cost NUMERIC(10, 2) default 0,
  storage_cost NUMERIC(10, 2) default 0,
  platform_fee NUMERIC(10, 2) default 0,
  other_cost NUMERIC(10, 2) default 0,
  gross_revenue NUMERIC(12, 2),
  net_revenue NUMERIC(12, 2),
  profit NUMERIC(12, 2),
  profit_per_kg NUMERIC(8, 2),
  margin_percentage NUMERIC(5, 2),
  reliability_score NUMERIC(5, 2),
  created_at TIMESTAMPTZ default NOW()
);

-- ============================================================================
-- STEP 4: INDEXES
-- ============================================================================
create index IF not exists idx_profiles_role on public.profiles (primary_role);

create index IF not exists idx_profiles_district on public.profiles (district);

create index IF not exists idx_produce_lots_farmer on public.produce_lots (farmer_id);

create index IF not exists idx_produce_lots_crop on public.produce_lots (crop_id);

create index IF not exists idx_produce_lots_status on public.produce_lots (status);

create index IF not exists idx_buyer_offers_lot on public.buyer_offers (lot_id);

create index IF not exists idx_buyer_offers_buyer on public.buyer_offers (buyer_id);

create index IF not exists idx_orders_buyer on public.orders (buyer_id);

create index IF not exists idx_orders_farmer on public.orders (farmer_id);

create index IF not exists idx_mandi_prices_crop on public.mandi_prices (crop_id);

create index IF not exists idx_mandi_prices_date on public.mandi_prices (price_date);

create index IF not exists idx_notifications_user on public.notifications (user_id, is_read);

create index IF not exists idx_lot_events_lot on public.lot_events (lot_id);

create index IF not exists idx_deliveries_transport on public.deliveries (transport_request_id);

-- ============================================================================
-- STEP 5: updated_at TRIGGER FUNCTION
-- ============================================================================
create or replace function public.fn_set_updated_at () RETURNS TRIGGER LANGUAGE plpgsql as $$
BEGIN NEW.updated_at = NOW(); RETURN NEW; END; $$;

do $$
DECLARE t TEXT;
BEGIN
    FOREACH t IN ARRAY ARRAY[
        'profiles','farmer_profiles','buyer_profiles','transporter_profiles',
        'storage_partner_profiles','user_preferences','storage_facilities',
        'storage_bookings','vehicles','crop_inventory','produce_lots',
        'buyer_offers','orders','transport_requests','deliveries',
        'government_schemes','ai_conversations','forward_contracts'
    ]
    LOOP
        EXECUTE format(
            'DROP TRIGGER IF EXISTS trg_%I_updated_at ON public.%I;
             CREATE TRIGGER trg_%I_updated_at BEFORE UPDATE ON public.%I
             FOR EACH ROW EXECUTE FUNCTION public.fn_set_updated_at();', t, t, t, t
        );
    END LOOP;
END; $$;

-- ============================================================================
-- STEP 6: TRUST SCORE FUNCTION + TRIGGER
-- ============================================================================
create or replace function public.fn_recalculate_trust_score (p_user_id UUID) RETURNS VOID LANGUAGE plpgsql as $$
DECLARE
    v_avg_rating       NUMERIC;
    v_completed_orders INTEGER;
    v_new_score        NUMERIC;
    v_new_tier         public.trust_tier;
BEGIN
    SELECT AVG(rating) INTO v_avg_rating FROM public.ratings WHERE reviewee_id = p_user_id;
    SELECT COUNT(*) INTO v_completed_orders FROM public.orders
    WHERE (buyer_id = p_user_id OR farmer_id = p_user_id) AND status = 'completed';

    v_new_score := ROUND(GREATEST(0, LEAST(100,
        (COALESCE(v_avg_rating, 3) / 5.0 * 60) + LEAST(v_completed_orders * 4, 40)
    )), 2);

    v_new_tier := CASE
        WHEN v_new_score >= 90 THEN 'Platinum'::public.trust_tier
        WHEN v_new_score >= 75 THEN 'Gold'::public.trust_tier
        WHEN v_new_score >= 50 THEN 'Silver'::public.trust_tier
        ELSE 'Bronze'::public.trust_tier
    END;

    UPDATE public.profiles SET trust_score = v_new_score, trust_tier = v_new_tier, updated_at = NOW()
    WHERE id = p_user_id;
END; $$;

create or replace function public.fn_after_rating_insert () RETURNS TRIGGER LANGUAGE plpgsql as $$
BEGIN PERFORM public.fn_recalculate_trust_score(NEW.reviewee_id); RETURN NEW; END; $$;

drop trigger IF exists trg_ratings_trust_update on public.ratings;

create trigger trg_ratings_trust_update
after INSERT on public.ratings for EACH row
execute FUNCTION public.fn_after_rating_insert ();

-- ============================================================================
-- STEP 7: AUTO-CREATE PROFILE ON SIGNUP
-- ============================================================================
create or replace function public.fn_handle_new_user () RETURNS TRIGGER LANGUAGE plpgsql SECURITY DEFINER
set
  search_path = public as $$
BEGIN
    INSERT INTO public.profiles (id, email, full_name, avatar_url)
    VALUES (
        NEW.id, NEW.email,
        COALESCE(NEW.raw_user_meta_data->>'full_name', NEW.email),
        NEW.raw_user_meta_data->>'avatar_url'
    )
    ON CONFLICT (id) DO NOTHING;
    RETURN NEW;
END; $$;

drop trigger IF exists trg_on_auth_user_created on auth.users;

create trigger trg_on_auth_user_created
after INSERT on auth.users for EACH row
execute FUNCTION public.fn_handle_new_user ();

-- ============================================================================
-- STEP 8: ROW LEVEL SECURITY
-- ============================================================================
alter table public.profiles ENABLE row LEVEL SECURITY;

alter table public.farmer_profiles ENABLE row LEVEL SECURITY;

alter table public.buyer_profiles ENABLE row LEVEL SECURITY;

alter table public.transporter_profiles ENABLE row LEVEL SECURITY;

alter table public.storage_partner_profiles ENABLE row LEVEL SECURITY;

alter table public.user_preferences ENABLE row LEVEL SECURITY;

alter table public.crop_inventory ENABLE row LEVEL SECURITY;

alter table public.produce_lots ENABLE row LEVEL SECURITY;

alter table public.produce_lot_images ENABLE row LEVEL SECURITY;

alter table public.lot_events ENABLE row LEVEL SECURITY;

alter table public.buyer_offers ENABLE row LEVEL SECURITY;

alter table public.orders ENABLE row LEVEL SECURITY;

alter table public.order_items ENABLE row LEVEL SECURITY;

alter table public.transport_requests ENABLE row LEVEL SECURITY;

alter table public.deliveries ENABLE row LEVEL SECURITY;

alter table public.delivery_status_history ENABLE row LEVEL SECURITY;

alter table public.ratings ENABLE row LEVEL SECURITY;

alter table public.notifications ENABLE row LEVEL SECURITY;

alter table public.watchlists ENABLE row LEVEL SECURITY;

alter table public.scheme_bookmarks ENABLE row LEVEL SECURITY;

alter table public.ai_conversations ENABLE row LEVEL SECURITY;

alter table public.ai_messages ENABLE row LEVEL SECURITY;

alter table public.crop_diagnoses ENABLE row LEVEL SECURITY;

alter table public.risk_simulations ENABLE row LEVEL SECURITY;

alter table public.realisation_calculations ENABLE row LEVEL SECURITY;

alter table public.storage_bookings ENABLE row LEVEL SECURITY;

alter table public.forward_contracts ENABLE row LEVEL SECURITY;

alter table public.vehicles ENABLE row LEVEL SECURITY;

alter table public.storage_facilities ENABLE row LEVEL SECURITY;

-- profiles
drop policy IF exists "Authenticated users view profiles" on public.profiles;

create policy "Authenticated users view profiles" on public.profiles for
select
  using (auth.role () = 'authenticated');

drop policy IF exists "Users update own profile" on public.profiles;

create policy "Users update own profile" on public.profiles
for update
  using (auth.uid () = id);

drop policy IF exists "Users insert own profile" on public.profiles;

create policy "Users insert own profile" on public.profiles for INSERT
with
  check (auth.uid () = id);

-- user_preferences
drop policy IF exists "Own preferences only" on public.user_preferences;

create policy "Own preferences only" on public.user_preferences for all using (auth.uid () = user_id);

-- farmer_profiles
drop policy IF exists "Authenticated view farmer profiles" on public.farmer_profiles;

create policy "Authenticated view farmer profiles" on public.farmer_profiles for
select
  using (auth.role () = 'authenticated');

drop policy IF exists "Farmers manage own farmer profile" on public.farmer_profiles;

create policy "Farmers manage own farmer profile" on public.farmer_profiles for all using (auth.uid () = profile_id);

-- buyer_profiles
drop policy IF exists "Authenticated view buyer profiles" on public.buyer_profiles;

create policy "Authenticated view buyer profiles" on public.buyer_profiles for
select
  using (auth.role () = 'authenticated');

drop policy IF exists "Buyers manage own buyer profile" on public.buyer_profiles;

create policy "Buyers manage own buyer profile" on public.buyer_profiles for all using (auth.uid () = profile_id);

-- transporter_profiles
drop policy IF exists "Authenticated view transporter profiles" on public.transporter_profiles;

create policy "Authenticated view transporter profiles" on public.transporter_profiles for
select
  using (auth.role () = 'authenticated');

drop policy IF exists "Transporters manage own transporter profile" on public.transporter_profiles;

create policy "Transporters manage own transporter profile" on public.transporter_profiles for all using (auth.uid () = profile_id);

-- storage_partner_profiles
drop policy IF exists "Authenticated view storage partner profiles" on public.storage_partner_profiles;

create policy "Authenticated view storage partner profiles" on public.storage_partner_profiles for
select
  using (auth.role () = 'authenticated');

drop policy IF exists "Storage partners manage own profile" on public.storage_partner_profiles;

create policy "Storage partners manage own profile" on public.storage_partner_profiles for all using (auth.uid () = profile_id);

-- crop_inventory
drop policy IF exists "Farmers manage own inventory" on public.crop_inventory;

create policy "Farmers manage own inventory" on public.crop_inventory for all using (auth.uid () = farmer_id);

drop policy IF exists "Authenticated view inventory" on public.crop_inventory;

create policy "Authenticated view inventory" on public.crop_inventory for
select
  using (auth.role () = 'authenticated');

-- produce_lots
drop policy IF exists "Anyone views published lots" on public.produce_lots;

create policy "Anyone views published lots" on public.produce_lots for
select
  using (status in ('published', 'partially_sold'));

drop policy IF exists "Farmers manage own lots" on public.produce_lots;

create policy "Farmers manage own lots" on public.produce_lots for all using (auth.uid () = farmer_id);

-- produce_lot_images & lot_events
drop policy IF exists "Public lot images read" on public.produce_lot_images;

create policy "Public lot images read" on public.produce_lot_images for
select
  using (true);

drop policy IF exists "Public lot events read" on public.lot_events;

create policy "Public lot events read" on public.lot_events for
select
  using (true);

drop policy IF exists "Actors insert lot events" on public.lot_events;

create policy "Actors insert lot events" on public.lot_events for INSERT
with
  check (auth.uid () = actor_id);

-- buyer_offers
drop policy IF exists "Buyers see own offers" on public.buyer_offers;

create policy "Buyers see own offers" on public.buyer_offers for
select
  using (auth.uid () = buyer_id);

drop policy IF exists "Farmers see offers on their lots" on public.buyer_offers;

create policy "Farmers see offers on their lots" on public.buyer_offers for
select
  using (
    auth.uid () in (
      select
        farmer_id
      from
        public.produce_lots
      where
        id = lot_id
    )
  );

drop policy IF exists "Buyers create offers" on public.buyer_offers;

create policy "Buyers create offers" on public.buyer_offers for INSERT
with
  check (auth.uid () = buyer_id);

drop policy IF exists "Buyers update own offers" on public.buyer_offers;

create policy "Buyers update own offers" on public.buyer_offers
for update
  using (auth.uid () = buyer_id);

-- orders
drop policy IF exists "Buyer or farmer see own orders" on public.orders;

create policy "Buyer or farmer see own orders" on public.orders for
select
  using (
    auth.uid () = buyer_id
    or auth.uid () = farmer_id
  );

-- order_items
drop policy IF exists "Order parties see order items" on public.order_items;

create policy "Order parties see order items" on public.order_items for
select
  using (
    auth.uid () in (
      select
        buyer_id
      from
        public.orders
      where
        id = order_id
      union
      select
        farmer_id
      from
        public.orders
      where
        id = order_id
    )
  );

-- transport_requests
drop policy IF exists "Relevant parties see transport requests" on public.transport_requests;

create policy "Relevant parties see transport requests" on public.transport_requests for
select
  using (
    auth.uid () = requested_by
    or auth.uid () = transporter_id
  );

-- deliveries & history
drop policy IF exists "Authenticated view deliveries" on public.deliveries;

create policy "Authenticated view deliveries" on public.deliveries for
select
  using (auth.role () = 'authenticated');

drop policy IF exists "Authenticated view delivery history" on public.delivery_status_history;

create policy "Authenticated view delivery history" on public.delivery_status_history for
select
  using (auth.role () = 'authenticated');

-- ratings
drop policy IF exists "Authenticated view ratings" on public.ratings;

create policy "Authenticated view ratings" on public.ratings for
select
  using (auth.role () = 'authenticated');

drop policy IF exists "Users create own ratings" on public.ratings;

create policy "Users create own ratings" on public.ratings for INSERT
with
  check (auth.uid () = reviewer_id);

-- notifications, watchlists, scheme_bookmarks
drop policy IF exists "Own notifications only" on public.notifications;

create policy "Own notifications only" on public.notifications for all using (auth.uid () = user_id);

drop policy IF exists "Own watchlists only" on public.watchlists;

create policy "Own watchlists only" on public.watchlists for all using (auth.uid () = user_id);

drop policy IF exists "Own scheme bookmarks only" on public.scheme_bookmarks;

create policy "Own scheme bookmarks only" on public.scheme_bookmarks for all using (auth.uid () = user_id);

-- ai
drop policy IF exists "Own AI conversations only" on public.ai_conversations;

create policy "Own AI conversations only" on public.ai_conversations for all using (auth.uid () = user_id);

drop policy IF exists "Own AI messages only" on public.ai_messages;

create policy "Own AI messages only" on public.ai_messages for all using (
  auth.uid () in (
    select
      user_id
    from
      public.ai_conversations
    where
      id = conversation_id
  )
);

-- analytics
drop policy IF exists "Own diagnoses only" on public.crop_diagnoses;

create policy "Own diagnoses only" on public.crop_diagnoses for all using (auth.uid () = user_id);

drop policy IF exists "Own risk simulations only" on public.risk_simulations;

create policy "Own risk simulations only" on public.risk_simulations for all using (auth.uid () = user_id);

drop policy IF exists "Own realisation calculations only" on public.realisation_calculations;

create policy "Own realisation calculations only" on public.realisation_calculations for all using (auth.uid () = user_id);

-- storage
drop policy IF exists "Public view active facilities" on public.storage_facilities;

create policy "Public view active facilities" on public.storage_facilities for
select
  using (status = 'active');

drop policy IF exists "Owners manage own facilities" on public.storage_facilities;

create policy "Owners manage own facilities" on public.storage_facilities for all using (auth.uid () = owner_profile_id);

drop policy IF exists "Farmers manage own bookings" on public.storage_bookings;

create policy "Farmers manage own bookings" on public.storage_bookings for all using (auth.uid () = farmer_id);

-- vehicles
drop policy IF exists "Transporters manage own vehicles" on public.vehicles;

create policy "Transporters manage own vehicles" on public.vehicles for all using (auth.uid () = transporter_id);

drop policy IF exists "Authenticated view vehicles" on public.vehicles;

create policy "Authenticated view vehicles" on public.vehicles for
select
  using (auth.role () = 'authenticated');

-- forward contracts
drop policy IF exists "Contract parties access" on public.forward_contracts;

create policy "Contract parties access" on public.forward_contracts for
select
  using (
    auth.uid () = farmer_id
    or auth.uid () = buyer_id
  );

-- public lookup tables (no auth required)
drop policy IF exists "Public crops read" on public.crops;

create policy "Public crops read" on public.crops for
select
  using (true);

drop policy IF exists "Public mandi read" on public.mandi_prices;

create policy "Public mandi read" on public.mandi_prices for
select
  using (true);

drop policy IF exists "Public schemes read" on public.government_schemes;

create policy "Public schemes read" on public.government_schemes for
select
  using (true);

drop policy IF exists "Public weather read" on public.weather_observations;

create policy "Public weather read" on public.weather_observations for
select
  using (true);

-- ============================================================================
-- STEP 9: SEED DATA
-- ============================================================================
-- Profiles
insert into
  public.profiles (
    id,
    full_name,
    email,
    mobile,
    avatar_url,
    primary_role,
    account_status,
    verification_status,
    trust_score,
    trust_tier,
    credit_points,
    language,
    preferred_language,
    address,
    village,
    district,
    state,
    pincode,
    latitude,
    longitude
  )
values
  (
    '11111111-1111-1111-1111-111111111111',
    'Ramesh Patil',
    'ramesh.patil@krishisetu.demo',
    '',
    'https://images.unsplash.com/photo-1507003211169-0a1dd7228f2d?w=150',
    'farmer',
    'active',
    'verified',
    88.50,
    'Gold',
    240,
    'mr',
    'mr',
    'Survey 42, Lasalgaon Road',
    'Niphad',
    'Nashik',
    'Maharashtra',
    '422303',
    20.1472,
    74.2238
  ),
  (
    '11111111-1111-1111-1111-111111111112',
    'Suresh Deshmukh',
    'suresh.deshmukh@krishisetu.demo',
    '',
    'https://images.unsplash.com/photo-1500648767791-00dcc994a43e?w=150',
    'farmer',
    'active',
    'verified',
    82.00,
    'Gold',
    180,
    'mr',
    'mr',
    'Khed Farm Clusters',
    'Chakan',
    'Pune',
    'Maharashtra',
    '410501',
    18.7597,
    73.8582
  ),
  (
    '22222222-2222-2222-2222-222222222222',
    'Rajesh Gupta',
    'rajesh.gupta@agrofoods.demo',
    '',
    'https://images.unsplash.com/photo-1472099645785-5658abf4ff4e?w=150',
    'buyer',
    'active',
    'verified',
    92.00,
    'Platinum',
    350,
    'en',
    'hi',
    'Gala No. 402, APMC Market-2, Vashi',
    'Vashi',
    'Navi Mumbai',
    'Maharashtra',
    '400703',
    19.0760,
    72.9980
  ),
  (
    '22222222-2222-2222-2222-222222222223',
    'Anita Mehta',
    'anita.mehta@freshcart.demo',
    '',
    'https://images.unsplash.com/photo-1544005313-94ddf0286df2?w=150',
    'buyer',
    'active',
    'verified',
    89.00,
    'Gold',
    290,
    'en',
    'en',
    'Plot 18, Sector 19, Turbhe',
    'Turbhe',
    'Thane',
    'Maharashtra',
    '400705',
    19.0833,
    73.0167
  ),
  (
    '33333333-3333-3333-3333-333333333333',
    'Vikas Shinde',
    'vikas.shinde@kisanlogistics.demo',
    '',
    'https://images.unsplash.com/photo-1519085360753-af0119f7cbe7?w=150',
    'transporter',
    'active',
    'verified',
    91.50,
    'Platinum',
    310,
    'mr',
    'mr',
    'Transport Nagar, Mumbai-Agra Highway',
    'Dwarka',
    'Nashik',
    'Maharashtra',
    '422011',
    19.9975,
    73.7898
  ),
  (
    '44444444-4444-4444-4444-444444444444',
    'Sanjay Jadhav',
    'sanjay.jadhav@mahacold.demo',
    '',
    'https://images.unsplash.com/photo-1506794778202-cad84cf45f1d?w=150',
    'storage_partner',
    'active',
    'verified',
    94.00,
    'Platinum',
    420,
    'mr',
    'mr',
    'Pimpalgaon Industrial Corridor',
    'Pimpalgaon Baswant',
    'Nashik',
    'Maharashtra',
    '422209',
    20.1700,
    73.9800
  ),
  (
    '99999999-9999-9999-9999-999999999999',
    'KrishiSetu Admin Node',
    'admin@krishisetu.gov.in.demo',
    '+91 1800 180 1551',
    'https://images.unsplash.com/photo-1534528741775-53994a69daeb?w=150',
    'admin',
    'active',
    'verified',
    99.00,
    'Platinum',
    1000,
    'en',
    'en',
    'Agri-Tech Innovation Mission Center',
    'Shivajinagar',
    'Pune',
    'Maharashtra',
    '411005',
    18.5308,
    73.8475
  )
on conflict (id) do nothing;

-- Role-specific profiles
insert into
  public.farmer_profiles (
    profile_id,
    farm_name,
    farm_size_acres,
    farming_type,
    fpo_name,
    preferred_market,
    irrigation_available,
    storage_available,
    years_of_farming,
    verification_details
  )
values
  (
    '11111111-1111-1111-1111-111111111111',
    'Patil Krishi Organic Farms',
    8.50,
    'Integrated Organic & GAP',
    'Godavari FPO Lasalgaon',
    'Lasalgaon APMC',
    true,
    true,
    14,
    '{"7_12_extract":"VERIFIED_MH_NSK_4021","aadhaar_linked":true,"soil_health_card":"SHC-2025-9921"}'::jsonb
  ),
  (
    '11111111-1111-1111-1111-111111111112',
    'Deshmukh Agri Estate',
    12.00,
    'Conventional High-Yield',
    'Indrayani Agro Producer Co',
    'Pune APMC Market',
    true,
    false,
    9,
    '{"7_12_extract":"VERIFIED_MH_PUN_1182","aadhaar_linked":true}'::jsonb
  )
on conflict (profile_id) do nothing;

insert into
  public.buyer_profiles (
    profile_id,
    business_name,
    business_type,
    procurement_capacity,
    preferred_crops,
    preferred_locations,
    payment_terms,
    verification_info
  )
values
  (
    '22222222-2222-2222-2222-222222222222',
    'Rajesh Agro Foods Ltd.',
    'Exporter & Food Processor',
    '250 Metric Tons / Month',
    array['Onion', 'Tomato', 'Potato', 'Soybean'],
    array['Nashik', 'Pune', 'Ahmednagar', 'Solapur'],
    'Immediate Escrow Release on Quality Inspection',
    '{"gstin":"27AABCR1234F1Z8","fssai":"10019022009876","verified_buyer":true}'::jsonb
  ),
  (
    '22222222-2222-2222-2222-222222222223',
    'FreshCart Retail Logistics',
    'Modern Retail Supermarket Chain',
    '120 Metric Tons / Month',
    array['Onion', 'Tomato', 'Capsicum', 'Potato'],
    array['Nashik', 'Pune', 'Thane'],
    'T+1 Working Day via KrishiSetu Escrow',
    '{"gstin":"27AACCF5432G1Z2","fssai":"11520033001234"}'::jsonb
  )
on conflict (profile_id) do nothing;

insert into
  public.transporter_profiles (
    profile_id,
    business_name,
    service_area,
    rating,
    availability_status
  )
values
  (
    '33333333-3333-3333-3333-333333333333',
    'Kisan Agri Logistics & Fleet',
    array[
      'Nashik',
      'Pune',
      'Mumbai',
      'Navi Mumbai',
      'Thane',
      'Dhule'
    ],
    4.90,
    'available'
  )
on conflict (profile_id) do nothing;

insert into
  public.storage_partner_profiles (profile_id, business_name, facility_type)
values
  (
    '44444444-4444-4444-4444-444444444444',
    'Maha-Agri Cold Hubs & Controlled Atmosphere',
    'Multi-Chamber Cold Storage & Warehouse'
  )
on conflict (profile_id) do nothing;

-- User preferences
insert into
  public.user_preferences (
    user_id,
    language,
    notification_enabled,
    whatsapp_alerts_enabled,
    preferred_units
  )
values
  (
    '11111111-1111-1111-1111-111111111111',
    'mr',
    true,
    true,
    'quintal'
  ),
  (
    '11111111-1111-1111-1111-111111111112',
    'mr',
    true,
    true,
    'quintal'
  ),
  (
    '22222222-2222-2222-2222-222222222222',
    'en',
    true,
    true,
    'quintal'
  ),
  (
    '33333333-3333-3333-3333-333333333333',
    'mr',
    true,
    true,
    'quintal'
  ),
  (
    '44444444-4444-4444-4444-444444444444',
    'mr',
    true,
    true,
    'quintal'
  )
on conflict (user_id) do nothing;

-- Crops
insert into
  public.crops (
    id,
    name,
    local_name,
    hindi_name,
    category,
    crop_type,
    common_varieties,
    unit,
    perishability_level,
    typical_storage_days,
    optimal_storage_temperature,
    optimal_storage_humidity
  )
values
  (
    '00000000-0000-0000-0000-000000000001',
    'Onion',
    'कांदा (Kanda)',
    'प्याज (Pyaz)',
    'vegetable',
    'Rabi / Kharif',
    array[
      'Garwa (Rabi)',
      'Fursungi Red',
      'Bhima Super',
      'Nashik Red'
    ],
    'kg',
    'medium',
    120,
    '0°C to 2°C (Cold) or Well-ventilated Ambient',
    '65% - 70%'
  ),
  (
    '00000000-0000-0000-0000-000000000002',
    'Tomato',
    'टोमॅटो (Tomato)',
    'टमाटर (Tamatar)',
    'vegetable',
    'Kharif / Rabi',
    array['Abhinav', 'Saaho 3251', 'Heemsona', 'Vaibhav'],
    'kg',
    'high',
    14,
    '10°C to 13°C',
    '85% - 90%'
  ),
  (
    '00000000-0000-0000-0000-000000000003',
    'Potato',
    'बटाटा (Batata)',
    'आलू (Aloo)',
    'vegetable',
    'Rabi',
    array[
      'Kufri Jyoti',
      'Kufri Pukhraj',
      'Kufri Chipsona',
      'Lady Rosetta'
    ],
    'kg',
    'medium',
    180,
    '4°C to 8°C with CIPC',
    '85% - 95%'
  ),
  (
    '00000000-0000-0000-0000-000000000004',
    'Wheat',
    'गहू (Gahu)',
    'गेहूं (Gehun)',
    'grain',
    'Rabi',
    array['Lokwan', 'Sharbati 1544', 'HD 2967', 'GW 496'],
    'kg',
    'low',
    365,
    'Ambient dry storage',
    'Under 60%'
  ),
  (
    '00000000-0000-0000-0000-000000000005',
    'Soybean',
    'सोयाबीन (Soybean)',
    'सोयाबीन (Soybean)',
    'oilseed',
    'Kharif',
    array[
      'JS 335',
      'JS 9560',
      'MACS 1407',
      'KDS 726 (Phule Sangam)'
    ],
    'kg',
    'low',
    270,
    'Dry warehouse below 12% moisture',
    '60% - 65%'
  ),
  (
    '00000000-0000-0000-0000-000000000006',
    'Cotton',
    'कापूस (Kapas)',
    'कपास (Kapas)',
    'cash_crop',
    'Kharif',
    array['Bt Cotton Hybrid', 'Mallika', 'RCH 659'],
    'kg',
    'low',
    360,
    'Dry protected warehouse',
    'Below 65%'
  )
on conflict (id) do nothing;

-- Storage facility
insert into
  public.storage_facilities (
    id,
    owner_profile_id,
    facility_name,
    facility_type,
    location,
    district,
    state,
    pincode,
    latitude,
    longitude,
    total_capacity_kg,
    available_capacity_kg,
    supported_crops,
    temperature_controlled,
    cold_storage,
    price_per_kg_per_day,
    rating,
    verification_status,
    status
  )
values
  (
    '55555555-5555-5555-5555-555555555551',
    '44444444-4444-4444-4444-444444444444',
    'Pimpalgaon Mega Cold Chain & Warehouse Hub',
    'Cold Storage & Controlled Atmosphere',
    'Plot 14-16, Pimpalgaon MIDC, NH-3',
    'Nashik',
    'Maharashtra',
    '422209',
    20.1744,
    73.9882,
    500000.00,
    380000.00,
    array['Onion', 'Tomato', 'Potato', 'Grapes'],
    true,
    true,
    0.0450,
    4.95,
    'verified',
    'active'
  )
on conflict (id) do nothing;

-- Vehicles
insert into
  public.vehicles (
    id,
    transporter_id,
    vehicle_type,
    registration_number,
    capacity_kg,
    refrigeration_available,
    service_area,
    status
  )
values
  (
    '66666666-6666-6666-6666-666666666661',
    '33333333-3333-3333-3333-333333333333',
    'Bolero Maxi Truck Plus (1.5 MT)',
    'MH-15-EG-4492',
    1500.00,
    false,
    array['Nashik', 'Pune', 'Mumbai', 'Thane'],
    'available'
  ),
  (
    '66666666-6666-6666-6666-666666666662',
    '33333333-3333-3333-3333-333333333333',
    'Eicher Pro 2049 Refrigerated Reefer (3.5 MT)',
    'MH-15-FV-8810',
    3500.00,
    true,
    array[
      'Nashik',
      'Mumbai',
      'Navi Mumbai',
      'Pune',
      'Surat'
    ],
    'available'
  )
on conflict (id) do nothing;

-- Crop inventory
insert into
  public.crop_inventory (
    id,
    farmer_id,
    crop_id,
    variety,
    batch_code,
    quantity_kg,
    available_quantity_kg,
    quality_grade,
    moisture_percentage,
    harvest_date,
    freshness_score,
    freshness_status,
    storage_condition,
    storage_facility_id,
    shelf_life_estimate_days,
    notes,
    image_url,
    status
  )
values
  (
    '77777777-7777-7777-7777-777777777771',
    '11111111-1111-1111-1111-111111111111',
    '00000000-0000-0000-0000-000000000001',
    'Nashik Red (Garwa)',
    'INV-NSK-2026-ON-01',
    500.00,
    400.00,
    'Grade A',
    11.20,
    CURRENT_DATE - INTERVAL '3 days',
    96.00,
    'Peak Fresh',
    'Shaded Farm Chawl (Well Ventilated)',
    null,
    90,
    'Even medium size (55mm+), deep red color, double-skinned, zero sprouting.',
    'https://images.unsplash.com/photo-1618512496248-a07fe83aa8cb?w=600',
    'partially_allocated'
  ),
  (
    '77777777-7777-7777-7777-777777777772',
    '11111111-1111-1111-1111-111111111111',
    '00000000-0000-0000-0000-000000000002',
    'Saaho 3251 Premium',
    'INV-NSK-2026-TM-02',
    1200.00,
    1200.00,
    'Grade A',
    89.00,
    CURRENT_DATE - INTERVAL '1 day',
    98.50,
    'Peak Fresh',
    'Crated Ambient',
    null,
    12,
    'Firm red, export grade, uniform shape.',
    'https://images.unsplash.com/photo-1592924357228-91a4daadcfea?w=600',
    'available'
  ),
  (
    '77777777-7777-7777-7777-777777777773',
    '11111111-1111-1111-1111-111111111112',
    '00000000-0000-0000-0000-000000000003',
    'Kufri Chipsona 1',
    'INV-PUN-2026-PT-03',
    4000.00,
    4000.00,
    'Grade A',
    18.50,
    CURRENT_DATE - INTERVAL '10 days',
    92.00,
    'Good',
    'Covered Farm Yard',
    null,
    150,
    'High solids, ideal for commercial processing.',
    'https://images.unsplash.com/photo-1518977676601-b53f82aba655?w=600',
    'available'
  )
on conflict (id) do nothing;

-- Produce lots
insert into
  public.produce_lots (
    id,
    farmer_id,
    inventory_id,
    crop_id,
    lot_code,
    variety,
    quantity_kg,
    available_quantity_kg,
    quality_grade,
    moisture_percentage,
    harvest_date,
    freshness_score,
    storage_condition,
    asking_price_per_quintal,
    minimum_offer_price_per_quintal,
    pickup_location,
    pickup_latitude,
    pickup_longitude,
    quality_notes,
    status,
    published_at
  )
values
  (
    '88888888-8888-8888-8888-888888888881',
    '11111111-1111-1111-1111-111111111111',
    '77777777-7777-7777-7777-777777777771',
    '00000000-0000-0000-0000-000000000001',
    'LOT-2026-ON-001',
    'Nashik Red (Garwa)',
    500.00,
    400.00,
    'Grade A',
    11.20,
    CURRENT_DATE - INTERVAL '3 days',
    96.00,
    'Shaded Farm Chawl (Well Ventilated)',
    2450.00,
    2300.00,
    'Niphad Village Gate, Lasalgaon Road, Nashik, Maharashtra 422303',
    20.1472,
    74.2238,
    'Hand-sorted 55-65mm bulb size. Cured for 7 days. Low neck thickness.',
    'partially_sold',
    NOW() - INTERVAL '2 days'
  ),
  (
    '88888888-8888-8888-8888-888888888882',
    '11111111-1111-1111-1111-111111111111',
    '77777777-7777-7777-7777-777777777772',
    '00000000-0000-0000-0000-000000000002',
    'LOT-2026-TM-002',
    'Saaho 3251 Premium',
    1000.00,
    1000.00,
    'Grade A',
    89.00,
    CURRENT_DATE - INTERVAL '1 day',
    98.50,
    'Crated Ambient',
    1850.00,
    1700.00,
    'Niphad Farm Yard, Nashik',
    20.1472,
    74.2238,
    'Bright red, firm skin, ideal for long distance transport to Mumbai/Delhi.',
    'published',
    NOW() - INTERVAL '1 day'
  ),
  (
    '88888888-8888-8888-8888-888888888883',
    '11111111-1111-1111-1111-111111111112',
    '77777777-7777-7777-7777-777777777773',
    '00000000-0000-0000-0000-000000000003',
    'LOT-2026-PT-003',
    'Kufri Chipsona 1',
    3000.00,
    3000.00,
    'Grade A',
    18.50,
    CURRENT_DATE - INTERVAL '10 days',
    92.00,
    'Covered Farm Yard',
    1600.00,
    1500.00,
    'Chakan Agro Belt, Pune, Maharashtra 410501',
    18.7597,
    73.8582,
    'Zero greening, high dry matter (>21%), excellent for chips manufacturing.',
    'published',
    NOW() - INTERVAL '3 days'
  )
on conflict (id) do nothing;

-- Lot images
insert into
  public.produce_lot_images (
    lot_id,
    storage_path,
    public_url,
    image_type,
    uploaded_by
  )
values
  (
    '88888888-8888-8888-8888-888888888881',
    'lots/lot-2026-on-001/primary.jpg',
    'https://images.unsplash.com/photo-1618512496248-a07fe83aa8cb?w=800',
    'primary',
    '11111111-1111-1111-1111-111111111111'
  ),
  (
    '88888888-8888-8888-8888-888888888882',
    'lots/lot-2026-tm-002/primary.jpg',
    'https://images.unsplash.com/photo-1592924357228-91a4daadcfea?w=800',
    'primary',
    '11111111-1111-1111-1111-111111111111'
  );

-- Buyer offers
insert into
  public.buyer_offers (
    id,
    lot_id,
    buyer_id,
    offered_quantity_kg,
    offered_price_per_quintal,
    proposed_pickup_date,
    proposed_delivery_date,
    payment_terms,
    message,
    status,
    parent_offer_id,
    counter_offer_number
  )
values
  (
    'aaaaaaaa-aaaa-aaaa-aaaa-aaaaaaaaaaaa',
    '88888888-8888-8888-8888-888888888881',
    '22222222-2222-2222-2222-222222222222',
    100.00,
    2400.00,
    CURRENT_DATE - INTERVAL '2 days',
    CURRENT_DATE - INTERVAL '1 day',
    'Escrow payment deposited with KrishiSetu. Immediate dispatch requested.',
    'We require 100 kg Grade A sample for export consignment approval. Immediate pickup.',
    'accepted',
    null,
    0
  ),
  (
    'aaaaaaaa-aaaa-aaaa-aaaa-bbbbbbbbbbbb',
    '88888888-8888-8888-8888-888888888881',
    '22222222-2222-2222-2222-222222222223',
    250.00,
    2380.00,
    CURRENT_DATE + INTERVAL '1 day',
    CURRENT_DATE + INTERVAL '2 days',
    'T+1 Bank Transfer post quality check',
    'Ready to procure 250 kg for Thane supermarket distribution.',
    'pending',
    null,
    0
  )
on conflict (id) do nothing;

-- Orders
insert into
  public.orders (
    id,
    order_number,
    buyer_id,
    farmer_id,
    accepted_offer_id,
    status,
    subtotal,
    transport_cost,
    storage_cost,
    platform_fee,
    total_amount,
    payment_status,
    payment_method,
    pickup_location,
    delivery_location,
    expected_delivery_date,
    actual_delivery_date,
    created_at
  )
values
  (
    'bbbbbbbb-bbbb-bbbb-bbbb-bbbbbbbbbbbb',
    'ORD-20260824-ON-001',
    '22222222-2222-2222-2222-222222222222',
    '11111111-1111-1111-1111-111111111111',
    'aaaaaaaa-aaaa-aaaa-aaaa-aaaaaaaaaaaa',
    'completed',
    2400.00,
    850.00,
    0.00,
    36.00,
    3286.00,
    'marked_paid',
    'KrishiSetu Escrow Protected',
    'Niphad Village Gate, Lasalgaon Road, Nashik 422303',
    'Rajesh Agro Foods Gala No. 402, APMC Market-2, Vashi, Navi Mumbai 400703',
    CURRENT_DATE - INTERVAL '1 day',
    CURRENT_DATE - INTERVAL '1 day',
    NOW() - INTERVAL '2 days'
  )
on conflict (id) do nothing;

insert into
  public.order_items (
    order_id,
    lot_id,
    crop_id,
    quantity_kg,
    price_per_quintal,
    subtotal
  )
values
  (
    'bbbbbbbb-bbbb-bbbb-bbbb-bbbbbbbbbbbb',
    '88888888-8888-8888-8888-888888888881',
    '00000000-0000-0000-0000-000000000001',
    100.00,
    2400.00,
    2400.00
  );

-- Transport
insert into
  public.transport_requests (
    id,
    order_id,
    requested_by,
    transporter_id,
    pickup_location,
    pickup_latitude,
    pickup_longitude,
    destination_location,
    destination_latitude,
    destination_longitude,
    requested_date,
    estimated_distance_km,
    estimated_cost,
    status,
    created_at
  )
values
  (
    'cccccccc-cccc-cccc-cccc-cccccccccccc',
    'bbbbbbbb-bbbb-bbbb-bbbb-bbbbbbbbbbbb',
    '11111111-1111-1111-1111-111111111111',
    '33333333-3333-3333-3333-333333333333',
    'Niphad Village Gate, Lasalgaon Road, Nashik',
    20.1472,
    74.2238,
    'Rajesh Agro Foods, APMC Market-2, Vashi, Navi Mumbai',
    19.0760,
    72.9980,
    CURRENT_DATE - INTERVAL '2 days',
    185.00,
    850.00,
    'completed',
    NOW() - INTERVAL '2 days'
  )
on conflict (id) do nothing;

insert into
  public.deliveries (
    id,
    transport_request_id,
    vehicle_id,
    driver_name,
    driver_mobile,
    pickup_started_at,
    picked_up_at,
    in_transit_at,
    delivered_at,
    completed_at,
    current_latitude,
    current_longitude,
    delivery_notes,
    proof_of_delivery_url,
    status,
    created_at
  )
values
  (
    'dddddddd-dddd-dddd-dddd-dddddddddddd',
    'cccccccc-cccc-cccc-cccc-cccccccccccc',
    '66666666-6666-6666-6666-666666666661',
    'Santosh Kadam',
    '',
    NOW() - INTERVAL '40 hours',
    NOW() - INTERVAL '38 hours',
    NOW() - INTERVAL '36 hours',
    NOW() - INTERVAL '26 hours',
    NOW() - INTERVAL '24 hours',
    19.0760,
    72.9980,
    'Delivered 100 kg Grade A Onion bags in prime condition. POD signed and stamped by buyer receiving manager.',
    'https://images.unsplash.com/photo-1586528116311-ad8dd3c8310d?w=800',
    'completed',
    NOW() - INTERVAL '2 days'
  )
on conflict (id) do nothing;

insert into
  public.delivery_status_history (
    delivery_id,
    status,
    latitude,
    longitude,
    notes,
    changed_by,
    created_at
  )
values
  (
    'dddddddd-dddd-dddd-dddd-dddddddddddd',
    'assigned',
    20.1472,
    74.2238,
    'Driver Santosh Kadam dispatched to Niphad farm.',
    '33333333-3333-3333-3333-333333333333',
    NOW() - INTERVAL '42 hours'
  ),
  (
    'dddddddd-dddd-dddd-dddd-dddddddddddd',
    'pickup_started',
    20.1472,
    74.2238,
    'Vehicle arrived at farmer gate. Loading 100 kg mesh bags.',
    '33333333-3333-3333-3333-333333333333',
    NOW() - INTERVAL '40 hours'
  ),
  (
    'dddddddd-dddd-dddd-dddd-dddddddddddd',
    'picked_up',
    20.1472,
    74.2238,
    'Produce loaded. Digital weight receipt generated.',
    '33333333-3333-3333-3333-333333333333',
    NOW() - INTERVAL '38 hours'
  ),
  (
    'dddddddd-dddd-dddd-dddd-dddddddddddd',
    'in_transit',
    19.5300,
    73.5000,
    'Crossing Kasara Ghat on NH-3 heading to Mumbai.',
    '33333333-3333-3333-3333-333333333333',
    NOW() - INTERVAL '32 hours'
  ),
  (
    'dddddddd-dddd-dddd-dddd-dddddddddddd',
    'delivered',
    19.0760,
    72.9980,
    'Arrived at Vashi APMC Unit. Unloaded and verified.',
    '33333333-3333-3333-3333-333333333333',
    NOW() - INTERVAL '26 hours'
  ),
  (
    'dddddddd-dddd-dddd-dddd-dddddddddddd',
    'completed',
    19.0760,
    72.9980,
    'Inspection signed. Escrow payout unlocked.',
    '33333333-3333-3333-3333-333333333333',
    NOW() - INTERVAL '24 hours'
  );

-- Ratings
insert into
  public.ratings (
    transaction_type,
    order_id,
    reviewer_id,
    reviewee_id,
    rating,
    review_text
  )
values
  (
    'order',
    'bbbbbbbb-bbbb-bbbb-bbbb-bbbbbbbbbbbb',
    '22222222-2222-2222-2222-222222222222',
    '11111111-1111-1111-1111-111111111111',
    5,
    'Excellent quality Grade A Onion! Accurate moisture and size grading. Looking forward to long-term contract.'
  ),
  (
    'order',
    'bbbbbbbb-bbbb-bbbb-bbbb-bbbbbbbbbbbb',
    '11111111-1111-1111-1111-111111111111',
    '22222222-2222-2222-2222-222222222222',
    5,
    'Fast approval, polite communication, prompt escrow payment release.'
  );

insert into
  public.ratings (
    transaction_type,
    transport_request_id,
    reviewer_id,
    reviewee_id,
    rating,
    review_text
  )
values
  (
    'transport',
    'cccccccc-cccc-cccc-cccc-cccccccccccc',
    '11111111-1111-1111-1111-111111111111',
    '33333333-3333-3333-3333-333333333333',
    5,
    'Vehicle arrived exactly on time at Niphad gate. Careful loading and live GPS tracking.'
  );

-- Lot events
insert into
  public.lot_events (
    lot_id,
    event_type,
    description,
    location,
    actor_id,
    metadata
  )
values
  (
    '88888888-8888-8888-8888-888888888881',
    'created',
    'Harvested 500 kg Nashik Red Garwa Onion. Sun-cured on field.',
    'Niphad, Nashik',
    '11111111-1111-1111-1111-111111111111',
    '{"batch":"INV-NSK-2026-ON-01"}'::jsonb
  ),
  (
    '88888888-8888-8888-8888-888888888881',
    'quality_checked',
    'AI Ag-Vision and manual moisture test verified: 11.2% moisture, 96/100 freshness score.',
    'Niphad Farm Lab',
    '11111111-1111-1111-1111-111111111111',
    '{"grade":"Grade A","tester":"Ramesh Patil"}'::jsonb
  ),
  (
    '88888888-8888-8888-8888-888888888881',
    'published',
    'Lot LOT-2026-ON-001 published to KrishiSetu marketplace at Rs.2,450/qtl.',
    'KrishiSetu Cloud',
    '11111111-1111-1111-1111-111111111111',
    '{"asking_price":2450}'::jsonb
  ),
  (
    '88888888-8888-8888-8888-888888888881',
    'offer_received',
    'Buyer Rajesh Agro Foods submitted offer for 100 kg at Rs.2,400/qtl.',
    'KrishiSetu Marketplace',
    '22222222-2222-2222-2222-222222222222',
    '{"offer_price":2400,"qty_kg":100}'::jsonb
  ),
  (
    '88888888-8888-8888-8888-888888888881',
    'offer_accepted',
    'Farmer accepted offer. Order ORD-20260824-ON-001 generated.',
    'Niphad, Nashik',
    '11111111-1111-1111-1111-111111111111',
    '{"order_id":"bbbbbbbb-bbbb-bbbb-bbbb-bbbbbbbbbbbb"}'::jsonb
  ),
  (
    '88888888-8888-8888-8888-888888888881',
    'picked_up',
    'Loaded 100 kg into Kisan Logistics Bolero MH-15-EG-4492.',
    'Niphad Farm Gate',
    '33333333-3333-3333-3333-333333333333',
    '{"driver":"Santosh Kadam"}'::jsonb
  ),
  (
    '88888888-8888-8888-8888-888888888881',
    'delivered',
    'Safely delivered to Rajesh Agro Foods Vashi APMC Hub.',
    'Vashi, Navi Mumbai',
    '33333333-3333-3333-3333-333333333333',
    '{"pod_verified":true}'::jsonb
  );

-- Mandi prices
insert into
  public.mandi_prices (
    crop_id,
    market_name,
    market_code,
    district,
    state,
    min_price,
    modal_price,
    max_price,
    unit,
    price_date,
    source,
    data_status
  )
values
  (
    '00000000-0000-0000-0000-000000000001',
    'Lasalgaon APMC',
    'MH-NSK-01',
    'Nashik',
    'Maharashtra',
    1900.00,
    2350.00,
    2600.00,
    'Quintal',
    CURRENT_DATE,
    'Agmarknet APMC Feed',
    'demo'
  ),
  (
    '00000000-0000-0000-0000-000000000001',
    'Lasalgaon APMC',
    'MH-NSK-01',
    'Nashik',
    'Maharashtra',
    1850.00,
    2280.00,
    2550.00,
    'Quintal',
    CURRENT_DATE - INTERVAL '1 day',
    'Agmarknet APMC Feed',
    'demo'
  ),
  (
    '00000000-0000-0000-0000-000000000001',
    'Lasalgaon APMC',
    'MH-NSK-01',
    'Nashik',
    'Maharashtra',
    1800.00,
    2200.00,
    2500.00,
    'Quintal',
    CURRENT_DATE - INTERVAL '2 days',
    'Agmarknet APMC Feed',
    'demo'
  ),
  (
    '00000000-0000-0000-0000-000000000001',
    'Lasalgaon APMC',
    'MH-NSK-01',
    'Nashik',
    'Maharashtra',
    1750.00,
    2150.00,
    2450.00,
    'Quintal',
    CURRENT_DATE - INTERVAL '3 days',
    'Agmarknet APMC Feed',
    'demo'
  ),
  (
    '00000000-0000-0000-0000-000000000001',
    'Lasalgaon APMC',
    'MH-NSK-01',
    'Nashik',
    'Maharashtra',
    1700.00,
    2100.00,
    2400.00,
    'Quintal',
    CURRENT_DATE - INTERVAL '4 days',
    'Agmarknet APMC Feed',
    'demo'
  ),
  (
    '00000000-0000-0000-0000-000000000001',
    'Nashik APMC',
    'MH-NSK-02',
    'Nashik',
    'Maharashtra',
    1950.00,
    2400.00,
    2680.00,
    'Quintal',
    CURRENT_DATE,
    'Agmarknet APMC Feed',
    'demo'
  ),
  (
    '00000000-0000-0000-0000-000000000001',
    'Pune APMC',
    'MH-PUN-01',
    'Pune',
    'Maharashtra',
    2100.00,
    2550.00,
    2800.00,
    'Quintal',
    CURRENT_DATE,
    'Agmarknet APMC Feed',
    'demo'
  ),
  (
    '00000000-0000-0000-0000-000000000001',
    'Mumbai Vashi APMC',
    'MH-MUM-01',
    'Mumbai',
    'Maharashtra',
    2300.00,
    2750.00,
    3100.00,
    'Quintal',
    CURRENT_DATE,
    'Agmarknet APMC Feed',
    'demo'
  ),
  (
    '00000000-0000-0000-0000-000000000002',
    'Pimpalgaon APMC',
    'MH-NSK-03',
    'Nashik',
    'Maharashtra',
    1400.00,
    1750.00,
    2100.00,
    'Quintal',
    CURRENT_DATE,
    'Agmarknet APMC Feed',
    'demo'
  ),
  (
    '00000000-0000-0000-0000-000000000002',
    'Narayangaon APMC',
    'MH-PUN-02',
    'Pune',
    'Maharashtra',
    1500.00,
    1820.00,
    2150.00,
    'Quintal',
    CURRENT_DATE,
    'Agmarknet APMC Feed',
    'demo'
  ),
  (
    '00000000-0000-0000-0000-000000000002',
    'Mumbai Vashi APMC',
    'MH-MUM-01',
    'Mumbai',
    'Maharashtra',
    1800.00,
    2200.00,
    2600.00,
    'Quintal',
    CURRENT_DATE,
    'Agmarknet APMC Feed',
    'demo'
  ),
  (
    '00000000-0000-0000-0000-000000000003',
    'Manchar APMC',
    'MH-PUN-03',
    'Pune',
    'Maharashtra',
    1200.00,
    1550.00,
    1800.00,
    'Quintal',
    CURRENT_DATE,
    'Agmarknet APMC Feed',
    'demo'
  ),
  (
    '00000000-0000-0000-0000-000000000003',
    'Mumbai Vashi APMC',
    'MH-MUM-01',
    'Mumbai',
    'Maharashtra',
    1450.00,
    1800.00,
    2100.00,
    'Quintal',
    CURRENT_DATE,
    'Agmarknet APMC Feed',
    'demo'
  ),
  (
    '00000000-0000-0000-0000-000000000005',
    'Latur APMC',
    'MH-LTR-01',
    'Latur',
    'Maharashtra',
    4200.00,
    4650.00,
    4900.00,
    'Quintal',
    CURRENT_DATE,
    'Agmarknet APMC Feed',
    'demo'
  )
on conflict (crop_id, market_code, price_date) do nothing;

-- Government schemes
insert into
  public.government_schemes (
    id,
    name,
    short_description,
    full_description,
    category,
    eligibility,
    benefits,
    documents_required,
    application_url,
    official_source,
    state,
    central_or_state,
    status,
    data_status
  )
values
  (
    'eeeeeeee-eeee-eeee-eeee-eeeeeeeeeeee',
    'Pradhan Mantri Fasal Bima Yojana (PMFBY)',
    'Comprehensive crop insurance against natural calamities, pests and diseases.',
    'PMFBY provides financial support to farmers suffering crop loss/damage arising out of unforeseen events. It covers all food & oilseed crops and annual commercial/horticultural crops.',
    'crop insurance',
    'All farmers growing notified crops in notified areas including sharecroppers and tenant farmers.',
    'Uniform maximum premium of 2% for Kharif, 1.5% for Rabi, 5% for commercial/horticultural crops. Balance subsidized by Govt.',
    array[
      'Aadhaar Card',
      'Land Record (7/12 Extract)',
      'Sowing Certificate',
      'Bank Passbook'
    ],
    'https://pmfby.gov.in',
    'Ministry of Agriculture & Farmers Welfare, Govt of India',
    null,
    'Central',
    'active',
    'demo_verified'
  ),
  (
    'eeeeeeee-eeee-eeee-eeee-ffffffffffff',
    'Agriculture Infrastructure Fund (AIF)',
    'Financing facility for post-harvest management infrastructure and community farming assets.',
    'AIF provides medium-to-long term debt financing facility for investment in viable projects for post-harvest management infrastructure and cold storage hubs.',
    'infrastructure',
    'Farmers, FPOs, PACS, Agri-entrepreneurs, Startups, Central/State agency sponsored projects.',
    'Interest subvention of 3% per annum up to a limit of Rs.2 Crore for a maximum period of 7 years, plus CGTMSE credit guarantee.',
    array[
      'Detailed Project Report (DPR)',
      'Land Ownership / Lease Agreement',
      'PAN & GSTIN',
      'Bank Loan Sanction Letter'
    ],
    'https://agriinfra.dac.gov.in',
    'Department of Agriculture, Cooperation & Farmers Welfare',
    null,
    'Central',
    'active',
    'demo_verified'
  ),
  (
    'eeeeeeee-eeee-eeee-eeee-111111111111',
    'Maha-DBT Magel Tyala Shet-Tale (Farm Pond On Demand)',
    'State subsidy for farm pond construction and micro-irrigation in Maharashtra.',
    'Under this scheme, farmers in drought-prone and agricultural belts are provided direct benefit transfer subsidy to construct in-situ water storage ponds.',
    'infrastructure',
    'Farmers in Maharashtra with at least 0.60 hectares land holding and clear 7/12 extract.',
    'Direct subsidy of up to Rs.50,000 to Rs.75,000 transferred to bank account upon geo-tagged inspection.',
    array[
      '7/12 Extract',
      '8A Extract',
      'Aadhaar Card',
      'Geo-tagged Site Photo'
    ],
    'https://mahadbt.maharashtra.gov.in',
    'Agriculture Department, Government of Maharashtra',
    'Maharashtra',
    'State',
    'active',
    'demo_verified'
  )
on conflict (id) do nothing;

-- AI Crop diagnosis
insert into
  public.crop_diagnoses (
    user_id,
    crop_id,
    inventory_id,
    image_url,
    diagnosis,
    detected_issue,
    confidence_score,
    severity,
    recommendations,
    ai_model,
    status
  )
values
  (
    '11111111-1111-1111-1111-111111111111',
    '00000000-0000-0000-0000-000000000001',
    '77777777-7777-7777-7777-777777777771',
    'https://images.unsplash.com/photo-1618512496248-a07fe83aa8cb?w=600',
    'Minor purple blotch symptoms detected on dry outer peel; interior bulb fully healthy.',
    'Purple Blotch (Alternaria porri) - Low Grade Initial Stage',
    94.20,
    'Low',
    'Maintain proper ambient ventilation with humidity under 70%. Ensure bulbs remain dry before crating.',
    'Gemini 2.5 Flash Ag-Vision',
    'completed'
  );

-- Risk simulation
insert into
  public.risk_simulations (
    user_id,
    crop_id,
    inventory_id,
    quantity_kg,
    scenario_name,
    assumed_price,
    storage_cost,
    transport_cost,
    estimated_revenue,
    estimated_cost,
    estimated_profit,
    weather_risk,
    spoilage_risk,
    overall_risk,
    assumptions
  )
values
  (
    '11111111-1111-1111-1111-111111111111',
    '00000000-0000-0000-0000-000000000001',
    '77777777-7777-7777-7777-777777777771',
    500.00,
    'Hold in Cold Storage for 45 Days vs Spot Sale',
    3100.00,
    1012.50,
    850.00,
    15500.00,
    1862.50,
    13637.50,
    'Low (Controlled Atmosphere)',
    'Minimal (Under 2% weight loss)',
    'Low-Medium',
    '{"current_spot_realisation":11400,"projected_net_gain":2237.50,"roi_increase_pct":19.6}'::jsonb
  );

-- Realisation calculations
insert into
  public.realisation_calculations (
    user_id,
    crop_id,
    quantity_kg,
    channel_type,
    buyer_or_market_name,
    quoted_price_per_quintal,
    logistics_cost,
    storage_cost,
    platform_fee,
    other_cost,
    gross_revenue,
    net_revenue,
    profit,
    profit_per_kg,
    margin_percentage,
    reliability_score
  )
values
  (
    '11111111-1111-1111-1111-111111111111',
    '00000000-0000-0000-0000-000000000001',
    500.00,
    'Direct Buyer',
    'Rajesh Agro Foods (KrishiSetu Verified)',
    2400.00,
    850.00,
    0.00,
    180.00,
    50.00,
    12000.00,
    10920.00,
    3420.00,
    6.84,
    28.50,
    98.00
  ),
  (
    '11111111-1111-1111-1111-111111111111',
    '00000000-0000-0000-0000-000000000001',
    500.00,
    'Mandi Sale',
    'Lasalgaon APMC Traditional Auction',
    2150.00,
    600.00,
    0.00,
    350.00,
    200.00,
    10750.00,
    9600.00,
    2100.00,
    4.20,
    19.53,
    75.00
  );

-- Weather
insert into
  public.weather_observations (
    location,
    latitude,
    longitude,
    observation_date,
    temperature,
    rainfall_mm,
    humidity,
    weather_condition,
    source,
    data_status
  )
values
  (
    'Lasalgaon / Niphad, Nashik',
    20.1472,
    74.2238,
    CURRENT_DATE,
    28.5,
    0.0,
    58.0,
    'Clear Sky',
    'IMD Agro-Meteorology (Demo)',
    'demo'
  ),
  (
    'Lasalgaon / Niphad, Nashik',
    20.1472,
    74.2238,
    CURRENT_DATE - INTERVAL '1 day',
    29.0,
    0.0,
    55.0,
    'Clear Sky',
    'IMD Agro-Meteorology (Demo)',
    'demo'
  ),
  (
    'Pune Chakan Agri Belt',
    18.7597,
    73.8582,
    CURRENT_DATE,
    27.2,
    0.0,
    62.0,
    'Partly Cloudy',
    'IMD Agro-Meteorology (Demo)',
    'demo'
  );

-- Notifications
insert into
  public.notifications (
    user_id,
    type,
    title,
    message,
    related_entity_type,
    related_entity_id,
    is_read
  )
values
  (
    '11111111-1111-1111-1111-111111111111',
    'offer_received',
    'New Offer Received for Onion Lot',
    'FreshCart Retail Logistics submitted an offer of Rs.2,380/qtl for 250 kg.',
    'offer',
    'aaaaaaaa-aaaa-aaaa-aaaa-bbbbbbbbbbbb',
    false
  ),
  (
    '11111111-1111-1111-1111-111111111111',
    'order_completed',
    'Order ORD-20260824-ON-001 Completed',
    'Consignment delivered to Rajesh Agro Foods. Escrow payment credited to your linked account.',
    'order',
    'bbbbbbbb-bbbb-bbbb-bbbb-bbbbbbbbbbbb',
    true
  );

-- Trust score recalculation
select
  public.fn_recalculate_trust_score ('11111111-1111-1111-1111-111111111111');

select
  public.fn_recalculate_trust_score ('22222222-2222-2222-2222-222222222222');

select
  public.fn_recalculate_trust_score ('33333333-3333-3333-3333-333333333333');

select
  public.fn_recalculate_trust_score ('44444444-4444-4444-4444-444444444444');

-- ============================================================================
-- DONE! Your KrishiSetu database is ready.
-- ============================================================================
