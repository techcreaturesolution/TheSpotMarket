import React, { useRef } from 'react';
import { ArrowRight, Sparkles, ChevronDown } from 'lucide-react';
import { useGSAP } from '@gsap/react';
import { gsap, scrollToTarget } from '@/lib/gsap';
import { Container } from '@/components/ui/Container';
import { Button } from '@/components/ui/Button';
import { Badge } from '@/components/ui/Badge';
import { GradientText } from '@/components/ui/GradientText';
import { PhoneMockup } from './PhoneMockup';
import { siteConfig } from '@/lib/site';

/**
 * SplitText-like helper component to split string words into individual animated span nodes.
 */
function SplitWords({ text, className = '' }) {
  const words = text.split(' ');
  return (
    <>
      {words.map((word, index) => (
        <span
          key={`${word}-${index}`}
          className="inline-block overflow-hidden mr-[0.24em] last:mr-0 align-top"
        >
          <span className={`inline-block split-word will-change-transform ${className}`}>
            {word}
          </span>
        </span>
      ))}
    </>
  );
}

/**
 * Hero Section:
 * - Staggered headline word reveal
 * - Subtext, App Store CTAs, See Features button
 * - CSS phone mockup with drawn SVG line chart & floating cards
 * - Mouse parallax tilt via gsap.quickTo
 * - Layered emerald radial glows & faint grid
 */
