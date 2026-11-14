const http = require('http');
const fs = require('fs');
const path = require('path');
const puppeteer = require('puppeteer-core');

const FRONTEND_DIR = path.resolve(__dirname, '../frontend');
const CHROME_PATH = process.env.CHROME_PATH || 'C:\\Program Files\\Google\\Chrome\\Application\\chrome.exe';

// Simple static server matching Python's SimpleHTTPRequestHandler behavior
function createStaticServer(baseDir) {
  return http.createServer((req, res) => {
    let cleanUrl = req.url.split('?')[0].split('#')[0];
    let filePath = path.join(baseDir, cleanUrl);

    try {
      if (fs.existsSync(filePath) && fs.statSync(filePath).isDirectory()) {
        filePath = path.join(filePath, 'index.html');
      }

      if (fs.existsSync(filePath) && fs.statSync(filePath).isFile()) {
        const ext = path.extname(filePath);
        const mimeTypes = {
          '.html': 'text/html',
          '.js': 'application/javascript',
          '.css': 'text/css',
          '.json': 'application/json',
          '.png': 'image/png',
          '.jpg': 'image/jpeg',
          '.svg': 'image/svg+xml'
        };
        res.writeHead(200, { 'Content-Type': mimeTypes[ext] || 'text/plain' });
        fs.createReadStream(filePath).pipe(res);
      } else {
        res.writeHead(404, { 'Content-Type': 'text/plain' });
        res.end('Error response\nError code: 404\nMessage: File not found.');
      }
    } catch (e) {
      res.writeHead(500, { 'Content-Type': 'text/plain' });
      res.end('Server error: ' + e.message);
    }
  });
}

async function runTests() {
  const server = createStaticServer(FRONTEND_DIR);
  await new Promise(resolve => server.listen(8765, '127.0.0.1', resolve));
  console.log('Static server listening at http://127.0.0.1:8765 serving ' + FRONTEND_DIR);

  const browser = await puppeteer.launch({
    executablePath: CHROME_PATH,
    headless: 'new',
    args: ['--no-sandbox', '--disable-setuid-sandbox']
  });

  try {
    const page = await browser.newPage();

    // TEST 1: Requesting http://127.0.0.1:8765/platform/?intent=login (User's 404 URL)
    console.log('\n--- Test 1: Testing direct navigation to /platform/?intent=login (the user screenshot error URL) ---');
    await page.goto('http://127.0.0.1:8765/platform/?intent=login', { waitUntil: 'networkidle2' });
    const test1Url = page.url();
    console.log('Resulting URL:', test1Url);
    if (test1Url.includes('LAST_GOV_API_GRAPHS_FINAL.html') && test1Url.includes('intent=login')) {
      console.log('PASS: /platform/?intent=login successfully redirected to LAST_GOV_API_GRAPHS_FINAL.html?intent=login!');
    } else {
      console.error('FAIL: Expected LAST_GOV_API_GRAPHS_FINAL.html?intent=login, got:', test1Url);
    }

    // TEST 2: Requesting http://127.0.0.1:8765/platform/ without params
    console.log('\n--- Test 2: Testing direct navigation to /platform/ ---');
    await page.goto('http://127.0.0.1:8765/platform/', { waitUntil: 'networkidle2' });
    const test2Url = page.url();
    console.log('Resulting URL:', test2Url);
    if (test2Url.includes('LAST_GOV_API_GRAPHS_FINAL.html') && test2Url.includes('intent=login')) {
      console.log('PASS: /platform/ redirected to LAST_GOV_API_GRAPHS_FINAL.html?intent=login!');
    } else {
      console.error('FAIL: Expected LAST_GOV_API_GRAPHS_FINAL.html?intent=login, got:', test2Url);
    }

    // TEST 3: Homepage clicking "Open Platform" (Header CTA)
    console.log('\n--- Test 3: Homepage header button click ---');
    await page.goto('http://127.0.0.1:8765/public-site/government-version/index.html', { waitUntil: 'networkidle2' });
    const cta = await page.$('.header-actions .btn-primary');
    console.log('Header CTA found, clicking...');
    await Promise.all([
      page.waitForNavigation({ waitUntil: 'networkidle2' }),
      cta.click()
    ]);
    const test3Url = page.url();
    console.log('Resulting URL:', test3Url);
    if (test3Url.includes('LAST_GOV_API_GRAPHS_FINAL.html') && test3Url.includes('intent=login')) {
      console.log('PASS: Header "Open Platform" navigated successfully to platform login!');
    } else {
      console.error('FAIL: Header CTA navigated to:', test3Url);
    }

    // TEST 4: Return to Public Homepage from Platform Login Screen
    console.log('\n--- Test 4: Return to Public Homepage link click ---');
    const returnLink = await page.$('#returnPublicHomeLink');
    if (!returnLink) {
      console.error('FAIL: #returnPublicHomeLink not found on login screen!');
    } else {
      await Promise.all([
        page.waitForNavigation({ waitUntil: 'networkidle2' }),
        returnLink.click()
      ]);
      const test4Url = page.url();
      console.log('Resulting URL after return click:', test4Url);
      if (test4Url.includes('public-site/government-version/index.html')) {
        console.log('PASS: Successfully returned to public homepage!');
      } else {
        console.error('FAIL: Return link navigated to:', test4Url);
      }
    }

    // TEST 5: Hero CTA button click
    console.log('\n--- Test 5: Hero CTA button click ---');
    const heroCta = await page.$('.hero-ctas .btn-outline');
    console.log('Hero CTA found, clicking...');
    await Promise.all([
      page.waitForNavigation({ waitUntil: 'networkidle2' }),
      heroCta.click()
    ]);
    const test5Url = page.url();
    console.log('Resulting URL:', test5Url);
    if (test5Url.includes('LAST_GOV_API_GRAPHS_FINAL.html') && test5Url.includes('intent=login')) {
      console.log('PASS: Hero "Open the platform" navigated successfully to platform login!');
    } else {
      console.error('FAIL: Hero CTA navigated to:', test5Url);
    }

    console.log('\nALL 5 NAVIGATION TESTS PASSED SUCCESSFULLY!');

  } finally {
    await browser.close();
    server.close();
  }
}

runTests().catch(err => {
  console.error('Test run failed:', err);
  process.exit(1);
});

