/* ============================================================
   KRISHI SETU — PUBLIC SITE CONTENT (shared information layer)
   Same content ships in BOTH versions; only the presentation
   layer (css/main.js) differs between them.
   Demo/sample data is explicitly labelled — nothing here claims
   official status or real-world results.
   ============================================================ */

const KS = {
  brand: 'Krishi Setu',
  tagline: 'Farm. Connect. Prosper.',
  platformUrl: (typeof window !== 'undefined' && (
    window.location.protocol === 'file:' ||
    (window.location.pathname && window.location.pathname.indexOf('government-version') !== -1)
  )) ? '../../LAST_GOV_API_GRAPHS_FINAL.html' : '/platform/',

  /* ---- What we are (used on home + about) ---- */
  whatIs: 'Krishi Setu connects Indian farmers, FPOs and institutional buyers in one agricultural OS — live mandi prices, direct farm-gate deals, AI crop care, cold-chain logistics, storage and government schemes.',

  /* ---- How it works (identical in both versions) ---- */
  steps: [
    { n: '01', icon: '👤', title: 'Create your profile', text: 'Register as a farmer, FPO, buyer or supervisor. Your role shapes the workspace you see.' },
    { n: '02', icon: '📦', title: 'Record crop inventory', text: 'Log crop, variety, harvest date, storage condition and moisture for every harvested batch.' },
    { n: '03', icon: '🔬', title: 'Analyze produce', text: 'AI freshness scoring and shelf-life prediction tell you which batches to sell first.' },
    { n: '04', icon: '🧺', title: 'Publish produce lot', text: 'Auto-fill lot details from inventory and list verified produce on the buyer marketplace.' },
    { n: '05', icon: '🤝', title: 'Receive & compare offers', text: 'Compare buyer bids on price, net realisation after deductions, pickup and payment terms.' },
    { n: '06', icon: '💳', title: 'Sell, ship & get paid', text: 'Lock the contract, arrange logistics, and settle through escrow rails on delivery approval.' }
  ],

  /* ---- Homepage market ticker ----------------------------------
     Demo reference prices — the SAME offline/reference values the
     application dashboard shows (MANDI_BENCHMARKS modal prices in
     LAST_GOV_API_GRAPHS_FINAL.html). NOT a live market feed; the
     ticker UI is explicitly labelled as demo data. When a live
     government feed is configured in the application, replace these
     entries with observations from that feed (same shape).
     ------------------------------------------------------------ */
  marketTickerNote: 'Demo reference prices for demonstration — not a live market feed.',
  marketTicker: [
    { emoji: '🧅', crop: 'Onion', state: 'Maharashtra', market: 'Lasalgaon APMC', price: 2950, dir: 'up', pct: 3.4 },
    { emoji: '🍅', crop: 'Tomato', state: 'Maharashtra', market: 'Narayangaon APMC', price: 2150, dir: 'down', pct: 2.1 },
    { emoji: '🥔', crop: 'Potato', state: 'Maharashtra', market: 'Khed APMC', price: 1780, dir: 'up', pct: 1.8 },
    { emoji: '🌱', crop: 'Soybean', state: 'Maharashtra', market: 'Latur APMC', price: 4550, dir: 'up', pct: 0.9 },
    { emoji: '🍇', crop: 'Grapes', state: 'Maharashtra', market: 'Pimpalgaon APMC', price: 6800, dir: 'up', pct: 1.2 },
    { emoji: '🌾', crop: 'Wheat', state: 'Madhya Pradesh', market: 'Indore APMC', price: 2750, dir: 'up', pct: 0.9 },
    { emoji: '🍚', crop: 'Rice', state: 'Haryana', market: 'Karnal APMC', price: 3600, dir: 'down', pct: 0.6 },
    { emoji: '☁️', crop: 'Cotton', state: 'Gujarat', market: 'Rajkot APMC', price: 7200, dir: 'up', pct: 1.1 }
  ],

  /* ---- Impact statistics (demo — replace with verified data) ---- */
  stats: [
    { value: 12000, suffix: '+', label: 'Farmers connected*' },
    { value: 45, suffix: '+', label: 'Produce categories' },
    { value: 260, suffix: '+', label: 'Mandi markets covered' },
    { value: 11, suffix: '', label: 'Indian languages' },
    { value: 2400, suffix: '+', label: 'Verified buyers*' },
    { value: 85, suffix: ' Cr+', label: 'Demo settlements (₹)*' }
  ],
  statNote: 'Demo figures for demonstration. Replace with verified platform statistics before public launch.',

  /* ---- Impact outcome cards ---- */
  outcomes: [
    { icon: '💰', title: 'Better prices', text: 'Farmers compare mandi benchmarks, buyer bids and channel net-realisation before selling.' },
    { icon: '⚡', title: 'Faster settlement', text: 'Escrow-backed settlement releases payment once the buyer approves delivery.' },
    { icon: '🌾', title: 'Less wastage', text: 'Shelf-life prediction and cold-chain logistics prioritise perishable batches.' },
    { icon: '🗺️', title: 'Market access', text: 'One marketplace connects village-level produce to institutional demand across states.' }
  ],

  /* ---- Government schemes (real schemes, guidance only) ---- */
  schemeNote: 'Scheme details below are general guidance for farmers. Always confirm eligibility, benefits and deadlines on the official portal of the scheme before applying.',
  schemes: [
    {
      name: 'PM-KISAN — Pradhan Mantri Kisan Samman Nidhi',
      cat: 'Income Support',
      purpose: 'Direct income support of ₹6,000 per year (in three instalments) to eligible landholding farmer families.',
      eligible: 'All landholding farmer families with cultivable land, subject to scheme exclusion criteria.',
      benefits: ['₹6,000/year in 3 instalments', 'Direct Benefit Transfer to Aadhaar-linked account', 'Fully online application & status check'],
      documents: 'Aadhaar, land records, bank account details',
      official: 'https://pmkisan.gov.in/'
    },
    {
      name: 'PMFBY — Pradhan Mantri Fasal Bima Yojana',
      cat: 'Crop Insurance',
      purpose: 'Crop insurance against non-preventable natural risks, with a uniform premium of 2% (kharif), 1.5% (rabi) and 5% (commercial/horticultural crops).',
      eligible: 'All farmers growing notified crops in notified areas; loanee and non-loanee farmers.',
      benefits: ['Subsidised premium', 'Coverage for prevented sowing, post-harvest losses and localised calamities', 'Online enrolment through banks / CSC'],
      documents: 'Land records, bank account, crop details',
      official: 'https://pmfby.gov.in/'
    },
    {
      name: 'Kisan Credit Card (KCC)',
      cat: 'Credit & Finance',
      purpose: 'Flexible short-term credit for cultivation, post-harvest needs and farm assets through banks.',
      eligible: 'Farmers, sharecroppers, tenant farmers and FPOs with a farm activity plan.',
      benefits: ['Low-interest crop loans', 'Withdrawal as needed within limit', 'Interest subvention under some state schemes'],
      documents: 'Identity proof, land records, crop plan',
      official: 'https://www.nabard.org/' /* guidance link — apply via your bank */
    },
    {
      name: 'eNAM — National Agriculture Market',
      cat: 'Market & Trade',
      purpose: 'Unified online pan-India trading portal for agricultural commodities, linking APMC mandis.',
      eligible: 'Farmers, traders, FPOs and commission agents registered on the eNAM portal.',
      benefits: ['Transparent online bidding', 'Access to buyers beyond local mandi', 'Standardised quality assessment'],
      documents: 'Registration on eNAM portal via mandi',
      official: 'https://enam.gov.in/'
    },
    {
      name: 'Soil Health Card (SHC)',
      cat: 'Crop Advisory',
      purpose: 'Soil nutrient status report for every farm holding, with fertiliser recommendations.',
      eligible: 'All farmers; soil samples tested at government/approved labs.',
      benefits: ['Free soil testing', 'Crop-wise fertiliser recommendation', 'Helps reduce input cost'],
      documents: 'Farmer ID, land details at testing camp',
      official: 'https://soilhealth.dac.gov.in/'
    },
    {
      name: 'PMKSY — Per Drop More Crop (Micro-Irrigation)',
      cat: 'Water & Irrigation',
      purpose: 'Efficient water use through drip/sprinkler systems with subsidy support.',
      eligible: 'Individual farmers and FPOs; subsidy varies by state and system type.',
      benefits: ['Up to 55% subsidy on micro-irrigation systems', 'Higher water-use efficiency', 'Better yield stability'],
      documents: 'Land records, bank account, project plan',
      official: 'https://pmksy.gov.in/'
    },
    {
      name: 'Agriculture Infrastructure Fund (AIF)',
      cat: 'Post-Harvest',
      purpose: 'Medium/long-term loans for post-harvest infrastructure — warehouses, cold storage, sorting/grading units.',
      eligible: 'Farmers, FPOs, agri-entrepreneurs, start-ups and cooperative societies.',
      benefits: ['Interest subvention on loans', 'Loans up to ₹2 crore for individual projects', 'Strengthens storage & logistics'],
      documents: 'Project report, land/building documents, bank proposal',
      official: 'https://agriinfra.dac.gov.in/'
    },
    {
      name: 'PM-AASHA — Price Support Scheme',
      cat: 'Market & Trade',
      purpose: 'Ensures remunerative prices through Price Support Scheme (PSS), Price Deficiency Payment (PDP) and pilot procurement.',
      eligible: 'Farmers producing notified oilseeds, pulses and copra at Minimum Support Price.',
      benefits: ['MSP assurance for notified crops', 'Procurement through agencies', 'Protects against price fall'],
      documents: 'Land records, crop details at procurement centre',
      official: 'https://pmaasha.gov.in/'
    },
    {
      name: 'MIDH — Mission for Integrated Development of Horticulture',
      cat: 'Horticulture',
      purpose: 'Holistic growth of horticulture — planting material, protected cultivation, post-harvest management.',
      eligible: 'Horticulture farmers and FPOs; assistance pattern differs by activity and state.',
      benefits: ['Assistance for polyhouse / shade net', 'Post-harvest & cold-chain support', 'Higher value horticulture crops'],
      documents: 'Project proposal, land records',
      official: 'https://midh.gov.in/'
    },
    {
      name: 'NFSM — National Food Security Mission',
      cat: 'Food Crops',
      purpose: 'Enhance production of rice, wheat, pulses and coarse cereals through technology demonstrations and inputs.',
      eligible: 'Farmers in notified districts cultivating target crops.',
      benefits: ['Subsidised seeds & inputs', 'Demonstration of improved practices', 'Increase in productivity'],
      documents: 'As notified by state agriculture department',
      official: 'https://nfsm.gov.in/'
    }
  ],

  /* ---- News (demo/sample stories, clearly labelled) ---- */
  newsNote: 'All stories below are SAMPLE content for demonstration. They are not real news reports.',
  news: [
    {
      id: 'n1', featured: true, cat: 'Platform', date: '05 Sep 2026', read: '4 min',
      title: 'Krishi Setu connects Nashik onion growers with farm-gate buyers',
      dek: 'A sample story: how farm-gate lots, freshness scoring and escrow settlement come together on one platform.',
      body: [
        'This is a sample article written for the demonstration website. It is not a real news report.',
        'In this scenario, onion growers record harvested batches in inventory, publish produce lots, and compare offers from institutional buyers — including net realisation after logistics and fees.',
        'Buyers see freshness scores, storage conditions and verified trust ratings before making an offer, and settlement runs through an escrow rail once delivery is approved.',
        'The story is illustrative of the product flow the Krishi Setu application demonstrates.'
      ]
    },
    {
      id: 'n2', cat: 'Market', date: '28 Aug 2026', read: '3 min',
      title: 'Mandi price trends: what to watch this month (sample)',
      dek: 'A sample market brief showing how modal prices, arrivals and trend signals are presented in the platform.',
      body: [
        'Sample content — not market advice. Krishi Setu surfaces government mandi observations when available, and clearly labels planning references otherwise.',
        'The demo dashboard tracks modal prices, 24-hour trends and arrival volumes across supported crops such as onion, tomato, potato and soybean.'
      ]
    },
    {
      id: 'n3', cat: 'Resources', date: '21 Aug 2026', read: '5 min',
      title: 'New farmer-guide modules on cold storage and shelf life (sample)',
      dek: 'Sample update: shelf-life prediction and cold-chain guidance modules added to the resource library.',
      body: [
        'Sample announcement. The resource library is organised into farmer guides, crop information, market resources, schemes, logistics and finance.',
        'Each module is written in simple language and is available in multiple Indian languages in the application.'
      ]
    },
    {
      id: 'n4', cat: 'Schemes', date: '14 Aug 2026', read: '3 min',
      title: 'PM-KISAN instalment status: how to check it (sample guide)',
      dek: 'A sample guide explaining how farmers can verify scheme instalment status on official portals.',
      body: [
        'Sample guidance. Farmers can check PM-KISAN instalment status on the official portal (pmkisan.gov.in) with their Aadhaar-linked details.',
        'Krishi Setu\'s scheme directory links to official portals — always verify details there before acting.'
      ]
    },
    {
      id: 'n5', cat: 'Farmer Stories', date: '07 Aug 2026', read: '4 min',
      title: 'FPO aggregation pilots show logistics savings (sample)',
      dek: 'Sample story: pooled lots from multiple farmers reduce per-quintal logistics cost for bulk buyers.',
      body: [
        'Sample illustration of the aggregation feature: compatible lots from nearby member farmers are pooled to meet institutional volume requirements.',
        'The match engine estimates combined volume, estimated net price and logistics savings before a consolidated lot is proposed.'
      ]
    },
    {
      id: 'n6', cat: 'Platform', date: '30 Jul 2026', read: '2 min',
      title: 'Eleven Indian languages now supported across the platform (sample)',
      dek: 'Sample announcement: English plus ten Indian languages across navigation, pages and resources.',
      body: [
        'Sample announcement. The application ships translation dictionaries for Hindi, Marathi, Gujarati, Punjabi, Bengali, Tamil, Telugu, Kannada, Malayalam and Odia.',
        'Language selection persists across sessions, and longer translated strings are layout-tested at mobile widths.'
      ]
    }
  ],

  /* ---- Resources (sample library) ---- */
  resources: [
    { icon: '📘', cat: 'Farmer Guides', title: 'Getting started with Krishi Setu', desc: 'A plain-language walkthrough: profile, inventory, publishing and your first sale.', type: 'Guide' },
    { icon: '🌾', cat: 'Crop Information', title: 'Onion crop care & storage basics', desc: 'Harvest maturity, curing, storage conditions and moisture control for onions.', type: 'Guide' },
    { icon: '🍅', cat: 'Crop Information', title: 'Tomato: freshness windows in hot weather', desc: 'How temperature and humidity shorten shelf life, and what to do about it.', type: 'Guide' },
    { icon: '📊', cat: 'Market Resources', title: 'Reading mandi price reports', desc: 'How modal, min and max prices work, and what a 24-hour trend does and does not mean.', type: 'Guide' },
    { icon: '🏛️', cat: 'Government Schemes', title: 'Scheme application checklist', desc: 'Documents usually needed for income support, insurance and credit schemes.', type: 'Checklist' },
    { icon: '🚚', cat: 'Logistics', title: 'Choosing a transport option', desc: 'Compare speed, capacity and spoilage risk across vehicle types for produce.', type: 'Guide' },
    { icon: '💳', cat: 'Finance', title: 'Understanding net realisation', desc: 'Gross price minus transport, cess and fees — what you actually keep.', type: 'Guide' },
    { icon: '🏦', cat: 'Finance', title: 'Warehouse financing basics', desc: 'How stored produce can support working-capital finance at a loan-to-value ratio.', type: 'Guide' },
    { icon: '🎓', cat: 'Training', title: 'Interactive platform tutorial', desc: 'A guided, role-specific walkthrough of the Krishi Setu application.', type: 'Interactive' },
    { icon: '❓', cat: 'Training', title: 'Frequently asked questions', desc: 'Common questions about roles, lots, offers, payments and support.', type: 'FAQ' },
    { icon: '🧊', cat: 'Logistics', title: 'Cold chain & reefer basics', desc: 'When refrigerated transport matters, and how to estimate its cost.', type: 'Guide' },
    { icon: '🤝', cat: 'Farmer Guides', title: 'Working with FPOs', desc: 'How farmer producer organisations pool produce and negotiate with buyers.', type: 'Guide' }
  ],

  /* ---- Support FAQs ---- */
  faqs: [
    { q: 'Is Krishi Setu a government website?', a: 'No. Krishi Setu is a demonstration platform. It links to official government scheme portals for reference, but it is not a government body and claims no official endorsement.' },
    { q: 'How do I switch between farmer and buyer workspaces?', a: 'After login, use the role persona switcher (Farmer / Buyer / Supervisor) in the top bar. Your role determines which workspace and tools you see.' },
    { q: 'How are buyer offers settled?', a: 'In the demonstration flow, accepted offers create an order and settlement runs through an escrow rail on delivery approval. Live payments require a production backend.' },
    { q: 'What do trust and credit points mean?', a: 'Two-way ratings between farmers and buyers build a trust score. Higher tiers receive visibility and fee benefits — see the Trust & Credit page in the application.' },
    { q: 'Are mandi prices real?', a: 'When a live government feed is configured, prices come from official observations. Until then the app shows clearly labelled offline/reference rows. Never treat it as a substitute for an official quote.' },
    { q: 'How do I report a problem?', a: 'Use the Customer Care page in the application, or the contact form on this website. This demo helpline is not a real support line.' }
  ]
};
/* Expose on window so later scripts can read the same content layer */
window.KS = KS;
