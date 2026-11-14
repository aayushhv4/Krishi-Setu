# Contributing to Krishi Setu

Thank you for your interest in contributing to Krishi Setu! This project is an open-source, digital public infrastructure platform empowering farmers with market intelligence, logistics aggregation, and fair pricing.

## Getting Started

### Local Development Setup

1. **Clone the repository:**
   ```bash
   git clone https://github.com/aayushhv4/Krishi-Setu.git
   cd Krishi-Setu
   ```

2. **Serve the project locally:**
   Because Krishi Setu uses a vanilla HTML/CSS/JavaScript single-page architecture, no compilation or build steps are required. Serve from the root folder:
   ```bash
   python -m http.server 8000
   ```
   Open `http://localhost:8000/frontend/public-site/government-version/index.html` in your browser.

3. **Database & Backend (Optional):**
   - The application functions seamlessly in **DEMO_MODE** out of the box without requiring a live Supabase connection.
   - To link a dedicated Supabase instance, apply the migrations sequentially from `backend/supabase/migrations/` (`001_schema.sql` through `005_seed_demo_data.sql`).
   - Configure your Supabase project URL and anon/publishable key in `frontend/LAST_GOV_API_GRAPHS_FINAL.html` and `frontend/public-site/government-version/js/auth.js`.

## Running Integration Tests

Headless integration tests use Puppeteer with your local Google Chrome or Chromium browser:

```bash
cd "Krishi Setu/tests"
npm install
node integration/deploy-qa.js
node verify_navigation.js
node test_fix_verification.js
```

Set `CHROME_PATH` if your browser is installed in a non-standard location:
```bash
CHROME_PATH="/path/to/chrome" node verify_navigation.js
```

## Pull Request Guidelines

1. **Security & Credentials:**
   - Never commit API secrets, private keys, service-role tokens, or personal information.
   - The frontend should strictly consume the Supabase **anon/publishable** key.

2. **Code Standards:**
   - Keep interactions accessible, responsive on mobile viewports (390px+), and compatible across major modern browsers.
   - Maintain multi-language support (English/Hindi) strings in UI components.
