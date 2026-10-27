import React, { useRef } from 'react';
import { useGSAP } from '@gsap/react';
import gsap from 'gsap';
import { Layers, Zap, Bot, ShieldCheck, CheckCircle2, Sparkles, ArrowRight } from 'lucide-react';
import { Container } from '@/components/ui/Container';
import { SectionHeading } from '@/components/ui/SectionHeading';
import { GradientText } from '@/components/ui/GradientText';
import { Badge } from '@/components/ui/Badge';
import { whySpotMarketBenefits } from '@/data';

const benefitIcons = {
  Layers,
  Zap,
  Bot,
  ShieldCheck,
};

function BenefitCard({ benefit, index }) {
  const cardRef = useRef(null);
  const glowRef = useRef(null);
  const IconComp = benefitIcons[benefit.iconName] || Sparkles;

  useGSAP(
    () => {
      const card = cardRef.current;
      const glow = glowRef.current;
      if (!card) return;

      const isTouch = 'ontouchstart' in window || navigator.maxTouchPoints > 0;
      const prefersReduced = window.matchMedia('(prefers-reduced-motion: reduce)').matches;
      if (isTouch || prefersReduced) return;

      const quickLift = gsap.quickTo(card, 'y', { duration: 0.35, ease: 'power2.out' });
      const quickGlowX = glow ? gsap.quickTo(glow, 'x', { duration: 0.25, ease: 'power1.out' }) : null;
      const quickGlowY = glow ? gsap.quickTo(glow, 'y', { duration: 0.25, ease: 'power1.out' }) : null;

      const handleMouseMove = (e) => {
        const rect = card.getBoundingClientRect();
        const px = e.clientX - rect.left;
        const py = e.clientY - rect.top;
        quickLift(-5);
        if (glow && quickGlowX && quickGlowY) {
          quickGlowX(px);
          quickGlowY(py);
        }
      };

      const handleMouseEnter = () => {
        if (glow) gsap.to(glow, { opacity: 0.15, duration: 0.3 });
      };

      const handleMouseLeave = () => {
        quickLift(0);
        if (glow) gsap.to(glow, { opacity: 0, duration: 0.4 });
      };

      card.addEventListener('mousemove', handleMouseMove, { passive: true });
      card.addEventListener('mouseenter', handleMouseEnter);
      card.addEventListener('mouseleave', handleMouseLeave);

      return () => {
        card.removeEventListener('mousemove', handleMouseMove);
        card.removeEventListener('mouseenter', handleMouseEnter);
        card.removeEventListener('mouseleave', handleMouseLeave);
      };
    },
    { scope: cardRef }
  );

  return (
    <div
      ref={cardRef}
      className="why-benefit-card group relative rounded-3xl bg-gradient-to-b from-surface to-surface-2 p-7 sm:p-8 border border-surface-border transition-colors hover:border-primary/50 shadow-xl overflow-hidden will-change-transform"
    >
      {/* Interactive cursor glow */}
      <div
        ref={glowRef}
        className="pointer-events-none absolute -top-24 -left-24 w-52 h-52 rounded-full bg-primary blur-3xl opacity-0"
        style={{ transform: 'translate3d(0, 0, 0)' }}
      />

      <div className="flex items-start justify-between gap-4 mb-6">
        <div className="w-14 h-14 rounded-2xl bg-primary/10 border border-primary/25 flex items-center justify-center text-primary group-hover:scale-105 group-hover:bg-primary/20 transition-all duration-300">
          <IconComp className="w-7 h-7 text-accent" />
        </div>
        <Badge variant="primary" size="sm" className="font-semibold tracking-wide">
          {benefit.badge}
        </Badge>
      </div>

      <h3 className="text-xl sm:text-2xl font-bold text-text-primary tracking-tight mb-3 group-hover:text-accent transition-colors">
        {benefit.title}
      </h3>

      <p className="text-sm sm:text-base text-text-secondary leading-relaxed mb-6">
        {benefit.description}
      </p>

      <div className="pt-4 border-t border-surface-border/70 flex items-center gap-2 text-xs font-semibold text-accent">
        <CheckCircle2 className="w-4 h-4 text-bull shrink-0" />
        <span>{benefit.highlight}</span>
      </div>
    </div>
  );
}

export function WhySpotMarketSection() {
  const containerRef = useRef(null);

  useGSAP(
    () => {
      const prefersReduced = window.matchMedia('(prefers-reduced-motion: reduce)').matches;
      if (prefersReduced) return;

      gsap.from('.why-benefit-card', {
        scrollTrigger: {
          trigger: containerRef.current,
          start: 'top 80%',
          toggleActions: 'play none none none',
        },
        y: 40,
        opacity: 0,
        stagger: 0.12,
        duration: 0.8,
        ease: 'power3.out',
      });
    },
    { scope: containerRef }
  );

  return (
    <section ref={containerRef} className="py-6 sm:py-10 relative overflow-hidden">
      {/* Ambient background glow */}
      <div className="absolute top-1/2 left-1/4 -translate-y-1/2 w-[650px] h-[450px] bg-primary/6 rounded-full blur-[160px] pointer-events-none -z-10" />

      <Container>
        <div className="text-center max-w-3xl mx-auto mb-8 sm:mb-10">
          <SectionHeading
            badge="The SpotMarket Advantage"
            title={
              <>
                Why Indian Investors Choose{' '}
                <GradientText variant="emerald">TheSpotMarket</GradientText>
              </>
            }
            subtitle="Built from the ground up for speed, security, and institutional clarity — without selling your data or cluttering your workflow."
          />
        </div>

        {/* 4 Benefits 2x2 Grid */}
        <div className="grid grid-cols-1 md:grid-cols-2 gap-6 sm:gap-8">
          {whySpotMarketBenefits.map((benefit, index) => (
            <BenefitCard key={benefit.id} benefit={benefit} index={index} />
          ))}
        </div>
      </Container>
    </section>
  );
}

export default WhySpotMarketSection;
