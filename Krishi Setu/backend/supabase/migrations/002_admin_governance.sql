-- ============================================================================
-- KRISHISETU: ADMIN & SUPERVISOR GOVERNANCE SCHEMA (Restoration version)
-- Compatible with Supabase PostgreSQL & Row Level Security (RLS)
-- Derived from 002_admin_governance.sql with demo auth user seeds omitted
-- (real supervisors/admins are assigned roles via verified auth.users IDs).
-- ============================================================================

-- 1. EXTENSIONS
CREATE EXTENSION IF NOT EXISTS "uuid-ossp";
CREATE EXTENSION IF NOT EXISTS "pgcrypto";

-- 2. ENUMS & TYPES
DO $$ BEGIN
    CREATE TYPE public.admin_supervisor_role AS ENUM ('supervisor', 'admin');
EXCEPTION WHEN duplicate_object THEN NULL; END $$;

DO $$ BEGIN
    CREATE TYPE public.alert_status AS ENUM ('NEW', 'ACKNOWLEDGED', 'UNDER REVIEW', 'RESOLVED', 'FALSE POSITIVE');
EXCEPTION WHEN duplicate_object THEN NULL; END $$;

DO $$ BEGIN
    CREATE TYPE public.alert_severity AS ENUM ('LOW', 'MEDIUM', 'HIGH', 'CRITICAL');
EXCEPTION WHEN duplicate_object THEN NULL; END $$;

DO $$ BEGIN
    CREATE TYPE public.case_status AS ENUM ('OPEN', 'UNDER REVIEW', 'ACTION REQUIRED', 'RESOLVED');
EXCEPTION WHEN duplicate_object THEN NULL; END $$;

DO $$ BEGIN
    CREATE TYPE public.risk_level AS ENUM ('LOW', 'MEDIUM', 'HIGH');
EXCEPTION WHEN duplicate_object THEN NULL; END $$;

-- 3. SUPERVISOR & ADMIN ROLES TABLE
CREATE TABLE IF NOT EXISTS public.supervisor_roles (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    user_id UUID REFERENCES auth.users(id) ON DELETE CASCADE,
    email TEXT NOT NULL,
    full_name TEXT NOT NULL,
    role public.admin_supervisor_role NOT NULL DEFAULT 'supervisor',
    department TEXT DEFAULT 'Compliance & Market Integrity',
    can_suspend_users BOOLEAN DEFAULT false,
    can_modify_rules BOOLEAN DEFAULT false,
    can_manage_escrow BOOLEAN DEFAULT false,
    is_active BOOLEAN DEFAULT true,
    created_at TIMESTAMPTZ DEFAULT NOW(),
    updated_at TIMESTAMPTZ DEFAULT NOW()
);

-- 4. IMMUTABLE AUDIT LOGS TABLE
-- Once written, records in this table must never be updated or deleted.
CREATE TABLE IF NOT EXISTS public.audit_logs (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    actor_id UUID REFERENCES auth.users(id) ON DELETE SET NULL,
    actor_name TEXT NOT NULL,
    actor_role TEXT NOT NULL,
    action TEXT NOT NULL,
    entity_type TEXT NOT NULL,
    entity_id TEXT NOT NULL,
    previous_value JSONB,
    new_value JSONB,
    reason TEXT,
    ip_address TEXT,
    created_at TIMESTAMPTZ DEFAULT NOW() NOT NULL
);

-- Enforce immutability via trigger
CREATE OR REPLACE FUNCTION prevent_audit_log_modification()
RETURNS TRIGGER AS $$
BEGIN
    RAISE EXCEPTION 'Audit logs are immutable and cannot be modified or deleted.';
END;
$$ LANGUAGE plpgsql;

DROP TRIGGER IF EXISTS trg_immutable_audit_logs ON public.audit_logs;
CREATE TRIGGER trg_immutable_audit_logs
BEFORE UPDATE OR DELETE ON public.audit_logs
FOR EACH ROW EXECUTE FUNCTION prevent_audit_log_modification();

-- 5. CONFIGURABLE RISK RULES TABLE
CREATE TABLE IF NOT EXISTS public.risk_rules (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    rule_code TEXT UNIQUE NOT NULL,
    rule_name TEXT NOT NULL,
    description TEXT,
    weight INTEGER NOT NULL DEFAULT 20,
    threshold_value NUMERIC NOT NULL,
    comparison_operator TEXT NOT NULL DEFAULT '>', -- '>', '<', '=', 'IN'
    severity public.alert_severity NOT NULL DEFAULT 'MEDIUM',
    is_active BOOLEAN DEFAULT true,
    updated_by UUID REFERENCES auth.users(id),
    updated_at TIMESTAMPTZ DEFAULT NOW()
);

