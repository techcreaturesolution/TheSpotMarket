import React, { useRef } from 'react';
import { useGSAP } from '@gsap/react';
import { gsap, ScrollTrigger } from '@/lib/gsap';
import {
  Calendar,
  Layers,
  TrendingUp,
  Clock,
  CheckCircle2,
  AlertCircle,
  ExternalLink,
  Info,
} from 'lucide-react';
import { Container } from '@/components/ui/Container';
import { SectionHeading } from '@/components/ui/SectionHeading';
import { GradientText } from '@/components/ui/GradientText';
import { Badge } from '@/components/ui/Badge';
import { sampleShowcaseIpos } from '@/data';

function IpoCard({ ipo, index }) {
  const cardRef = useRef(null);
  const progressRef = useRef(null);

  useGSAP(
    () => {
      const prefersReduced = window.matchMedia('(prefers-reduced-motion: reduce)').matches;
      if (prefersReduced) return;

      if (progressRef.current) {
        gsap.fromTo(
          progressRef.current,
          { width: '0%' },
          {
            width: `${Math.min(ipo.subscriptionProgress || 50, 100)}%`,
            duration: 1.2,
            ease: 'power2.out',
            scrollTrigger: {
              trigger: cardRef.current,
              start: 'top 90%',
              toggleActions: 'play none none none',
              once: true,
            },
          }
        );
      }
    },
    { scope: cardRef }
  );

  const getStatusBadge = (status) => {
    switch (status) {
      case 'Open':
        return <Badge variant="bullish" size="sm" pulse>Open Now</Badge>;
      case 'Upcoming':
        return <Badge variant="primary" size="sm">Upcoming</Badge>;
      case 'Closed':
        return <Badge variant="neutral" size="sm">Closed</Badge>;
      default:
        return <Badge variant="primary" size="sm">{status}</Badge>;
    }
  };

  return (
    <div
      ref={cardRef}
      className="ipo-showcase-card group relative rounded-3xl bg-surface/90 backdrop-blur-xl border border-primary/25 hover:border-primary/50 p-6 sm:p-7 shadow-[0_15px_40px_-10px_rgba(0,0,0,0.85)] hover:shadow-[0_20px_50px_-10px_rgba(16,185,129,0.2)] transition-all duration-300 flex flex-col justify-between"
    >
      {/* Sample Watermark & Badges Header */}
      <div>
        <div className="flex items-center justify-between gap-2 mb-4">
          <div className="flex items-center gap-2">
            {getStatusBadge(ipo.status)}
            {ipo.isSme ? (
              <Badge variant="sme" size="sm">SME IPO</Badge>
            ) : (
              <Badge variant="neutral" size="sm">Mainboard</Badge>
            )}
          </div>
          <span className="text-[10px] uppercase font-bold tracking-wider text-accent/90 bg-accent/10 px-2.5 py-0.5 rounded-full border border-accent/25">
            Sample Card
          </span>
        </div>

        {/* Company Title & Industry */}
        <h3 className="text-xl font-bold text-white tracking-tight group-hover:text-accent transition-colors">
          {ipo.name}
        </h3>
        <p className="text-xs text-muted mt-1 mb-5 line-clamp-1">
          {ipo.issuer}
        </p>

        {/* Key Metrics Grid */}
        <div className="grid grid-cols-2 gap-3.5 p-3.5 rounded-2xl bg-surface-2/80 border border-white/5 mb-5 text-xs">
          <div>
            <span className="text-[10px] text-muted uppercase block">Price Band</span>
            <span className="font-bold text-white text-sm mt-0.5 block">{ipo.priceBand}</span>
          </div>
          <div>
            <span className="text-[10px] text-muted uppercase block">Lot Size</span>
            <span className="font-bold text-white text-sm mt-0.5 block">{ipo.lotSize}</span>
          </div>
          <div>
            <span className="text-[10px] text-muted uppercase block">Bidding Dates</span>
            <span className="font-semibold text-text-secondary mt-0.5 flex items-center gap-1">
              <Calendar className="w-3 h-3 text-primary inline" />
              {ipo.dates}
            </span>
          </div>
          <div>
            <span className="text-[10px] text-muted uppercase block">Min Investment</span>
            <span className="font-semibold text-text-secondary mt-0.5 block">{ipo.minInvestment}</span>
          </div>
        </div>

        {/* Subscription Progress Bar */}
        <div className="mb-5 space-y-1.5">
          <div className="flex items-center justify-between text-xs font-semibold">
            <span className="text-muted flex items-center gap-1">
              <Layers className="w-3.5 h-3.5 text-accent" /> Total Subscription
            </span>
            <span className="text-white font-bold">{ipo.subscription}</span>
          </div>
          <div className="w-full h-2 rounded-full bg-[#16291E] overflow-hidden">
            <div
              ref={progressRef}
              className="h-full rounded-full bg-gradient-to-r from-primary to-accent shadow-[0_0_10px_rgba(16,185,129,0.5)]"
              style={{ width: `${Math.min(ipo.subscriptionProgress || 50, 100)}%` }}
            />
          </div>
        </div>
      </div>

      {/* Card Footer: Expected GMP & Sentiment */}
      <div className="pt-4 border-t border-primary/15 flex items-center justify-between">
        <div>
          <span className="text-[10px] uppercase tracking-wide text-muted block">Expected GMP</span>
          <div className="text-base font-extrabold text-bull flex items-center gap-1 mt-0.5">
            {ipo.gmp} <span className="text-xs font-semibold text-accent">({ipo.gmpPercent})</span>
          </div>
        </div>
        <div className="px-3 py-1 rounded-xl bg-primary/20 border border-primary/30 text-xs font-bold text-accent">
          {ipo.sentiment}
        </div>
      </div>
    </div>
  );
}

