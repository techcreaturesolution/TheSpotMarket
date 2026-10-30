import React, { useEffect } from 'react';
import { Helmet } from 'react-helmet-async';
import {
  HeroSection,
  MarketTicker,
  StatsRow,
  FeaturesGrid,
  HowItWorksSection,
  WhySpotMarketSection,
  ScreenshotsSection,
  SpotAiSection,
  FinalCtaBanner,
} from '@/components/sections';
import { ScrollTrigger } from '@/lib/gsap';
import { siteConfig } from '@/lib/site';

export function HomePage() {
  // Ensure ScrollTrigger recalculated after layout mounts & fonts ready
  useEffect(() => {
    const timer = setTimeout(() => {
      ScrollTrigger.refresh();
    }, 150);

    return () => clearTimeout(timer);
  }, []);

  // Organization + SoftwareApplication JSON-LD Structured Data
  const homeJsonLd = {
    '@context': 'https://schema.org',
    '@graph': [
      {
        '@type': 'Organization',
        '@id': 'https://thespotmarket.com/#organization',
        name: 'TheSpotMarket',
        url: 'https://thespotmarket.com',
        logo: 'https://thespotmarket.com/images/app_icon.png',
        description:
          'Next-generation market intelligence platform for Indian IPOs, stocks, live Grey Market Premium (GMP), and SpotAI filings analysis.',
        sameAs: [
          siteConfig.socials.twitter,
          siteConfig.socials.linkedin,
          siteConfig.socials.instagram,
        ],
      },
      {
        '@type': 'SoftwareApplication',
        '@id': 'https://thespotmarket.com/#software',
        name: 'TheSpotMarket',
        operatingSystem: 'Android, iOS',
        applicationCategory: 'FinanceApplication',
        offers: {
          '@type': 'Offer',
          price: '0',
          priceCurrency: 'INR',
        },
        description:
          'Track live Mainline and SME IPO subscriptions, real-time Grey Market Premiums, verify allotment status by PAN, and ask SpotAI for DRHP prospectus breakdowns.',
        downloadUrl: siteConfig.links.playStore,
        installUrl: siteConfig.links.playStore,
      },
    ],
  };

  return (
    <div className="pb-12 sm:pb-16 overflow-hidden">
      {/* SEO Meta + Schema.org Structured Data */}
      <Helmet>
        <title>TheSpotMarket - Live IPO GMP, Indian & Global Markets, SpotAI Intelligence</title>
        <meta
          name="description"
          content="Track real-time Indian Mainline and SME IPOs, live Grey Market Premiums (GMP), check allotment status by PAN, and analyze SEBI filings with SpotAI."
        />
        <meta property="og:title" content="TheSpotMarket - Every IPO. Every Market. One Smart App." />
        <meta
          property="og:description"
          content="Live GMP alerts, SME listings, one-tap registrar PAN allotment, and conversational prospectus intelligence."
        />
        <meta property="og:type" content="website" />
        <script type="application/ld+json">{JSON.stringify(homeJsonLd)}</script>
      </Helmet>

      {/* 1. First Screen Fold: Hero Section + Market Ticker docked at bottom */}
      <div className="relative flex flex-col justify-between min-h-[calc(100dvh-4.5rem)]">
        <HeroSection />
        <MarketTicker />
      </div>

      {/* 2. Remaining Sections with Standard Vertical Rhythm */}
      <div className="space-y-6 sm:space-y-10 mt-6 sm:mt-10">
        {/* 3. Honest Key Product Stats (GSAP useCounter on ScrollTrigger) */}
        <StatsRow />

        {/* 4. 8-Card Features Grid (id="features", GSAP quickTo Lift & Stagger Reveal) */}
        <FeaturesGrid />

        {/* 6. How It Works Section (id="how-it-works", 3 Steps + Scrubbed Connecting SVG Line) */}
        <HowItWorksSection />

        {/* 7. Why TheSpotMarket (4 Core Benefits: All-in-One, Fast, AI-Assisted, Privacy-Friendly) */}
        <WhySpotMarketSection />

        {/* 8. Mobile Screenshots Scroller (5 Phone Frames + GSAP Draggable Support & CSS Fallback) */}
        <ScreenshotsSection />

        {/* 9. SpotAI Split Section (id="spotai", Liquid-Glass Fake Chat UI with Typewriter Animation) */}
        <SpotAiSection />

        {/* 10. Final CTA Banner (Emerald Gradient Card with Breathing Glow & Download CTAs) */}
        <FinalCtaBanner />
      </div>
    </div>
  );
}

export default HomePage;
