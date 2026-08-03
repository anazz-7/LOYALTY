-- ============================================================
-- B-INDUSTRIES LOYALTY & POS — OFFICIAL SUPABASE DATABASE SCHEMA
-- Copy and run this script in your Supabase SQL Editor:
-- Dashboard -> SQL Editor -> New Query -> Run
-- ============================================================

-- 1. Store Settings Table
CREATE TABLE IF NOT EXISTS public.settings (
    id BIGINT PRIMARY KEY DEFAULT 1,
    biz_name TEXT DEFAULT 'B-INDUSTRIES LOYALTY',
    rate NUMERIC DEFAULT 100,
    redeem_val NUMERIC DEFAULT 1,
    country_code TEXT DEFAULT '91',
    ref_bonus_referrer NUMERIC DEFAULT 20,
    ref_bonus_referee NUMERIC DEFAULT 10,
    updated_at TIMESTAMPTZ DEFAULT NOW()
);

-- 2. Staff Accounts & Roster Table
CREATE TABLE IF NOT EXISTS public.staff (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    name TEXT NOT NULL,
    pin TEXT NOT NULL,
    role TEXT DEFAULT 'staff',
    created_at TIMESTAMPTZ DEFAULT NOW()
);

-- 3. Customers Account Directory Table
CREATE TABLE IF NOT EXISTS public.customers (
    phone TEXT PRIMARY KEY,
    name TEXT NOT NULL,
    total_points NUMERIC DEFAULT 0,
    total_spent NUMERIC DEFAULT 0,
    visits INT DEFAULT 0,
    first_visit DATE DEFAULT CURRENT_DATE,
    last_visit DATE DEFAULT CURRENT_DATE,
    referral_code TEXT,
    referred_by TEXT,
    created_at TIMESTAMPTZ DEFAULT NOW()
);

-- 4. Bill Transactions & Invoices Table
CREATE TABLE IF NOT EXISTS public.transactions (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    bill_no TEXT NOT NULL,
    date DATE DEFAULT CURRENT_DATE,
    phone TEXT NOT NULL,
    name TEXT NOT NULL,
    amount NUMERIC DEFAULT 0,
    earned NUMERIC DEFAULT 0,
    redeemed NUMERIC DEFAULT 0,
    staff_name TEXT DEFAULT 'Owner',
    created_at TIMESTAMPTZ DEFAULT NOW()
);

-- 5. Customer Point Redemptions Table
CREATE TABLE IF NOT EXISTS public.redemptions (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    phone TEXT NOT NULL,
    name TEXT NOT NULL,
    points NUMERIC DEFAULT 0,
    value NUMERIC DEFAULT 0,
    code TEXT NOT NULL,
    status TEXT DEFAULT 'pending',
    created_at TIMESTAMPTZ DEFAULT NOW(),
    fulfilled_at TIMESTAMPTZ
);

-- ============================================================
-- DISABLE ROW LEVEL SECURITY (RLS) FOR FREE PUBLIC POS SYNC
-- ============================================================
ALTER TABLE public.settings DISABLE ROW LEVEL SECURITY;
ALTER TABLE public.staff DISABLE ROW LEVEL SECURITY;
ALTER TABLE public.customers DISABLE ROW LEVEL SECURITY;
ALTER TABLE public.transactions DISABLE ROW LEVEL SECURITY;
ALTER TABLE public.redemptions DISABLE ROW LEVEL SECURITY;

-- Grant Full Access to Anon Public Key
GRANT ALL ON TABLE public.settings TO anon, authenticated, service_role;
GRANT ALL ON TABLE public.staff TO anon, authenticated, service_role;
GRANT ALL ON TABLE public.customers TO anon, authenticated, service_role;
GRANT ALL ON TABLE public.transactions TO anon, authenticated, service_role;
GRANT ALL ON TABLE public.redemptions TO anon, authenticated, service_role;

-- Enable Realtime Live Publication
ALTER PUBLICATION supabase_realtime ADD TABLE public.settings;
ALTER PUBLICATION supabase_realtime ADD TABLE public.staff;
ALTER PUBLICATION supabase_realtime ADD TABLE public.customers;
ALTER PUBLICATION supabase_realtime ADD TABLE public.transactions;
ALTER PUBLICATION supabase_realtime ADD TABLE public.redemptions;

-- ============================================================
-- INITIAL SEED DATA
-- ============================================================
INSERT INTO public.settings (id, biz_name, rate, redeem_val, country_code, ref_bonus_referrer, ref_bonus_referee)
VALUES (1, 'B-INDUSTRIES LOYALTY', 100, 1, '91', 20, 10)
ON CONFLICT (id) DO NOTHING;

INSERT INTO public.staff (name, pin, role)
VALUES ('Owner', '1234', 'owner')
ON CONFLICT DO NOTHING;
