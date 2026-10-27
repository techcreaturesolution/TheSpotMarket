import React, { useRef } from 'react';
import { useLocation, useNavigate } from 'react-router-dom';
import { Sparkles } from 'lucide-react';
import { useGSAP } from '@gsap/react';
import { gsap, scrollToTarget } from '@/lib/gsap';

/**
 * Floating "SpotAI" liquid-glass button.
 * Features:
 * - Fixed at bottom-right viewport
 * - Scrolls smoothly to #spotai on home page, or navigates to /#spotai
 * - Continuous gentle GSAP floating and breathing pulse loop
 * - Respects prefers-reduced-motion
 */
export function FloatingSpotAiButton() {
  const buttonRef = useRef(null);
  const location = useLocation();
  const navigate = useNavigate();

  // Gentle GSAP idle float and glow pulse loop
  useGSAP(
    () => {
      const button = buttonRef.current;
      if (!button) return;

      const mm = gsap.matchMedia();

      mm.add('(prefers-reduced-motion: no-preference)', () => {
        // Idle vertical float
        gsap.to(button, {
          y: -7,
          duration: 2.4,
          repeat: -1,
          yoyo: true,
          ease: 'sine.inOut',
        });

        // Glowing pulse
        gsap.to(button, {
          boxShadow: '0 0 30px -4px rgba(16, 185, 129, 0.55), 0 0 15px rgba(52, 211, 153, 0.35)',
          duration: 1.8,
          repeat: -1,
          yoyo: true,
          ease: 'sine.inOut',
        });
      });

      return () => mm.revert();
    },
    { scope: buttonRef }
  );

  const handleClick = (e) => {
    e.preventDefault();

    if (location.pathname === '/') {
      scrollToTarget('#spotai', { offset: 80, duration: 1 });
    } else {
      navigate('/#spotai');
      // Timeout to allow DOM mount after navigation
      setTimeout(() => {
        scrollToTarget('#spotai', { offset: 80, duration: 1 });
      }, 150);
    }
  };

  return (
    <button
      ref={buttonRef}
      type="button"
      onClick={handleClick}
      aria-label="Scroll to SpotAI Intelligence"
      className="fixed bottom-6 right-6 md:bottom-8 md:right-8 z-40 group flex items-center gap-2.5 px-4 py-3 rounded-full bg-surface/80 hover:bg-surface-2 backdrop-blur-xl border border-primary/40 hover:border-accent text-white font-semibold text-sm shadow-card-glow transition-all duration-300 active:scale-95 focus-visible:ring-2 focus-visible:ring-accent focus-visible:outline-none"
    >
      <div className="relative flex items-center justify-center h-7 w-7 rounded-full bg-primary/20 border border-primary/50 text-accent group-hover:scale-110 transition-transform duration-300">
        <Sparkles className="h-4 w-4 animate-pulse text-accent" />
        <span className="absolute -top-0.5 -right-0.5 h-2 w-2 rounded-full bg-accent animate-ping opacity-75" />
      </div>

      <div className="flex flex-col text-left leading-tight">
        <span className="text-xs font-extrabold tracking-heading text-white group-hover:text-accent transition-colors">
          SpotAI
        </span>
        <span className="text-[10px] text-muted font-normal">Ask Intelligence</span>
      </div>
    </button>
  );
}

export default FloatingSpotAiButton;
