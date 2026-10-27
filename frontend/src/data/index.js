// Static sample data for market ticker demonstration (not live exchange feeds)
// Used in the seamless GSAP marquee ticker strip on the Home page
export const sampleTickerData = [
  { symbol: 'NIFTY 50', price: '24,860.50', change: '+142.30', percent: '+0.58%', isBull: true },
  { symbol: 'SENSEX', price: '81,420.10', change: '+460.20', percent: '+0.57%', isBull: true },
  { symbol: 'BANKNIFTY', price: '51,780.40', change: '-110.20', percent: '-0.21%', isBull: false },
  { symbol: 'S&P 500', price: '5,815.20', change: '+24.10', percent: '+0.42%', isBull: true },
  { symbol: 'NASDAQ', price: '18,518.60', change: '+112.50', percent: '+0.61%', isBull: true },
  { symbol: 'GOLD (MCX)', price: '₹78,450', change: '-180.00', percent: '-0.23%', isBull: false },
];

// 8 Core Features for Home Page Features Grid
export const homeFeatures = [
  {
    id: 'ipo-tracker',
    title: 'IPO Tracker',
    badge: 'Mainline & SME',
    description:
      'Track live Open, Upcoming, Closed, and Listed IPOs with real-time GMP, expected listing gains, and bidding timers.',
    iconName: 'TrendingUp',
    accentColor: '#10B981',
  },
  {
    id: 'indian-markets',
    title: 'Indian Share Market',
    badge: 'NSE & BSE',
    description:
      'Live market breadth snapshots, top gainers and losers, 52-week highs, and real-time market sentiment mood index.',
    iconName: 'Activity',
    accentColor: '#34D399',
  },
  {
    id: 'intl-markets',
    title: 'International Markets',
    badge: 'US & Global',
    description:
      'Global macroeconomic cues covering S&P 500, NASDAQ, FTSE, and Asian indices with intelligent sentiment filters.',
    iconName: 'Globe2',
    accentColor: '#10B981',
  },
  {
    id: 'market-news',
    title: 'Market News',
    badge: 'Live Feeds',
    description:
      'Bite-sized, curated corporate disclosures, earnings reports, and regulatory updates minus unnecessary financial noise.',
    iconName: 'Newspaper',
    accentColor: '#34D399',
  },
  {
    id: 'allotment-status',
    title: 'IPO Allotment Status',
    badge: 'Instant PAN Check',
    description:
      'Direct one-tap allotment check by PAN via official registrar portals (Link Intime, KFintech, Bigshare, Skyline).',
    iconName: 'FileCheck2',
    accentColor: '#10B981',
  },
  {
    id: 'trade-suggestions',
    title: 'Buy/Sell/Hold Suggestions',
    badge: 'Actionable Setups',
    description:
      'Structured technical and fundamental trade views with clear target zones, trailing stop-losses, and risk-reward ratios.',
    iconName: 'Target',
    accentColor: '#34D399',
  },
  {
    id: 'spot-ai',
    title: 'SpotAI Assistant',
    badge: 'AI Copilot',
    description:
      'Ask any question about RHP prospectus filings, debt ratios, peer comparisons, and listing valuations in plain language.',
    iconName: 'Bot',
    accentColor: '#10B981',
  },
  {
    id: 'secure-auth',
    title: 'Secure Authentication',
    badge: 'Privacy First',
    description:
      'Quick email or mobile OTP login. We respect investor privacy with zero unsolicited promotional spam or broker credentials sharing.',
    iconName: 'ShieldCheck',
    accentColor: '#34D399',
  },
];

