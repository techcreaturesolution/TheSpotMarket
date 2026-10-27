import React, { useRef, useState, useEffect } from 'react';
import { useGSAP } from '@gsap/react';
import gsap from 'gsap';
import { Draggable } from '@/lib/gsap';
import {
  ChevronLeft,
  ChevronRight,
  Sparkles,
  Smartphone,
  TrendingUp,
  FileCheck2,
  Bot,
  Layers,
  ArrowRight,
  Grab,
  Clock,
  CheckCircle2,
  Activity,
  Search,
} from 'lucide-react';
import { Container } from '@/components/ui/Container';
import { SectionHeading } from '@/components/ui/SectionHeading';
import { GradientText } from '@/components/ui/GradientText';
import { Badge } from '@/components/ui/Badge';
import { appScreenshots } from '@/data';

function ScreenMockupFallback({ screenId }) {
  switch (screenId) {
    case 'home':
      return (
        <div className="p-4 space-y-3 h-full flex flex-col justify-between text-left select-none">
          <div>
            <div className="flex items-center justify-between pb-2 border-b border-surface-border">
              <span className="text-[11px] font-bold text-text-primary">NIFTY 50</span>
              <span className="text-[11px] font-bold text-bull">24,860.50 (+0.58%)</span>
            </div>
            <div className="mt-3 p-3 rounded-xl bg-gradient-to-br from-[#0C2016] to-[#040E08] border border-primary/25">
              <div className="flex justify-between items-center mb-1">
                <span className="text-[9px] uppercase font-bold text-accent">Spotlight IPO</span>
                <span className="text-[9px] text-bull font-bold">+84% GMP</span>
              </div>
              <div className="text-xs font-bold text-white">Tata Technologies</div>
              <div className="text-[10px] text-text-muted mt-0.5">32.4x Subscribed • Closes in 2d</div>
            </div>
            <div className="mt-2.5 p-2.5 rounded-xl bg-surface-2 border border-surface-border flex items-center justify-between">
              <div className="flex items-center gap-2">
                <Bot className="w-4 h-4 text-accent" />
                <span className="text-[10px] font-semibold text-text-primary">SpotAI Sentiment</span>
              </div>
              <span className="text-[10px] font-bold text-bull">8.9/10</span>
            </div>
          </div>
          <div className="py-1 px-3 rounded-lg bg-primary/10 border border-primary/20 text-[9px] text-accent text-center font-semibold">
            Tap to open real-time dashboard
          </div>
        </div>
      );
    case 'ipos':
      return (
        <div className="p-4 space-y-2.5 h-full flex flex-col justify-between text-left select-none">
          <div>
            <div className="text-xs font-bold text-white mb-2 flex items-center justify-between">
              <span>Mainboard & SME</span>
              <span className="text-[10px] text-accent font-semibold">12 Active</span>
            </div>
            <div className="p-2.5 rounded-xl bg-surface-2 border border-primary/25 mb-2">
              <div className="flex items-center justify-between">
                <span className="text-xs font-bold text-white">Premier Energies</span>
                <span className="text-[10px] font-bold text-bull">+₹390</span>
              </div>
              <div className="text-[10px] text-text-muted mt-0.5">Price: ₹450 • Lot: 33</div>
              <div className="mt-1.5 w-full bg-[#182B1F] h-1.5 rounded-full overflow-hidden">
                <div className="bg-primary h-full rounded-full w-[74%]" />
              </div>
            </div>
            <div className="p-2.5 rounded-xl bg-surface-2 border border-surface-border">
              <div className="flex items-center justify-between">
                <span className="text-xs font-bold text-white">Resourceful SME</span>
                <span className="text-[10px] font-bold text-bull">+₹105</span>
              </div>
              <div className="text-[10px] text-text-muted mt-0.5">Subscription: 418x • Closed</div>
            </div>
          </div>
          <div className="py-1 px-3 rounded-lg bg-surface border border-surface-border text-[9px] text-text-muted text-center">
            GMP & Subscription Meter
          </div>
        </div>
      );
    case 'market':
      return (
        <div className="p-4 space-y-3 h-full flex flex-col justify-between text-left select-none">
          <div>
            <div className="flex items-center justify-between pb-2 border-b border-surface-border">
              <span className="text-xs font-bold text-white">Market Breadth</span>
              <span className="text-[10px] text-bull font-bold">1,420 Adv / 580 Dec</span>
            </div>
            <div className="mt-3 space-y-2">
              <div className="p-2 rounded-xl bg-surface-2 flex items-center justify-between text-xs">
                <span className="font-semibold text-white">RELIANCE</span>
                <span className="text-bull font-bold">+1.84%</span>
              </div>
              <div className="p-2 rounded-xl bg-surface-2 flex items-center justify-between text-xs">
                <span className="font-semibold text-white">HDFCBANK</span>
                <span className="text-bear font-bold">-0.62%</span>
              </div>
              <div className="p-2 rounded-xl bg-surface-2 flex items-center justify-between text-xs">
                <span className="font-semibold text-white">S&P 500 (US)</span>
                <span className="text-bull font-bold">+0.42%</span>
              </div>
            </div>
          </div>
          <div className="py-1 px-3 rounded-lg bg-primary/10 border border-primary/20 text-[9px] text-accent text-center font-semibold">
            Indian & Global Synchronized
          </div>
        </div>
      );
    case 'allotment':
      return (
        <div className="p-4 space-y-3 h-full flex flex-col justify-between text-left select-none">
          <div>
            <div className="text-xs font-bold text-white mb-2 flex items-center gap-1.5">
              <FileCheck2 className="w-3.5 h-3.5 text-accent" />
              <span>Instant Registrar Gateway</span>
            </div>
            <div className="p-3 rounded-xl bg-surface-2 border border-surface-border space-y-2">
              <div className="text-[10px] text-text-muted">SELECT REGISTRAR</div>
              <div className="text-xs font-bold text-accent">Link Intime India Pvt Ltd</div>
              <div className="mt-2 text-[10px] text-text-muted">STORED PAN (ON-DEVICE)</div>
              <div className="text-xs font-mono font-bold text-text-primary">ABCDE••••F</div>
            </div>
            <div className="mt-3 p-2 rounded-lg bg-bull/15 border border-bull/30 text-center">
              <span className="text-xs font-bold text-bull">ALLOTTED: 1 LOT (33 SHARES)</span>
            </div>
          </div>
          <div className="py-1 px-3 rounded-lg bg-surface border border-surface-border text-[9px] text-text-muted text-center">
            Zero Server PAN Retention
          </div>
        </div>
      );
    case 'spotai':
    default:
      return (
        <div className="p-4 space-y-3 h-full flex flex-col justify-between text-left select-none">
          <div>
            <div className="flex items-center gap-2 pb-2 border-b border-surface-border">
              <Bot className="w-4 h-4 text-accent" />
              <span className="text-xs font-bold text-white">SpotAI Co-Pilot</span>
            </div>
            <div className="mt-3 p-2.5 rounded-xl rounded-tr-none bg-primary/20 text-[10px] text-text-primary leading-relaxed">
              Q: Top 2 revenue risks in RHP?
            </div>
            <div className="mt-2 p-2.5 rounded-xl rounded-tl-none bg-surface-2 text-[10px] text-text-secondary leading-relaxed border border-surface-border">
              1. 42% revenue reliance on anchor OEM accounts.
              <br />
              2. Forex exposure on overseas engineering hubs.
            </div>
          </div>
          <div className="py-1 px-3 rounded-lg bg-primary/10 border border-primary/20 text-[9px] text-accent text-center font-semibold">
            Verified DRHP Citations
          </div>
        </div>
      );
  }
}