export function HeroSection() {
  const sectionRef = useRef(null);
  const headlineWordsRef = useRef(null);
  const subtextRef = useRef(null);
  const ctaButtonsRef = useRef(null);
  const phoneWrapperRef = useRef(null);
  const phoneMockupRef = useRef(null);

  // 1. GSAP Intro Timeline (Headline words, subtext, CTAs, phone entrance)
  useGSAP(
    () => {
      const section = sectionRef.current;
      if (!section) return;

      const mm = gsap.matchMedia();

      mm.add('(prefers-reduced-motion: no-preference)', () => {
        const words = headlineWordsRef.current?.querySelectorAll('.split-word');
        const subtext = subtextRef.current;
        const ctas = ctaButtonsRef.current?.children;
        const phone = phoneWrapperRef.current;

        const tl = gsap.timeline({
          defaults: { ease: 'power3.out' },
          onComplete: () => {
            // Trigger chart stroke drawing on phone
            phoneMockupRef.current?.animateChart();
          },
        });

        // 1. Headline words reveal with stagger from beneath
        if (words && words.length > 0) {
          tl.fromTo(
            words,
            { yPercent: 115, opacity: 0, rotateZ: 2 },
            { yPercent: 0, opacity: 1, rotateZ: 0, duration: 0.7, stagger: 0.05 }
          );
        }

        // 2. Subtext fade & rise
        if (subtext) {
          tl.fromTo(
            subtext,
            { opacity: 0, y: 22 },
            { opacity: 1, y: 0, duration: 0.55 },
            '-=0.3'
          );
        }

        // 3. CTA Buttons pop-in
        if (ctas && ctas.length > 0) {
          tl.fromTo(
            ctas,
            { opacity: 0, y: 16, scale: 0.95 },
            { opacity: 1, y: 0, scale: 1, duration: 0.5, stagger: 0.08 },
            '-=0.3'
          );
        }

        // 4. Phone mockup slides & rotates in
        if (phone) {
          tl.fromTo(
            phone,
            { opacity: 0, x: 60, rotationY: -15, scale: 0.95 },
            { opacity: 1, x: 0, rotationY: 0, scale: 1, duration: 1.1, ease: 'power2.out' },
            '-=0.7'
          );

          // Pop in floating cards around phone
          const floatCards = phoneMockupRef.current?.getFloatCards();
          if (floatCards && floatCards.length > 0) {
            tl.fromTo(
              floatCards,
              { opacity: 0, scale: 0.75, y: 15 },
              { opacity: 1, scale: 1, y: 0, duration: 0.6, stagger: 0.1, ease: 'back.out(1.5)' },
              '-=0.5'
            );
          }
        }
      });

      mm.add('(prefers-reduced-motion: reduce)', () => {
        // Immediate static layout for accessibility
        gsap.set(
          [
            headlineWordsRef.current?.querySelectorAll('.split-word'),
            subtextRef.current,
            ctaButtonsRef.current?.children,
            phoneWrapperRef.current,
          ],
          { opacity: 1, yPercent: 0, y: 0, x: 0, rotationY: 0, scale: 1 }
        );
      });

      return () => mm.revert();
    },
    { scope: sectionRef }
  );

  // 2. Subtle Mouse Parallax using gsap.quickTo (disabled on touch & reduced motion)
  useGSAP(
    () => {
      const section = sectionRef.current;
      const tiltEl = phoneMockupRef.current?.getTiltElement();

      if (!section || !tiltEl) return;

      // Check for touch device or reduced motion
      const isTouch = window.matchMedia('(pointer: coarse)').matches;
      const isReduced = window.matchMedia('(prefers-reduced-motion: reduce)').matches;
      if (isTouch || isReduced) return;

      // quickTo setters for high-performance 60fps tilt
      const setRotY = gsap.quickTo(tiltEl, 'rotationY', { duration: 0.8, ease: 'power2.out' });
      const setRotX = gsap.quickTo(tiltEl, 'rotationX', { duration: 0.8, ease: 'power2.out' });
      const setX = gsap.quickTo(tiltEl, 'x', { duration: 0.8, ease: 'power2.out' });
      const setY = gsap.quickTo(tiltEl, 'y', { duration: 0.8, ease: 'power2.out' });

      const handlePointerMove = (e) => {
        const rect = section.getBoundingClientRect();
        // Normalized coordinates from -1 to 1 centered on section
        const normX = ((e.clientX - rect.left) / rect.width) * 2 - 1;
        const normY = ((e.clientY - rect.top) / rect.height) * 2 - 1;

        // Subtle 3D rotation (max +/- 7 degrees) and slight translation (+/- 8px)
        setRotY(normX * 8);
        setRotX(-normY * 8);
        setX(normX * 10);
        setY(normY * 10);
      };

      const handlePointerLeave = () => {
        setRotY(0);
        setRotX(0);
        setX(0);
        setY(0);
      };

      section.addEventListener('pointermove', handlePointerMove);
      section.addEventListener('pointerleave', handlePointerLeave);

      return () => {
        section.removeEventListener('pointermove', handlePointerMove);
        section.removeEventListener('pointerleave', handlePointerLeave);
      };
    },
    { scope: sectionRef }
  );

  return (
    <section
      ref={sectionRef}
      className="relative overflow-hidden flex-1 flex items-center py-4 sm:py-6 lg:py-4 xl:py-8 bg-hero-atmosphere bg-grid-faint"
    >
      <Container className="w-full">
        <div className="grid grid-cols-1 lg:grid-cols-12 gap-8 lg:gap-6 xl:gap-8 items-center">
          {/* Left Column: Hero Content & CTAs (7 columns on lg) */}
          <div className="lg:col-span-7 space-y-4 sm:space-y-5 text-left z-10">
            {/* Live Indicator Pill */}
            <div className="inline-flex items-center gap-2">
              <Badge variant="live" size="sm" pulse>
                Indian IPO & Market Intelligence
              </Badge>
              <span className="hidden sm:inline-block text-[11px] text-subtle font-mono">
                Real-Time NSE / BSE Feeds
              </span>
            </div>

            {/* Headline with Staggered Word Splitting */}
            <h1
              ref={headlineWordsRef}
              className="text-3xl sm:text-5xl lg:text-[42px] xl:text-6xl font-extrabold text-white tracking-heading leading-[1.08]"
            >
              <span className="block">
                <SplitWords text="Every IPO." />
              </span>
              <span className="block">
                <SplitWords text="Every Market." />
              </span>
              <span className="block mt-0.5 sm:mt-1">
                <GradientText variant="emerald" as="span">
                  <SplitWords text="One Smart App." />
                </GradientText>
              </span>
            </h1>

            {/* Subtext */}
            <p
              ref={subtextRef}
              className="text-sm sm:text-base text-muted font-normal max-w-xl leading-relaxed"
            >
              Track real-time Indian & global IPO subscriptions, live Grey Market Premium (GMP) shifts, registrar allotment statuses, and AI financial summaries in one high-performance mobile app.
            </p>

            {/* CTAs Button Row */}
            <div
              ref={ctaButtonsRef}
              className="flex flex-wrap items-center gap-3 pt-1"
            >
              {/* Google Play Store CTA */}
              <Button
                href={siteConfig.links.playStore}
                variant="primary"
                size="md"
                icon={
                  <svg className="h-4 w-4 fill-current" viewBox="0 0 24 24">
                    <path d="M3.609 1.814L13.792 12 3.61 22.186a2.274 2.274 0 01-.61-.918V2.732c.16-.363.376-.684.61-.918zM15.207 13.414l2.583 2.583-11.45 6.55 8.867-9.133zm0-2.828L6.34 1.453l11.45 6.55-2.583 2.583zm1.414 1.414l3.664-2.096c1.19-.68 1.19-1.79 0-2.47L16.621 12z" />
                  </svg>
                }
                className="font-bold shadow-btn-glow"
              >
                Download on Play Store
              </Button>

            </div>

            {/* Trust badge */}
            <div className="flex items-center gap-2 pt-1 text-xs text-subtle">
              <span className="flex h-1.5 w-1.5 rounded-full bg-accent" />
              <span>Free to download • Direct mobile sync • Zero registration barrier</span>
            </div>
          </div>

          {/* Right Column: 3D Phone Mockup (5 columns on lg) */}
          <div
            ref={phoneWrapperRef}
            className="lg:col-span-5 flex justify-center lg:justify-end z-20"
          >
            <PhoneMockup ref={phoneMockupRef} />
          </div>
        </div>
      </Container>
    </section>
  );
}

export default HeroSection;
