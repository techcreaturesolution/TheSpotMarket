import { useEffect } from 'react';
import { useLocation } from 'react-router-dom';
import { scrollToTarget } from '@/lib/gsap';

/**
 * Handles scroll behavior on client-side routing:
 * 1. On route change without hash: instantly scrolls to the top of the new page (0, 0).
 * 2. On hash navigation (e.g. #features, #how-it-works, #faq): scrolls smoothly to the target element.
 */
export function ScrollToTop() {
  const { pathname, hash } = useLocation();

  useEffect(() => {
    if ('scrollRestoration' in window.history) {
      window.history.scrollRestoration = 'manual';
    }
  }, []);

  // Handle route changes & hash navigation
  useEffect(() => {
    if (hash) {
      // Scroll to specific hash target with retries if page just mounted
      const scrollIfFound = () => {
        const el = document.querySelector(hash);
        if (el) {
          scrollToTarget(hash, { offset: 80 });
          return true;
        }
        return false;
      };

      if (!scrollIfFound()) {
        const t1 = setTimeout(scrollIfFound, 100);
        const t2 = setTimeout(scrollIfFound, 300);
        return () => {
          clearTimeout(t1);
          clearTimeout(t2);
        };
      }
    } else {
      // Navigating to a new page without hash: ALWAYS start at the very top (0, 0)
      window.scrollTo({
        top: 0,
        left: 0,
        behavior: 'instant',
      });
      document.documentElement.scrollTop = 0;
      document.body.scrollTop = 0;

      // Double-check on next frame in case of layout shifts during mount
      const raf = requestAnimationFrame(() => {
        window.scrollTo({
          top: 0,
          left: 0,
          behavior: 'instant',
        });
      });

      return () => cancelAnimationFrame(raf);
    }
  }, [pathname, hash]);

  return null;
}

export default ScrollToTop;
