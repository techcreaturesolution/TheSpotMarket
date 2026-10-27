import { useGSAP } from '@gsap/react';
import { gsap } from '@/lib/gsap';

/**
 * Hook to reveal child elements inside a container with a staggered fade & rise animation.
 * Respects prefers-reduced-motion and automatically cleans up via useGSAP.
 *
 * @param {import('react').RefObject} containerRef - Container ref whose children are targeted
 * @param {string} [selector=':scope > *'] - CSS selector for children (supports relative selectors like '> *' or ':scope > div')
 * @param {Object} [options={}] - Animation options
 * @param {number} [options.stagger=0.08] - Delay between each element in seconds
 * @param {number} [options.delay=0] - Initial delay in seconds
 * @param {number} [options.duration=0.6] - Duration per element in seconds
 * @param {number} [options.distance=24] - Initial translateY offset in px
 * @param {string} [options.start='top 85%'] - ScrollTrigger start position
 * @param {string} [options.ease='power3.out'] - Easing curve
 */
export function useStagger(containerRef, selector = ':scope > *', options = {}) {
  const {
    stagger = 0.08,
    delay = 0,
    duration = 0.6,
    distance = 24,
    start = 'top 85%',
    ease = 'power3.out',
  } = options;

  useGSAP(
    () => {
      const container = containerRef?.current;
      if (!container) return;

      let items = [];
      try {
        const trimmed = selector ? selector.trim() : ':scope > *';
        // Normalize relative selectors like '> div' or '> *' by prepending :scope
        const normalized = trimmed.startsWith('>') ? `:scope ${trimmed}` : trimmed;
        items = Array.from(container.querySelectorAll(normalized));
      } catch {
        // Safe fallback to direct children
        items = Array.from(container.children || []);
      }

      if (!items || items.length === 0) return;

      const mm = gsap.matchMedia();

      mm.add('(prefers-reduced-motion: no-preference)', () => {
        gsap.fromTo(
          items,
          {
            opacity: 0,
            y: distance,
          },
          {
            opacity: 1,
            y: 0,
            duration,
            stagger,
            delay,
            ease,
            scrollTrigger: {
              trigger: container,
              start,
              toggleActions: 'play none none none',
            },
          }
        );
      });

      mm.add('(prefers-reduced-motion: reduce)', () => {
        gsap.set(items, { opacity: 1, y: 0 });
      });

      return () => mm.revert();
    },
    {
      scope: containerRef,
      dependencies: [selector, stagger, delay, duration, distance, start, ease],
    }
  );
}

export default useStagger;
