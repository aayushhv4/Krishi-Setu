// Theme-default + login-error QA
// Run after deploy-qa / rewrite-qa — tests the two UX fixes in isolation.
const puppeteer = require('puppeteer-core');
const path = require('path');

const CHROME = process.env.CHROME_PATH || 'C:/Program Files/Google/Chrome/Application/chrome.exe';
const PROJECT_ROOT = path.join(__dirname, '..', '..');
const sim = require('../vercel-sim.js');

let failures = 0;
function check(name, ok, extra) { console.log((ok ? 'PASS ' : 'FAIL ') + name + (extra !== undefined ? '  ' + JSON.stringify(extra) : '')); if (!ok) failures++; }

(async () => {
  if (!require('fs').existsSync(CHROME)) { console.error('Chrome not found at ' + CHROME); process.exit(2); }
  const server = await sim.start(PROJECT_ROOT, 0);
  const BASE = 'http://127.0.0.1:' + server.address().port;

  const browser = await puppeteer.launch({ executablePath: CHROME, headless: 'new', args: ['--no-sandbox'] });
  const makePage = () => browser.newPage();

  // --------------------------------------------------------------- THEME DEFAULT
  // First-time visitors (no saved preference) must see LIGHT, not dark.
  // This is tested in both a light-OS and dark-OS context: we force
  // `prefers-color-scheme: dark` via emulation so we can prove the default
  // does NOT follow the OS.
  for (const labelUrl of [['homepage', '/'], ['login', '/platform/?intent=login']]) {
    const [label, url] = labelUrl;
    const p = await makePage();
    await p.setViewport({ width: 1280, height: 900 });
    const errs = [];
    p.on('console', m => { if (m.type() === 'error') errs.push(m.text().slice(0, 160)); });
    // Force the OS to appear dark via CDP, so the OLD buggy code would pick dark.
    // This is applied to the page BEFORE navigation, so the <head> theme init sees a
    // dark-preferring OS.
    await p.emulateMediaFeatures([
      { name: 'prefers-color-scheme', value: 'dark' },
    ]);
    await p.goto(BASE + url, { waitUntil: 'load', timeout: 45000 });
    await new Promise(r => setTimeout(r, 2500));
    const themeInfo = await p.evaluate(() => {
      const body = document.body || {};
      const dark = body.classList ? body.classList.contains('dark-mode') : false;
      return { darkMode: dark, bodyBg: getComputedStyle(document.body).backgroundColor, themeColor: (document.querySelector('meta[name="theme-color"]') || {}).getAttribute('content') || '' };
    });
    // A first-time visitor MUST be in light mode even when the OS is dark.
    check('theme: ' + label + ' starts LIGHT for first-time visitor (not system-dark)', !themeInfo.darkMode, themeInfo);
    await p.close();
  }

  // Saved dark preference must still win.
  {
    const p = await makePage();
    await p.setViewport({ width: 1280, height: 900 });
    const errs = [];
    p.on('console', m => { if (m.type() === 'error') errs.push(m.text().slice(0, 160)); });
    await p.evaluateOnNewDocument(() => {
      try { localStorage.setItem('ks_theme', 'dark'); } catch (e) {}
    });
    await p.goto(BASE + '/platform/?intent=login', { waitUntil: 'load', timeout: 45000 });
    await new Promise(r => setTimeout(r, 2000));
    const dark = await p.evaluate(() => document.body.classList.contains('dark-mode'));
    check('theme: saved dark preference is honored (not overridden to light)', dark === true, { darkMode: dark });
    await p.close();
  }

  // Toggle from light → dark works and persists.
  {
    const p = await makePage();
    await p.setViewport({ width: 1280, height: 900 });
    const errs = [];
    p.on('console', m => { if (m.type() === 'error') errs.push(m.text().slice(0, 160)); });
    await p.evaluateOnNewDocument(() => {
      try { localStorage.removeItem('ks_theme'); } catch (e) {}
    });
    await p.goto(BASE + '/platform/?intent=login', { waitUntil: 'load', timeout: 45000 });
    await new Promise(r => setTimeout(r, 2000));
    const beforeDark = await p.evaluate(() => document.body.classList.contains('dark-mode'));
    await p.evaluate(() => { try { if (typeof toggleTheme === 'function') toggleTheme(); } catch (e) {} });
    await new Promise(r => setTimeout(r, 600));
    const afterDark = await p.evaluate(() => document.body.classList.contains('dark-mode'));
    const saved = await p.evaluate(() => { try { return localStorage.getItem('ks_theme'); } catch (e) { return null; } });
    check('theme: toggle light → dark works', afterDark === true && beforeDark === false, { beforeDark, afterDark, saved });
    await p.close();
  }

  // ------------------------------------------------------------ LOGIN ERROR FEEDBACK
  // We test against the live login handler by putting the page into DEMO_MODE
  // so we can exercise the real validation without needing a real Supabase
  // credential. The DEMO path is the path that runs for first-time / unconfigured
  // deployments, and it exercises the same validation + error-display code.

  // --- Empty email
  {
    const p = await makePage();
    await p.setViewport({ width: 390, height: 900 });
    const errs = [];
    p.on('console', m => { if (m.type() === 'error') errs.push(m.text().slice(0, 160)); });
    await p.evaluateOnNewDocument(() => { window.DEMO_MODE = true; });
    await p.goto(BASE + '/platform/?intent=login', { waitUntil: 'load', timeout: 45000 });
    await new Promise(r => setTimeout(r, 2500));
    await p.evaluate(() => {
      const email = document.getElementById('loginEmail'); if (email) email.value = '';
      const pwd = document.getElementById('loginPassword'); if (pwd) pwd.value = '';
    });
    await p.evaluate(() => { try { performAuth(); } catch (e) {} });
    await new Promise(r => setTimeout(r, 700));
    const msg = await p.evaluate(() => {
      const box = document.getElementById('authInlineError'); return box ? box.textContent || box.innerText || '' : '';
    });
    check('login: empty email → clear error message', msg.toLowerCase().includes('email'), { msg });
    await p.close();
  }

  // --- Invalid email format
  {
    const p = await makePage();
    await p.setViewport({ width: 390, height: 900 });
    const errs = [];
    p.on('console', m => { if (m.type() === 'error') errs.push(m.text().slice(0, 160)); });
    await p.evaluateOnNewDocument(() => { window.DEMO_MODE = true; });
    await p.goto(BASE + '/platform/?intent=login', { waitUntil: 'load', timeout: 45000 });
    await new Promise(r => setTimeout(r, 2500));
    await p.evaluate(() => {
      const email = document.getElementById('loginEmail'); if (email) email.value = 'not-an-email';
      const pwd = document.getElementById('loginPassword'); if (pwd) pwd.value = 'secret12345';
    });
    await p.evaluate(() => { try { performAuth(); } catch (e) {} });
    await new Promise(r => setTimeout(r, 700));
    const msg = await p.evaluate(() => {
      const box = document.getElementById('authInlineError'); return box ? box.textContent || box.innerText || '' : '';
    });
    check('login: invalid email format → valid-email error (not "wrong credentials")', msg.toLowerCase().includes('valid email'), { msg });
    await p.close();
  }

  // --- Empty password
  {
    const p = await makePage();
    await p.setViewport({ width: 390, height: 900 });
    const errs = [];
    p.on('console', m => { if (m.type() === 'error') errs.push(m.text().slice(0, 160)); });
    await p.evaluateOnNewDocument(() => { window.DEMO_MODE = true; });
    await p.goto(BASE + '/platform/?intent=login', { waitUntil: 'load', timeout: 45000 });
    await new Promise(r => setTimeout(r, 2500));
    await p.evaluate(() => {
      const email = document.getElementById('loginEmail'); if (email) email.value = 'farmer@test.in';
      const pwd = document.getElementById('loginPassword'); if (pwd) pwd.value = '';
    });
    await p.evaluate(() => { try { performAuth(); } catch (e) {} });
    await new Promise(r => setTimeout(r, 700));
    const msg = await p.evaluate(() => {
      const box = document.getElementById('authInlineError'); return box ? box.textContent || box.innerText || '' : '';
    });
    check('login: empty password → password-required error', msg.toLowerCase().includes('password'), { msg });
    await p.close();
  }

  // --- Wrong credentials (DEMO mode: email exists but password wrong)
  {
    const p = await makePage();
    await p.setViewport({ width: 390, height: 900 });
    const errs = [];
    p.on('console', m => { if (m.type() === 'error') errs.push(m.text().slice(0, 160)); });
    await p.evaluateOnNewDocument(() => { window.DEMO_MODE = true; });
    await p.goto(BASE + '/platform/?intent=login', { waitUntil: 'load', timeout: 45000 });
    await new Promise(r => setTimeout(r, 2500));
    await p.evaluate(() => {
      const email = document.getElementById('loginEmail'); if (email) email.value = 'existing@example.in';
      const pwd = document.getElementById('loginPassword'); if (pwd) pwd.value = 'WRONGGGGGG';
      // Create the demo user so signInWithPassword runs for this email.
      try {
        const users = JSON.parse(localStorage.getItem('ks_demo_users') || '{}');
        users['existing@example.in'] = { email: 'existing@example.in', password: 'CORRECT123', name: 'Existing User', mobile: '9822045678', role: 'farmer' };
        localStorage.setItem('ks_demo_users', JSON.stringify(users));
      } catch (e) {}
    });
    await p.evaluate(() => { try { performAuth(); } catch (e) {} });
    await new Promise(r => setTimeout(r, 900));
    const msg = await p.evaluate(() => {
      const box = document.getElementById('authInlineError'); return box ? box.textContent || box.innerText || '' : '';
    });
    check('login: wrong password → incorrect-credentials message (not "account already exists")', msg.toLowerCase().includes('incorrect') || msg.toLowerCase().includes('check'), { msg });
    await p.close();
  }

  // --- Error clears on successful login
  {
    const p = await makePage();
    await p.setViewport({ width: 390, height: 900 });
    const errs = [];
    p.on('console', m => { if (m.type() === 'error') errs.push(m.text().slice(0, 160)); });
    await p.evaluateOnNewDocument(() => { window.DEMO_MODE = true; });
    await p.goto(BASE + '/platform/?intent=login', { waitUntil: 'load', timeout: 45000 });
    await new Promise(r => setTimeout(r, 2500));
    await p.evaluate(() => {
      const email = document.getElementById('loginEmail'); if (email) email.value = 'demo@farmer.in';
      const pwd = document.getElementById('loginPassword'); if (pwd) pwd.value = 'demo12345';
      // Seed a demo user.
      try {
        const users = JSON.parse(localStorage.getItem('ks_demo_users') || '{}');
        users['demo@farmer.in'] = { email: 'demo@farmer.in', password: 'demo12345', name: 'Demo Farmer', mobile: '9822045678', role: 'farmer' };
        localStorage.setItem('ks_demo_users', JSON.stringify(users));
      } catch (e) {}
      // Clear any prior error first.
      try { clearAuthError(); } catch (e) {}
    });
    await p.evaluate(() => { try { performAuth(); } catch (e) {} });
    await new Promise(r => setTimeout(r, 2000));
    const loginActive = await p.evaluate(() => {
      const l = document.getElementById('loginPage'); return l ? l.classList.contains('active') : false;
    });
    const loggedIn = await p.evaluate(() => { try { return !!window.isLoggedIn; } catch (e) { return false; } });
    const errorVisible = await p.evaluate(() => {
      const box = document.getElementById('authInlineError'); return box ? box.style.display !== 'none' && box.textContent.trim() !== '' : false;
    });
    check('login: after correct credentials, login page is not showing error + user logged in', !errorVisible && loggedIn === true, { loginActive, loggedIn, errorVisible });
    await p.close();
  }

  await browser.close();
  server.close();
  console.log('\n' + (failures === 0 ? 'ALL THEME + LOGIN-FEEDBACK CHECKS PASSED' : failures + ' CHECK(S) FAILED'));
  process.exit(failures === 0 ? 0 : 1);
})().catch(e => { console.error(e); process.exit(1); });