// 3 How It Works Steps
export const howItWorksSteps = [
  {
    step: '01',
    title: 'Download the App',
    subtitle: 'Free on Android & iOS',
    description:
      'Get TheSpotMarket mobile app and log in instantly with email or mobile OTP. No mandatory broker linking required.',
    iconName: 'Smartphone',
    highlight: 'Instant Setup in 30s',
  },
  {
    step: '02',
    title: 'Explore IPOs & Markets',
    subtitle: 'Track GMP & Subscriptions',
    description:
      'Browse live Mainboard and SME IPOs, monitor real-time Grey Market Premiums, and review institutional QIB/NII bidding momentum.',
    iconName: 'Layers',
    highlight: 'Live Subscription Feeds',
  },
  {
    step: '03',
    title: 'Ask SpotAI & Decide',
    subtitle: 'Smart Prospectus Intelligence',
    description:
      'Query SpotAI for instant risk assessments, verify official allotment status by PAN, and execute informed bidding decisions.',
    iconName: 'Sparkles',
    highlight: 'Data-Backed Decisions',
  },
];

// 3 Sample Showcase IPO Cards (clearly labeled Sample)
export const sampleShowcaseIpos = [
  {
    id: 'sample-ipo-1',
    name: 'Premier Energies Ltd',
    issuer: 'Solar Cells & Module Manufacturing',
    type: 'Mainboard',
    isSme: false,
    status: 'Open',
    priceBand: '₹427 - ₹450',
    lotSize: '33 Shares',
    minInvestment: '₹14,850',
    dates: 'Aug 27 - Aug 29',
    subscription: '74.3x',
    subscriptionProgress: 74,
    gmp: '+₹390',
    gmpPercent: '+86.7%',
    sentiment: 'Strong Bull',
    isSample: true,
  },
  {
    id: 'sample-ipo-2',
    name: 'Ecos Mobility Limited',
    issuer: 'Chauffeur Driven Car Rental & Mobility',
    type: 'Mainboard',
    isSme: false,
    status: 'Upcoming',
    priceBand: '₹318 - ₹334',
    lotSize: '44 Shares',
    minInvestment: '₹14,696',
    dates: 'Aug 28 - Aug 30',
    subscription: 'Opens Soon',
    subscriptionProgress: 28,
    gmp: '+₹160',
    gmpPercent: '+47.9%',
    sentiment: 'Bullish',
    isSample: true,
  },
  {
    id: 'sample-ipo-3',
    name: 'Resourceful Auto Ltd',
    issuer: 'Automotive Dealership & Services',
    type: 'SME',
    isSme: true,
    status: 'Closed',
    priceBand: '₹117',
    lotSize: '1,200 Shares',
    minInvestment: '₹1,40,400',
    dates: 'Aug 22 - Aug 26',
    subscription: '418.8x',
    subscriptionProgress: 100,
    gmp: '+₹105',
    gmpPercent: '+89.7%',
    sentiment: 'Oversubscribed',
    isSample: true,
  },
];

// Backward compatibility export
export const sampleIpos = sampleShowcaseIpos;

// 4 Core "Why TheSpotMarket" Benefits
export const whySpotMarketBenefits = [
  {
    id: 'all-in-one',
    iconName: 'Layers',
    title: 'All-in-One Platform',
    badge: 'Unified',
    description:
      'Stop switching between 5 different portals. Mainline IPOs, SME issues, live exchange feeds, global indices, and corporate disclosures live together under one roof.',
    highlight: '5 Tools in 1 Clean App',
  },
  {
    id: 'ultra-fast',
    iconName: 'Zap',
    title: 'Ultra-Fast Real-Time Feeds',
    badge: 'Sub-Second',
    description:
      'Live Grey Market Premiums (GMP) and subscription tallies update with high-frequency caching, ensuring you never miss a bidding cut-off.',
    highlight: 'Instant GMP & Bidding Alerts',
  },
  {
    id: 'ai-assisted',
    iconName: 'Bot',
    title: 'AI-Assisted (SpotAI)',
    badge: 'Next-Gen',
    description:
      'SpotAI distills complex 400-page DRHP and RHP regulatory filings into crisp risk factors, debt ratios, and promoter peer multiples within seconds.',
    highlight: 'DRHP Synthesis in Seconds',
  },
  {
    id: 'privacy-friendly',
    iconName: 'ShieldCheck',
    title: 'Privacy-Friendly & Safe',
    badge: 'Hardware Encrypted',
    description:
      'Your PAN data stays strictly on your physical phone in encrypted hardware storage. We never store PANs on external servers or ask for broker login credentials.',
    highlight: 'Zero Server PAN Storage',
  },
];

