import React, { useRef } from 'react';
import { Outlet, useLocation } from 'react-router-dom';
import { useGSAP } from '@gsap/react';
import { gsap } from '@/lib/gsap';
import SEO from './SEO';
import SkipToContent from './SkipToContent';
import ScrollToTop from './ScrollToTop';
import Navbar from './Navbar';
import Footer from './Footer';
import FloatingSpotAiButton from './FloatingSpotAiButton';

/**
 * Main application Layout shell.
 * Integrates:
 * - Default SEO (react-helmet-async)
 * - Accessible skip-to-content navigation
 * - ScrollToTop route listener
 * - Sticky responsive Navbar
 * - Page transition fade via GSAP on route change
 * - Floating SpotAI liquid-glass button
 * - 4-column regulatory compliant Footer
 */
export function MainLayout() {
  const location = useLocation();
  const mainRef = useRef(null);

  // GSAP Page Transition Fade on location.pathname change
  useGSAP(
    () => {
      const mainEl = mainRef.current;
      if (!mainEl) return;

      const mm = gsap.matchMedia();

      mm.add('(prefers-reduced-motion: no-preference)', () => {
        gsap.fromTo(
          mainEl,
          {
            opacity: 0.7,
            y: 8,
          },
          {
            opacity: 1,
            y: 0,
            duration: 0.25,
            ease: 'power2.out',
            clearProps: 'all',
          }
        );
      });

      mm.add('(prefers-reduced-motion: reduce)', () => {
        gsap.set(mainEl, { clearProps: 'all' });
      });

      return () => {
        gsap.set(mainEl, { clearProps: 'all' });
      };
    },
    { scope: mainRef, dependencies: [location.pathname] }
  );

  return (
    <div className="min-h-screen flex flex-col bg-background text-text antialiased selection:bg-primary/20 selection:text-white relative">
      <SEO />
      <SkipToContent />
      <ScrollToTop />

      <Navbar />

      <main
        id="main-content"
        ref={mainRef}
        tabIndex="-1"
        className="flex-1 focus:outline-none"
      >
        <Outlet />
      </main>

      <FloatingSpotAiButton />

      <Footer />
    </div>
  );
}

export default MainLayout;
