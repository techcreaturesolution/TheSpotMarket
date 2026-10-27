import React, { useRef } from 'react';
import { useGSAP } from '@gsap/react';
import gsap from 'gsap';
import { Smartphone, Layers, Sparkles, CheckCircle2, ArrowRight } from 'lucide-react';
import { Container } from '@/components/ui/Container';
import { SectionHeading } from '@/components/ui/SectionHeading';
import { GradientText } from '@/components/ui/GradientText';
import { Badge } from '@/components/ui/Badge';
import { howItWorksSteps } from '@/data';

const stepIcons = {
  Smartphone,
  Layers,
  Sparkles,
};

export function HowItWorksSection() {
  const containerRef = useRef(null);
  const linePathRef = useRef(null);
  const mobileLineRef = useRef(null);
  const stepRefs = useRef([]);

  useGSAP(
    () => {
      const prefersReduced = window.matchMedia('(prefers-reduced-motion: reduce)').matches;
      if (prefersReduced) return;

      // 1. Desktop SVG Path Scroll-Scrub
      if (linePathRef.current) {
        const pathLength = linePathRef.current.getTotalLength?.() || 600;
        gsap.set(linePathRef.current, {
          strokeDasharray: pathLength,
          strokeDashoffset: pathLength,
        });

        gsap.to(linePathRef.current, {
          strokeDashoffset: 0,
          ease: 'none',
          scrollTrigger: {
            trigger: containerRef.current,
            start: 'top 70%',
            end: 'bottom 80%',
            scrub: 0.8,
          },
        });
      }

      // 2. Mobile vertical line scrub
      if (mobileLineRef.current) {
        gsap.fromTo(
          mobileLineRef.current,
          { scaleY: 0 },
          {
            scaleY: 1,
            transformOrigin: 'top center',
            ease: 'none',
            scrollTrigger: {
              trigger: containerRef.current,
              start: 'top 75%',
              end: 'bottom 80%',
              scrub: 0.8,
            },
          }
        );
      }

      // 3. Sequential Highlight for Step Cards
      stepRefs.current.forEach((el, index) => {
        if (!el) return;

        gsap.fromTo(
          el,
          { opacity: 0.45, y: 30, scale: 0.96 },
          {
            opacity: 1,
            y: 0,
            scale: 1,
            duration: 0.6,
            ease: 'power2.out',
            scrollTrigger: {
              trigger: el,
              start: 'top 82%',
              end: 'top 50%',
              toggleActions: 'play none none reverse',
            },
          }
        );
      });
    },
    { scope: containerRef }
  );

  return (
    <section id="how-it-works" ref={containerRef} className="scroll-mt-24 py-6 sm:py-10 relative overflow-hidden">
      {/* Background glow disc */}
      <div className="absolute top-1/3 left-1/2 -translate-x-1/2 w-[600px] h-[350px] bg-primary/8 rounded-full blur-[140px] pointer-events-none -z-10" />

      <Container>
        <div className="text-center max-w-3xl mx-auto mb-8 sm:mb-10">
          <SectionHeading
            badge="Simple 3-Step Flow"
            title={
              <>
                How TheSpotMarket Gives You{' '}
                <GradientText variant="emerald">The Listing Edge</GradientText>
              </>
            }
            subtitle="From raw SEBI filings and grey market chatter to clear, actionable conviction on your phone in under 60 seconds."
          />
        </div>

        {/* Desktop Container with SVG Connecting Path */}
        <div className="relative">
          {/* Desktop SVG Line (hidden on small screens, drawn on scroll) */}
          <div className="hidden lg:block absolute top-[72px] left-[15%] right-[15%] h-8 pointer-events-none z-0">
            <svg className="w-full h-full overflow-visible" preserveAspectRatio="none" viewBox="0 0 700 24">
              {/* Background faint guideline */}
              <line
                x1="0"
                y1="12"
                x2="700"
                y2="12"
                stroke="#1B2F23"
                strokeWidth="3"
                strokeDasharray="6 6"
              />
              {/* Animated GSAP Scrubbed Stroke */}
              <line
                ref={linePathRef}
                x1="0"
                y1="12"
                x2="700"
                y2="12"
                stroke="#10B981"
                strokeWidth="3"
                strokeLinecap="round"
              />
            </svg>
          </div>

          {/* Mobile vertical guideline (drawn down on scroll) */}
          <div className="lg:hidden absolute top-8 bottom-8 left-[35px] w-[3px] bg-[#1B2F23] pointer-events-none">
            <div
              ref={mobileLineRef}
              className="w-full h-full bg-gradient-to-b from-primary via-accent to-primary"
            />
          </div>

          {/* 3 Step Cards */}
          <div className="grid grid-cols-1 lg:grid-cols-3 gap-8 sm:gap-10 relative z-10">
            {howItWorksSteps.map((item, index) => {
              const IconComp = stepIcons[item.iconName] || Sparkles;

              return (
                <div
                  key={item.step}
                  ref={(el) => (stepRefs.current[index] = el)}
                  className="relative flex flex-col items-start lg:items-center text-left lg:text-center pl-16 lg:pl-0"
                >
                  {/* Step Number Circle Indicator */}
                  <div className="relative mb-6">
                    <div className="w-16 h-16 rounded-2xl bg-surface-2 border-2 border-primary/30 shadow-[0_0_25px_rgba(16,185,129,0.2)] flex items-center justify-center text-primary transition-all duration-300">
                      <IconComp className="w-7 h-7 text-accent" />
                    </div>
                    {/* Step number badge */}
                    <div className="absolute -top-2.5 -right-2.5 w-7 h-7 rounded-full bg-primary text-black font-extrabold text-xs flex items-center justify-center shadow-md">
                      {item.step}
                    </div>
                  </div>

                  {/* Step Card Content */}
                  <div className="w-full rounded-2xl bg-gradient-to-b from-surface to-surface-2 p-6 sm:p-7 border border-surface-border shadow-lg hover:border-primary/40 transition-colors">
                    <div className="inline-block mb-2">
                      <Badge variant="primary" size="sm">
                        {item.subtitle}
                      </Badge>
                    </div>

                    <h3 className="text-xl font-bold text-text-primary tracking-tight mb-2.5">
                      {item.title}
                    </h3>

                    <p className="text-sm text-text-secondary leading-relaxed mb-4">
                      {item.description}
                    </p>

                    <div className="pt-3 border-t border-surface-border/60 flex items-center justify-between text-xs font-semibold text-accent">
                      <span className="flex items-center gap-1.5">
                        <CheckCircle2 className="w-3.5 h-3.5 text-bull" />
                        {item.highlight}
                      </span>
                      {index < 2 && (
                        <ArrowRight className="hidden lg:inline w-4 h-4 text-text-muted/60" />
                      )}
                    </div>
                  </div>
                </div>
              );
            })}
          </div>
        </div>
      </Container>
    </section>
  );
}

export default HowItWorksSection;
