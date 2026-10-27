import { useGSAP } from '@gsap/react';
import { gsap } from '@/lib/gsap';

/**
 * Hook to animate a numeric count-up on scroll.
 * Respects prefers-reduced-motion and automatically cleans up via useGSAP.
 *
 * @param {import('react').RefObject} targetRef - Element ref where number will be rendered
 * @param {number} endValue - Target numeric value to count up to
 * @param {Object} [options={}] - Animation options
 * @param {number} [options.startValue=0] - Initial value to start counting from
 * @param {number} [options.duration=1.8] - Animation duration in seconds
 * @param {number} [options.decimals=0] - Number of decimal places
 * @param {string} [options.prefix=''] - Text before the number (e.g. '₹', '+')
 * @param {string} [options.suffix=''] - Text after the number (e.g. '+', '%', 'x')
 * @param {string} [options.start='top 85%'] - ScrollTrigger start position
 * @param {string} [options.ease='power2.out'] - Easing curve
 */
export function useCounter(targetRef, endValue, options = {}) {
  const {
    startValue = 0,
    duration = 1.8,
    decimals = 0,
    prefix = '',
    suffix = '',
    start = 'top 85%',
    ease = 'power2.out',
  } = options;

  useGSAP(
    () => {
      const element = targetRef?.current;
      if (!element || typeof endValue !== 'number') return;

      const formatNumber = (val) => {
        const rounded = val.toFixed(decimals);
        // Format with comma separators for integer parts
        const parts = rounded.split('.');
        parts[0] = parts[0].replace(/\B(?=(\d{3})+(?!\d))/g, ',');
        return `${prefix}${parts.join('.')}${suffix}`;
      };

      const mm = gsap.matchMedia();

      mm.add('(prefers-reduced-motion: no-preference)', () => {
        const counterObj = { value: startValue };
        element.textContent = formatNumber(startValue);

        gsap.to(counterObj, {
          value: endValue,
          duration,
          ease,
          scrollTrigger: {
            trigger: element,
            start,
            toggleActions: 'play none none none',
          },
          onUpdate: () => {
            element.textContent = formatNumber(counterObj.value);
          },
        });
      });

      mm.add('(prefers-reduced-motion: reduce)', () => {
        element.textContent = formatNumber(endValue);
      });

      return () => mm.revert();
    },
    {
      scope: targetRef,
      dependencies: [endValue, startValue, duration, decimals, prefix, suffix, start, ease],
    }
  );
}

export default useCounter;
