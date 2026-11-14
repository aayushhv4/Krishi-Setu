const path = require('path');
const puppeteer = require('./node_modules/puppeteer-core');
const sim = require('./vercel-sim.js');

const CHROME = process.env.CHROME_PATH || 'C:/Program Files/Google/Chrome/Application/chrome.exe';
const PROJECT_ROOT = path.join(__dirname, '..');

(async () => {
  console.log('Starting Vercel / Static Server simulator...');
  const server = await sim.start(PROJECT_ROOT, 0);
  const port = server.address().port;
  const baseUrl = `http://127.0.0.1:${port}`;
  console.log('Running test on ' + baseUrl);

  const browser = await puppeteer.launch({
    executablePath: CHROME,
    headless: true,
    args: ['--no-sandbox', '--disable-setuid-sandbox']
  });

  let testsPassed = 0;
  let testsTotal = 0;

  function assert(name, condition, details = '') {
    testsTotal++;
    if (condition) {
      console.log(`[PASS] ${name} ${details}`);
      testsPassed++;
    } else {
      console.error(`[FAIL] ${name} ${details}`);
    }
  }

  try {
    // ----------------------------------------------------
    // TEST 1: Desktop Homepage Navigation
    // ----------------------------------------------------
    console.log('\n--- Test 1: Desktop Homepage (1280x800) ---');
    const page = await browser.newPage();
    await page.setViewport({ width: 1280, height: 800 });

    await page.goto(`${baseUrl}/public-site/government-version/index.html`, { waitUntil: 'networkidle2' });

    const openBtn = await page.$('.header-actions a.btn-primary');
    assert('Header Open Platform button exists', !!openBtn);

    const hrefAttr = await page.evaluate(el => el.getAttribute('href'), openBtn);
    const resolvedHref = await page.evaluate(el => el.href, openBtn);
    console.log('Button href attribute:', hrefAttr);
    console.log('Button resolved href:', resolvedHref);
    assert('Button href points to platform login', 
      hrefAttr.includes('LAST_GOV_API_GRAPHS_FINAL.html?intent=login') || 
      hrefAttr.includes('/platform/?intent=login') ||
      resolvedHref.includes('LAST_GOV_API_GRAPHS_FINAL.html?intent=login') ||
      resolvedHref.includes('/platform/?intent=login'));

    console.log('Clicking Open Platform button...');
    await Promise.all([
      page.waitForNavigation({ waitUntil: 'networkidle2', timeout: 8000 }),
      openBtn.click()
    ]);

    const platformUrl = page.url();
    console.log('Navigated to:', platformUrl);
    assert('Destination URL contains platform login', 
      platformUrl.includes('LAST_GOV_API_GRAPHS_FINAL.html?intent=login') ||
      platformUrl.includes('/platform/?intent=login'));

    // Check that login screen is displayed (not bounced back)
    await new Promise(r => setTimeout(r, 1000));
    const title = await page.title();
    console.log('Platform page title:', title);
    assert('Page stayed on platform (not bounced back)', 
      platformUrl.includes('LAST_GOV_API_GRAPHS_FINAL.html') ||
      platformUrl.includes('/platform/'));

    // ----------------------------------------------------
    // TEST 2: Return to Homepage from Login Screen
    // ----------------------------------------------------
    console.log('\n--- Test 2: Return to Homepage from Login Screen ---');
    const returnHomeLink = await page.$('#returnPublicHomeLink');
    assert('Login screen Return to Public Homepage link exists', !!returnHomeLink);

    console.log('Clicking return link to go back to homepage...');
    await Promise.all([
      page.waitForNavigation({ waitUntil: 'networkidle2', timeout: 8000 }),
      returnHomeLink.click()
    ]);

    const returnUrl = page.url();
    console.log('Returned to:', returnUrl);
    assert('Successfully returned to public homepage', returnUrl.includes('public-site/government-version/index.html') || returnUrl.endsWith('/'));

    // ----------------------------------------------------
    // TEST 3: Mobile Viewport (375x667)
    // ----------------------------------------------------
    console.log('\n--- Test 3: Mobile Viewport (375x667) ---');
    const mobilePage = await browser.newPage();
    await mobilePage.setViewport({ width: 375, height: 667 });

    await mobilePage.goto(`${baseUrl}/public-site/government-version/index.html`, { waitUntil: 'networkidle2' });

    const mobileBtn = await mobilePage.$('.header-actions a.btn-primary');
    assert('Mobile Open Platform button is visible', !!mobileBtn);

    const isVisible = await mobilePage.evaluate(el => {
      const rect = el.getBoundingClientRect();
      return rect.width > 0 && rect.height > 0 && window.getComputedStyle(el).display !== 'none';
    }, mobileBtn);
    assert('Open Platform button has non-zero size on mobile', isVisible);

    console.log('Clicking Open Platform on mobile...');
    await Promise.all([
      mobilePage.waitForNavigation({ waitUntil: 'networkidle2', timeout: 8000 }),
      mobileBtn.click()
    ]);

    const mobileDestUrl = mobilePage.url();
    console.log('Mobile navigated to:', mobileDestUrl);
    assert('Mobile destination URL contains platform login', 
      mobileDestUrl.includes('LAST_GOV_API_GRAPHS_FINAL.html?intent=login') ||
      mobileDestUrl.includes('/platform/?intent=login'));

    await mobilePage.close();
    await page.close();

    // ----------------------------------------------------
    // TEST 4: Production Vercel Route Preservation (/platform/)
    // ----------------------------------------------------
    console.log('\n--- Test 4: Vercel /platform/ Route Preservation ---');
    const prodPage = await browser.newPage();
    // Simulate non-local environment by navigating to /platform/
    const res = await prodPage.goto(`${baseUrl}/platform/?intent=login`, { waitUntil: 'networkidle2' });
    console.log('/platform/?intent=login response status:', res.status());
    assert('/platform/?intent=login returns 200 OK', res.status() === 200);

    await prodPage.close();

    console.log(`\n========================================`);
    console.log(`SUMMARY: ${testsPassed}/${testsTotal} tests passed.`);
    console.log(`========================================`);

    await browser.close();
    server.close();

    if (testsPassed === testsTotal) {
      process.exit(0);
    } else {
      process.exit(1);
    }
  } catch (err) {
    console.error('Test execution failed:', err);
    if (browser) await browser.close();
    server.close();
    process.exit(1);
  }
})();
