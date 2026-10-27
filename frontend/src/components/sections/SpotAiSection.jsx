import React, { useRef, useState } from 'react';
import { useGSAP } from '@gsap/react';
import gsap from 'gsap';
import {
  Sparkles,
  Bot,
  User,
  ArrowRight,
  ShieldAlert,
  Zap,
  CheckCircle2,
  FileSpreadsheet,
  TrendingUp,
} from 'lucide-react';
import { Container } from '@/components/ui/Container';
import { SectionHeading } from '@/components/ui/SectionHeading';
import { GradientText } from '@/components/ui/GradientText';
import { Button } from '@/components/ui/Button';
import { Badge } from '@/components/ui/Badge';
import { siteConfig } from '@/lib/site';

const aiHighlights = [
  'Instant Red Herring Prospectus (RHP) & DRHP synthesis',
  'Real-time Grey Market Premium sentiment weighting',
  'Peer valuation comparison across P/E, RoNW, and EV/EBITDA',
  'Jargon-free promoter background and risk factor disclosures',
];

const chatScript = [
  {
    sender: 'user',
    text: 'What is the 30-second verdict on the upcoming Tata Technologies IPO?',
  },
  {
    sender: 'ai',
    text: 'DRHP Verdict: Clean balance sheet with zero debt, 18.6% EBITDA margin, and 64% revenue from EV architecture. Key risk: 42% revenue reliance on top anchor OEMs. Sentiment Score: 8.9 / 10 (Strong Bullish).',
  },
  {
    sender: 'user',
    text: 'What listing gain does the current GMP suggest?',
  },
  {
    sender: 'ai',
    text: 'Latest GMP trades at +₹415 against a ₹500 cut-off, projecting ~83.0% expected listing pop. Retail & QIB tranches already showing heavy demand.',
  },
];

