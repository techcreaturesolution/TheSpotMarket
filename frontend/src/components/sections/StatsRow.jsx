import React, { useRef } from 'react';
import { Calendar, Globe2, Sparkles, CheckCircle2 } from 'lucide-react';
import { Container } from '@/components/ui/Container';
import { GlassCard } from '@/components/ui/GlassCard';
import { useCounter } from '@/hooks/useCounter';

/**
 * Honest Stats Row component:
 * - "IPO Updates Daily"
 * - "Indian + Global Markets"
 * - "AI Powered"
 * - "Free to Use"
 * - Strict adherence to honest labels (NO fake user counts).
 * - Animated smoothly on scroll with useCounter hook.
 */
export function StatsRow() {
  const stat1Ref = useRef(null);
  const stat2Ref = useRef(null);
  const stat3Ref = useRef(null);
  const stat4Ref = useRef(null);

  // Counter 1: 365 Days / Continuous IPO tracking
  useCounter(stat1Ref, 365, {
    duration: 1.8,
    suffix: ' Days/Yr',
    decimals: 0,
  });

  // Counter 2: 50+ Key Benchmarks & Indices
  useCounter(stat2Ref, 50, {
    duration: 1.6,
    prefix: '+',
    decimals: 0,
  });

  // Counter 3: 100% SpotAI Analysis
  useCounter(stat3Ref, 100, {
    duration: 1.8,
    suffix: '%',
    decimals: 0,
  });

  // Counter 4: ₹0 Cost
  useCounter(stat4Ref, 0, {
    duration: 1.0,
    prefix: '₹',
    decimals: 0,
  });

  const stats = [
    {
      ref: stat1Ref,
      fallbackText: '365 Days/Yr',
      title: 'IPO Updates Daily',
      desc: 'Real-time subscription & GMP quotes throughout active bidding windows.',
      icon: <Calendar className="h-5 w-5 text-accent" />,
    },
    {
      ref: stat2Ref,
      fallbackText: '+50',
      title: 'Indian + Global Markets',
      desc: 'Coverage spanning NSE, BSE, US benchmarks, commodities & currency.',
      icon: <Globe2 className="h-5 w-5 text-accent" />,
    },
    {
      ref: stat3Ref,
      fallbackText: '100%',
      title: 'AI Powered (SpotAI)',
      desc: 'Machine synthesis of financial filings, RHP disclosures & market sentiment.',
      icon: <Sparkles className="h-5 w-5 text-accent" />,
    },
    {
      ref: stat4Ref,
      fallbackText: '₹0',
      title: 'Free to Use',
      desc: 'No paywalls, subscription tiers, or credit card requirements for retail investors.',
      icon: <CheckCircle2 className="h-5 w-5 text-bull" />,
    },
  ];

  return (
    <section aria-label="Key Product Statistics" className="py-4 sm:py-6">
      <Container>
        <div className="grid grid-cols-1 sm:grid-cols-2 lg:grid-cols-4 gap-5">
          {stats.map((stat, i) => (
            <GlassCard
              key={i}
              hover
              padding="p-6"
              className="relative space-y-3 border-white/10 hover:border-primary/40 bg-card-gradient"
            >
              <div className="flex items-center justify-between">
                <div className="h-10 w-10 rounded-xl bg-primary/20 border border-primary/30 flex items-center justify-center">
                  {stat.icon}
                </div>
                <span className="text-[10px] font-mono uppercase text-subtle font-semibold">
                  Verified
                </span>
              </div>

              <div>
                <div
                  ref={stat.ref}
                  className="text-2xl sm:text-3xl font-extrabold text-white font-mono tracking-tight"
                >
                  {stat.fallbackText}
                </div>
                <h3 className="text-sm font-bold text-white mt-1 leading-snug">
                  {stat.title}
                </h3>
              </div>

              <p className="text-xs text-muted leading-relaxed">
                {stat.desc}
              </p>
            </GlassCard>
          ))}
        </div>
      </Container>
    </section>
  );
}

export default StatsRow;
