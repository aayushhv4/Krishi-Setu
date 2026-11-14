// Comprehensive Final Auth, UX, Theme, and Regression QA
const puppeteer = require('puppeteer-core');
const path = require('path');
const fs = require('fs');

const CHROME = process.env.CHROME_PATH || 'C:/Program Files/Google/Chrome/Application/chrome.exe';
const PROJECT_ROOT = path.join(__dirname, '..', '..');
const sim = require('../vercel-sim.js');

let failures = 0;
function check(name, ok, extra) {
  console.log((ok ? 'PASS ' : 'FAIL ') + name + (extra !== undefined ? '  ' + JSON.stringify(extra) : ''));
  if (!ok) failures++;
}

(async () => {
  if (!fs.existsSync(CHROME)) {
    console.error('Chrome not found at ' + CHROME);
    process.exit(2);
  }

  const server = await sim.start(PROJECT_ROOT, 0);
  const BASE = 'http://127.0.0.1:' + server.address().port;
  console.log('Serving from ' + BASE);

  const browser = await puppeteer.launch({
    executablePath: CHROME,
    headless: 'new',
    args: ['--no-sandbox', '--disable-setuid-sandbox']
  });

  const makePage = async (viewport = { width: 1280, height: 900 }) => {
    const p = await browser.newPage();
    await p.setViewport(viewport);
    return p;
  };

  console.log('\n=== 1. DEFAULT THEME CHECKS (New user, OS dark mode emulation) ===');
  for (const [name, route] of [['Homepage /', '/'], ['Login /platform/?intent=login', '/platform/?intent=login']]) {
    const p = await makePage();
    await p.emulateMediaFeatures([{ name: 'prefers-color-scheme', value: 'dark' }]);
    await p.goto(BASE + route, { waitUntil: 'load', timeout: 30000 });
    await new Promise(r => setTimeout(r, 1500));
    const isDark = await p.evaluate(() => document.body.classList.contains('dark-mode') || document.documentElement.classList.contains('dark'));
    check(`Default theme on ${name} is LIGHT for first-time visitor (even with OS dark mode)`, !isDark, { isDark });
    await p.close();
  }

  console.log('\n=== 2. SAVED THEME PREFERENCE CHECKS ===');
  {
    const p = await makePage();
    await p.evaluateOnNewDocument(() => {
      try { localStorage.setItem('ks_theme', 'dark'); } catch (e) {}
    });
    await p.goto(BASE + '/platform/?intent=login', { waitUntil: 'load', timeout: 30000 });
    await new Promise(r => setTimeout(r, 1500));
    const isDark = await p.evaluate(() => document.body.classList.contains('dark-mode'));
    check('Saved dark theme is honored', isDark === true, { isDark });
    await p.close();
  }

  console.log('\n=== 3. SIGN IN PASSWORD EYE TOGGLE ===');
  {
    const p = await makePage();
    await p.goto(BASE + '/platform/?intent=login', { waitUntil: 'load', timeout: 30000 });
    await new Promise(r => setTimeout(r, 1500));

    // Check initial state
    const initState = await p.evaluate(() => {
      const inp = document.getElementById('loginPassword');
      const btn = document.getElementById('togglePasswordBtn');
      return {
        type: inp ? inp.type : null,
        ariaLabel: btn ? btn.getAttribute('aria-label') : null,
        btnVisible: btn ? window.getComputedStyle(btn).display !== 'none' : false
      };
    });
    check('Initial sign in password field is type=password & has accessible eye button', initState.type === 'password' && initState.ariaLabel === 'Show password', initState);

    // Click toggle button to show password
    await p.click('#togglePasswordBtn');
    await new Promise(r => setTimeout(r, 200));

    const shownState = await p.evaluate(() => {
      const inp = document.getElementById('loginPassword');
      const btn = document.getElementById('togglePasswordBtn');
      return {
        type: inp ? inp.type : null,
        ariaLabel: btn ? btn.getAttribute('aria-label') : null
      };
    });
    check('Clicking eye button toggles password to plain text & updates aria-label to "Hide password"', shownState.type === 'text' && shownState.ariaLabel === 'Hide password', shownState);

    // Click again to hide password
    await p.click('#togglePasswordBtn');
    await new Promise(r => setTimeout(r, 200));

    const hiddenAgainState = await p.evaluate(() => {
      const inp = document.getElementById('loginPassword');
      const btn = document.getElementById('togglePasswordBtn');
      return {
        type: inp ? inp.type : null,
        ariaLabel: btn ? btn.getAttribute('aria-label') : null
      };
    });
    check('Clicking eye button again restores password type & updates aria-label to "Show password"', hiddenAgainState.type === 'password' && hiddenAgainState.ariaLabel === 'Show password', hiddenAgainState);
    await p.close();
  }

  console.log('\n=== 4. CREATE ACCOUNT (SIGN UP) DUAL PASSWORD & VALIDATION ===');
  {
    const p = await makePage();
    await p.goto(BASE + '/platform/?intent=login', { waitUntil: 'load', timeout: 30000 });
    await new Promise(r => setTimeout(r, 1500));

    // Switch to create account mode
    await p.click('#authCreateTab');
    await new Promise(r => setTimeout(r, 300));

    // Select role so validation proceeds to password checks
    await p.click('#loginRoleFarmer');
    await p.type('#loginName', 'Ramesh Farmer');
    await p.type('#loginMobile', '9822012345');
    await p.type('#loginEmail', 'ramesh.farmer@example.com');

    // Check password fields and eye buttons
    const passStructure = await p.evaluate(() => {
      const passInp = document.getElementById('loginPassword');
      const passEye = document.getElementById('togglePasswordBtn');
      const confirmInp = document.getElementById('loginConfirmPassword');
      const confirmEye = confirmInp?.parentElement?.querySelector('.password-eye-btn');
      return {
        passType: passInp?.type,
        hasPassEye: !!passEye,
        confirmType: confirmInp?.type,
        confirmHasEye: !!confirmEye
      };
    });
    check('Create account has password field with eye AND confirm password field with NO eye', passStructure.hasPassEye && !passStructure.confirmHasEye, passStructure);

    // Case 4a: Missing password
    await p.evaluate(() => {
      document.getElementById('loginPassword').value = '';
      document.getElementById('loginConfirmPassword').value = '';
    });
    await p.click('#authPrimaryBtn');
    await new Promise(r => setTimeout(r, 300));
    let err = await p.evaluate(() => document.getElementById('authInlineError')?.innerText || '');
    check('Signup: Missing password shows validation error', err.includes('Please enter your password'), { err });

    // Case 4b: Password too short (< 6)
    await p.type('#loginPassword', '12345');
    await p.click('#authPrimaryBtn');
    await new Promise(r => setTimeout(r, 300));
    err = await p.evaluate(() => document.getElementById('authInlineError')?.innerText || '');
    check('Signup: Password < 6 chars shows length validation error', err.includes('at least 6 characters'), { err });

    // Case 4c: Missing confirm password
    await p.evaluate(() => { document.getElementById('loginPassword').value = 'securePass123'; });
    await p.click('#authPrimaryBtn');
    await new Promise(r => setTimeout(r, 300));
    err = await p.evaluate(() => document.getElementById('authInlineError')?.innerText || '');
    check('Signup: Missing confirm password shows validation error', err.includes('Please confirm your password'), { err });

    // Case 4d: Mismatched passwords
    await p.type('#loginConfirmPassword', 'differentPass456');
    await p.click('#authPrimaryBtn');
    await new Promise(r => setTimeout(r, 300));
    err = await p.evaluate(() => document.getElementById('authInlineError')?.innerText || '');
    check('Signup: Mismatched passwords blocked with "Passwords do not match"', err.includes('Passwords do not match'), { err });

    await p.close();
  }

  console.log('\n=== 5. FORGOT PASSWORD & RESET FLOW ===');
  {
    const p = await makePage();
    await p.goto(BASE + '/platform/?intent=login', { waitUntil: 'load', timeout: 30000 });
    await new Promise(r => setTimeout(r, 1500));

    // Verify "Forgot password?" link exists on Sign In form
    const forgotLinkVisible = await p.evaluate(() => {
      const el = document.getElementById('forgotPasswordLink');
      return el && window.getComputedStyle(el).display !== 'none';
    });
    check('Forgot password? link is visible on Sign In form', forgotLinkVisible);

    // Click "Forgot password?"
    await p.click('#forgotPasswordLink');
    await new Promise(r => setTimeout(r, 300));

    const forgotModeState = await p.evaluate(() => {
      const emailVisible = document.getElementById('authEmailGroup')?.style.display !== 'none';
      const passVisible = document.getElementById('authPasswordGroup')?.style.display !== 'none';
      const btnText = document.getElementById('authPrimaryBtn')?.innerText || '';
      const backVisible = document.getElementById('authBackToSignInWrap')?.style.display !== 'none';
      return { emailVisible, passVisible, btnText, backVisible };
    });
    check('Forgot password view displays email field, reset button and back link while hiding password', forgotModeState.emailVisible && !forgotModeState.passVisible && forgotModeState.btnText.includes('Reset Link') && forgotModeState.backVisible, forgotModeState);

    // Case 5a: Empty email
    await p.evaluate(() => { document.getElementById('loginEmail').value = ''; });
    await p.click('#authPrimaryBtn');
    await new Promise(r => setTimeout(r, 300));
    let err = await p.evaluate(() => document.getElementById('authInlineError')?.innerText || '');
    check('Forgot password: Empty email shows validation error', err.includes('Please enter your email address'), { err });

    // Case 5b: Malformed email
    await p.type('#loginEmail', 'invalidemailformat');
    await p.click('#authPrimaryBtn');
    await new Promise(r => setTimeout(r, 300));
    err = await p.evaluate(() => document.getElementById('authInlineError')?.innerText || '');
    check('Forgot password: Invalid email format shows validation error', err.includes('valid email address'), { err });

    // Case 5c: Valid email -> reset request
    await p.evaluate(() => { document.getElementById('loginEmail').value = 'farmer.test@krishisetu.in'; });
    await p.click('#authPrimaryBtn');
    await new Promise(r => setTimeout(r, 2000));
    const successMsg = await p.evaluate(() => document.getElementById('authInlineError')?.innerText || '');
    check('Forgot password: Valid email sends reset link & displays clear success feedback', successMsg.includes('Password reset email sent') || successMsg.includes('inbox'), { successMsg });

    // Case 5d: Back to Sign In button works
    await p.click('#authBackToSignInWrap button');
    await new Promise(r => setTimeout(r, 300));
    const returnedToSignIn = await p.evaluate(() => {
      const passVisible = document.getElementById('authPasswordGroup')?.style.display !== 'none';
      const btnText = document.getElementById('authPrimaryBtn')?.innerText || '';
      return passVisible && btnText.includes('Sign In');
    });
    check('Back to Sign In returns to normal Sign In form', returnedToSignIn);

    await p.close();
  }

  console.log('\n=== 6. PASSWORD UPDATE (RECOVERY VIEW) ===');
  {
    const p = await makePage();
    await p.goto(BASE + '/platform/?intent=login#type=recovery', { waitUntil: 'load', timeout: 30000 });
    await new Promise(r => setTimeout(r, 1500));

    const updateView = await p.evaluate(() => {
      const upGroup = document.getElementById('authUpdatePasswordGroup');
      const passEye = document.getElementById('toggleNewPasswordBtn');
      const confirmInp = document.getElementById('confirmNewPasswordInput');
      const confirmHasEye = !!confirmInp?.closest('.password-field-wrap') || !!confirmInp?.nextElementSibling?.classList?.contains('password-eye-btn');
      return {
        visible: upGroup && window.getComputedStyle(upGroup).display !== 'none',
        hasPassEye: !!passEye,
        confirmHasEye
      };
    });
    check('Recovery hash triggers Update Password view with eye on new password and NO eye on confirm', updateView.visible && updateView.hasPassEye && !updateView.confirmHasEye, updateView);

    // Mismatched passwords
    await p.type('#newPasswordInput', 'brandNewPass123');
    await p.type('#confirmNewPasswordInput', 'differentNewPass456');
    await p.click('#updatePasswordBtn');
    await new Promise(r => setTimeout(r, 300));
    const mismatchErr = await p.evaluate(() => document.getElementById('authInlineError')?.innerText || '');
    check('Password update: Mismatched new passwords blocked with "Passwords do not match"', mismatchErr.includes('Passwords do not match'), { mismatchErr });

    await p.close();
  }

  console.log('\n=== 7. LIVE SUPABASE AUTH CALL WITH INVALID CREDENTIALS ===');
  {
    const p = await makePage();
    let supabaseRequestMade = false;
    p.on('request', req => {
      if (req.url().includes('supabase.co/auth/v1/token')) {
        supabaseRequestMade = true;
      }
    });

    await p.goto(BASE + '/platform/?intent=login', { waitUntil: 'load', timeout: 30000 });
    await new Promise(r => setTimeout(r, 1500));

    await p.type('#loginEmail', 'real_check_unregistered@krishisetu.in');
    await p.type('#loginPassword', 'wrongpass123');
    await p.click('#authPrimaryBtn');
    await new Promise(r => setTimeout(r, 2500));

    check('Supabase token endpoint was called over the network', supabaseRequestMade);

    const errBoxInfo = await p.evaluate(() => {
      const el = document.getElementById('authInlineError');
      const btn = document.getElementById('authPrimaryBtn');
      return {
        visible: el && el.style.display !== 'none',
        text: el ? el.innerText : '',
        btnDisabled: btn ? btn.disabled : false
      };
    });

    check('Inline error is displayed clearly near the form', errBoxInfo.visible);
    check('Error message is user-friendly and security-safe', errBoxInfo.text.includes('Incorrect email or password'), { text: errBoxInfo.text });
    check('Button is re-enabled after failed auth', !errBoxInfo.btnDisabled);
    await p.close();
  }

  console.log('\n=== 8. DEMO PERSONA LOGIN, REFRESH PERSISTENCE & LOGOUT ===');
  {
    const p = await makePage();
    await p.goto(BASE + '/platform/?intent=login', { waitUntil: 'load', timeout: 30000 });
    await new Promise(r => setTimeout(r, 1500));

    await p.evaluate(() => window.demoLogin('farmer'));
    await new Promise(r => setTimeout(r, 1500));

    const stateAfterLogin = await p.evaluate(() => ({
      isLoggedIn: window.isLoggedIn,
      currentRole: window.currentRole,
      bodyAuthFirst: document.body.classList.contains('auth-first')
    }));
    check('Demo login successfully signs in and opens dashboard', stateAfterLogin.isLoggedIn && !stateAfterLogin.bodyAuthFirst, stateAfterLogin);

    // Refresh after login -> session must persist
    await p.reload({ waitUntil: 'load' });
    await new Promise(r => setTimeout(r, 1500));

    const stateAfterReload = await p.evaluate(() => ({
      isLoggedIn: window.isLoggedIn,
      currentRole: window.currentRole,
      bodyAuthFirst: document.body.classList.contains('auth-first')
    }));
    check('Session persists upon dashboard refresh without flashing login', stateAfterReload.isLoggedIn && !stateAfterReload.bodyAuthFirst, stateAfterReload);

    // Logout -> navigates to Government homepage
    await p.evaluate(() => window.logout());
    await new Promise(r => setTimeout(r, 1500));

    const afterLogoutUrl = p.url();
    check('Logout navigates to public government site', afterLogoutUrl.includes('government-version') || afterLogoutUrl.endsWith('/'), { afterLogoutUrl });
    await p.close();
  }

  console.log('\n=== 9. RBAC WHATSAPP BETA VISIBILITY CHECKS ===');
  for (const role of ['farmer', 'buyer', 'supervisor']) {
    const p = await makePage();
    await p.goto(BASE + '/platform/?intent=login', { waitUntil: 'load', timeout: 30000 });
    await new Promise(r => setTimeout(r, 1500));

    await p.evaluate((r) => window.demoLogin(r), role);
    await new Promise(r => setTimeout(r, 1200));

    const waVisibility = await p.evaluate(() => {
      const waPill = document.querySelector('.nav-whatsapp');
      if (!waPill) return { exists: false, visible: false };
      const style = window.getComputedStyle(waPill);
      const visible = style.display !== 'none' && style.visibility !== 'hidden' && style.opacity !== '0';
      return { exists: true, visible, display: style.display };
    });

    if (role === 'supervisor') {
      check('Supervisor workspace hides WhatsApp Beta', !waVisibility.visible, waVisibility);
    } else {
      check(`${role} workspace shows WhatsApp Beta`, waVisibility.visible, waVisibility);
    }
    await p.evaluate(() => { try { window.logout(); } catch(e){} });
    await p.close();
  }

  console.log('\n=== 10. RESPONSIVE VIEWPORT CHECKS (360, 390, 430, 768, 1024, 1280) ===');
  const viewports = [360, 390, 430, 768, 1024, 1280];
  for (const w of viewports) {
    const p = await makePage({ width: w, height: 800 });
    await p.evaluateOnNewDocument(() => {
      try {
        localStorage.removeItem('krishiSetuDemoLoggedIn');
        localStorage.removeItem('krishiSetuLoggedIn');
        localStorage.removeItem('krishiSetuSavedIdentity');
      } catch(e){}
    });
    await p.goto(BASE + '/platform/?intent=login', { waitUntil: 'load', timeout: 30000 });
    await new Promise(r => setTimeout(r, 1200));

    await p.evaluate(async () => {
      const email = document.getElementById('loginEmail');
      if (email) email.value = '';
      const pwd = document.getElementById('loginPassword');
      if (pwd) pwd.value = '';
      if (typeof performAuth === 'function') await performAuth();
    });
    await new Promise(r => setTimeout(r, 600));

    const layout = await p.evaluate(() => {
      const scrollW = document.documentElement.scrollWidth;
      const clientW = document.documentElement.clientWidth;
      const errBox = document.getElementById('authInlineError');
      const errRect = errBox ? errBox.getBoundingClientRect() : null;
      return {
        hasOverflow: scrollW > clientW,
        scrollW,
        clientW,
        errBoxVisible: errBox && errBox.style.display !== 'none',
        errBoxWidth: errRect ? errRect.width : 0
      };
    });

    check(`Viewport ${w}px has no horizontal overflow & error displays cleanly`, !layout.hasOverflow && layout.errBoxVisible && layout.errBoxWidth > 0, layout);
    await p.close();
  }

  await browser.close();
  server.close();

  console.log('\n' + (failures === 0 ? 'ALL VERIFICATION CHECKS PASSED (0 failures)!' : `${failures} CHECK(S) FAILED!`));
  process.exit(failures === 0 ? 0 : 1);
})().catch(e => {
  console.error('Test run crashed:', e);
  process.exit(1);
});
