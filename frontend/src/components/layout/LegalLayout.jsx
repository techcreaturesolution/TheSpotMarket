// NOTE: This legal document template reflects actual technical implementation and is for informational transparency.
// It should be reviewed by a qualified Indian cyber/securities lawyer before official commercial publication.

import React, { useRef, useState, useEffect } from 'react';
import { NavLink, useLocation } from 'react-router-dom';
import { useGSAP } from '@gsap/react';
import gsap from 'gsap';
import {
  Printer,
  Calendar,
  ShieldCheck,
  FileText,
  ShieldAlert,
  Trash2,
  ChevronRight,
  ExternalLink,
  Scale,
} from 'lucide-react';
import { Container } from '@/components/ui/Container';
import { Badge } from '@/components/ui/Badge';
import { Button } from '@/components/ui/Button';
import { GlassCard } from '@/components/ui/GlassCard';
import { siteConfig } from '@/lib/site';

// Navigation links across all legal documents
const LEGAL_NAV = [
  { name: 'Privacy Policy', path: '/privacy-policy', icon: ShieldCheck },
  { name: 'Terms of Service', path: '/terms', icon: Scale },
  { name: 'SEBI Disclaimer', path: '/disclaimer', icon: ShieldAlert },
  { name: 'Data Deletion', path: '/data-deletion', icon: Trash2 },
];

/**
 * Shared LegalLayout component
 * Provides sticky Table of Contents, last-updated badge, print-friendly styling,
 * document switcher tabs, and subtle GSAP content entrance fade.
 *
 * @param {Object} props
 * @param {string} props.badge - Category badge label (e.g. 'DPDP Act Compliance')
 * @param {string} props.title - Document title (e.g. 'Privacy Policy')
 * @param {string} props.subtitle - Document summary/lead paragraph
 * @param {string} [props.lastUpdated='October 27, 2026'] - Last modified date
 * @param {Array<{id: string, title: string}>} [props.toc=[]] - Table of contents sections
 * @param {React.ReactNode} props.children - Main legal document text
 */
