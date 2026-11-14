# Krishi Setu — Farm. Connect. Prosper.

Krishi Setu is a unified agricultural operating platform for Indian farmers, FPOs, institutional buyers and market supervisors. It brings the full sell-side journey into one application: track harvested inventory, publish produce lots, receive and compare institutional buyer offers, calculate profit and net realisation across selling channels (APMC mandi, direct buyers, and quick-commerce partners such as Zepto, Blinkit and Swiggy Instamart), arrange cold-chain logistics, and settle payments through escrow-protected rails.

Built as a single-page application for a Smart India Hackathon (SIH) submission, it runs entirely client-side in demo mode and optionally connects to a Supabase backend for live data.

## Problem being solved

Indian farmers typically sell at the nearest APMC mandi with little price transparency and no way to compare what they would actually take home after freight, commission, unloading and cess deductions. Buyers struggle to find verified, graded produce. Krishi Setu connects both sides: farmers get per-channel net-realisation comparison, buyers get a verified marketplace with quality gates, and supervisors get governance tooling.

## Main features

- **Farmer workspace** — dashboard, crop inventory (add / edit / track freshness), AI crop doctor, shelf-life predictor, crop price outlook (government mandi feed), FPO aggregation
- **Marketplace** — publish produce lots, live buyer offers, accept / counter-offer, instant sell, online retail channels (Zepto, Blinkit, Swiggy Instamart partner onboarding)
- **Finance** — profit calculator, net realisation engine with per-channel cost breakdown, trust & credit points, warehouse financing, payment & settlement centre
- **Logistics** — route / cost comparison, live shipment tracking, cold storage finder, lot passport with QR traceability
- **Buyer workspace** — RFQs & reverse auctions, lot inspection, make-offer, orders, price index, verified supplier directory, cold-chain booking, escrow & credit line
- **Supervisor workspace** — user/seller/buyer registries, listing & purchase oversight, risk alerts, investigation desk, immutable audit trail, platform settings
- **Platform features** — login (demo personas), farmer/buyer/supervisor mode switching, 11-language i18n (Google Translate fallback), light/dark theme with system preference, high-contrast sunlight mode, font sizing, WhatsApp alerts (local toggle), custom 404 page

## Technology stack

| Layer | Technology |
| --- | --- |
| Frontend | Single-file HTML5 + vanilla JavaScript + CSS (no build step, no framework) |
| Charts / viz | Inline SVG + CSS (no chart library) |
| Backend | Supabase (optional; the app auto-falls back to `DEMO_MODE` with mock data when the key is invalid or offline) |
| Database | PostgreSQL via Supabase (migrations in `backend/supabase/migrations`) |
| Edge functions | `refresh-gov-feed` — server-side refresh of the government mandi price cache |
| External assets | Supabase JS CDN, Unsplash imagery, Google Translate (runtime fallback for dynamic text) |

## Product parts

| Part | Path | What it is |
| --- | --- | --- |
| **Public homepage** (front door) | `frontend/public-site/government-version/index.html` | Government-style public website — Home, About, How It Works, Schemes, News, Resources, Impact, Support, Contact. No login required; "Open Platform" leads into the authenticated platform. |
| **Premium direction** (comparison) | `frontend/public-site/premium-version/index.html` | Same content, animated/interactive presentation; light + dark. |
| **Authenticated platform** | `frontend/LAST_GOV_API_GRAPHS_FINAL.html` | The full dashboard (farmer / buyer / supervisor) with login, Supabase session, marketplace, finance, logistics. |
| **WhatsApp Beta** (prototype) | `frontend/whatsapp-beta/index.html` | Simplified chat-style interface for farmers — clearly labelled SIH prototype; all actions simulated. |

The product is **front-door first**: opening the app directly without a session routes you to the public homepage; "Open Platform" shows the existing login for guests, while logged-in users go straight to the dashboard (one Supabase session — no second login).

## How to run

Krishi Setu is static — no server or build step is required.

1. Open the product entry: `index.html` at the workspace root (redirects to the public homepage), or `frontend/public-site/government-version/index.html` directly.
2. Click **Open Platform** → on the login screen choose a demo persona — **Farmer**, **Buyer** or **Supervisor** (one-click demo logins) — or sign in with a real Supabase account.
3. From the dashboard, the sidebar **Krishi Setu on WhatsApp (BETA)** opens the WhatsApp prototype in a new tab.
4. Optional: connect a live Supabase project (see `docs/SETUP.md`).

Recommended local serving (one origin, so the public site and dashboard share the session):

```bash
cd <workspace root>
python -m http.server 8000   # then open http://localhost:8000/
```

## Environment variables

Copy `.env.example` to `.env` for your Supabase project credentials (names only are committed; never commit real values). Note: the current single-file frontend keeps its Supabase config inline for portability — see `docs/SETUP.md` for the production-ready extraction steps.

## Deployment

- **Static hosting (recommended):** Netlify / Vercel / GitHub Pages — serve the `frontend/` folder as-is. No build command.
- **Live backend:** apply `backend/supabase/migrations/*.sql` in order in your Supabase project, then deploy `backend/supabase/functions/refresh-gov-feed` and schedule it (see `backend/supabase/README.md`).
- **Domain:** the public homepage is already indexable; only the authenticated dashboard and the WhatsApp prototype carry intentional `noindex`. See `docs/DEPLOYMENT.md` for the exact Vercel + Supabase settings.

## Project structure

```
Krishi Setu/
├── frontend/
│   ├── LAST_GOV_API_GRAPHS_FINAL.html   # main application (single-file, authoritative)
│   ├── public-site/                     # public website (government + premium versions)
│   │   ├── government-version/          # ← the public front door
│   │   └── premium-version/
│   └── whatsapp-beta/                   # WhatsApp-style SIH prototype (index.html + css/ js/)
├── backend/
│   └── supabase/                        # migrations (001–005), edge functions, README
├── database/
│   └── README.md                        # database migration reference
├── docs/                                # architecture, API, setup, release + issue reports, SIH deck
├── tests/                               # headless integration checks (Puppeteer)
├── archive/                             # archived dev tools / orphaned files (not part of product)
├── .env.example                         # environment variable names (no secrets)
├── .gitignore
├── CONTRIBUTING.md                      # local setup, testing, and contribution guide
├── SECURITY.md                          # security policy and credential disclosure guidelines
└── README.md
```

## Known Limitations

- **Email Confirmation & Profile Synchronization:** If email confirmation is enabled on your Supabase instance, profile rows are automatically provisioned and synchronized on the user's first login. A manual fallback "Retry Save Profile" action is also accessible in the UI profile section.
- **Client Configuration:** The publishable anon key is intentionally client-side and secured via PostgreSQL Row Level Security (RLS) policies. For independent production deployments, replace the project URL and publishable key with your own dedicated Supabase instance credentials.

See `docs/README.md` for the documentation index, `docs/ARCHITECTURE.md` for a deep dive, `docs/API.md` for the data contract, and `docs/SETUP.md` for environment and deployment steps.