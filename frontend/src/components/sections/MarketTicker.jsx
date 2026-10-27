import React, { useRef } from 'react';
import { TrendingUp, TrendingDown, Activity } from 'lucide-react';
import { useGSAP } from '@gsap/react';
import { gsap } from '@/lib/gsap';
import { sampleTickerData } from '@/data';

/**
 * Market ticker strip:
 * - Seamless infinite horizontal marquee built with GSAP (not CSS)
 * - Pauses cleanly on mouse hover
 * - Displays static sample market data (NIFTY 50, SENSEX, BANKNIFTY, S&P 500, NASDAQ, GOLD)
 * - Complies with prefers-reduced-motion
 */
export function MarketTicker() {
  const containerRef = useRef(null);
  const trackRef = useRef(null);
  const tweenRef = useRef(null);

  // Duplicate items twice to ensure a completely seamless continuous infinite loop
  const duplicatedItems = [...sampleTickerData, ...sampleTickerData, ...sampleTickerData];

  useGSAP(
    () => {
      const track = trackRef.current;
      const container = containerRef.current;
      if (!track || !container) return;

      const mm = gsap.matchMedia();

      mm.add('(prefers-reduced-motion: no-preference)', () => {
        // Infinite seamless loop via xPercent: -50
        const tween = gsap.to(track, {
          xPercent: -50,
          repeat: -1,
          duration: 30,
          ease: 'none',
        });

        tweenRef.current = tween;

        // Pause on mouse enter, resume on mouse leave
        const handleMouseEnter = () => tween.pause();
        const handleMouseLeave = () => tween.play();

        container.addEventListener('mouseenter', handleMouseEnter);
        container.addEventListener('mouseleave', handleMouseLeave);

        return () => {
          container.removeEventListener('mouseenter', handleMouseEnter);
          container.removeEventListener('mouseleave', handleMouseLeave);
        };
      });

      mm.add('(prefers-reduced-motion: reduce)', () => {
        gsap.set(track, { xPercent: 0 });
      });

      return () => mm.revert();
    },
    { scope: containerRef }
  );

  return (
    <section
      aria-label="Market Data Ticker"
      ref={containerRef}
      className="relative w-full overflow-hidden border-y border-white/10 bg-surface/75 backdrop-blur-md py-3 select-none"
    >
      {/* Left and Right Fade Gradients for smooth edge blending */}
      <div className="pointer-events-none absolute left-0 top-0 bottom-0 w-16 sm:w-28 bg-gradient-to-r from-background to-transparent z-10" />
      <div className="pointer-events-none absolute right-0 top-0 bottom-0 w-16 sm:w-28 bg-gradient-to-l from-background to-transparent z-10" />

      {/* Marquee Motion Track */}
      <div
        ref={trackRef}
        className="flex w-max items-center gap-6 sm:gap-10 will-change-transform"
      >
        {duplicatedItems.map((item, idx) => {
          const isBull = item.isBull;
          return (
            <div
              key={`${item.symbol}-${idx}`}
              className="flex items-center gap-2.5 text-xs sm:text-sm font-mono whitespace-nowrap cursor-default"
            >
              {/* Asset Name */}
              <span className="font-bold text-white tracking-wide">
                {item.symbol}
              </span>

              {/* Price */}
              <span className="text-white/90 font-medium">
                {item.price}
              </span>

              {/* Change Indicator */}
              <div
                className={`inline-flex items-center gap-1 font-semibold px-2 py-0.5 rounded-md ${
                  isBull
                    ? 'text-bull bg-bull/15 border border-bull/25'
                    : 'text-bear bg-bear/15 border border-bear/25'
                }`}
              >
                {isBull ? (
                  <TrendingUp className="h-3 w-3" />
                ) : (
                  <TrendingDown className="h-3 w-3" />
                )}
                <span>{item.percent}</span>
              </div>

              {/* Subtle divider dot */}
              <span className="text-white/20 pl-4 sm:pl-6">•</span>
            </div>
          );
        })}
      </div>

      {/* Note: Static sample data for demo preview */}
      <div className="sr-only">
        Sample market benchmark prices for Nifty, Sensex, Bank Nifty, and global indices.
      </div>
    </section>
  );
}

export default MarketTicker;