export function SpotAiSection() {
  const containerRef = useRef(null);
  const chatBoxRef = useRef(null);
  const msgRefs = useRef([]);
  const [typedText1, setTypedText1] = useState('');
  const [typedText2, setTypedText2] = useState('');
  const [isTyping1, setIsTyping1] = useState(false);
  const [isTyping2, setIsTyping2] = useState(false);

  useGSAP(
    () => {
      const prefersReduced = window.matchMedia('(prefers-reduced-motion: reduce)').matches;

      if (prefersReduced) {
        setTypedText1(chatScript[1].text);
        setTypedText2(chatScript[3].text);
        gsap.set(msgRefs.current, { opacity: 1, y: 0 });
        return;
      }

      const tl = gsap.timeline({
        scrollTrigger: {
          trigger: chatBoxRef.current,
          start: 'top 75%',
          toggleActions: 'play none none none',
        },
      });

      // 1. First user message reveals
      tl.fromTo(
        msgRefs.current[0],
        { opacity: 0, y: 15, scale: 0.95 },
        { opacity: 1, y: 0, scale: 1, duration: 0.5, ease: 'power2.out' }
      );

      // 2. First AI typing
      tl.call(() => setIsTyping1(true), null, '+=0.2');

      const targetText1 = chatScript[1].text;
      const progressObj1 = { charIndex: 0 };

      tl.to(progressObj1, {
        charIndex: targetText1.length,
        duration: 2.2,
        ease: 'none',
        onUpdate: () => {
          setTypedText1(targetText1.slice(0, Math.round(progressObj1.charIndex)));
        },
        onComplete: () => {
          setIsTyping1(false);
        },
      });

      // 3. Second user message reveals
      tl.fromTo(
        msgRefs.current[2],
        { opacity: 0, y: 15, scale: 0.95 },
        { opacity: 1, y: 0, scale: 1, duration: 0.5, ease: 'power2.out' },
        '+=0.4'
      );

      // 4. Second AI typing
      tl.call(() => setIsTyping2(true), null, '+=0.2');

      const targetText2 = chatScript[3].text;
      const progressObj2 = { charIndex: 0 };

      tl.to(progressObj2, {
        charIndex: targetText2.length,
        duration: 1.8,
        ease: 'none',
        onUpdate: () => {
          setTypedText2(targetText2.slice(0, Math.round(progressObj2.charIndex)));
        },
        onComplete: () => {
          setIsTyping2(false);
        },
      });
    },
    { scope: containerRef }
  );

  return (
    <section id="spotai" ref={containerRef} className="scroll-mt-24 py-6 sm:py-10 relative overflow-hidden">
      {/* Ambient background glow */}
      <div className="absolute top-1/2 right-10 -translate-y-1/2 w-[550px] h-[550px] bg-primary/10 rounded-full blur-[160px] pointer-events-none -z-10" />

      <Container>
        <div className="grid grid-cols-1 lg:grid-cols-12 gap-12 lg:gap-14 items-center">
          {/* Left Column: Copy & Value Proposition */}
          <div className="lg:col-span-6 flex flex-col items-start text-left">
            <div className="mb-4 inline-flex items-center gap-2 px-3 py-1.5 rounded-full border border-primary/30 bg-primary/10 backdrop-blur-md">
              <Bot className="w-4 h-4 text-accent" />
              <span className="text-xs font-semibold text-text-primary tracking-wide">
                SpotAI Intelligence Engine
              </span>
            </div>

            <h2 className="text-3xl sm:text-4xl md:text-5xl font-extrabold text-text-primary tracking-tight leading-[1.12] mb-6">
              Ask Anything.{' '}
              <GradientText variant="emerald">Unpack Filings in Seconds.</GradientText>
            </h2>

            <p className="text-base sm:text-lg text-text-secondary leading-relaxed mb-6">
              Reading through a 400-page DRHP is tedious. SpotAI distills complex financial jargon,
              debt schedules, peer multiples, and grey market sentiment into crisp, conversational insights you can act on.
            </p>

            {/* Checklist */}
            <div className="space-y-3 mb-8 w-full">
              {aiHighlights.map((item, idx) => (
                <div key={idx} className="flex items-start gap-3">
                  <div className="w-5 h-5 rounded-full bg-primary/20 flex items-center justify-center shrink-0 mt-0.5">
                    <CheckCircle2 className="w-3.5 h-3.5 text-bull" />
                  </div>
                  <span className="text-sm font-medium text-text-primary/90">
                    {item}
                  </span>
                </div>
              ))}
            </div>

            {/* Regulatory Disclaimer Box */}
            <div className="p-4 rounded-xl bg-surface-2 border border-surface-border mb-8 w-full flex items-start gap-3">
              <ShieldAlert className="w-5 h-5 text-accent shrink-0 mt-0.5" />
              <div className="text-xs text-text-muted leading-relaxed">
                <strong className="text-text-primary">Important Disclosure:</strong> AI-generated information, not financial advice. Past performance or GMP signals do not guarantee future listing gains. Always refer to official exchange filings.
              </div>
            </div>

            {/* CTA */}
            <div className="flex flex-wrap items-center gap-4">
              <Button
                variant="primary"
                size="lg"
                className="shadow-glow group"
                onClick={() => alert('SpotAI is built directly inside TheSpotMarket app! Download coming soon.')}
              >
                <Sparkles className="w-4 h-4 mr-2 text-accent" />
                Try SpotAI in App
              </Button>
              <Button
                to="/about"
                variant="outline"
                size="lg"
                className="border-surface-border text-text-primary hover:border-primary/40"
              >
                Learn How SpotAI Works
                <ArrowRight className="w-4 h-4 ml-1.5 transition-transform group-hover:translate-x-1" />
              </Button>
            </div>
          </div>

          {/* Right Column: Liquid-Glass Fake Chat UI */}
          <div className="lg:col-span-6">
            <div
              ref={chatBoxRef}
              className="relative rounded-3xl bg-surface/80 backdrop-blur-2xl border border-primary/30 p-5 sm:p-7 shadow-[0_20px_60px_-15px_rgba(0,0,0,0.8),0_0_40px_rgba(16,185,129,0.12)] overflow-hidden"
            >
              {/* Chat Header */}
              <div className="flex items-center justify-between pb-4 border-b border-surface-border/70 mb-5">
                <div className="flex items-center gap-3">
                  <div className="relative">
                    <div className="w-10 h-10 rounded-xl bg-gradient-to-tr from-primary to-accent flex items-center justify-center text-black font-extrabold shadow-md">
                      <Bot className="w-5 h-5 text-black" />
                    </div>
                    <span className="absolute -bottom-0.5 -right-0.5 w-3 h-3 rounded-full bg-bull border-2 border-surface" />
                  </div>
                  <div>
                    <div className="text-sm font-bold text-text-primary flex items-center gap-1.5">
                      SpotAI Copilot
                      <Badge variant="primary" size="sm">v2.4</Badge>
                    </div>
                    <div className="text-xs text-text-muted flex items-center gap-1.5">
                      <span className="w-1.5 h-1.5 rounded-full bg-bull animate-pulse" />
                      Active • Sub-second Latency
                    </div>
                  </div>
                </div>

                <div className="flex items-center gap-1.5">
                  <span className="w-2.5 h-2.5 rounded-full bg-[#1F3327]" />
                  <span className="w-2.5 h-2.5 rounded-full bg-[#1F3327]" />
                  <span className="w-2.5 h-2.5 rounded-full bg-primary/40" />
                </div>
              </div>

              {/* Chat Conversation Stream */}
              <div className="space-y-4 min-h-[340px] flex flex-col justify-center">
                {/* 1. User Query 1 */}
                <div
                  ref={(el) => (msgRefs.current[0] = el)}
                  className="flex items-start justify-end gap-2.5 pl-6"
                >
                  <div className="max-w-[85%] rounded-2xl rounded-tr-sm bg-primary/20 border border-primary/35 p-3.5 text-xs sm:text-sm text-text-primary shadow-sm leading-relaxed">
                    {chatScript[0].text}
                  </div>
                  <div className="w-7 h-7 rounded-lg bg-surface-2 border border-surface-border flex items-center justify-center shrink-0 text-text-muted mt-0.5">
                    <User className="w-4 h-4" />
                  </div>
                </div>

                {/* 2. SpotAI Response 1 */}
                <div
                  ref={(el) => (msgRefs.current[1] = el)}
                  className="flex items-start gap-2.5 pr-6"
                >
                  <div className="w-7 h-7 rounded-lg bg-primary/20 border border-primary/40 flex items-center justify-center shrink-0 text-accent mt-0.5">
                    <Bot className="w-4 h-4" />
                  </div>
                  <div className="max-w-[88%] rounded-2xl rounded-tl-sm bg-surface-2/95 border border-surface-border p-3.5 text-xs sm:text-sm text-text-primary shadow-md leading-relaxed">
                    {typedText1 || <span className="text-text-muted italic">Analyzing DRHP filings...</span>}
                    {isTyping1 && (
                      <span className="inline-block w-1.5 h-3.5 ml-1 bg-accent animate-pulse align-middle" />
                    )}
                  </div>
                </div>

                {/* 3. User Query 2 */}
                <div
                  ref={(el) => (msgRefs.current[2] = el)}
                  className="flex items-start justify-end gap-2.5 pl-6"
                >
                  <div className="max-w-[85%] rounded-2xl rounded-tr-sm bg-primary/20 border border-primary/35 p-3.5 text-xs sm:text-sm text-text-primary shadow-sm leading-relaxed">
                    {chatScript[2].text}
                  </div>
                  <div className="w-7 h-7 rounded-lg bg-surface-2 border border-surface-border flex items-center justify-center shrink-0 text-text-muted mt-0.5">
                    <User className="w-4 h-4" />
                  </div>
                </div>

                {/* 4. SpotAI Response 2 */}
                <div
                  ref={(el) => (msgRefs.current[3] = el)}
                  className="flex items-start gap-2.5 pr-6"
                >
                  <div className="w-7 h-7 rounded-lg bg-primary/20 border border-primary/40 flex items-center justify-center shrink-0 text-accent mt-0.5">
                    <Bot className="w-4 h-4" />
                  </div>
                  <div className="max-w-[88%] rounded-2xl rounded-tl-sm bg-surface-2/95 border border-surface-border p-3.5 text-xs sm:text-sm text-text-primary shadow-md leading-relaxed">
                    {typedText2 || (
                      <span className="text-text-muted italic">
                        {isTyping2 ? 'Checking GMP feeds...' : 'Ready'}
                      </span>
                    )}
                    {isTyping2 && (
                      <span className="inline-block w-1.5 h-3.5 ml-1 bg-accent animate-pulse align-middle" />
                    )}
                  </div>
                </div>
              </div>

              {/* Chat Input Simulated Footer */}
              <div className="mt-5 pt-3.5 border-t border-surface-border/70 flex items-center justify-between text-xs text-text-muted">
                <span className="text-text-muted/75">Ask about subscription status, valuation, or promoter background...</span>
                <div className="px-2.5 py-1 rounded-lg bg-primary/10 border border-primary/30 text-accent font-semibold flex items-center gap-1">
                  <Zap className="w-3 h-3 text-accent" />
                  Instant
                </div>
              </div>
            </div>
          </div>
        </div>
      </Container>
    </section>
  );
}

export default SpotAiSection;
