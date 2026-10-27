import gsap from 'gsap';
import { ScrollTrigger } from 'gsap/ScrollTrigger';
import { ScrollToPlugin } from 'gsap/ScrollToPlugin';
import { Draggable } from 'gsap/Draggable';

// Register ScrollTrigger, ScrollToPlugin and Draggable once globally
if (typeof window !== 'undefined') {
  gsap.registerPlugin(ScrollTrigger, ScrollToPlugin, Draggable);

  // Set default GSAP configuration
  gsap.config({
    nullTargetWarn: false,
    autoSleep: 60,
  });

  // Refresh ScrollTrigger once fonts are loaded to eliminate layout shifts & ensure pixel-perfect trigger offsets
  if (document.fonts && document.fonts.ready) {
    document.fonts.ready.then(() => {
      ScrollTrigger.refresh();
    });
  }

  window.addEventListener('load', () => {
    ScrollTrigger.refresh();
  });
}



/**
 * Helper to smoothly scroll to a section or offset with GSAP ScrollToPlugin
 * with fallback to native scroll.
 *
 * @param {string | Element | number} target - CSS selector, DOM node, or Y offset
 * @param {Object} [options]
 * @param {number} [options.offset=80] - Top offset (for sticky navbar)
 * @param {number} [options.duration=0.8] - Duration in seconds
 * @param {string} [options.ease='power2.out'] - Easing curve
 */
export function scrollToTarget(target, options = {}) {
  const { offset = 80, duration = 0.8, ease = 'power2.out' } = options;

  if (typeof window === 'undefined') return;

  let targetY = 0;

  if (typeof target === 'number') {
    targetY = Math.max(0, target - offset);
  } else if (typeof target === 'string') {
    const el = document.querySelector(target);
    if (!el) {
      console.warn(`[TheSpotMarket] scrollToTarget: target "${target}" not found.`);
      return;
    }
    const rect = el.getBoundingClientRect();
    targetY = Math.max(0, rect.top + window.pageYOffset - offset);
  } else if (target && typeof target.getBoundingClientRect === 'function') {
    const rect = target.getBoundingClientRect();
    targetY = Math.max(0, rect.top + window.pageYOffset - offset);
  } else {
    return;
  }

  // Check prefers-reduced-motion
  const prefersReduced = window.matchMedia('(prefers-reduced-motion: reduce)').matches;
  if (prefersReduced) {
    window.scrollTo({ top: targetY, behavior: 'instant' });
    return;
  }

  try {
    gsap.to(window, {
      duration,
      ease,
      scrollTo: {
        y: targetY,
        autoKill: false,
      },
      overwrite: 'auto',
    });
  } catch {
    // Fallback if ScrollToPlugin encounters issues
    window.scrollTo({ top: targetY, behavior: 'smooth' });
  }
}

export { gsap, ScrollTrigger, ScrollToPlugin, Draggable };
export default gsap;