// 5 Mobile App Screenshots
export const appScreenshots = [
  {
    id: 'home',
    title: 'Home & Markets',
    subtitle: 'Real-Time Pulse',
    description: 'Live indices, top market movers, and curated IPO spotlight cards.',
    badge: 'Dashboard',
    image: '/images/screens/screen_home.png',
  },
  {
    id: 'ipos',
    title: 'IPO Tracker',
    subtitle: 'Mainline & SME',
    description: 'Live GMP trends, expected listing gains, and bidding timers.',
    badge: 'IPO Radar',
    image: '/images/screens/screen_ipos.png',
  },
  {
    id: 'market',
    title: 'Indian & Global',
    subtitle: 'NSE, BSE & Wall St',
    description: 'Real-time market breadth, heatmaps, and global macroeconomic cues.',
    badge: 'Market Breadth',
    image: '/images/screens/screen_market.png',
  },
  {
    id: 'allotment',
    title: 'Allotment Gateway',
    subtitle: 'One-Tap PAN Check',
    description: 'Instant queries via Link Intime, KFintech, and Bigshare portals.',
    badge: 'Fast Allotment',
    image: '/images/screens/screen_allotment.png',
  },
  {
    id: 'spotai',
    title: 'SpotAI Co-Pilot',
    subtitle: 'Prospectus Synthesis',
    description: 'Conversational risk assessments, balance sheet checks, and valuation multiples.',
    badge: 'AI Assistant',
    image: '/images/screens/screen_spotai.png',
  },
];

// 8 Comprehensive FAQ Items
export const homeFaqs = [
  {
    q: 'Is TheSpotMarket completely free to use?',
    a: 'Yes! All core features — including live IPO tracking, Grey Market Premiums (GMP), market breadth snapshots, allotment queries, and SpotAI prospectus summaries — are 100% free with no hidden paywalls or subscription fees.',
  },
  {
    q: 'Is TheSpotMarket registered with SEBI as an investment advisor?',
    a: 'No. TheSpotMarket is an educational financial technology and data intelligence app. We do not provide SEBI-registered investment advice, stock recommendations, or guaranteed listing returns. Always consult a qualified SEBI-registered financial advisor before investing.',
  },
  {
    q: 'How does the IPO allotment status check work?',
    a: 'Our app connects directly to official registrar portals (including Link Intime, KFintech, Bigshare, and Skyline Financial Services) through automated verification gateways. You simply enter your PAN on your device to fetch live allotment results.',
  },
  {
    q: 'Is my PAN stored on TheSpotMarket servers?',
    a: 'Never. We take user privacy very seriously. Your PAN profile is saved exclusively in local encrypted hardware storage on your physical device (using secure hardware keystore). It is never uploaded to our servers, sold, or shared with third parties.',
  },
  {
    q: 'What data sources power the live market numbers?',
    a: 'TheSpotMarket aggregates exchange feeds, corporate disclosures, and market snapshots from IndianAPI, Angel One SmartAPI, NSE/BSE circulars, and official registrar websites.',
  },
  {
    q: 'How accurate is the SpotAI assistant?',
    a: 'SpotAI is trained specifically on regulatory exchange filings, including Draft Red Herring Prospectuses (DRHP), Red Herring Prospectuses (RHP), and audited quarterly balance sheets. While it provides factual breakdowns with high precision, it is an informational tool and not a substitute for reviewing full regulatory filings.',
  },
  {
    q: 'Which platforms are supported?',
    a: 'TheSpotMarket is available natively for Android (Google Play Store) and iOS (Apple App Store). We also offer this fast web companion for desktop and mobile web browsers.',
  },
  {
    q: 'How can I get support or report a bug?',
    a: 'You can reach out to our engineering and support team directly via email at support@thespotmarket.com or visit our Contact page. We review all feedback, feature requests, and bug reports promptly.',
  },
];
