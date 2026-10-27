import React from 'react';
import { Helmet } from 'react-helmet-async';
import { Flame, ArrowUpRight } from 'lucide-react';
import { Container } from '@/components/ui/Container';
import { SectionHeading } from '@/components/ui/SectionHeading';
import { GlassCard } from '@/components/ui/GlassCard';
import { Badge } from '@/components/ui/Badge';
import { Button } from '@/components/ui/Button';

export function IpoPage() {
  return (
    <>
      <Helmet>
        <title>IPO Tracker & GMP - TheSpotMarket</title>
        <meta
          name="description"
          content="Track live Indian IPO subscription figures, GMP rates, and listing estimates."
        />
      </Helmet>

      <section className="py-10 sm:py-14 bg-radial-glow">
        <Container>
          <SectionHeading
            badge="Phase 1 Placeholder"
            title="Indian IPO Tracker & Live GMP"
            subtitle="Full interactive IPO tables, GMP trend charts, and subscription calculators will be introduced in upcoming phases."
          />

          <div className="mt-12 max-w-2xl mx-auto">
            <GlassCard className="p-8 text-center space-y-4">
              <div className="mx-auto w-12 h-12 rounded-2xl bg-primary/20 border border-primary/40 flex items-center justify-center text-accent">
                <Flame className="h-6 w-6" />
              </div>
              <h3 className="text-2xl font-bold text-white">Upcoming Feature</h3>
              <p className="text-muted text-sm leading-relaxed">
                Connects directly to our Node.js IndianAPI & SmartAPI backend for live subscription status, GMP alerts, and allotment verification.
              </p>
              <div className="pt-2">
                <Button to="/" variant="primary" size="md">
                  Back to Home
                </Button>
              </div>
            </GlassCard>
          </div>
        </Container>
      </section>
    </>
  );
}

export default IpoPage;
