# Krishi Setu — Integration Tests

These scripts drive the **real application UI** in headless Chrome (via `puppeteer-core` — no browser download needed; it reuses your installed Chrome/Edge). They are the same checks used during final QA.

## Prerequisites

- Node.js 18+
- Google Chrome or Edge installed (standard location), or set `CHROME_PATH` env var

## Setup

```bash
cd tests
npm install
```

## Run

```bash
# Walk every page of a role at a viewport width; flags dead buttons, stuck
# loading text, horizontal overflow and console errors.
node integration/walk-pages.js farmer 390      # roles: farmer | buyer | supervisor
node integration/walk-pages.js supervisor 1280

# Drive the core flows end-to-end (add crop -> publish -> offers -> profit ->
# logistics -> payments -> buyer -> supervisor).
node integration/core-flows.js

# Switch the app to Hindi and verify translation + no overflow at mobile widths.
node integration/i18n-mobile.js

# Public ⇄ dashboard integration: front-door routing, CTA label swap,
# logo/logout flows and the auth session bridge.
node integration/public-bridge.js

# Public Government site language switcher: real Hindi switch, persistence,
# public ⇄ dashboard sync (both directions), dynamic content, mobile.
node integration/lang-switcher.js

# WhatsApp Beta: every guided flow at mobile + desktop, light + dark.
node integration/whatsapp-demo.js

# Final authentication flow check: Supabase auth state, session handling
node integration/final-auth-check.js

# Theme & login regression verification
# Note: Section 5 makes live auth test calls against the configured Supabase endpoint
node integration/theme-login-fix.js

# Public site navigation and deep link verification
node verify_navigation.js

# Static server fix and path verification
node test_fix_verification.js

# Deployment QA over HTTP: root redirect, all public pages, dead-link crawl,
# app + WhatsApp Beta + premium pages, mobile overflow. Point at the live
# site after deploy: KS_BASE_URL=https://your-domain node integration/deploy-qa.js
node integration/deploy-qa.js
```

Pass `CHROME_PATH=/path/to/chrome node integration/...` to use a non-default browser.

## What each script asserts

- **walk-pages** — every nav-reachable page renders (no 404 for real targets), no `Loading…` leftovers, no horizontal overflow, every inline `onclick` handler resolves to a real global function (no dead buttons), no uncaught page errors.
- **core-flows** — add crop batch persists to inventory; publish lot auto-fills from that batch and creates an `Active` lot; buyer offers render; profit calculator results change with inputs; logistics recalcs; payments render; buyer + supervisor workspaces load.
- **i18n-mobile** — language switch applies (Hindi visible), all key pages stay within the viewport at 390px, no console warnings from the app itself.

## Notes

- Expect `Failed to load resource` console noise for CDN/Google-Translate calls when the machine is offline — the scripts filter those; they are not app errors.
- These tests are optional tooling, not part of the shipped application.