import React from 'react';
import { Link, useLocation, useNavigate } from 'react-router-dom';
import {
  Send,
  Linkedin,
  Instagram,
  Youtube,
  ShieldAlert,
  Smartphone,
  ExternalLink,
} from 'lucide-react';
import { scrollToTarget } from '@/lib/gsap';
import { siteConfig } from '@/lib/site';

export function Footer() {
  const location = useLocation();
  const navigate = useNavigate();

  const handleLinkClick = (e, link) => {
    if (link.isHash) {
      e.preventDefault();
      if (location.pathname === '/') {
        if (window.location.hash !== link.hash) {
          window.history.pushState(null, '', `/${link.hash}`);
        }
        scrollToTarget(link.hash, { offset: 80 });
      } else {
        navigate(`/${link.hash}`);
        setTimeout(() => {
          scrollToTarget(link.hash, { offset: 80 });
        }, 120);
      }
    }
  };

  return (
    <footer
      className="border-t border-white/10 bg-surface/70 backdrop-blur-md mt-auto relative z-10"
      aria-label="Footer"
    >
      <div className="mx-auto max-w-7xl px-4 sm:px-6 lg:px-8 pt-14 pb-24 md:pt-18 md:pb-16">
        <div className="grid grid-cols-1 md:grid-cols-2 lg:grid-cols-5 gap-10 lg:gap-8">
          {/* Column 1: Brand + Tagline + Socials (occupies 2 cols on lg) */}
          <div className="lg:col-span-2 space-y-5">
            <Link
              to="/"
              className="inline-flex items-center gap-3 group focus-visible:ring-2 focus-visible:ring-primary focus-visible:rounded-xl focus-visible:outline-none"
            >
              <img
                src="/images/app_icon.png"
                alt="TheSpotMarket App Icon"
                width="36"
                height="36"
                loading="lazy"
                decoding="async"
                className="h-9 w-9 rounded-xl object-cover border border-primary/40 shadow-sm transition-transform duration-200 group-hover:scale-105"
              />
              <span className="font-extrabold text-xl tracking-heading text-white">
                TheSpot<span className="text-primary">Market</span>
              </span>
            </Link>

            <p className="text-sm text-muted max-w-sm leading-relaxed">
              {siteConfig.tagline}. Track real-time Indian IPO subscriptions, Live Grey Market Premiums (GMP), and SpotAI sentiment analysis.
            </p>

            {/* Social Icons */}
            <div className="space-y-2">
              <span className="text-xs font-semibold uppercase tracking-wider text-subtle font-mono">
                Connect with us
              </span>
              <div className="flex items-center gap-2 pt-1">
                {/* Twitter / X */}
                <a
                  href={siteConfig.links.twitter}
                  target="_blank"
                  rel="noopener noreferrer"
                  className="h-9 w-9 rounded-xl bg-white/5 hover:bg-white/10 border border-white/10 flex items-center justify-center text-muted hover:text-white transition-all hover:scale-105 focus-visible:ring-2 focus-visible:ring-primary focus-visible:outline-none"
                  aria-label="TheSpotMarket on X (Twitter)"
                >
                  <svg className="h-4 w-4 fill-current" viewBox="0 0 24 24">
                    <path d="M18.244 2.25h3.308l-7.227 8.26 8.502 11.24H16.17l-5.214-6.817L4.99 21.75H1.68l7.73-8.835L1.254 2.25H8.08l4.713 6.231zm-1.161 17.52h1.833L7.084 4.126H5.117z" />
                  </svg>
                </a>

                {/* Telegram */}
                <a
                  href={siteConfig.links.telegram}
                  target="_blank"
                  rel="noopener noreferrer"
                  className="h-9 w-9 rounded-xl bg-white/5 hover:bg-white/10 border border-white/10 flex items-center justify-center text-muted hover:text-accent transition-all hover:scale-105 focus-visible:ring-2 focus-visible:ring-primary focus-visible:outline-none"
                  aria-label="TheSpotMarket on Telegram"
                >
                  <Send className="h-4 w-4" />
                </a>

                {/* LinkedIn */}
                <a
                  href={siteConfig.links.linkedin}
                  target="_blank"
                  rel="noopener noreferrer"
                  className="h-9 w-9 rounded-xl bg-white/5 hover:bg-white/10 border border-white/10 flex items-center justify-center text-muted hover:text-[#0a66c2] transition-all hover:scale-105 focus-visible:ring-2 focus-visible:ring-primary focus-visible:outline-none"
                  aria-label="TheSpotMarket on LinkedIn"
                >
                  <Linkedin className="h-4 w-4" />
                </a>

                {/* Instagram */}
                <a
                  href={siteConfig.links.instagram}
                  target="_blank"
                  rel="noopener noreferrer"
                  className="h-9 w-9 rounded-xl bg-white/5 hover:bg-white/10 border border-white/10 flex items-center justify-center text-muted hover:text-[#e4405f] transition-all hover:scale-105 focus-visible:ring-2 focus-visible:ring-primary focus-visible:outline-none"
                  aria-label="TheSpotMarket on Instagram"
                >
                  <Instagram className="h-4 w-4" />
                </a>

                {/* YouTube */}
                <a
                  href={siteConfig.links.youtube}
                  target="_blank"
                  rel="noopener noreferrer"
                  className="h-9 w-9 rounded-xl bg-white/5 hover:bg-white/10 border border-white/10 flex items-center justify-center text-muted hover:text-[#ff0000] transition-all hover:scale-105 focus-visible:ring-2 focus-visible:ring-primary focus-visible:outline-none"
                  aria-label="TheSpotMarket on YouTube"
                >
                  <Youtube className="h-4 w-4" />
                </a>
              </div>
            </div>
          </div>

          {/* Column 2: Product (Features, How it Works, FAQ) */}
          <div className="space-y-4">
            <h4 className="text-xs font-bold uppercase tracking-wider text-white font-mono">
              Product
            </h4>
            <ul className="space-y-2.5 text-sm" aria-label="Product Links">
              {siteConfig.footer.product.map((item) => (
                <li key={item.name}>
                  {item.isHash ? (
                    <a
                      href={item.path}
                      onClick={(e) => handleLinkClick(e, item)}
                      className="text-muted hover:text-white transition-colors focus-visible:ring-2 focus-visible:ring-primary focus-visible:rounded focus-visible:outline-none"
                    >
                      {item.name}
                    </a>
                  ) : (
                    <Link
                      to={item.path}
                      className="text-muted hover:text-white transition-colors focus-visible:ring-2 focus-visible:ring-primary focus-visible:rounded focus-visible:outline-none"
                    >
                      {item.name}
                    </Link>
                  )}
                </li>
              ))}
            </ul>
          </div>

          {/* Column 3: Company (About, Team, Contact) */}
          <div className="space-y-4">
            <h4 className="text-xs font-bold uppercase tracking-wider text-white font-mono">
              Company
            </h4>
            <ul className="space-y-2.5 text-sm" aria-label="Company Links">
              {siteConfig.footer.company.map((item) => (
                <li key={item.name}>
                  <Link
                    to={item.path}
                    className="text-muted hover:text-white transition-colors focus-visible:ring-2 focus-visible:ring-primary focus-visible:rounded focus-visible:outline-none"
                  >
                    {item.name}
                  </Link>
                </li>
              ))}
            </ul>
          </div>

          {/* Column 4: Legal (Privacy Policy, Terms, Disclaimer, Data Deletion) */}
          <div className="space-y-4">
            <h4 className="text-xs font-bold uppercase tracking-wider text-white font-mono">
              Legal & Compliance
            </h4>
            <ul className="space-y-2.5 text-sm" aria-label="Legal Links">
              {siteConfig.footer.legal.map((item) => (
                <li key={item.name}>
                  <Link
                    to={item.path}
                    className="text-muted hover:text-white transition-colors focus-visible:ring-2 focus-visible:ring-primary focus-visible:rounded focus-visible:outline-none"
                  >
                    {item.name}
                  </Link>
                </li>
              ))}
            </ul>
          </div>
        </div>

        {/* Bottom Section */}
        <div className="mt-12 pt-8 border-t border-white/5 space-y-6">
          {/* Mandatory Regulatory Disclaimer Banner */}
          <div className="flex justify-center">
            <div className="w-full max-w-3xl flex items-center justify-center gap-2.5 px-4 py-2.5 rounded-xl bg-bear/[0.08] border border-bear/20 text-red-300/90 text-xs text-center leading-relaxed">
              <ShieldAlert className="h-4 w-4 text-bear shrink-0" />
              <span>Not SEBI registered investment advice. Strictly for educational & tracking purposes.</span>
            </div>
          </div>

          {/* Copyright & Developer Credits Bar */}
          <div className="flex flex-col sm:flex-row items-center justify-between gap-3 text-xs text-subtle md:pr-36">
            <p className="text-center sm:text-left">
              © {new Date().getFullYear()} {siteConfig.legalName}. All rights reserved.
            </p>
            <p className="text-center sm:text-right text-muted whitespace-nowrap">
              Designed & Developed by{' '}
              <a
                href="https://techcreaturesolution.com/"
                target="_blank"
                rel="noopener noreferrer"
                className="text-white hover:text-accent font-semibold underline underline-offset-4 decoration-accent/40 hover:decoration-accent transition-colors"
              >
                Tech Creature Solution
              </a>
            </p>
          </div>
        </div>
      </div>
    </footer>
  );
}

export default Footer;