function PhoneFrameCard({ screenshot, index }) {
  const [imgError, setImgError] = useState(false);

  return (
    <div className="shrink-0 w-[275px] sm:w-[295px] select-none flex flex-col items-center">
      {/* Phone chassis */}
      <div className="relative w-full h-[530px] rounded-[42px] bg-[#020503] p-2.5 border-4 border-[#1A2E22] shadow-[0_20px_50px_-15px_rgba(0,0,0,0.85),0_0_35px_rgba(16,185,129,0.14)] overflow-hidden">
        {/* Inner screen */}
        <div className="relative w-full h-full rounded-[32px] bg-[#040A07] overflow-hidden flex flex-col border border-surface-border">
          {/* Status bar */}
          <div className="pt-2 px-5 pb-1 flex items-center justify-between text-[10px] text-text-muted">
            <span className="font-semibold text-white">9:41</span>
            <div className="w-16 h-3.5 bg-black rounded-full flex items-center justify-center">
              <div className="w-2 h-2 bg-[#0C1610] rounded-full" />
            </div>
            <span className="font-semibold text-accent">5G</span>
          </div>

          {/* Screen Content: Image or Graceful Interactive CSS Fallback */}
          <div className="flex-1 w-full overflow-hidden relative">
            {!imgError ? (
              <img
                src={screenshot.image}
                alt={screenshot.title}
                onError={() => setImgError(true)}
                className="w-full h-full object-cover object-top"
                loading="lazy"
              />
            ) : null}

            {/* If image fails or does not exist, render CSS mockup fallback */}
            {imgError && <ScreenMockupFallback screenId={screenshot.id} />}
          </div>
        </div>
      </div>

      {/* Caption info below phone */}
      <div className="text-center mt-5 px-3">
        <Badge variant="primary" size="sm" className="mb-1.5">
          {screenshot.badge}
        </Badge>
        <h4 className="text-base font-bold text-text-primary tracking-tight">
          {screenshot.title}
        </h4>
        <p className="text-xs text-text-muted mt-1 leading-snug">
          {screenshot.description}
        </p>
      </div>
    </div>
  );
}

