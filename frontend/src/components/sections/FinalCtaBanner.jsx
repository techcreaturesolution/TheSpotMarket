import React, { useRef } from 'react';
import { useGSAP } from '@gsap/react';
import { gsap, ScrollTrigger } from '@/lib/gsap';
import {
  ShieldCheck,
  Zap,
  Lock,
} from 'lucide-react';
import { Container } from '@/components/ui/Container';
import { Button } from '@/components/ui/Button';
import { GradientText } from '@/components/ui/GradientText';
import { siteConfig } from '@/lib/site';

export function FinalCtaBanner() {
  const containerRef = useRef(null);
  const cardRef = useRef(null);

  useGSAP(
    () => {
      const prefersReduced = window.matchMedia('(prefers-reduced-motion: reduce)').matches;
      if (prefersReduced) return;

      gsap.fromTo(
        cardRef.current,
        { opacity: 0, y: 25, scale: 0.98 },
        {
          opacity: 1,
          y: 0,
          scale: 1,
          duration: 0.7,
          ease: 'power3.out',
          scrollTrigger: {
            trigger: containerRef.current,
            start: 'top 88%',
            toggleActions: 'play none none none',
            once: true,
          },
        }
      );
    },
    { scope: containerRef }
  );

  return (
    <section ref={containerRef} className="py-6 sm:py-10 relative overflow-hidden">
      <Container>
        <div className="relative">
          {/* Ambient subtle glow disc */}
          <div className="absolute top-1/2 left-1/2 -translate-x-1/2 -translate-y-1/2 w-full max-w-xl h-28 bg-primary/15 rounded-full blur-[90px] pointer-events-none -z-10" />

          {/* Compact Redesigned Banner Pod */}
          <div
            ref={cardRef}
            className="relative rounded-3xl bg-gradient-to-r from-surface/95 via-[#0A1A12]/90 to-surface/95 backdrop-blur-2xl border border-primary/30 hover:border-primary/50 transition-all duration-300 p-6 sm:p-7 md:p-8 shadow-[0_20px_50px_-15px_rgba(0,0,0,0.85),0_0_30px_rgba(16,185,129,0.12)] overflow-hidden"
          >
            {/* Top accent light reflection line */}
            <div className="absolute top-0 left-10 right-10 h-[1px] bg-gradient-to-r from-transparent via-primary/50 to-transparent" />

            {/* Responsive Flex: Left info, Right action pod */}
            <div className="flex flex-col lg:flex-row items-start lg:items-center justify-between gap-6 lg:gap-8">
              {/* Left Column: Compact Copy */}
              <div className="space-y-2 max-w-2xl text-left">
                <div className="inline-flex items-center gap-2 px-2.5 py-0.5 rounded-full bg-primary/10 border border-primary/25">
                  <span className="flex h-1.5 w-1.5 rounded-full bg-accent animate-pulse" />
                  <span className="text-[10px] sm:text-[11px] font-bold font-mono tracking-wider uppercase text-accent">
                    Mobile Intelligence • Android Native
                  </span>
                </div>

                <h2 className="text-2xl sm:text-3xl font-extrabold text-white tracking-tight leading-tight">
                  Every Market Move.{' '}
                  <GradientText variant="emerald">In Your Pocket.</GradientText>
                </h2>

                <p className="text-xs sm:text-sm text-muted leading-relaxed max-w-xl">
                  Real-time Mainline & SME IPO tracking, live GMP shifts, PAN allotment check, and SpotAI prospectus breakdown — zero broker linking required.
                </p>

                {/* Micro Trust Indicators Row */}
                <div className="flex flex-wrap items-center gap-x-5 gap-y-1 pt-1 text-[11px] sm:text-xs text-subtle">
                  <span className="inline-flex items-center gap-1.5">
                    <ShieldCheck className="w-3.5 h-3.5 text-bull" />
                    100% Free Forever
                  </span>
                  <span className="inline-flex items-center gap-1.5">
                    <Lock className="w-3.5 h-3.5 text-accent" />
                    PAN Stays on Device
                  </span>
                  <span className="inline-flex items-center gap-1.5">
                    <Zap className="w-3.5 h-3.5 text-amber-400" />
                    Instant Registrar Sync
                  </span>
                </div>
              </div>

              {/* Right Column: Interactive Download Pod */}
              <div className="w-full lg:w-auto flex flex-col sm:flex-row lg:flex-col items-stretch sm:items-center lg:items-end gap-3 shrink-0 pt-2 lg:pt-0">
                <div className="flex items-center gap-3">
                  <img
                    src="/images/app_icon.png"
                    alt="TheSpotMarket App"
                    className="h-10 w-10 sm:h-11 sm:w-11 rounded-2xl object-cover border border-primary/40 shadow-sm shrink-0"
                    onError={(e) => {
                      e.currentTarget.style.display = 'none';
                    }}
                  />
                  <div className="text-left lg:text-right">
                    <span className="font-extrabold text-sm text-white block leading-tight">
                      TheSpot<span className="text-primary">Market</span>
                    </span>
                    <span className="text-[10px] text-muted font-mono block">
                      Android • Google Play Store
                    </span>
                  </div>
                </div>

                <Button
                  href={siteConfig.links.playStore}
                  variant="primary"
                  size="md"
                  className="font-bold shadow-btn-glow w-full sm:w-auto justify-center"
                  icon={
                    <svg className="h-4 w-4 fill-current" viewBox="0 0 24 24">
                      <path d="M3.609 1.814L13.792 12 3.61 22.186a2.274 2.274 0 01-.61-.918V2.732c.16-.363.376-.684.61-.918zM15.207 13.414l2.583 2.583-11.45 6.55 8.867-9.133zm0-2.828L6.34 1.453l11.45 6.55-2.583 2.583zm1.414 1.414l3.664-2.096c1.19-.68 1.19-1.79 0-2.47L16.621 12z" />
                    </svg>
                  }
                >
                  Download on Play Store
                </Button>
              </div>
            </div>
          </div>
        </div>
      </Container>
    </section>
  );
}

export default FinalCtaBanner;
