import React, { useEffect, useRef, useState } from 'react';
import { useGSAP } from '@gsap/react';
import { gsap } from '@/lib/gsap';
import { Sparkles, Activity } from 'lucide-react';

/**
 * InitialPreloader:
 * Simple, unique & advanced starting loader for TheSpotMarket.
 * Features:
 * - High-end liquid dark emerald glass aesthetic (#040A07)
 * - Concentric radar pulse rings around brand logo
 * - Live animated Market Heartbeat ECG / Trendline SVG
 * - Real-time calibration status counter (0% -> 100%)
 * - Smooth curtain wipe-up exit transition into Hero
 */
export function InitialPreloader({ onFinish }) {
  const containerRef = useRef(null);
  const contentRef = useRef(null);
  const linePathRef = useRef(null);
  const progressBarRef = useRef(null);
  const [progress, setProgress] = useState(0);
  const [statusText, setStatusText] = useState('CONNECTING TO NSE / BSE...');
  const [isDone, setIsDone] = useState(false);

  useEffect(() => {
    // Lock body scrolling while preloader is active
    document.body.style.overflow = 'hidden';
    return () => {
      document.body.style.overflow = '';
    };
  }, []);

  useGSAP(
    () => {
      const container = containerRef.current;
      const content = contentRef.current;
      const path = linePathRef.current;
      const bar = progressBarRef.current;
      if (!container || !content) return;

      // Animate SVG path draw
      if (path) {
        const length = path.getTotalLength();
        gsap.set(path, {
          strokeDasharray: length,
          strokeDashoffset: length,
        });
        gsap.to(path, {
          strokeDashoffset: 0,
          duration: 1.5,
          ease: 'power2.inOut',
        });
      }

      // Progress counter object
      const progressObj = { value: 0 };
      const tl = gsap.timeline({
        onComplete: () => {
          // Exit curtain animation
          gsap.to(content, {
            y: -25,
            opacity: 0,
            duration: 0.35,
            ease: 'power2.in',
          });

          gsap.to(container, {
            yPercent: -100,
            duration: 0.65,
            ease: 'power4.inOut',
            delay: 0.15,
            onComplete: () => {
              setIsDone(true);
              document.body.style.overflow = '';
              if (onFinish) onFinish();
            },
          });
        },
      });

      tl.to(progressObj, {
        value: 100,
        duration: 1.6,
        ease: 'power1.inOut',
        onUpdate: () => {
          const current = Math.round(progressObj.value);
          setProgress(current);

          if (bar) {
            bar.style.width = `${current}%`;
          }

          if (current < 35) {
            setStatusText('CONNECTING TO LIVE TICKERS...');
          } else if (current < 75) {
            setStatusText('CALIBRATING SPOTAI ENGINE...');
          } else {
            setStatusText('MARKET INTELLIGENCE READY');
          }
        },
      });
    },
    { scope: containerRef }
  );

  if (isDone) return null;

  return (
    <aside
      ref={containerRef}
      aria-label="Website loading screen"
      className="fixed inset-0 z-[99999] bg-[#040A07] flex flex-col items-center justify-center select-none overflow-hidden"
    >
      {/* Background radial ambient emerald glow */}
      <div className="absolute w-[600px] h-[600px] rounded-full bg-gradient-to-tr from-primary/15 via-accent/10 to-transparent blur-[120px] pointer-events-none" />

      {/* Subtle fine cyber grid overlay */}
      <div
        className="absolute inset-0 opacity-[0.03] pointer-events-none"
        style={{
          backgroundImage:
            'radial-gradient(rgba(16, 185, 129, 0.4) 1px, transparent 1px)',
          backgroundSize: '24px 24px',
        }}
      />

      <div
        ref={contentRef}
        className="relative z-10 flex flex-col items-center max-w-sm w-full px-6 text-center"
      >
        {/* Brand Icon Pod with Radar Rings */}
        <div className="relative mb-6 flex items-center justify-center">
          {/* Concentric pulsating radar rings */}
          <div className="absolute -inset-4 rounded-3xl border border-primary/20 animate-ping opacity-30" />
          <div className="absolute -inset-2 rounded-2xl border border-accent/30 animate-pulse" />

          {/* Logo Glass Card */}
          <div className="relative w-16 h-16 rounded-2xl bg-surface/90 border border-primary/50 shadow-[0_0_35px_rgba(16,185,129,0.35)] flex items-center justify-center backdrop-blur-xl p-2.5">
            <img
              src="/images/app_icon.png"
              alt="TheSpotMarket Logo"
              width="48"
              height="48"
              className="w-full h-full object-cover rounded-xl"
            />
          </div>
        </div>

        {/* Brand Title */}
        <div className="space-y-1 mb-5">
          <h1 className="text-xl sm:text-2xl font-extrabold tracking-heading text-white">
            TheSpot<span className="text-primary">Market</span>
          </h1>
          <p className="text-[10px] font-mono tracking-widest text-muted/70 uppercase">
            IPO & MARKET INTELLIGENCE
          </p>
        </div>

        {/* Live Market Heartbeat ECG / Trendline SVG */}
        <div className="w-48 h-8 mb-4 relative flex items-center justify-center">
          <svg
            viewBox="0 0 160 40"
            className="w-full h-full overflow-visible"
            fill="none"
            xmlns="http://www.w3.org/2000/svg"
          >
            {/* Background muted track */}
            <path
              d="M0 20 H30 L40 5 L55 35 L70 12 L85 24 L100 10 L115 28 L125 18 H160"
              stroke="rgba(255,255,255,0.08)"
              strokeWidth="2"
              strokeLinecap="round"
              strokeLinejoin="round"
            />
            {/* Active glowing emerald trend line */}
            <path
              ref={linePathRef}
              d="M0 20 H30 L40 5 L55 35 L70 12 L85 24 L100 10 L115 28 L125 18 H160"
              stroke="#10B981"
              strokeWidth="2.5"
              strokeLinecap="round"
              strokeLinejoin="round"
              style={{
                filter: 'drop-shadow(0 0 6px rgba(16, 185, 129, 0.8))',
              }}
            />
          </svg>
        </div>

        {/* Laser Progress Bar */}
        <div className="w-56 h-1 rounded-full bg-white/5 border border-white/10 overflow-hidden relative mb-3">
          <div
            ref={progressBarRef}
            className="h-full bg-gradient-to-r from-primary via-accent to-emerald-300 rounded-full transition-all duration-75 relative shadow-[0_0_12px_rgba(16,185,129,0.8)]"
            style={{ width: `${progress}%` }}
          >
            {/* Glowing moving beam at head */}
            <div className="absolute top-0 right-0 bottom-0 w-3 bg-white blur-[2px] opacity-80" />
          </div>
        </div>

        {/* Dynamic Status & Live Counter */}
        <div className="w-56 flex items-center justify-between text-[11px] font-mono text-muted/80">
          <span className="flex items-center gap-1.5 truncate max-w-[170px] text-left">
            <span className="w-1.5 h-1.5 rounded-full bg-accent animate-pulse" />
            <span className="tracking-tight text-[10px] text-text-subtle font-medium truncate">
              {statusText}
            </span>
          </span>
          <span className="font-bold text-accent font-mono shrink-0 pl-2">
            {progress}%
          </span>
        </div>
      </div>
    </aside>
  );
}

export default InitialPreloader;