-- Seed Default Explainable Risk Rules
INSERT INTO public.risk_rules (rule_code, rule_name, description, weight, threshold_value, comparison_operator, severity)
VALUES
('PRICE_DEV_BELOW', 'Severe Price Dumping vs Mandi', 'Traded or listed price is over 30% below modal APMC mandi benchmark', 35, 30.0, '>', 'HIGH'),
('PRICE_DEV_ABOVE', 'Abnormal Price Spike vs Mandi', 'Traded price is over 50% above modal APMC mandi benchmark (wash trading / gouging)', 30, 50.0, '>', 'HIGH'),
('QTY_OUTLIER', 'Unusual Large Volume Order', 'Produce quantity exceeds 25,000 kg without prior certified warehouse receipt', 25, 25000.0, '>', 'MEDIUM'),
('RAPID_VELOCITY', 'High Frequency Velocity Spike', 'Over 3 listings or transactions created within 5 minutes', 30, 3.0, '>', 'HIGH'),
('HIGH_CANCELLATION', 'Excessive Order Cancellations', 'Buyer or Seller cancellation rate exceeds 30% over past 5 transactions', 25, 30.0, '>', 'MEDIUM'),
('COLD_CHAIN_BREACH', 'Reefer Sensor Temperature Breach', 'Cold chain reefer temperature exceeds 8.0°C for more than 2 hours', 40, 8.0, '>', 'CRITICAL'),
('FRESHNESS_MISMATCH', 'Inconsistent Produce Freshness Claim', 'Claimed freshness >90% on produce harvested over 14 days ago in uncooled warehouse', 20, 14.0, '>', 'MEDIUM'),
('HIGH_VAL_UNVERIFIED', 'Unverified High Value Transaction', 'Transaction value exceeds ₹5,00,000 initiated by an unverified KYC profile', 35, 500000.0, '>', 'HIGH')
ON CONFLICT (rule_code) DO UPDATE SET
    rule_name = EXCLUDED.rule_name,
    weight = EXCLUDED.weight,
    threshold_value = EXCLUDED.threshold_value,
    severity = EXCLUDED.severity;

-- 6. RISK SCORES & SIGNALS TABLE
CREATE TABLE IF NOT EXISTS public.risk_scores (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    entity_type TEXT NOT NULL, -- 'user', 'listing', 'order', 'shipment'
    entity_id TEXT NOT NULL,
    score INTEGER NOT NULL CHECK (score >= 0 AND score <= 100),
    severity public.risk_level NOT NULL,
    reason TEXT NOT NULL,
    signals JSONB NOT NULL DEFAULT '[]'::jsonb,
    calculated_at TIMESTAMPTZ DEFAULT NOW(),
    updated_at TIMESTAMPTZ DEFAULT NOW(),
    CONSTRAINT uq_entity_risk UNIQUE (entity_type, entity_id)
);

-- 7. RISK EVENTS LOG
CREATE TABLE IF NOT EXISTS public.risk_events (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    entity_type TEXT NOT NULL,
    entity_id TEXT NOT NULL,
    rule_code TEXT REFERENCES public.risk_rules(rule_code) ON DELETE CASCADE,
    signal_text TEXT NOT NULL,
    severity public.alert_severity NOT NULL,
    deviation_value NUMERIC,
    created_at TIMESTAMPTZ DEFAULT NOW()
);

-- 8. ALERT CENTER TABLE
CREATE TABLE IF NOT EXISTS public.alerts (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    alert_code TEXT NOT NULL,
    type TEXT NOT NULL,
    severity public.alert_severity NOT NULL,
    title TEXT NOT NULL,
    message TEXT NOT NULL,
    entity_type TEXT NOT NULL,
    entity_id TEXT NOT NULL,
    related_user_id UUID,
    risk_score INTEGER DEFAULT 0,
    status public.alert_status NOT NULL DEFAULT 'NEW',
    assigned_to UUID REFERENCES auth.users(id),
    acknowledged_by UUID REFERENCES auth.users(id),
    acknowledged_at TIMESTAMPTZ,
    resolved_by UUID REFERENCES auth.users(id),
    resolved_at TIMESTAMPTZ,
    resolution_notes TEXT,
    created_at TIMESTAMPTZ DEFAULT NOW()
);

-- 9. INVESTIGATION CASES TABLE
CREATE TABLE IF NOT EXISTS public.investigation_cases (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    case_number TEXT UNIQUE NOT NULL,
    title TEXT NOT NULL,
    reason TEXT NOT NULL,
    target_user_id UUID,
    target_user_name TEXT,
    entity_type TEXT NOT NULL,
    entity_id TEXT NOT NULL,
    risk_score INTEGER NOT NULL,
    severity public.alert_severity NOT NULL,
    status public.case_status NOT NULL DEFAULT 'OPEN',
    assigned_supervisor_id UUID REFERENCES auth.users(id),
    assigned_supervisor_name TEXT,
    evidence JSONB NOT NULL DEFAULT '[]'::jsonb,
    notes_timeline JSONB NOT NULL DEFAULT '[]'::jsonb,
    resolution_summary TEXT,
    created_at TIMESTAMPTZ DEFAULT NOW(),
    updated_at TIMESTAMPTZ DEFAULT NOW()
);

