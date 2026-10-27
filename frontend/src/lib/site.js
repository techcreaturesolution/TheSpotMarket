export const siteConfig = {
  name: 'TheSpotMarket',
  legalName: 'TheSpotMarket Technologies Private Limited',
  tagline: 'IPO, Stocks & Market Intelligence',
  description:
    'Real-time Indian IPO subscriptions, Live GMP trends, NSE/BSE stock quotes, and SpotAI market intelligence app for intelligent investors.',
  domain: 'thespotmarket.com',
  url: 'https://thespotmarket.com',
  ogImage: '/images/app_icon.png',
  contactEmail: 'support@thespotmarket.com',
  pressEmail: 'contact@thespotmarket.com',
  phonePlaceholder: '+91 (0) 22 4000 8900',
  address: 'Mumbai, Maharashtra, India',

  links: {
    playStore: 'https://play.google.com/store/apps/details?id=com.techcreaturesolution.thespotmarket',
    appStore: 'https://apps.apple.com/app/thespotmarket/id000000000',
    twitter: 'https://twitter.com/thespotmarket',
    telegram: 'https://t.me/thespotmarket',
    linkedin: 'https://www.linkedin.com/company/thespotmarket',
    instagram: 'https://instagram.com/thespotmarket',
    youtube: 'https://youtube.com/@thespotmarket',
    github: 'https://github.com/techcreaturesolution/TheSpotMarket',
  },

  socials: {
    twitter: 'https://twitter.com/thespotmarket',
    linkedin: 'https://www.linkedin.com/company/thespotmarket',
    instagram: 'https://instagram.com/thespotmarket',
    github: 'https://github.com/techcreaturesolution/TheSpotMarket',
    telegram: 'https://t.me/thespotmarket',
    youtube: 'https://youtube.com/@thespotmarket',
  },

  nav: [
    { name: 'Home', path: '/', isHash: false },
    { name: 'Features', path: '/#features', hash: '#features', isHash: true },
    { name: 'How it Works', path: '/#how-it-works', hash: '#how-it-works', isHash: true },
    { name: 'About', path: '/about', isHash: false },
    { name: 'Contact', path: '/contact', isHash: false },
  ],

  footer: {
    product: [
      { name: 'Features', path: '/#features', hash: '#features', isHash: true },
      { name: 'How it Works', path: '/#how-it-works', hash: '#how-it-works', isHash: true },
      { name: 'SpotAI Analytics', path: '/#spotai', hash: '#spotai', isHash: true },
      { name: 'FAQ', path: '/contact#faq', hash: '#faq', isHash: false },
    ],
    company: [
      { name: 'About Us', path: '/about' },
      { name: 'Contact Us', path: '/contact' },
    ],
    legal: [
      { name: 'Privacy Policy', path: '/privacy-policy' },
      { name: 'Terms of Service', path: '/terms' },
      { name: 'SEBI Disclaimer', path: '/disclaimer' },
      { name: 'Data Deletion', path: '/data-deletion' },
    ],
  },

  features: {
    liveGmp: 'Live Grey Market Premium updates with real-time sentiment',
    ipoSubscription: 'Real-time retail, QIB, and HNI subscription tracking',
    spotAi: 'SpotAI conversational queries on Indian financial filings and stocks',
    smartWatchlist: 'Synced Indian stock watchlists with Angel One integration',
  },
};

export default siteConfig;
