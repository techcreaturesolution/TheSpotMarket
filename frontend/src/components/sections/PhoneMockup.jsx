import React, { useRef, forwardRef, useImperativeHandle } from 'react';
import {
  TrendingUp,
  Sparkles,
  Zap,
  Activity,
  ArrowUpRight,
  Wifi,
  Battery,
  ShieldCheck,
} from 'lucide-react';
import { useGSAP } from '@gsap/react';
import { gsap } from '@/lib/gsap';
import { Badge } from '@/components/ui/Badge';

/**
 * Pure CSS-built phone mockup with floating cards, live SVG drawn line chart,
 * and GSAP yoyo float animations.
 */
export const PhoneMockup = forwardRef(function PhoneMockup(props, ref) {
  const containerRef = useRef(null);
  const tiltCardRef = useRef(null);
  const chartPathRef = useRef(null);
  const floatCard1Ref = useRef(null);
  const floatCard2Ref = useRef(null);
  const floatCard3Ref = useRef(null);

  // Expose the tilt element to parent for mouse-parallax quickTo
  useImperativeHandle(ref, () => ({
    getTiltElement: () => tiltCardRef.current,
    getContainer: () => containerRef.current,
    animateChart: () => {
      if (chartPathRef.current) {
        const path = chartPathRef.current;
        const length = path.getTotalLength();
        gsap.fromTo(
          path,
          { strokeDasharray: length, strokeDashoffset: length },
          { strokeDashoffset: 0, duration: 1.4, ease: 'power2.out' }
        );
      }
    },
    getFloatCards: () => [
      floatCard1Ref.current,
      floatCard2Ref.current,
      floatCard3Ref.current,
    ],
  }));

  // Setup GSAP floating animations for the 3 orbiting cards
  useGSAP(
    () => {
      const card1 = floatCard1Ref.current;
      const card2 = floatCard2Ref.current;
      const card3 = floatCard3Ref.current;
      const chartPath = chartPathRef.current;

      const mm = gsap.matchMedia();

      mm.add('(prefers-reduced-motion: no-preference)', () => {
        // Line chart stroke draw
        if (chartPath) {
          const length = chartPath.getTotalLength();
          gsap.fromTo(
            chartPath,
            { strokeDasharray: length, strokeDashoffset: length },
            {
              strokeDashoffset: 0,
              duration: 1.6,
              delay: 0.5,
              ease: 'power2.out',
            }
          );
        }

        // Floating Card 1: Top-Left (NIFTY 50)
        if (card1) {
          gsap.to(card1, {
            y: -10,
            x: -3,
            rotation: -1,
            duration: 2.7,
            repeat: -1,
            yoyo: true,
            ease: 'sine.inOut',
          });
        }

        // Floating Card 2: Top-Right (IPO Open)
        if (card2) {
          gsap.to(card2, {
            y: 12,
            x: 4,
            rotation: 1.5,
            duration: 3.4,
            delay: 0.3,
            repeat: -1,
            yoyo: true,
            ease: 'sine.inOut',
          });
        }

        // Floating Card 3: Bottom-Left (SpotAI Brief)
        if (card3) {
          gsap.to(card3, {
            y: -9,
            x: 5,
            rotation: -1,
            duration: 3.0,
            delay: 0.6,
            repeat: -1,
            yoyo: true,
            ease: 'sine.inOut',
          });
        }
      });

      return () => mm.revert();
    },
    { scope: containerRef }
  );

  return (
    <div
      ref={containerRef}
      className="relative flex items-center justify-center select-none py-2 lg:py-3"
      style={{ perspective: '1200px' }}
    >
      {/* 3D Tilt Wrapper for mouse-parallax */}
      <div
        ref={tiltCardRef}
        className="relative transition-transform duration-75 will-change-transform"
        style={{ transformStyle: 'preserve-3d' }}
      >
        {/* Ambient Phone Glow behind device */}
        <div className="absolute -inset-6 rounded-full bg-primary/20 blur-3xl pointer-events-none -z-10 opacity-70" />

        {/* Outer Phone Chassis */}
        <div className="relative rounded-[40px] bg-[#0A120E] p-2.5 sm:p-3 border border-white/15 shadow-[0_25px_60px_-15px_rgba(0,0,0,0.9),0_0_40px_rgba(16,185,129,0.18)] w-[270px] sm:w-[295px] xl:w-[315px]">
          {/* Glass reflection gradient on chassis border */}
          <div className="absolute top-0 left-12 right-12 h-[1px] bg-gradient-to-r from-transparent via-white/30 to-transparent" />

          {/* Screen Bezel */}
          <div className="relative rounded-[32px] bg-[#040A07] border border-white/10 overflow-hidden flex flex-col h-[485px] sm:h-[510px] xl:h-[535px]">
            {/* Top Dynamic Island Pill */}
            <div className="pt-2 px-5 flex items-center justify-between text-[11px] font-semibold text-white/70">
              <span>09:41</span>
              <div className="w-20 h-4 bg-black rounded-full border border-white/5 flex items-center justify-end pr-2">
                <span className="h-1.5 w-1.5 rounded-full bg-primary/80" />
              </div>
              <div className="flex items-center gap-1.5 text-white/70">
                <Wifi className="h-3 w-3" />
                <Battery className="h-3 w-3" />
              </div>
            </div>

            {/* In-App Header */}
            <div className="px-4 py-3 flex items-center justify-between border-b border-white/5">
              <div className="flex items-center gap-2">
                <div className="h-6 w-6 rounded-lg bg-primary/20 border border-primary/40 flex items-center justify-center text-accent">
                  <TrendingUp className="h-3.5 w-3.5" />
                </div>
                <span className="font-extrabold text-xs tracking-heading text-white">
                  TheSpot<span className="text-primary">Market</span>
                </span>
              </div>
              <Badge variant="live" size="sm" pulse>
                Live
              </Badge>
            </div>

            {/* Screen Content Body */}
            <div className="p-3.5 space-y-3 overflow-hidden flex-1">
              {/* Feature Card 1: Active IPO with mini SVG chart */}
              <div className="rounded-card bg-card-gradient border border-white/10 p-3 space-y-2.5 shadow-sm">
                <div className="flex items-start justify-between">
                  <div>
                    <div className="flex items-center gap-1.5">
                      <span className="text-xs font-bold text-white leading-tight">
                        SolarTech Energy
                      </span>
                      <Badge variant="sme" size="sm">
                        SME
                      </Badge>
                    </div>
                    <p className="text-[10px] text-muted font-mono mt-0.5">
                      Bidding Closes in 2d • ₹92 - ₹98
                    </p>
                  </div>
                  <Badge variant="bullish" size="sm">
                    +83.6%
                  </Badge>
                </div>

                {/* Mini Line Chart SVG */}
                <div className="relative h-14 w-full bg-black/25 rounded-lg border border-white/5 p-1 flex items-center">
                  <svg
                    viewBox="0 0 200 50"
                    className="w-full h-full overflow-visible"
                    fill="none"
                  >
                    <defs>
                      <linearGradient id="chartGradient" x1="0" y1="0" x2="1" y2="0">
                        <stop offset="0%" stopColor="#10B981" />
                        <stop offset="100%" stopColor="#34D399" />
                      </linearGradient>
                      <linearGradient id="areaGradient" x1="0" y1="0" x2="0" y2="1">
                        <stop offset="0%" stopColor="#10B981" stopOpacity="0.3" />
                        <stop offset="100%" stopColor="#10B981" stopOpacity="0.0" />
                      </linearGradient>
                    </defs>

                    {/* Area under curve */}
                    <path
                      d="M 5 45 C 35 42, 60 32, 90 35 C 120 38, 150 16, 195 8 L 195 48 L 5 48 Z"
                      fill="url(#areaGradient)"
                    />

                    {/* Stroke line drawn via GSAP */}
                    <path
                      ref={chartPathRef}
                      d="M 5 45 C 35 42, 60 32, 90 35 C 120 38, 150 16, 195 8"
                      stroke="url(#chartGradient)"
                      strokeWidth="2.5"
                      strokeLinecap="round"
                    />

                    {/* Pulsing point at latest price */}
                    <circle cx="195" cy="8" r="3.5" fill="#34D399" />
                    <circle cx="195" cy="8" r="6" fill="#34D399" opacity="0.4" />
                  </svg>
                </div>

                {/* Key Metrics Row */}
                <div className="grid grid-cols-2 gap-2 pt-1 border-t border-white/5 text-[10px]">
                  <div>
                    <span className="text-subtle block">Grey Market Premium</span>
                    <span className="font-extrabold text-accent text-xs">
                      +₹82 (Bullish)
                    </span>
                  </div>
                  <div className="text-right">
                    <span className="text-subtle block">Subscription</span>
                    <span className="font-extrabold text-white text-xs">
                      42.8x Overbooked
                    </span>
                  </div>
                </div>
              </div>

              {/* Feature Card 2: Market Snapshot (NSE) */}
              <div className="rounded-xl bg-surface/70 border border-white/10 p-2.5 flex items-center justify-between">
                <div className="flex items-center gap-2">
                  <div className="h-7 w-7 rounded-lg bg-bull/20 border border-bull/30 flex items-center justify-center text-bull">
                    <Activity className="h-4 w-4" />
                  </div>
                  <div>
                    <span className="text-xs font-bold text-white block leading-none">
                      NIFTY 50
                    </span>
                    <span className="text-[10px] text-muted font-mono">24,860.50</span>
                  </div>
                </div>
                <div className="text-right">
                  <span className="text-xs font-extrabold text-bull block leading-none">
                    +0.58%
                  </span>
                  <span className="text-[9px] text-subtle font-mono">+142.30 pts</span>
                </div>
              </div>

              {/* Feature Card 3: SpotAI Prompt Preview */}
              <div className="rounded-xl bg-[#0C1A13] border border-primary/25 p-2.5 space-y-1">
                <div className="flex items-center gap-1.5 text-accent text-[11px] font-bold">
                  <Sparkles className="h-3 w-3" />
                  <span>SpotAI Sentiment</span>
                </div>
                <p className="text-[10px] text-muted leading-tight">
                  &ldquo;Retail quota subscribed 18.2x by 12:30 PM. Institutional bids accelerating.&rdquo;
                </p>
              </div>
            </div>

            {/* In-App Bottom Navigation Mock */}
            <div className="p-3 border-t border-white/5 bg-[#07110B] flex items-center justify-around text-muted">
              <div className="flex flex-col items-center text-primary">
                <TrendingUp className="h-4 w-4" />
                <span className="text-[8px] font-bold mt-0.5">Home</span>
              </div>
              <div className="flex flex-col items-center">
                <Activity className="h-4 w-4" />
                <span className="text-[8px] mt-0.5">IPOs</span>
              </div>
              <div className="flex flex-col items-center text-accent">
                <Sparkles className="h-4 w-4" />
                <span className="text-[8px] mt-0.5">SpotAI</span>
              </div>
            </div>
          </div>
        </div>

        {/* =========================================================================
            FLOATING SATELLITE CARDS (Animated with infinite GSAP yoyo tweens)
            ========================================================================= */}

        {/* Floating Card 1: Top-Left (NIFTY +0.8%) */}
        <div
          ref={floatCard1Ref}
          className="absolute -top-3 -left-4 sm:-left-10 z-20 rounded-2xl bg-surface/85 backdrop-blur-xl border border-white/15 p-3 shadow-xl flex items-center gap-2.5 pointer-events-none"
        >
          <div className="h-8 w-8 rounded-xl bg-bull/20 border border-bull/30 flex items-center justify-center text-bull">
            <ArrowUpRight className="h-4 w-4" />
          </div>
          <div>
            <div className="text-[11px] font-bold text-white leading-tight">
              NIFTY 50
            </div>
            <div className="text-xs font-extrabold text-bull font-mono">
              +0.84% <span className="text-[10px] text-muted font-normal">(Bullish)</span>
            </div>
          </div>
        </div>

        {/* Floating Card 2: Top-Right (IPO Open • Live) */}
        <div
          ref={floatCard2Ref}
          className="absolute top-16 -right-4 sm:-right-8 z-20 rounded-2xl bg-surface/85 backdrop-blur-xl border border-primary/30 p-3 shadow-xl flex items-center gap-2.5 pointer-events-none"
        >
          <Badge variant="live" size="sm" pulse>
            IPO Open
          </Badge>
          <div>
            <div className="text-[11px] font-bold text-white leading-tight">
              Tata Tech IPO
            </div>
            <div className="text-[10px] text-accent font-semibold">
              Live GMP: +₹415
            </div>
          </div>
        </div>

        {/* Floating Card 3: Bottom-Left (SpotAI Brief) */}
        <div
          ref={floatCard3Ref}
          className="absolute bottom-2 -left-2 sm:-left-6 z-20 rounded-2xl bg-card-gradient backdrop-blur-xl border border-primary/35 p-2.5 sm:p-3 shadow-xl flex items-center gap-2.5 pointer-events-none max-w-[200px]"
        >
          <div className="h-8 w-8 rounded-xl bg-primary/20 border border-primary/40 flex items-center justify-center text-accent shrink-0">
            <Sparkles className="h-4 w-4" />
          </div>
          <div className="leading-tight">
            <span className="text-[10px] font-mono uppercase text-accent font-bold block">
              SpotAI Brief
            </span>
            <span className="text-[11px] font-semibold text-white">
              Strong QIB Bidding Surge
            </span>
          </div>
        </div>
      </div>
    </div>
  );
});

export default PhoneMockup;