export function IpoShowcaseSection() {
  const containerRef = useRef(null);

  useGSAP(
    () => {
      const prefersReduced = window.matchMedia('(prefers-reduced-motion: reduce)').matches;
      if (prefersReduced) return;

      // Animate cards into view with fromTo to avoid stuck opacity:0
      gsap.fromTo(
        '.ipo-showcase-card',
        { opacity: 0, y: 35 },
        {
          opacity: 1,
          y: 0,
          stagger: 0.1,
          duration: 0.7,
          ease: 'power2.out',
          scrollTrigger: {
            trigger: containerRef.current,
            start: 'top 85%',
            toggleActions: 'play none none none',
            once: true,
          },
          onComplete: () => {
            gsap.set('.ipo-showcase-card', { clearProps: 'opacity,transform' });
          },
        }
      );

      // Safety fallback: ensure cards are always visible even if ScrollTrigger offset is passed
      const safetyTimer = setTimeout(() => {
        gsap.to('.ipo-showcase-card', {
          opacity: 1,
          y: 0,
          duration: 0.3,
          overwrite: 'auto',
          clearProps: 'opacity,transform',
        });
      }, 700);

      return () => clearTimeout(safetyTimer);
    },
    { scope: containerRef }
  );

  return (
    <section id="ipos" ref={containerRef} className="py-6 sm:py-10 relative">
      <Container>
        <div className="flex flex-col sm:flex-row sm:items-end justify-between gap-4 mb-8 sm:mb-10">
          <div>
            <SectionHeading
              badge="IPO Pulse"
              title={
                <>
                  Live & Upcoming{' '}
                  <GradientText variant="emerald">IPO Showcase</GradientText>
                </>
              }
              subtitle="Get real-time updates on subscription status, GMP premiums, and bidding deadlines inside the app."
            />
          </div>
          <div className="text-left sm:text-right">
            <div className="inline-flex items-center gap-1.5 px-3 py-1 rounded-full bg-surface-2 border border-surface-border text-xs text-muted">
              <Info className="w-3.5 h-3.5 text-accent" />
              <span>Labelled Sample data for UI demonstration</span>
            </div>
          </div>
        </div>

        {/* 3 Showcase Cards Grid */}
        <div className="grid grid-cols-1 md:grid-cols-2 lg:grid-cols-3 gap-6">
          {(sampleShowcaseIpos || []).map((ipo, index) => (
            <IpoCard key={ipo.id} ipo={ipo} index={index} />
          ))}
        </div>
      </Container>
    </section>
  );
}

export default IpoShowcaseSection;
