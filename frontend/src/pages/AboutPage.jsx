import React, { useRef, useEffect } from 'react';
import { Helmet } from 'react-helmet-async';
import { Link } from 'react-router-dom';
import { useGSAP } from '@gsap/react';
import gsap from 'gsap';
import { ScrollTrigger } from '@/lib/gsap';
import {
  Target,
  Eye,
  ShieldCheck,
  Zap,
  Lock,
  Sparkles,
  Database,
  FileText,
  AlertTriangle,
  ArrowRight,
  TrendingUp,
  Cpu,
  Layers,
  HeartHandshake,
  CheckCircle2,
  Server,
  Globe2,
} from 'lucide-react';
import { Container } from '@/components/ui/Container';
import { SectionHeading } from '@/components/ui/SectionHeading';
import { GradientText } from '@/components/ui/GradientText';
import { GlassCard } from '@/components/ui/GlassCard';
import { Badge } from '@/components/ui/Badge';
import { Button } from '@/components/ui/Button';
import AboutStoryTimeline from '@/components/sections/AboutStoryTimeline';
import FinalCtaBanner from '@/components/sections/FinalCtaBanner';
import { siteConfig } from '@/lib/site';

// 6 Core Company Values
const companyValues = [
  {
    icon: Target,
    title: 'Retail-First Access',
    description:
      'Institutional investors spend lakhs on high-end terminals. We believe retail investors deserve the same fast data, completely free of subscription fees and paywalls.',
  },
  {
    icon: Lock,
    title: 'Zero-Storage Privacy',
    description:
      'We never store, log, or sell your PAN or financial credentials. Allotment checks query registrars directly from your device using encrypted, isolated memory.',
  },
  {
    icon: FileText,
    title: 'Verifiable Prospectus Truth',
    description:
      'No unverified hype or speculative tips. SpotAI grounds its analysis strictly in official SEBI DRHP and RHP documents with direct paragraph references.',
  },
  {
    icon: Zap,
    title: 'Sub-Second Speed',
    description:
      'Financial decisions require velocity. Our event-driven Node.js aggregation delivers live GMP and market shifts without latency bottlenecks or server crashes.',
  },
  {
    icon: Eye,
    title: 'Ad-Free, Zero Noise',
    description:
      'We do not bombard users with banner ads, predatory credit card spam, or casino promotions. Clean, focused intelligence is our only product.',
  },
  {
    icon: HeartHandshake,
    title: 'Educated Autonomy',
    description:
      'We empower you with facts, subscription ratios, and historical listing metrics so you make your own informed investment decisions with total clarity.',
  },
];

// Data Transparency Breakdown
const dataSources = [
  {
    icon: TrendingUp,
    title: 'Indian Stock Equities & Indices',
    badge: 'NSE & BSE Feeds',
    summary:
      'Live and delayed market breadth, NIFTY 50, SENSEX, sectoral movements, and stock quote changes are aggregated through authorized market data gateways and exchange circulars.',
    details: 'Covers price performance, volume analysis, 52-week extremes, and market mood index.',
  },
  {
    icon: ShieldCheck,
    title: 'IPO Allotment Verification',
    badge: 'Official SEBI Registrars',
    summary:
      'When an IPO allotment is finalized, queries are made directly from your device to the designated registrar (Link Intime India, KFin Technologies, Bigshare Services, Skyline, etc.).',
    details: 'PAN data stays strictly in local device memory. We do not maintain any central database of PANs.',
  },
  {
    icon: Layers,
    title: 'Grey Market Premium (GMP)',
    badge: 'Market Dealer Desk Survey',
    summary:
      'GMP data is aggregated from multiple active merchant banking dealers, verified broker networks, and primary market desks across Mumbai, Gujarat, and Delhi trading hubs.',
    details: 'GMP reflects unofficial sentiment prior to listing and is displayed strictly for informational research.',
  },
  {
    icon: Cpu,
    title: 'SpotAI Document Intelligence',
    badge: 'SEBI DRHP & Disclosures',
    summary:
      'SpotAI reads, vectors, and analyzes public regulatory filings submitted to SEBI and stock exchanges. It deciphers complex balance sheets, debt obligations, and litigation history.',
    details: 'AI responses are fact-checked against prospectus text and should be verified with full DRHP filings.',
  },
  {
    icon: Globe2,
    title: 'Global Macroeconomic Benchmarks',
    badge: 'International Indices',
    summary:
      'Global market indicators (S&P 500, NASDAQ, Dow Jones, FTSE, Nikkei, Hang Seng) are fetched to offer macro context on opening sentiment before domestic Indian trading bells ring.',
    details: 'Helps investors evaluate overnight cross-border cues and currency headwinds.',
  },
];

