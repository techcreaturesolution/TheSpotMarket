import React, { useRef } from 'react';
import { useGSAP } from '@gsap/react';
import gsap from 'gsap';
import { ScrollTrigger } from '@/lib/gsap';
import { Calendar, Flag, Sparkles, ShieldCheck, Zap, Rocket } from 'lucide-react';
import { Badge } from '@/components/ui/Badge';
import { GlassCard } from '@/components/ui/GlassCard';

const storyMilestones = [
  {
    period: 'Q1 2024',
    badge: 'The Spark',
    icon: Flag,
    title: 'Frustration with Telegram Rumors & Crashed Portals',
    description:
      'Indian retail participation was booming, but investors were stuck in chaotic WhatsApp groups, unreliable GMP rumors, and crashed registrar servers on allotment nights. We set out to build a clean, unified platform with verified facts.',
    highlights: ['Zero Telegram gossip', 'Clean UI vision', 'Direct registrar integration'],
  },
  {
    period: 'Q3 2024',
    badge: 'Core Engine',
    icon: Zap,
    title: 'High-Throughput Node.js & Flutter Client Built',
    description:
      'Engineered an event-driven Node.js backend capable of processing exchange feeds and registrar responses in sub-seconds. Developed the Flutter mobile app ensuring 120 FPS buttery-smooth performance without annoying ads.',
    highlights: ['Sub-second latency', 'Flutter 120 FPS client', '100% Ad-free commitment'],
  },
  {
    period: 'Q1 2025',
    badge: 'AI Breakthrough',
    icon: Sparkles,
    title: 'SpotAI: Conversational DRHP Intelligence Launched',
    description:
      'IPO Draft Red Herring Prospectuses (DRHP) exceed 400 pages of dense legal text. We trained SpotAI on official SEBI filings to provide retail investors with objective, paragraph-referenced summaries of risks, financials, and promoter history.',
    highlights: ['Official SEBI prospectus parsing', 'Cites exact DRHP pages', 'Plain English answers'],
  },
  {
    period: 'Q3 2025',
    badge: 'Privacy Standard',
    icon: ShieldCheck,
    title: 'Zero-Knowledge Client-Side PAN Architecture',
    description:
      'To safeguard investor privacy, we re-architected the allotment verification workflow. Allotment requests query registrars directly from the client device using encrypted tokens, guaranteeing PAN numbers are never stored on our servers.',
    highlights: ['Hardware keystore storage', 'Zero PAN data logged', 'Full compliance with DPDP Act'],
  },
  {
    period: '2026 & Beyond',
    badge: 'Scaling Up',
    icon: Rocket,
    title: 'Empowering Millions of Retail Investors Across India',
    description:
      'Expanding coverage across SME exchanges, global benchmark indices, and advanced sentiment analytics. Continuously democratizing institutional-grade market data for every Indian investor.',
    highlights: ['Mainline & SME tracking', 'Global market context', 'Community-driven roadmap'],
  },
];

export function AboutStoryTimeline() {
  const containerRef = useRef(null);
  const lineRef = useRef(null);

  useGSAP(
    () => {
      const prefersReduced = window.matchMedia('(prefers-reduced-motion: reduce)').matches;
      if (prefersReduced) return;

      // 1. Vertical timeline line draw via ScrollTrigger scrub
      if (lineRef.current) {
        gsap.fromTo(
          lineRef.current,
          { scaleY: 0 },
          {
            scaleY: 1,
            ease: 'none',
            transformOrigin: 'top center',
            scrollTrigger: {
              trigger: containerRef.current,
              start: 'top 75%',
              end: 'bottom 85%',
              scrub: 0.6,
            },
          }
        );
      }

      // 2. Ensure all milestone cards are cleanly rendered and visible
      gsap.set('.story-milestone-item', { clearProps: 'all' });
    },
    { scope: containerRef }
  );

  return (
    <div ref={containerRef} className="relative max-w-4xl mx-auto py-6 sm:py-8">
      {/* Background Track Line */}
      <div className="absolute left-6 md:left-1/2 top-0 bottom-0 w-0.5 -translate-x-1/2 bg-white/10" />

      {/* Animated Glowing Drawn Line */}
      <div
        ref={lineRef}
        className="absolute left-6 md:left-1/2 top-0 bottom-0 w-0.5 -translate-x-1/2 bg-gradient-to-b from-primary via-accent to-emerald-400 shadow-[0_0_12px_rgba(16,185,129,0.7)]"
      />

      {/* Timeline Milestones */}
      <div className="space-y-6 md:space-y-8">
        {storyMilestones.map((milestone, idx) => {
          const isEven = idx % 2 === 0;
          const IconComponent = milestone.icon;

          return (
            <div
              key={milestone.period}
              className={`story-milestone-item relative flex flex-col md:flex-row items-start md:items-center ${
                isEven ? 'md:flex-row-reverse' : ''
              }`}
            >
              {/* Timeline Center Node Badge */}
              <div className="absolute left-6 md:left-1/2 -translate-x-1/2 flex items-center justify-center w-12 h-12 rounded-2xl bg-surface border-2 border-primary shadow-[0_0_16px_rgba(16,185,129,0.35)] z-10 transition-transform duration-300 hover:scale-110">
                <IconComponent className="w-5 h-5 text-accent" />
              </div>

              {/* Content Card (Left or Right on Desktop) */}
              <div
                className={`w-full md:w-[calc(50%-2.5rem)] pl-16 md:pl-0 ${
                  isEven ? 'md:text-left md:pl-10' : 'md:text-right md:pr-10'
                }`}
              >
                <GlassCard hover className="p-6 md:p-7 space-y-3.5 border-white/10 hover:border-primary/40">
                  <div
                    className={`flex items-center gap-2 flex-wrap ${
                      isEven ? 'md:justify-start' : 'md:justify-end'
                    }`}
                  >
                    <Badge variant="primary" size="sm" className="font-mono">
                      {milestone.period}
                    </Badge>
                    <span className="text-xs font-semibold uppercase tracking-wider text-accent/90">
                      {milestone.badge}
                    </span>
                  </div>

                  <h3 className="text-lg md:text-xl font-bold text-white leading-snug">
                    {milestone.title}
                  </h3>

                  <p className="text-sm text-muted leading-relaxed">
                    {milestone.description}
                  </p>

                  {/* Bullet Highlights */}
                  <div
                    className={`pt-2 flex flex-wrap gap-2 ${
                      isEven ? 'md:justify-start' : 'md:justify-end'
                    }`}
                  >
                    {milestone.highlights.map((h, hIdx) => (
                      <span
                        key={hIdx}
                        className="inline-flex items-center text-xs font-mono px-2.5 py-1 rounded-md bg-surface-2 border border-white/5 text-subtle"
                      >
                        ✓ {h}
                      </span>
                    ))}
                  </div>
                </GlassCard>
              </div>
            </div>
          );
        })}
      </div>
    </div>
  );
}

export default AboutStoryTimeline;
