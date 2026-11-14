# Krishi Setu — Setup Guide

> Recreated during the final project cleanup (the original copy was missing
> from the workspace). Content reflects the verified, current project.

## What you need

- Any modern browser (Chrome recommended) — the application is a static
  single-file HTML app; no build step.
- A Supabase project for authentication + storage (the app already embeds a
  publishable/anon key; migrations in `backend/supabase/migrations` define
  the schema).
- Node.js 18+ **only** for the headless test suite (`tests/`).
- Optional: a data.gov.in API key if you want the `refresh-gov-feed` edge
  function to pull live mandi prices.

## 1. Database / Supabase

1. Create a project at https://supabase.com.
2. Apply the migrations in order from `backend/supabase/migrations/`
   (`001_schema.sql` → `005_seed_demo_data.sql`) via the SQL editor or the
   Supabase CLI (`supabase db push` with a linked project).
3. The app reads `SUPABASE_URL` + the anon key from its own config block in
   `frontend/LAST_GOV_API_GRAPHS_FINAL.html` (see **Environment variables**).
4. Optional backend service: deploy the edge function
   `backend/supabase/functions/refresh-gov-feed/index.ts`, add a
   `GOV_API_KEY` secret (data.gov.in), and schedule it (e.g. hourly cron).

## 2. Run the application

Open (or serve) these from the project root:

| What | Path |
|---|---|
| Public homepage (Government version) | `frontend/public-site/government-version/index.html` |
| Premium design direction (comparison) | `frontend/public-site/premium-version/index.html` |
| Authenticated platform (dashboard + login) | `frontend/LAST_GOV_API_GRAPHS_FINAL.html` |
| WhatsApp Beta prototype | `frontend/whatsapp-beta/index.html` |

Recommended local serving (one origin — required for the public site and
dashboard to share the Supabase session):

```bash
cd <workspace root>          # the folder containing Krishi Setu/
python -m http.server 8000
# http://localhost:8000/
```

## 3. Environment variables

`.env.example` at the project root lists names only — copy it to `.env` and
fill real values **outside** the repository (never commit `.env`):

| Variable | Used by | Notes |
|---|---|---|
| `SUPABASE_URL` | Application / public site | Must match the app's embedded config |
| `SUPABASE_PUBLISHABLE_KEY` | Application / public site | Publishable / anon key (safe in browser; alias: `SUPABASE_ANON_KEY`) |
| `GOV_API_KEY` | `refresh-gov-feed` edge function | data.gov.in secret, set as a Supabase function secret |
| `CHROME_PATH` | Test suite only | Path to Chrome when not in the default location |

The single-file app keeps its Supabase URL + anon key in a clearly marked
config block near the top of its main script; the public site mirrors them
in `frontend/public-site/government-version/js/auth.js`. Keep both in sync
when switching projects.

## 4. Tests

```bash
cd tests
npm install
CHROME_PATH="C:/Program Files/Google/Chrome/Application/chrome.exe" npm run walk
node integration/core-flows.js
node integration/i18n-mobile.js
node integration/public-bridge.js    # public ⇄ dashboard integration + front-door routing
node integration/whatsapp-demo.js    # WhatsApp Beta flows
```

## 5. Auth & email confirmation (production notes)

- The app restores a valid Supabase session on load and skips login.
- Signup confirmation emails use `KRISHISETU_APP_URL` — set
  `window.KRISHISETU_APP_URL` before the app script (or serve over https)
  so confirmation links point at the deployed app, not `localhost`.
- Deployed elsewhere? Override `window.KRISHISETU_PUBLIC_HOME_URL` (app) and
  `KS.platformUrl` (public site `js/data.js`) in one place each.

## 6. Deployment

- Both the public site and the dashboard are static — host the whole
  workspace root (so `frontend/` and `frontend/public-site/` resolve) on any
  static host over HTTPS.
- The public homepage is already indexable (no `noindex`). The private
  authenticated dashboard and the WhatsApp prototype intentionally carry
  `noindex` — keep those. Add `robots.txt`/`sitemap.xml` only if you want
  advanced SEO.
- The WhatsApp Beta is a static prototype and needs no backend.