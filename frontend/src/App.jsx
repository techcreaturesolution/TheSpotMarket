import React from 'react';
import { BrowserRouter, Routes, Route } from 'react-router-dom';
import { HelmetProvider } from 'react-helmet-async';
import MainLayout from '@/components/layout/MainLayout';
import HomePage from '@/pages/HomePage';
import AboutPage from '@/pages/AboutPage';
import ContactPage from '@/pages/ContactPage';
import PrivacyPage from '@/pages/PrivacyPage';
import TermsPage from '@/pages/TermsPage';
import DisclaimerPage from '@/pages/DisclaimerPage';
import DataDeletionPage from '@/pages/DataDeletionPage';
import IpoPage from '@/pages/IpoPage';
import StocksPage from '@/pages/StocksPage';
import NotFoundPage from '@/pages/NotFoundPage';

export function App() {
  return (
    <HelmetProvider>
      <BrowserRouter>
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
      </BrowserRouter>
    </HelmetProvider>
  );
}

export default App;