export function ScreenshotsSection() {
  const containerRef = useRef(null);
  const trackRef = useRef(null);
  const draggableInstance = useRef(null);

  useGSAP(
    () => {
      const track = trackRef.current;
      const container = containerRef.current;
      if (!track || !container) return;

      const prefersReduced = window.matchMedia('(prefers-reduced-motion: reduce)').matches;

      // Initialize GSAP Draggable with bounds
      if (typeof Draggable !== 'undefined') {
        const instances = Draggable.create(track, {
          type: 'x',
          edgeResistance: 0.85,
          dragResistance: 0.1,
          bounds: container,
          cursor: 'grab',
          activeCursor: 'grabbing',
          zIndexBoost: false,
          allowContextMenu: true,
        });

        draggableInstance.current = instances[0];
      }

      // Entrance animation
      if (!prefersReduced) {
        gsap.from(track.children, {
          scrollTrigger: {
            trigger: containerRef.current,
            start: 'top 80%',
            toggleActions: 'play none none none',
          },
          x: 60,
          opacity: 0,
          stagger: 0.1,
          duration: 0.8,
          ease: 'power3.out',
        });
      }

      return () => {
        draggableInstance.current?.kill();
      };
    },
    { scope: containerRef }
  );

  const scrollByDirection = (direction) => {
    if (!trackRef.current) return;
    const currentX = gsap.getProperty(trackRef.current, 'x') || 0;
    const step = 310;
    const targetX = direction === 'left' ? currentX + step : currentX - step;

    // Constrain within track bounds
    const containerWidth = containerRef.current?.offsetWidth || 1000;
    const trackWidth = trackRef.current.scrollWidth || 1500;
    const minX = Math.min(0, containerWidth - trackWidth - 32);

    const clampedX = Math.max(minX, Math.min(0, targetX));

    gsap.to(trackRef.current, {
      x: clampedX,
      duration: 0.5,
      ease: 'power2.out',
    });
  };

  return (
    <section ref={containerRef} className="py-6 sm:py-10 relative overflow-hidden">
      {/* Ambient background glow */}
      <div className="absolute top-1/2 right-1/4 -translate-y-1/2 w-[600px] h-[500px] bg-primary/7 rounded-full blur-[160px] pointer-events-none -z-10" />

      <Container>
        <div className="flex flex-col sm:flex-row sm:items-end justify-between gap-6 mb-6 sm:mb-8">
          <div>
            <SectionHeading
              badge="App Experience"
              title={
                <>
                  Crafted for Serious{' '}
                  <GradientText variant="emerald">Mobile Intelligence</GradientText>
                </>
              }
              subtitle="Swipe through the 5 core mobile workflows designed to give you a definitive edge on every IPO listing."
            />
          </div>

          {/* Drag Pill + Left / Right Nav Buttons */}
          <div className="flex items-center gap-3">
            <div className="hidden sm:inline-flex items-center gap-1.5 px-3 py-1.5 rounded-full bg-surface-2 border border-surface-border text-xs text-text-muted">
              <Grab className="w-3.5 h-3.5 text-accent" />
              <span>Drag or use arrows</span>
            </div>

            <button
              onClick={() => scrollByDirection('left')}
              className="w-10 h-10 rounded-xl bg-surface-2 border border-surface-border hover:border-primary/50 text-text-primary flex items-center justify-center transition-colors active:scale-95"
              aria-label="Scroll screenshots left"
            >
              <ChevronLeft className="w-5 h-5" />
            </button>

            <button
              onClick={() => scrollByDirection('right')}
              className="w-10 h-10 rounded-xl bg-surface-2 border border-surface-border hover:border-primary/50 text-text-primary flex items-center justify-center transition-colors active:scale-95"
              aria-label="Scroll screenshots right"
            >
              <ChevronRight className="w-5 h-5" />
            </button>
          </div>
        </div>

        {/* Draggable Track Container */}
        <div className="overflow-visible cursor-grab active:cursor-grabbing pb-8">
          <div
            ref={trackRef}
            className="flex items-start gap-6 sm:gap-8 w-max will-change-transform"
          >
            {appScreenshots.map((item, index) => (
              <PhoneFrameCard key={item.id} screenshot={item} index={index} />
            ))}
          </div>
        </div>
      </Container>
    </section>
  );
}

export default ScreenshotsSection;