-- 10. PLATFORM ADMIN SETTINGS TABLE
CREATE TABLE IF NOT EXISTS public.admin_settings (
    key TEXT PRIMARY KEY,
    value JSONB NOT NULL,
    category TEXT NOT NULL DEFAULT 'general',
    description TEXT,
    updated_by UUID REFERENCES auth.users(id),
    updated_at TIMESTAMPTZ DEFAULT NOW()
);

INSERT INTO public.admin_settings (key, value, category, description)
VALUES
('escrow_auto_release_hours', '24'::jsonb, 'escrow', 'Hours post Gate-QC delivery before auto-releasing locked funds'),
('dispute_resolution_sla_hours', '48'::jsonb, 'compliance', 'Maximum SLA hours for supervisor resolution of trade disputes'),
('platform_commission_pct', '1.25'::jsonb, 'finance', 'Standard platform market facilitator commission percentage'),
('min_freshness_threshold', '75'::jsonb, 'quality', 'Minimum freshness index score to permit public listing on marketplace'),
('reefer_temp_max_threshold', '8.0'::jsonb, 'logistics', 'Maximum allowable temperature (°C) for perishable reefer shipments')
ON CONFLICT (key) DO NOTHING;

-- 11. ROW LEVEL SECURITY (RLS) POLICIES
ALTER TABLE public.supervisor_roles ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.audit_logs ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.risk_rules ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.risk_scores ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.risk_events ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.alerts ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.investigation_cases ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.admin_settings ENABLE ROW LEVEL SECURITY;

-- Helper function to check if caller is an authorized supervisor or admin
CREATE OR REPLACE FUNCTION public.is_supervisor_or_admin()
RETURNS BOOLEAN AS $$
BEGIN
    RETURN EXISTS (
        SELECT 1 FROM public.supervisor_roles
        WHERE user_id = auth.uid() AND is_active = true
    );
END;
$$ LANGUAGE plpgsql SECURITY DEFINER;

-- Helper function to check if caller is an admin
CREATE OR REPLACE FUNCTION public.is_admin()
RETURNS BOOLEAN AS $$
BEGIN
    RETURN EXISTS (
        SELECT 1 FROM public.supervisor_roles
        WHERE user_id = auth.uid() AND role = 'admin' AND is_active = true
    );
END;
$$ LANGUAGE plpgsql SECURITY DEFINER;

-- RLS: Supervisors and Admins can read all governance tables
DROP POLICY IF EXISTS "Supervisors and Admins can view audit logs" ON public.audit_logs;
CREATE POLICY "Supervisors and Admins can view audit logs"
ON public.audit_logs FOR SELECT
USING (public.is_supervisor_or_admin());

DROP POLICY IF EXISTS "Supervisors and Admins can view alerts" ON public.alerts;
CREATE POLICY "Supervisors and Admins can view alerts"
ON public.alerts FOR SELECT
USING (public.is_supervisor_or_admin());

DROP POLICY IF EXISTS "Supervisors and Admins can update alerts" ON public.alerts;
CREATE POLICY "Supervisors and Admins can update alerts"
ON public.alerts FOR UPDATE
USING (public.is_supervisor_or_admin());

DROP POLICY IF EXISTS "Supervisors and Admins can view investigations" ON public.investigation_cases;
CREATE POLICY "Supervisors and Admins can view investigations"
ON public.investigation_cases FOR SELECT
USING (public.is_supervisor_or_admin());

DROP POLICY IF EXISTS "Supervisors and Admins can modify investigations" ON public.investigation_cases;
CREATE POLICY "Supervisors and Admins can modify investigations"
ON public.investigation_cases FOR ALL
USING (public.is_supervisor_or_admin());

DROP POLICY IF EXISTS "Admins can modify risk rules" ON public.risk_rules;
CREATE POLICY "Admins can modify risk rules"
ON public.risk_rules FOR ALL
USING (public.is_admin());

DROP POLICY IF EXISTS "Supervisors can view risk rules" ON public.risk_rules;
CREATE POLICY "Supervisors can view risk rules"
ON public.risk_rules FOR SELECT
USING (public.is_supervisor_or_admin());

DROP POLICY IF EXISTS "Admins can modify admin settings" ON public.admin_settings;
CREATE POLICY "Admins can modify admin settings"
ON public.admin_settings FOR ALL
USING (public.is_admin());

DROP POLICY IF EXISTS "Supervisors can view admin settings" ON public.admin_settings;
CREATE POLICY "Supervisors can view admin settings"
ON public.admin_settings FOR SELECT
USING (public.is_supervisor_or_admin());

