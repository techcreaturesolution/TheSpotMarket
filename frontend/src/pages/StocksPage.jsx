import React from 'react';
import { Helmet } from 'react-helmet-async';
import { BarChart3 } from 'lucide-react';
import { Container } from '@/components/ui/Container';
import { SectionHeading } from '@/components/ui/SectionHeading';
import { GlassCard } from '@/components/ui/GlassCard';
import { Button } from '@/components/ui/Button';

export function StocksPage() {
  return (
    <>
      <Helmet>
        <title>NSE/BSE Stocks - TheSpotMarket</title>
        <meta
          name="description"
          content="Live NSE/BSE stock data, Angel One SmartAPI integration, and SpotAI insights."
        />
      </Helmet>

      <section className="py-10 sm:py-14 bg-radial-glow">
        <Container>
          <SectionHeading
            badge="Phase 1 Placeholder"
            title="NSE/BSE Stocks & Market Intelligence"
            subtitle="Real-time Indian market feeds, technical heatmaps, and AI summaries."
          />

          <div className="mt-12 max-w-2xl mx-auto">
            <GlassCard className="p-8 text-center space-y-4">
              <div className="mx-auto w-12 h-12 rounded-2xl bg-primary/20 border border-primary/40 flex items-center justify-center text-accent">
                <BarChart3 className="h-6 w-6" />
              </div>
              <h3 className="text-2xl font-bold text-white">Market Intelligence Hub</h3>
              <p className="text-muted text-sm leading-relaxed">
                Stay tuned as we roll out high-performance marketing landing pages with live market data feeds and Angel One SmartAPI indicators.
              </p>
              <div className="pt-2">
                <Button to="/" variant="glass" size="md">
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

export default StocksPage;