export function AboutPage() {
  const containerRef = useRef(null);
  const valuesRef = useRef(null);
  const sourcesRef = useRef(null);

  // Recalculate ScrollTrigger on load
  useEffect(() => {
    const timer = setTimeout(() => {
      ScrollTrigger.refresh();
    }, 150);
    return () => clearTimeout(timer);
  }, []);

  useGSAP(
    () => {
      // Ensure all cards are cleanly rendered and fully visible with no stuck opacity
      gsap.set(['.mission-vision-card', '.value-card-item', '.data-source-item'], {
        clearProps: 'all',
      });
    },
    { scope: containerRef }
  );

  // Schema.org BreadcrumbList JSON-LD
  const breadcrumbJsonLd = {
    '@context': 'https://schema.org',
    '@type': 'BreadcrumbList',
    itemListElement: [
      {
        '@type': 'ListItem',
        position: 1,
        name: 'Home',
        item: siteConfig.url,
      },
      {
        '@type': 'ListItem',
        position: 2,
        name: 'About',
        item: `${siteConfig.url}/about`,
      },
    ],
  };

  return (
    <div ref={containerRef} className="space-y-8 sm:space-y-12 pb-12 overflow-hidden">
      {/* SEO Helmet */}
      <Helmet>
        <title>About Us - TheSpotMarket | Indian IPO & Market Intelligence</title>
        <meta
          name="description"
          content="Learn about TheSpotMarket's mission to empower Indian retail investors with real-time IPO tracking, live GMP, device-isolated PAN privacy, and SpotAI."
        />
        <meta property="og:title" content="About TheSpotMarket - Democratizing Market Intelligence" />
        <meta
          property="og:description"
          content="Our story, core values, data transparency disclosures, and mission to eliminate noise for Indian stock and IPO investors."
        />
        <meta property="og:url" content={`${siteConfig.url}/about`} />
        <meta property="og:type" content="website" />
        <link rel="canonical" href={`${siteConfig.url}/about`} />
        <script type="application/ld+json">{JSON.stringify(breadcrumbJsonLd)}</script>
      </Helmet>

      {/* 1. Hero Section */}
      <section className="relative pt-10 sm:pt-14 pb-4 bg-radial-glow">
        <Container>
          <div className="max-w-4xl mx-auto text-center space-y-6">
            <div className="inline-flex">
              <Badge variant="primary" size="md">
                About TheSpotMarket
              </Badge>
            </div>

            <h1 className="text-4xl sm:text-5xl lg:text-6xl font-extrabold text-white tracking-tight leading-[1.15]">
              Democratizing Market Intelligence for{' '}
              <GradientText>Every Indian Investor</GradientText>
            </h1>

            <p className="text-lg sm:text-xl text-muted max-w-3xl mx-auto leading-relaxed">
              We started TheSpotMarket with one conviction: institutional-grade IPO research, live
              GMP sentiment, and balance sheet insights should belong in the hands of everyday
              investors — fast, completely ad-free, and with zero compromises on privacy.
            </p>

            {/* Quick Metrics Bar */}
            <div className="pt-8 grid grid-cols-2 sm:grid-cols-4 gap-4 max-w-3xl mx-auto">
              <div className="p-4 rounded-xl bg-surface/70 border border-white/5 text-center">
                <div className="text-2xl sm:text-3xl font-extrabold font-mono text-accent">100%</div>
                <div className="text-xs text-subtle mt-1 font-medium">Free Access</div>
              </div>
              <div className="p-4 rounded-xl bg-surface/70 border border-white/5 text-center">
                <div className="text-2xl sm:text-3xl font-extrabold font-mono text-white">0 Byte</div>
                <div className="text-xs text-subtle mt-1 font-medium">PAN Data Logged</div>
              </div>
              <div className="p-4 rounded-xl bg-surface/70 border border-white/5 text-center">
                <div className="text-2xl sm:text-3xl font-extrabold font-mono text-accent">&lt;1 Sec</div>
                <div className="text-xs text-subtle mt-1 font-medium">Update Latency</div>
              </div>
              <div className="p-4 rounded-xl bg-surface/70 border border-white/5 text-center">
                <div className="text-2xl sm:text-3xl font-extrabold font-mono text-white">400+ pgs</div>
                <div className="text-xs text-subtle mt-1 font-medium">DRHP Parsed in Secs</div>
              </div>
            </div>
          </div>
        </Container>
      </section>

      {/* 2. Mission & Vision */}
      <section className="relative">
        <Container>
          <div className="mission-vision-grid grid grid-cols-1 md:grid-cols-2 gap-8 max-w-5xl mx-auto">
            {/* Mission */}
            <GlassCard hover className="mission-vision-card p-8 sm:p-10 space-y-5 border-primary/30 relative overflow-hidden group">
              <div className="absolute top-0 right-0 w-36 h-36 bg-primary/10 rounded-full blur-3xl pointer-events-none group-hover:bg-primary/20 transition-all duration-500" />
              <div className="w-14 h-14 rounded-2xl bg-primary/20 border border-primary/40 flex items-center justify-center text-accent">
                <Target className="w-7 h-7" />
              </div>
              <div className="space-y-2">
                <span className="text-xs font-mono uppercase tracking-widest text-accent font-semibold">
                  Our Mission
                </span>
                <h2 className="text-2xl sm:text-3xl font-bold text-white">
                  Leveling the Primary & Secondary Market Playing Field
                </h2>
              </div>
              <p className="text-muted text-base leading-relaxed">
                To equip India’s 15+ crore retail investors with accurate, real-time IPO timelines,
                unfiltered subscription figures, verifiable Grey Market Premiums, and AI-powered DRHP
                clarity — without requiring expensive subscriptions or technical expertise.
              </p>
              <div className="pt-2 flex items-center gap-2 text-sm text-accent font-medium">
                <CheckCircle2 className="w-4 h-4" />
                <span>Empowering independent financial conviction</span>
              </div>
            </GlassCard>

            {/* Vision */}
            <GlassCard hover className="mission-vision-card p-8 sm:p-10 space-y-5 border-accent/30 relative overflow-hidden group">
              <div className="absolute top-0 right-0 w-36 h-36 bg-accent/10 rounded-full blur-3xl pointer-events-none group-hover:bg-accent/20 transition-all duration-500" />
              <div className="w-14 h-14 rounded-2xl bg-accent/20 border border-accent/40 flex items-center justify-center text-accent">
                <Eye className="w-7 h-7" />
              </div>
              <div className="space-y-2">
                <span className="text-xs font-mono uppercase tracking-widest text-accent font-semibold">
                  Our Vision
                </span>
                <h2 className="text-2xl sm:text-3xl font-bold text-white">
                  A World Without Telegram Noise & Hidden Traps
                </h2>
              </div>
              <p className="text-muted text-base leading-relaxed">
                To build India's definitive market intelligence companion: where unverified tips are
                replaced by verifiable disclosures, clunky government registrar searches are
                instantaneous, and privacy is treated as a fundamental constitutional right.
              </p>
              <div className="pt-2 flex items-center gap-2 text-sm text-accent font-medium">
                <CheckCircle2 className="w-4 h-4" />
                <span>Zero telemetry, maximum transparency</span>
              </div>
            </GlassCard>
          </div>
        </Container>
      </section>

      {/* 3. Our Story: Vertical Timeline (Line Draws on Scroll via GSAP ScrollTrigger) */}
      <section className="relative">
        <Container>
          <SectionHeading
            badge="Our Journey"
            title="The Story Behind TheSpotMarket"
            subtitle="From frustration with unverified IPO rumors to building India's fastest, privacy-first market intelligence platform."
          />

          <AboutStoryTimeline />
        </Container>
      </section>

      {/* 4. Values Grid */}
      <section className="relative bg-surface/30 py-8 sm:py-10 border-y border-white/5">
        <Container>
          <SectionHeading
            badge="Guiding Principles"
            title="What We Stand For"
            subtitle="Six non-negotiable principles guiding every feature, algorithm, and interface decision we make."
          />

          <div
            ref={valuesRef}
            className="mt-8 sm:mt-10 grid grid-cols-1 md:grid-cols-2 lg:grid-cols-3 gap-6 max-w-6xl mx-auto"
          >
            {companyValues.map((val, idx) => {
              const IconComp = val.icon;
              return (
                <GlassCard
                  key={idx}
                  hover
                  className="value-card-item p-7 space-y-4 border-white/5 hover:border-primary/40 flex flex-col justify-between"
                >
                  <div className="space-y-3">
                    <div className="w-12 h-12 rounded-xl bg-primary/15 border border-primary/30 flex items-center justify-center text-accent">
                      <IconComp className="w-6 h-6" />
                    </div>
                    <h3 className="text-xl font-bold text-white">{val.title}</h3>
                    <p className="text-sm text-muted leading-relaxed">{val.description}</p>
                  </div>
                </GlassCard>
              );
            })}
          </div>
        </Container>
      </section>

      {/* 5. Data Sources & Transparency */}
      <section className="relative">
        <Container>
          <SectionHeading
            badge="Transparency First"
            title="Where Our Data Comes From"
            subtitle="We believe in full transparency. Here is an honest, plain-English breakdown of every data source powering TheSpotMarket."
          />

          <div
            ref={sourcesRef}
            className="mt-8 sm:mt-10 space-y-4 max-w-4xl mx-auto"
          >
            {dataSources.map((source, sIdx) => {
              const IconComp = source.icon;
              return (
                <GlassCard
                  key={sIdx}
                  hover
                  className="data-source-item p-6 sm:p-7 border-white/10 hover:border-accent/40"
                >
                  <div className="flex flex-col sm:flex-row sm:items-start gap-4">
                    <div className="w-12 h-12 rounded-xl bg-surface-2 border border-white/10 flex items-center justify-center text-accent shrink-0">
                      <IconComp className="w-6 h-6" />
                    </div>
                    <div className="space-y-2 flex-1">
                      <div className="flex flex-wrap items-center gap-2.5">
                        <h3 className="text-lg font-bold text-white">{source.title}</h3>
                        <Badge variant="outline" size="sm" className="font-mono text-xs">
                          {source.badge}
                        </Badge>
                      </div>
                      <p className="text-sm text-muted leading-relaxed">{source.summary}</p>
                      <p className="text-xs font-mono text-subtle pt-1">{source.details}</p>
                    </div>
                  </div>
                </GlassCard>
              );
            })}

            {/* SEBI Compliance Notice Box */}
            <div className="mt-8 p-6 rounded-2xl bg-warning/10 border border-warning/30 flex items-start gap-4 text-warning-muted">
              <AlertTriangle className="w-6 h-6 text-warning shrink-0 mt-0.5" />
              <div className="space-y-1.5 text-xs sm:text-sm">
                <span className="font-bold text-white block">SEBI Regulatory Notice & Disclaimer</span>
                <p className="text-muted leading-relaxed">
                  TheSpotMarket is a financial data aggregator, educational portal, and analytical
                  companion. We are <strong className="text-white">NOT</strong> a SEBI-registered
                  Investment Advisor (RIA) or Research Analyst (RA). We do not solicit funds, execute
                  brokerage orders, or guarantee IPO allotment and listing returns. Always conduct
                  independent due diligence or consult a qualified SEBI-registered professional
                  before investing in Indian securities.
                </p>
              </div>
            </div>
          </div>
        </Container>
      </section>

      {/* 6. Final Call to Action Banner */}
      <FinalCtaBanner />
    </div>
  );
}

export default AboutPage;
