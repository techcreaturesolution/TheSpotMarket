import React from 'react';
import { Helmet } from 'react-helmet-async';
import { Home, AlertCircle } from 'lucide-react';
import { Container } from '@/components/ui/Container';
import { Button } from '@/components/ui/Button';
import { GlassCard } from '@/components/ui/GlassCard';

export function NotFoundPage() {
  return (
    <>
      <Helmet>
        <title>404 - Page Not Found | TheSpotMarket</title>
      </Helmet>

      <section className="min-h-[70vh] flex items-center justify-center py-20 bg-radial-glow">
        <Container size="sm">
          <GlassCard className="p-10 text-center space-y-6">
            <div className="mx-auto w-16 h-16 rounded-2xl bg-bear/20 border border-bear/30 flex items-center justify-center text-bear">
              <AlertCircle className="h-8 w-8" />
            </div>
            <div className="space-y-2">
              <h1 className="text-4xl font-extrabold text-white">404</h1>
              <p className="text-xl font-semibold text-white">Page Not Found</p>
              <p className="text-muted text-sm max-w-sm mx-auto">
                The market data page you are looking for does not exist or has been relocated.
              </p>
            </div>
            <div>
              <Button to="/" variant="primary" size="md" icon={<Home className="h-4 w-4" />}>
                Return to Home
              </Button>
            </div>
          </GlassCard>
        </Container>
      </section>
    </>
  );
}

export default NotFoundPage;
