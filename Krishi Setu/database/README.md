# Database Migrations and Schemas

This directory previously housed legacy exploratory SQL exports.

All canonical, version-controlled database migrations are now located in:
`backend/supabase/migrations/`

### Migration Order
1. `001_schema.sql` — Core database tables, triggers, and baseline RLS policies
2. `002_admin_governance.sql` — Administrative functions, verification flags, and governance policies
3. `003_repair_profiles.sql` — Profile table repairs and self-heal triggers
4. `004_gov_feed_cache.sql` — Government weather and price feed cache structures
5. `005_seed_demo_data.sql` — Sanitized demo and testing fixtures (with non-identifiable test data)