export function LegalLayout({
  badge = 'Legal & Regulatory',
  title,
  subtitle,
  lastUpdated = 'October 27, 2026',
  toc = [],
  children,
}) {
  const contentRef = useRef(null);
  const location = useLocation();
  const [activeSection, setActiveSection] = useState(toc[0]?.id || '');

  // Subtle GSAP content fade-in on route change
  useGSAP(
    () => {
      const prefersReduced = window.matchMedia('(prefers-reduced-motion: reduce)').matches;
      if (prefersReduced || !contentRef.current) return;

      gsap.fromTo(
        contentRef.current,
        { opacity: 0, y: 16 },
        { opacity: 1, y: 0, duration: 0.45, ease: 'power2.out' }
      );
    },
    { dependencies: [location.pathname] }
  );

  // IntersectionObserver to highlight current active TOC section on scroll
  useEffect(() => {
    if (!toc || toc.length === 0) return;

    const observer = new IntersectionObserver(
      (entries) => {
        const visibleEntries = entries.filter((e) => e.isIntersecting);
        if (visibleEntries.length > 0) {
          setActiveSection(visibleEntries[0].target.id);
        }
      },
      {
        rootMargin: '-80px 0px -65% 0px',
        threshold: 0,
      }
    );

    toc.forEach((item) => {
      const el = document.getElementById(item.id);
      if (el) observer.observe(el);
    });

    return () => observer.disconnect();
  }, [toc]);

  const handlePrint = () => {
    if (typeof window !== 'undefined') {
      window.print();
    }
  };

  const handleTocClick = (e, id) => {
    e.preventDefault();
    const el = document.getElementById(id);
    if (el) {
      const offset = 90;
      const top = el.getBoundingClientRect().top + window.scrollY - offset;
      window.scrollTo({ top, behavior: 'smooth' });
      setActiveSection(id);
      window.history.replaceState(null, '', `#${id}`);
    }
  };

  return (
    <div className="py-8 sm:py-12 bg-radial-glow relative">
      {/* Print-specific style rules */}
      <style>{`
        @media print {
          /* Hide non-printable UI shells */
          header, nav, footer, .legal-sidebar, .legal-nav-tabs, .print-btn, .spotai-floating-btn {
            display: none !important;
          }
          body {
            background: #ffffff !important;
            color: #111827 !important;
            font-size: 11pt !important;
            line-height: 1.5 !important;
          }
          .legal-content {
            color: #1f2937 !important;
            max-width: 100% !important;
            padding: 0 !important;
          }
          .legal-content h2, .legal-content h3 {
            color: #111827 !important;
            page-break-after: avoid;
          }
          .legal-card {
            border: 1px solid #e5e7eb !important;
            background: #ffffff !important;
            box-shadow: none !important;
            padding: 1rem 0 !important;
          }
          a {
            color: #059669 !important;
            text-decoration: underline !important;
          }
        }
      `}</style>

      <Container>
        {/* Top Header & Breadcrumb */}
        <div className="max-w-4xl mx-auto text-center space-y-4 mb-6 sm:mb-8">
          <div className="inline-flex">
            <Badge variant="primary" size="md">
              {badge}
            </Badge>
          </div>

          <h1 className="text-3xl sm:text-4xl lg:text-5xl font-extrabold text-white tracking-tight">
            {title}
          </h1>

          {subtitle && (
            <p className="text-base sm:text-lg text-muted max-w-2xl mx-auto leading-relaxed">
              {subtitle}
            </p>
          )}

          {/* Metadata & Print Bar */}
          <div className="pt-2 flex flex-wrap items-center justify-center gap-4 text-xs font-mono text-subtle">
            <div className="flex items-center gap-1.5">
              <Calendar className="w-4 h-4 text-accent" />
              <span>Last Updated: {lastUpdated}</span>
            </div>
            <span className="text-white/20">•</span>
            <span>Applies to App v1.0+ & Web</span>
            <span className="text-white/20">•</span>
            <button
              onClick={handlePrint}
              type="button"
              className="print-btn inline-flex items-center gap-1.5 text-accent hover:text-white transition-colors cursor-pointer"
              title="Print or Save as PDF"
            >
              <Printer className="w-3.5 h-3.5" />
              <span>Print / PDF</span>
            </button>
          </div>
        </div>

        {/* Legal Document Switcher Tabs */}
        <div className="legal-nav-tabs max-w-5xl mx-auto mb-12">
          <div className="flex items-center justify-start sm:justify-center gap-2 overflow-x-auto pb-2 scrollbar-none">
            {LEGAL_NAV.map((item) => {
              const IconComp = item.icon;
              return (
                <NavLink
                  key={item.path}
                  to={item.path}
                  className={({ isActive }) =>
                    `inline-flex items-center gap-2 px-4 py-2.5 rounded-xl text-xs font-medium whitespace-nowrap transition-all duration-200 border ${
                      isActive
                        ? 'bg-primary/20 border-primary text-accent shadow-[0_0_15px_rgba(16,185,129,0.25)]'
                        : 'bg-surface/60 border-white/5 text-muted hover:text-white hover:border-white/20 hover:bg-surface'
                    }`
                  }
                >
                  <IconComp className="w-3.5 h-3.5" />
                  <span>{item.name}</span>
                </NavLink>
              );
            })}
          </div>
        </div>

        {/* Two-Column Body: Sticky TOC Sidebar + Main Legal Text */}
        <div className="grid grid-cols-1 lg:grid-cols-12 gap-10 max-w-6xl mx-auto items-start relative">
          {/* LEFT: Fixed/Sticky Table of Contents (4 cols on lg) */}
          {toc.length > 0 && (
            <aside className="legal-sidebar lg:col-span-4 sticky top-24 self-start space-y-4 z-20">
              <GlassCard className="p-5 space-y-3 border-white/10 backdrop-blur-xl shadow-2xl max-h-[calc(100vh-140px)] flex flex-col">
                <div className="flex items-center justify-between pb-2 border-b border-white/5 shrink-0">
                  <span className="text-xs font-mono uppercase tracking-wider text-accent font-semibold flex items-center gap-1.5">
                    <FileText className="w-3.5 h-3.5" />
                    <span>Table of Contents</span>
                  </span>
                  <span className="text-[10px] font-mono text-subtle">{toc.length} Sections</span>
                </div>

                <nav className="space-y-1 overflow-y-auto pr-1 flex-1 scrollbar-thin">
                  {toc.map((item) => {
                    const isActive = activeSection === item.id;
                    return (
                      <a
                        key={item.id}
                        href={`#${item.id}`}
                        onClick={(e) => handleTocClick(e, item.id)}
                        className={`group flex items-center justify-between text-xs py-1.5 px-2.5 rounded-lg transition-all duration-150 ${
                          isActive
                            ? 'bg-primary/20 text-accent font-semibold border-l-2 border-primary pl-2'
                            : 'text-muted hover:text-white hover:bg-white/5'
                        }`}
                      >
                        <span className="truncate">{item.title}</span>
                        <ChevronRight
                          className={`w-3 h-3 shrink-0 ml-1.5 transition-transform duration-150 ${
                            isActive ? 'opacity-100 translate-x-0.5' : 'opacity-0 group-hover:opacity-60'
                          }`}
                        />
                      </a>
                    );
                  })}
                </nav>
              </GlassCard>

              {/* Quick Legal Help Box */}
              <div className="p-4 rounded-2xl bg-surface/40 border border-white/5 text-xs text-subtle space-y-1.5">
                <div className="font-semibold text-white">Grievance & Legal Officer</div>
                <p className="text-[11px] leading-relaxed">
                  For formal compliance inquiries or DPDP Act notifications, contact our legal desk directly:
                </p>
                <a
                  href={`mailto:${siteConfig.contactEmail}?subject=Legal%20Inquiry`}
                  className="inline-flex items-center gap-1 text-accent font-mono text-xs hover:underline pt-0.5"
                >
                  <span>{siteConfig.contactEmail}</span>
                  <ExternalLink className="w-3 h-3" />
                </a>
              </div>
            </aside>
          )}

          {/* RIGHT: Document Content (8 cols on lg) */}
          <main
            ref={contentRef}
            className={`legal-content ${toc.length > 0 ? 'lg:col-span-8' : 'lg:col-span-12'}`}
          >
            <GlassCard className="legal-card p-7 sm:p-10 border-white/10 text-sm text-muted leading-relaxed space-y-8">
              {children}
            </GlassCard>
          </main>
        </div>
      </Container>
    </div>
  );
}

export default LegalLayout;
