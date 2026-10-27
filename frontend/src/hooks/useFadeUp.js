import { useGSAP } from '@gsap/react';
import { gsap } from '@/lib/gsap';

/**
 * Hook to fade and translate up an element when it scrolls into view.
 * Respects prefers-reduced-motion and automatically cleans up via useGSAP.
 *
 * @param {import('react').RefObject} targetRef - Element ref to animate
 * @param {Object} options - Animation options
 * @param {number} [options.delay=0] - Delay in seconds
 * @param {number} [options.duration=0.8] - Duration in seconds
 * @param {number} [options.distance=36] - Initial translateY offset in px
 * @param {string} [options.start='top 85%'] - ScrollTrigger start position
 * @param {string} [options.ease='power3.out'] - Easing curve
 */
export function useFadeUp(targetRef, options = {}) {
  const {
    delay = 0,
    duration = 0.8,
    distance = 36,
    start = 'top 85%',
    ease = 'power3.out',
  } = options;

  useGSAP(
    () => {
      const element = targetRef?.current;
      if (!element) return;

      const mm = gsap.matchMedia();

      // Normal animation when reduced motion is NOT requested
      mm.add('(prefers-reduced-motion: no-preference)', () => {
        gsap.fromTo(
          element,
          {
            opacity: 0,
            y: distance,
          },
          {
            opacity: 1,
            y: 0,
            duration,
            delay,
            ease,
            scrollTrigger: {
              trigger: element,
              start,
              toggleActions: 'play none none none',
            },
          }
        );
      });

      // Accessible fallback: instantly display without motion
      mm.add('(prefers-reduced-motion: reduce)', () => {
        gsap.set(element, { opacity: 1, y: 0 });
      });

      return () => mm.revert();
    },
    { scope: targetRef, dependencies: [delay, duration, distance, start, ease] }
  );
}

export default useFadeUp;
