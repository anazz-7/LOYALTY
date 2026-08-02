-- ========================================================
-- B-INDUSTRIES LOYALTY — SUPABASE / POSTGRESQL SCHEMA SCRIPT
-- Paste this script directly into your Supabase SQL Editor:
-- https://app.supabase.com/project/_/sql/new
-- ========================================================

-- Enable UUID extension
CREATE EXTENSION IF NOT EXISTS "uuid-ossp";

-- 1. SETTINGS TABLE
CREATE TABLE IF NOT EXISTS public.settings (
    id INT PRIMARY KEY DEFAULT 1,
    biz_name TEXT NOT NULL DEFAULT 'B-INDUSTRIES LOYALTY',
    rate NUMERIC NOT NULL DEFAULT 100,
    redeem_val NUMERIC NOT NULL DEFAULT 1,
    country_code TEXT NOT NULL DEFAULT '91',
    ref_bonus_referrer NUMERIC NOT NULL DEFAULT 20,
    ref_bonus_referee NUMERIC NOT NULL DEFAULT 10,
    updated_at TIMESTAMPTZ DEFAULT NOW(),
    CONSTRAINT single_row CHECK (id = 1)
);

-- Insert default settings row if missing
INSERT INTO public.settings (id, biz_name, rate, redeem_val, country_code, ref_bonus_referrer, ref_bonus_referee)
VALUES (1, 'B-INDUSTRIES LOYALTY', 100, 1, '91', 20, 10)
ON CONFLICT (id) DO NOTHING;

-- 2. STAFF LOGINS TABLE
CREATE TABLE IF NOT EXISTS public.staff (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    name TEXT NOT NULL,
    pin TEXT NOT NULL,
    role TEXT NOT NULL DEFAULT 'staff' CHECK (role IN ('owner', 'staff')),
    created_at TIMESTAMPTZ DEFAULT NOW()
);

-- Insert default Owner account
INSERT INTO public.staff (name, pin, role)
VALUES ('Owner', '1234', 'owner')
ON CONFLICT DO NOTHING;

-- 3. CUSTOMERS TABLE
CREATE TABLE IF NOT EXISTS public.customers (
    phone TEXT PRIMARY KEY,
    name TEXT NOT NULL,
    total_points NUMERIC NOT NULL DEFAULT 0,
    total_spent NUMERIC NOT NULL DEFAULT 0,
    visits INT NOT NULL DEFAULT 0,
    first_visit DATE NOT NULL DEFAULT CURRENT_DATE,
    last_visit DATE NOT NULL DEFAULT CURRENT_DATE,
    referral_code TEXT UNIQUE,
    referred_by TEXT REFERENCES public.customers(phone) ON DELETE SET NULL,
    created_at TIMESTAMPTZ DEFAULT NOW()
);

-- 4. TRANSACTIONS TABLE (INVOICES / BILLS)
CREATE TABLE IF NOT EXISTS public.transactions (
    id TEXT PRIMARY KEY,
    bill_no TEXT NOT NULL,
    date DATE NOT NULL,
    phone TEXT NOT NULL REFERENCES public.customers(phone) ON DELETE CASCADE,
    name TEXT NOT NULL,
    amount NUMERIC NOT NULL DEFAULT 0,
    earned NUMERIC NOT NULL DEFAULT 0,
    redeemed NUMERIC NOT NULL DEFAULT 0,
    staff_name TEXT DEFAULT '—',
    created_at TIMESTAMPTZ DEFAULT NOW()
);

-- 5. REDEMPTIONS TABLE (VOUCHERS)
CREATE TABLE IF NOT EXISTS public.redemptions (
    id TEXT PRIMARY KEY,
    phone TEXT NOT NULL REFERENCES public.customers(phone) ON DELETE CASCADE,
    name TEXT NOT NULL,
    points NUMERIC NOT NULL DEFAULT 0,
    value NUMERIC NOT NULL DEFAULT 0,
    code TEXT NOT NULL,
    status TEXT NOT NULL DEFAULT 'pending' CHECK (status IN ('pending', 'fulfilled', 'cancelled')),
    created_at TIMESTAMPTZ DEFAULT NOW(),
    fulfilled_at TIMESTAMPTZ
);

-- INDEXES FOR FAST SEARCH
CREATE INDEX IF NOT EXISTS idx_customers_name ON public.customers(name);
CREATE INDEX IF NOT EXISTS idx_transactions_phone ON public.transactions(phone);
CREATE INDEX IF NOT EXISTS idx_transactions_date ON public.transactions(date);
CREATE INDEX IF NOT EXISTS idx_redemptions_status ON public.redemptions(status);

-- ENABLE ROW LEVEL SECURITY (RLS) FOR PUBLIC ACCESS
ALTER TABLE public.settings ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.staff ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.customers ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.transactions ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.redemptions ENABLE ROW LEVEL SECURITY;

-- CREATE RLS PERMISSIVE POLICIES FOR WEB APP ANONYMOUS / PUBLIC ACCESS
CREATE POLICY "Public Read Settings" ON public.settings FOR SELECT USING (true);
CREATE POLICY "Public Update Settings" ON public.settings FOR UPDATE USING (true);

CREATE POLICY "Public All Staff" ON public.staff FOR ALL USING (true);
CREATE POLICY "Public All Customers" ON public.customers FOR ALL USING (true);
CREATE POLICY "Public All Transactions" ON public.transactions FOR ALL USING (true);
CREATE POLICY "Public All Redemptions" ON public.redemptions FOR ALL USING (true);
