import React, { useRef } from 'react';
import { useGSAP } from '@gsap/react';
import gsap from 'gsap';
import {
  TrendingUp,
  Activity,
  Globe2,
  Newspaper,
  FileCheck2,
  Target,
  Bot,
  ShieldCheck,
  Sparkles,
} from 'lucide-react';
import { Container } from '@/components/ui/Container';
import { SectionHeading } from '@/components/ui/SectionHeading';
import { GradientText } from '@/components/ui/GradientText';
import { Badge } from '@/components/ui/Badge';
import { homeFeatures } from '@/data';

const iconMap = {
  TrendingUp,
  Activity,
  Globe2,
  Newspaper,
  FileCheck2,
  Target,
  Bot,
  ShieldCheck,
};

function FeatureCard({ feature, index }) {
  const cardRef = useRef(null);
  const glowRef = useRef(null);
  const IconComponent = iconMap[feature.iconName] || Sparkles;

  useGSAP(
    () => {
      const card = cardRef.current;
      const glow = glowRef.current;
      if (!card) return;

      const isTouch = 'ontouchstart' in window || navigator.maxTouchPoints > 0;
      const prefersReduced = window.matchMedia('(prefers-reduced-motion: reduce)').matches;
      if (isTouch || prefersReduced) return;

      // GSAP quickTo for silky 60fps lift & micro-tilt without GC spikes
      const quickLift = gsap.quickTo(card, 'y', { duration: 0.35, ease: 'power2.out' });
      const quickRotX = gsap.quickTo(card, 'rotationX', { duration: 0.4, ease: 'power2.out' });
      const quickRotY = gsap.quickTo(card, 'rotationY', { duration: 0.4, ease: 'power2.out' });
      const quickGlowX = glow ? gsap.quickTo(glow, 'x', { duration: 0.25, ease: 'power1.out' }) : null;
      const quickGlowY = glow ? gsap.quickTo(glow, 'y', { duration: 0.25, ease: 'power1.out' }) : null;

      const handleMouseMove = (e) => {
        const rect = card.getBoundingClientRect();
        const px = e.clientX - rect.left;
        const py = e.clientY - rect.top;
        const nx = (px / rect.width - 0.5) * 2;
        const ny = (py / rect.height - 0.5) * 2;

        quickLift(-6);
        quickRotX(-ny * 4);
        quickRotY(nx * 5);

        if (glow && quickGlowX && quickGlowY) {
          quickGlowX(px);
          quickGlowY(py);
        }
      };

      const handleMouseEnter = () => {
        if (glow) gsap.to(glow, { opacity: 0.18, duration: 0.3 });
      };

      const handleMouseLeave = () => {
        quickLift(0);
        quickRotX(0);
        quickRotY(0);
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
      className="feature-card group relative rounded-2xl bg-gradient-to-b from-surface to-surface-2 p-6 border border-surface-border transition-colors hover:border-primary/50 shadow-lg overflow-hidden will-change-transform"
      style={{ transformStyle: 'preserve-3d' }}
    >
      {/* Interactive radial cursor glow */}
      <div
        ref={glowRef}
        className="pointer-events-none absolute -top-24 -left-24 w-48 h-48 rounded-full bg-primary blur-3xl opacity-0"
        style={{ transform: 'translate3d(0, 0, 0)' }}
      />

      {/* Top row: Icon + Feature Badge */}
      <div className="flex items-center justify-between mb-5">
        <div className="w-12 h-12 rounded-xl bg-primary/10 border border-primary/20 flex items-center justify-center text-primary group-hover:scale-105 group-hover:bg-primary/20 transition-all duration-300">
          <IconComponent className="w-6 h-6 text-accent" />
        </div>
        <Badge variant="primary" size="sm" className="font-semibold tracking-wide">
          {feature.badge}
        </Badge>
      </div>

      {/* Card Content */}
      <h3 className="text-lg font-bold text-text-primary tracking-tight mb-2.5 group-hover:text-accent transition-colors">
        {feature.title}
      </h3>
      <p className="text-sm text-text-secondary leading-relaxed">
        {feature.description}
      </p>

      {/* Subtle bottom border accent line */}
      <div className="absolute bottom-0 left-6 right-6 h-[2px] bg-gradient-to-r from-transparent via-primary/30 to-transparent opacity-0 group-hover:opacity-100 transition-opacity duration-500" />
    </div>
  );
}

export function FeaturesGrid() {
  const containerRef = useRef(null);

  useGSAP(
    () => {
      const prefersReduced = window.matchMedia('(prefers-reduced-motion: reduce)').matches;
      if (prefersReduced) return;

      gsap.from('.feature-card', {
        scrollTrigger: {
          trigger: containerRef.current,
          start: 'top 80%',
          toggleActions: 'play none none none',
        },
        y: 35,
        opacity: 0,
        stagger: 0.07,
        duration: 0.7,
        ease: 'power3.out',
      });
    },
    { scope: containerRef }
  );

  return (
    <section id="features" ref={containerRef} className="scroll-mt-24 py-6 sm:py-10 relative">
      {/* Subtle background ambient radial light */}
      <div className="absolute top-1/2 left-1/2 -translate-x-1/2 -translate-y-1/2 w-[700px] h-[500px] bg-primary/5 rounded-full blur-[140px] pointer-events-none -z-10" />

      <Container>
        <div className="text-center max-w-3xl mx-auto mb-8 sm:mb-10">
          <SectionHeading
            badge="App Capabilities"
            title={
              <>
                Engineered for Every Move in{' '}
                <GradientText variant="emerald">Modern Markets</GradientText>
              </>
            }
            subtitle="From mainline listings and SME subscriptions to global indices and AI-synthesized filings, experience all 8 core market capabilities under one hood."
          />
        </div>

        {/* 8-Card Responsive Grid */}
        <div className="grid grid-cols-1 sm:grid-cols-2 lg:grid-cols-4 gap-5 sm:gap-6">
          {homeFeatures.map((feature, index) => (
            <FeatureCard key={feature.id} feature={feature} index={index} />
          ))}
        </div>
      </Container>
    </section>
  );
}

export default FeaturesGrid;
