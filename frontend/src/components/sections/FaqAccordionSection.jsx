import React, { useState, useRef } from 'react';
import { useGSAP } from '@gsap/react';
import gsap from 'gsap';
import { Helmet } from 'react-helmet-async';
import { Plus, Minus, HelpCircle, Sparkles } from 'lucide-react';
import { Container } from '@/components/ui/Container';
import { SectionHeading } from '@/components/ui/SectionHeading';
import { GradientText } from '@/components/ui/GradientText';
import { homeFaqs } from '@/data';

function FaqItem({ item, index, isOpen, onToggle }) {
  const contentRef = useRef(null);
  const iconRef = useRef(null);

  useGSAP(
    () => {
      const content = contentRef.current;
      const icon = iconRef.current;
      if (!content) return;

      const prefersReduced = window.matchMedia('(prefers-reduced-motion: reduce)').matches;

      if (isOpen) {
        gsap.to(content, {
          height: 'auto',
          opacity: 1,
          duration: prefersReduced ? 0 : 0.35,
          ease: 'power2.out',
        });
        if (icon && !prefersReduced) {
          gsap.to(icon, { rotate: 45, duration: 0.25, ease: 'power2.out' });
        }
      } else {
        gsap.to(content, {
          height: 0,
          opacity: 0,
          duration: prefersReduced ? 0 : 0.25,
          ease: 'power2.in',
        });
        if (icon && !prefersReduced) {
          gsap.to(icon, { rotate: 0, duration: 0.2, ease: 'power2.in' });
        }
      }
    },
    { dependencies: [isOpen] }
  );

  return (
    <div
      className={`rounded-2xl transition-colors duration-300 border ${
        isOpen
          ? 'bg-surface-2/90 border-primary/45 shadow-lg'
          : 'bg-surface/70 border-surface-border hover:border-surface-border/90'
      }`}
    >
      <button
        type="button"
        id={`faq-trigger-${index}`}
        aria-expanded={isOpen}
        aria-controls={`faq-answer-${index}`}
        onClick={onToggle}
        className="w-full text-left p-5 sm:p-6 flex items-center justify-between gap-4 focus:outline-none focus-visible:ring-2 focus-visible:ring-primary rounded-2xl"
      >
        <div className="flex items-center gap-3">
          <HelpCircle
            className={`w-5 h-5 shrink-0 transition-colors ${
              isOpen ? 'text-accent' : 'text-text-muted'
            }`}
          />
          <span className="text-base sm:text-lg font-bold text-text-primary tracking-tight">
            {item.q}
          </span>
        </div>

        <div
          ref={iconRef}
          className={`w-8 h-8 rounded-lg flex items-center justify-center shrink-0 transition-colors ${
            isOpen ? 'bg-primary/20 text-accent' : 'bg-surface-2 text-text-muted'
          }`}
        >
          <Plus className="w-4 h-4" />
        </div>
      </button>

      {/* Accordion collapsible body */}
      <div
        id={`faq-answer-${index}`}
        role="region"
        aria-labelledby={`faq-trigger-${index}`}
        ref={contentRef}
        style={{ height: 0, opacity: 0, overflow: 'hidden' }}
      >
        <div className="px-5 sm:px-6 pb-6 pt-1 text-sm sm:text-base text-text-secondary leading-relaxed border-t border-surface-border/40">
          <p>{item.a}</p>
        </div>
      </div>
    </div>
  );
}

export function FaqAccordionSection() {
  // Allow multiple items to be toggled independently, or single item (first one open by default)
  const [openIndexes, setOpenIndexes] = useState([0]);
  const containerRef = useRef(null);

  const toggleIndex = (index) => {
    setOpenIndexes((prev) =>
      prev.includes(index) ? prev.filter((i) => i !== index) : [...prev, index]
    );
  };

  useGSAP(
    () => {
      const prefersReduced = window.matchMedia('(prefers-reduced-motion: reduce)').matches;
      if (prefersReduced) return;

      gsap.from('.faq-card-item', {
        scrollTrigger: {
          trigger: containerRef.current,
          start: 'top 80%',
          toggleActions: 'play none none none',
        },
        y: 30,
        opacity: 0,
        stagger: 0.08,
        duration: 0.7,
        ease: 'power3.out',
      });
    },
    { scope: containerRef }
  );

  // Schema.org FAQPage JSON-LD structured data
  const faqJsonLd = {
    '@context': 'https://schema.org',
    '@type': 'FAQPage',
    mainEntity: homeFaqs.map((faq) => ({
      '@type': 'Question',
      name: faq.q,
      acceptedAnswer: {
        '@type': 'Answer',
        text: faq.a,
      },
    })),
  };

  return (
    <section id="faq" ref={containerRef} className="scroll-mt-24 py-6 sm:py-10 relative">
      {/* Inject FAQ structured data */}
      <Helmet>
        <script type="application/ld+json">{JSON.stringify(faqJsonLd)}</script>
      </Helmet>

      {/* Ambient background glow */}
      <div className="absolute top-1/2 left-1/2 -translate-x-1/2 -translate-y-1/2 w-[700px] h-[400px] bg-primary/6 rounded-full blur-[160px] pointer-events-none -z-10" />

      <Container size="md">
        <div className="text-center max-w-2xl mx-auto mb-8 sm:mb-10">
          <SectionHeading
            badge="Frequently Asked Questions"
            title={
              <>
                Got Questions?{' '}
                <GradientText variant="emerald">We’ve Got Answers.</GradientText>
              </>
            }
            subtitle="Everything you need to know about TheSpotMarket platform, SEBI compliance, PAN privacy, and SpotAI intelligence."
          />
        </div>

        {/* 8 Questions Accordion List */}
        <div className="space-y-4">
          {homeFaqs.map((faq, index) => (
            <div key={index} className="faq-card-item">
              <FaqItem
                item={faq}
                index={index}
                isOpen={openIndexes.includes(index)}
                onToggle={() => toggleIndex(index)}
              />
            </div>
          ))}
        </div>
      </Container>
    </section>
  );
}

export default FaqAccordionSection;
