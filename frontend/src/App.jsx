import React, { Suspense, lazy } from 'react';
import { BrowserRouter, Routes, Route } from 'react-router-dom';
import { HelmetProvider } from 'react-helmet-async';
import MainLayout from '@/components/layout/MainLayout';

// Route-level code splitting via dynamic imports
const HomePage = lazy(() => import('@/pages/HomePage'));
const AboutPage = lazy(() => import('@/pages/AboutPage'));
const ContactPage = lazy(() => import('@/pages/ContactPage'));
const PrivacyPage = lazy(() => import('@/pages/PrivacyPage'));
const TermsPage = lazy(() => import('@/pages/TermsPage'));
const DisclaimerPage = lazy(() => import('@/pages/DisclaimerPage'));
const DataDeletionPage = lazy(() => import('@/pages/DataDeletionPage'));
const IpoPage = lazy(() => import('@/pages/IpoPage'));
const StocksPage = lazy(() => import('@/pages/StocksPage'));
const NotFoundPage = lazy(() => import('@/pages/NotFoundPage'));

// Sleek dark pulse loader for seamless route transitions
function PageFallback() {
  return (
    <div className="min-h-[60vh] flex flex-col items-center justify-center gap-3">
      <div className="relative flex items-center justify-center">
        <div className="w-10 h-10 rounded-full border-2 border-primary/20 border-t-primary animate-spin" />
        <div className="absolute w-2 h-2 rounded-full bg-accent animate-pulse" />
      </div>
      <span className="text-xs font-mono text-muted/60 tracking-wider uppercase">Loading...</span>
    </div>
  );
}

export function App() {
  return (
    <HelmetProvider>
      <BrowserRouter>
        <Suspense fallback={<PageFallback />}>
          <Routes>
            <Route path="/" element={<MainLayout />}>
              <Route index element={<HomePage />} />
              <Route path="about" element={<AboutPage />} />
              <Route path="contact" element={<ContactPage />} />
              <Route path="faq" element={<ContactPage />} />
              <Route path="privacy-policy" element={<PrivacyPage />} />
              <Route path="privacy" element={<PrivacyPage />} />
              <Route path="terms" element={<TermsPage />} />
              <Route path="disclaimer" element={<DisclaimerPage />} />
              <Route path="data-deletion" element={<DataDeletionPage />} />
              <Route path="ipos" element={<IpoPage />} />
              <Route path="stocks" element={<StocksPage />} />
              <Route path="*" element={<NotFoundPage />} />
            </Route>
          </Routes>
        </Suspense>
      </BrowserRouter>
    </HelmetProvider>
  );
}

export default App;
