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
      <div className="relative w-full h-[540px] rounded-[42px] bg-[#020503] p-2.5 border-4 border-[#1A2E22] shadow-[0_20px_50px_-15px_rgba(0,0,0,0.85),0_0_35px_rgba(16,185,129,0.14)] overflow-hidden">
        {/* Inner screen */}
        <div className="relative w-full h-full rounded-[32px] bg-[#040A07] overflow-hidden flex flex-col border border-surface-border">
          {/* Status bar only for fallback */}
          {imgError && (
            <div className="pt-2 px-5 pb-1 flex items-center justify-between text-[10px] text-text-muted">
              <span className="font-semibold text-white">9:41</span>
              <div className="w-16 h-3.5 bg-black rounded-full flex items-center justify-center">
                <div className="w-2 h-2 bg-[#0C1610] rounded-full" />
              </div>
              <span className="font-semibold text-accent">5G</span>
            </div>
          )}

          {/* Screen Content: Real Image or Graceful Interactive CSS Fallback */}
          <div className="flex-1 w-full h-full overflow-hidden relative">
            {!imgError ? (
              <img
                src={screenshot.image}
                alt={screenshot.title}
                width="295"
                height="540"
                loading="lazy"
                decoding="async"
                onError={() => setImgError(true)}
                className="w-full h-full object-cover object-top"
              />
            ) : (
              <ScreenMockupFallback screenId={screenshot.id} />
            )}
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
  const setWidthRef = useRef(2289);
  const isHoveredRef = useRef(false);
  const [isHovered, setIsHovered] = useState(false);

  // Triple set of screenshots for seamless infinite circular scrolling in both directions
  const tripleScreenshots = [
    ...appScreenshots.map((item) => ({ ...item, uniqueKey: `set1-${item.id}` })),
    ...appScreenshots.map((item) => ({ ...item, uniqueKey: `set2-${item.id}` })),
    ...appScreenshots.map((item) => ({ ...item, uniqueKey: `set3-${item.id}` })),
  ];

  useEffect(() => {
    isHoveredRef.current = isHovered;
  }, [isHovered]);

  const measureSetWidth = () => {
    if (!trackRef.current || !trackRef.current.children) return 2289;
    const firstCard = trackRef.current.children[0];
    const eighthCard = trackRef.current.children[appScreenshots.length];
    if (firstCard && eighthCard) {
      const width = eighthCard.offsetLeft - firstCard.offsetLeft;
      if (width > 0) {
        setWidthRef.current = width;
        return width;
      }
    }
    return 2289;
  };

  const scrollByDirection = (direction) => {
    if (!trackRef.current) return;
    const setWidth = measureSetWidth();
    const currentX = gsap.getProperty(trackRef.current, 'x') || 0;
    const step = setWidth / appScreenshots.length;
    const targetX = direction === 'right' ? currentX - step : currentX + step;

    gsap.to(trackRef.current, {
      x: targetX,
      duration: 0.65,
      ease: 'power2.out',
      overwrite: 'auto',
      onComplete: () => {
        if (!trackRef.current) return;
        const finalX = gsap.getProperty(trackRef.current, 'x') || 0;
        // Seamless circular wrap: if scrolled into 3rd set, wrap back to 2nd set
        if (finalX <= -setWidth * 2) {
          gsap.set(trackRef.current, { x: finalX + setWidth });
        } else if (finalX >= -setWidth * 0.2) {
          // If scrolled backwards into 1st set, wrap forward to 2nd set
          gsap.set(trackRef.current, { x: finalX - setWidth });
        }
      },
    });
  };

  useGSAP(
    () => {
      const track = trackRef.current;
      const container = containerRef.current;
      if (!track || !container) return;

      const setWidth = measureSetWidth();

      // Start at Set 2 (middle copy) so user can scroll seamlessly in both directions
      gsap.set(track, { x: -setWidth });

      // Initialize GSAP Draggable with seamless circular wrapping during drag
      if (typeof Draggable !== 'undefined') {
        const instances = Draggable.create(track, {
          type: 'x',
          edgeResistance: 0,
          dragResistance: 0.05,
          cursor: 'grab',
          activeCursor: 'grabbing',
          zIndexBoost: false,
          allowContextMenu: true,
          onDragStart: () => {
            isHoveredRef.current = true;
          },
          onDrag: function () {
            const sw = setWidthRef.current || 2289;
            if (this.x <= -sw * 2) {
              this.x += sw;
              gsap.set(track, { x: this.x });
            } else if (this.x >= -sw * 0.2) {
              this.x -= sw;
              gsap.set(track, { x: this.x });
            }
          },
          onDragEnd: function () {
            const sw = setWidthRef.current || 2289;
            const current = gsap.getProperty(track, 'x') || 0;
            if (current <= -sw * 2) {
              gsap.set(track, { x: current + sw });
            } else if (current >= -sw * 0.2) {
              gsap.set(track, { x: current - sw });
            }
            setTimeout(() => {
              isHoveredRef.current = false;
            }, 1200);
          },
        });

        draggableInstance.current = instances[0];
      }

      // Entrance fade animation
      const prefersReduced = window.matchMedia('(prefers-reduced-motion: reduce)').matches;
      if (!prefersReduced) {
        gsap.from(track.children, {
          scrollTrigger: {
            trigger: containerRef.current,
            start: 'top 80%',
            toggleActions: 'play none none none',
          },
          opacity: 0,
          y: 35,
          stagger: 0.03,
          duration: 0.7,
          ease: 'power3.out',
        });
      }

      return () => {
        draggableInstance.current?.kill();
      };
    },
    { scope: containerRef }
  );

  // Auto-scroll loop: continuously advances forward in an endless seamless circle
  useEffect(() => {
    const prefersReduced = window.matchMedia('(prefers-reduced-motion: reduce)').matches;
    if (prefersReduced) return;

    const interval = setInterval(() => {
      if (isHoveredRef.current || draggableInstance.current?.isDragging) return;
      scrollByDirection('right');
    }, 3200);

    return () => clearInterval(interval);
  }, []);

  return (
    <section ref={containerRef} className="py-6 sm:py-10 relative overflow-hidden">
      {/* Ambient background glow */}
      <div className="absolute top-1/2 right-1/4 -translate-y-1/2 w-[600px] h-[500px] bg-primary/7 rounded-full blur-[160px] pointer-events-none -z-10" />

      <Container>
        {/* 1. Centered Section Heading (Red Box) */}
        <div className="text-center max-w-3xl mx-auto mb-8 sm:mb-12">
          <SectionHeading
            align="center"
            badge="App Experience"
            title={
              <>
                Crafted for Serious{' '}
                <GradientText variant="emerald">Mobile Intelligence</GradientText>
              </>
            }
            subtitle="Swipe through real mobile app workflows designed to give you a definitive edge on every IPO listing."
          />
        </div>

        {/* 2. Carousel Container with Floating Left & Right Arrows */}
        <div
          className="relative group/carousel pb-8"
          onMouseEnter={() => setIsHovered(true)}
          onMouseLeave={() => setIsHovered(false)}
        >
          {/* Left Arrow Button */}
          <button
            type="button"
            onClick={() => scrollByDirection('left')}
            className="absolute -left-2 sm:-left-3 lg:-left-5 top-[250px] -translate-y-1/2 z-30 w-11 h-11 sm:w-12 sm:h-12 rounded-2xl bg-[#020503]/85 hover:bg-primary/20 backdrop-blur-md border border-white/15 hover:border-primary/60 text-white flex items-center justify-center shadow-[0_10px_35px_rgba(0,0,0,0.85)] transition-all duration-200 active:scale-90 hover:scale-105 focus-visible:outline-none focus-visible:ring-2 focus-visible:ring-primary"
            aria-label="Previous screenshot"
          >
            <ChevronLeft className="w-5 h-5 sm:w-6 sm:h-6 text-white transition-colors" />
          </button>

          {/* Right Arrow Button */}
          <button
            type="button"
            onClick={() => scrollByDirection('right')}
            className="absolute -right-2 sm:-right-3 lg:-right-5 top-[250px] -translate-y-1/2 z-30 w-11 h-11 sm:w-12 sm:h-12 rounded-2xl bg-[#020503]/85 hover:bg-primary/20 backdrop-blur-md border border-white/15 hover:border-primary/60 text-white flex items-center justify-center shadow-[0_10px_35px_rgba(0,0,0,0.85)] transition-all duration-200 active:scale-90 hover:scale-105 focus-visible:outline-none focus-visible:ring-2 focus-visible:ring-primary"
            aria-label="Next screenshot"
          >
            <ChevronRight className="w-5 h-5 sm:w-6 sm:h-6 text-white transition-colors" />
          </button>

          {/* Draggable Track Container */}
          <div className="overflow-visible cursor-grab active:cursor-grabbing px-2 sm:px-4">
            <div
              ref={trackRef}
              className="flex items-start gap-6 sm:gap-8 w-max will-change-transform"
            >
              {tripleScreenshots.map((item, index) => (
                <PhoneFrameCard key={item.uniqueKey} screenshot={item} index={index} />
              ))}
            </div>
          </div>
        </div>
      </Container>
    </section>
  );
}

export default ScreenshotsSection;
