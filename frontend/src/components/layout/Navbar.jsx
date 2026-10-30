import React, { useRef, useState, useEffect } from 'react';
import { Link, NavLink, useLocation, useNavigate } from 'react-router-dom';
import { Menu, X, Smartphone, ArrowRight } from 'lucide-react';
import { useGSAP } from '@gsap/react';
import { gsap, ScrollTrigger, scrollToTarget } from '@/lib/gsap';
import { Button } from '@/components/ui/Button';
import { siteConfig } from '@/lib/site';

export function Navbar() {
  const [isOpen, setIsOpen] = useState(false);
  const location = useLocation();
  const navigate = useNavigate();

  const navRef = useRef(null);
  const bgGlassRef = useRef(null);
  const drawerRef = useRef(null);
  const overlayRef = useRef(null);
  const linksContainerRef = useRef(null);
  const timelineRef = useRef(null);

  // 1. ScrollTrigger to smoothly fade-in glass background on scroll
  useGSAP(
    () => {
      const bgGlass = bgGlassRef.current;
      if (!bgGlass) return;

      const mm = gsap.matchMedia();

      mm.add('(prefers-reduced-motion: no-preference)', () => {
        // Initially transparent background
        gsap.set(bgGlass, { opacity: 0 });

        ScrollTrigger.create({
          start: 'top -20px',
          end: 'top -80px',
          scrub: true,
          onUpdate: (self) => {
            gsap.to(bgGlass, {
              opacity: self.progress,
              duration: 0.15,
              overwrite: 'auto',
            });
          },
        });
      });

      mm.add('(prefers-reduced-motion: reduce)', () => {
        gsap.set(bgGlass, { opacity: 1 });
      });

      return () => ScrollTrigger.getAll().forEach((t) => t.kill());
    },
    { scope: navRef }
  );

  // 2. GSAP timeline-driven slide-in drawer for mobile
  useGSAP(
    () => {
      const overlay = overlayRef.current;
      const drawer = drawerRef.current;
      const linksContainer = linksContainerRef.current;

      if (!overlay || !drawer || !linksContainer) return;

      // Initialize hidden states
      gsap.set(overlay, { opacity: 0, pointerEvents: 'none' });
      gsap.set(drawer, { x: '100%' });

      // Create reusable timeline
      const tl = gsap.timeline({
        paused: true,
        onReverseComplete: () => {
          gsap.set(overlay, { pointerEvents: 'none' });
        },
      });

      tl.to(overlay, {
        opacity: 1,
        pointerEvents: 'auto',
        duration: 0.25,
        ease: 'power2.out',
      })
        .to(
          drawer,
          {
            x: '0%',
            duration: 0.35,
            ease: 'power3.out',
          },
          '-=0.15'
        )
        .fromTo(
          linksContainer.children,
          { opacity: 0, x: 24 },
          {
            opacity: 1,
            x: 0,
            duration: 0.22,
            stagger: 0.05,
            ease: 'power2.out',
          },
          '-=0.2'
        );

      timelineRef.current = tl;
    },
    { scope: navRef }
  );

  // Play / reverse drawer timeline on state change
  useEffect(() => {
    const tl = timelineRef.current;
    if (!tl) return;

    if (isOpen) {
      document.body.style.overflow = 'hidden';
      tl.play();
    } else {
      document.body.style.overflow = '';
      tl.reverse();
    }
  }, [isOpen]);

  // Keyboard accessibility: Close drawer on Escape
  useEffect(() => {
    const handleKeyDown = (e) => {
      if (e.key === 'Escape' && isOpen) {
        setIsOpen(false);
      }
    };

    window.addEventListener('keydown', handleKeyDown);
    return () => window.removeEventListener('keydown', handleKeyDown);
  }, [isOpen]);

  // Close drawer on route change
  useEffect(() => {
    setIsOpen(false);
  }, [location.pathname]);

  // Handle smooth hash navigation
  const handleNavClick = (e, link) => {
    if (link.isHash) {
      e.preventDefault();
      setIsOpen(false);

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
    } else {
      setIsOpen(false);
    }
  };

  return (
    <header
      ref={navRef}
      className="sticky top-0 z-50 w-full transition-colors duration-300"
    >
      {/* Dynamic Glass Backdrop Layer */}
      <div
        ref={bgGlassRef}
        className="absolute inset-0 bg-background/85 backdrop-blur-xl border-b border-white/10 pointer-events-none shadow-lg"
      />

      <div className="relative mx-auto flex h-18 max-w-7xl items-center justify-between px-4 sm:px-6 lg:px-8 py-3">
        {/* Brand Logo & Name */}
        <Link
          to="/"
          className="flex items-center gap-3 group focus-visible:ring-2 focus-visible:ring-primary focus-visible:rounded-xl focus-visible:outline-none"
          aria-label="TheSpotMarket Home"
        >
          <img
            src="/images/app_icon.png"
            alt="TheSpotMarket App Icon"
            width="40"
            height="40"
            className="h-10 w-10 rounded-xl object-cover border border-primary/40 shadow-sm transition-transform duration-200 group-hover:scale-105"
            onError={(e) => {
              // Fallback if image fails to load
              e.currentTarget.style.display = 'none';
            }}
          />
          <div className="flex flex-col">
            <span className="font-extrabold text-xl tracking-heading text-white leading-none">
              TheSpot<span className="text-primary">Market</span>
            </span>
            <span className="text-[10px] font-semibold text-subtle tracking-wider uppercase mt-1">
              IPO & Market Intel
            </span>
          </div>
        </Link>

        {/* Desktop Navigation Links */}
        <nav
          className="hidden md:flex items-center gap-1 lg:gap-2"
          aria-label="Primary Navigation"
        >
          {siteConfig.nav.map((link) => {
            if (link.isHash) {
              return (
                <a
                  key={link.name}
                  href={link.path}
                  onClick={(e) => handleNavClick(e, link)}
                  className="px-3.5 py-2 rounded-xl text-sm font-medium text-muted hover:text-white hover:bg-white/5 transition-all duration-200 focus-visible:ring-2 focus-visible:ring-primary focus-visible:outline-none"
                >
                  {link.name}
                </a>
              );
            }

            return (
              <NavLink
                key={link.name}
                to={link.path}
                className={({ isActive }) =>
                  `px-3.5 py-2 rounded-xl text-sm font-medium transition-all duration-200 focus-visible:ring-2 focus-visible:ring-primary focus-visible:outline-none ${
                    isActive
                      ? 'text-white bg-white/10 font-semibold'
                      : 'text-muted hover:text-white hover:bg-white/5'
                  }`
                }
              >
                {link.name}
              </NavLink>
            );
          })}
        </nav>

        {/* Right Side: Download App Glass Button */}
        <div className="hidden md:flex items-center gap-3">
          <Button
            href={siteConfig.links.playStore}
            variant="glass"
            size="sm"
            icon={<Smartphone className="h-4 w-4 text-accent" />}
            className="font-semibold border-primary/30 hover:border-primary"
          >
            Download App
          </Button>
        </div>

        {/* Mobile Hamburger Toggle Button */}
        <button
          type="button"
          onClick={() => setIsOpen(!isOpen)}
          className="md:hidden inline-flex items-center justify-center p-2.5 rounded-xl text-muted hover:text-white hover:bg-white/5 border border-white/10 focus-visible:ring-2 focus-visible:ring-primary focus-visible:outline-none"
          aria-label={isOpen ? 'Close menu' : 'Open navigation menu'}
          aria-expanded={isOpen}
          aria-controls="mobile-navigation-drawer"
        >
          {isOpen ? <X className="h-6 w-6" /> : <Menu className="h-6 w-6" />}
        </button>
      </div>

      {/* Mobile Drawer Backdrop Overlay */}
      <div
        ref={overlayRef}
        onClick={() => setIsOpen(false)}
        className="fixed inset-0 bg-black/70 backdrop-blur-sm z-50 md:hidden"
        aria-hidden="true"
      />

      {/* Mobile Slide-in Drawer */}
      <div
        ref={drawerRef}
        id="mobile-navigation-drawer"
        role="dialog"
        aria-modal="true"
        aria-label="Mobile Navigation Menu"
        className="fixed top-0 right-0 bottom-0 w-full max-w-xs bg-surface border-l border-white/10 z-50 md:hidden flex flex-col justify-between p-6 shadow-2xl overflow-y-auto"
      >
        <div className="space-y-6">
          {/* Header of Drawer */}
          <div className="flex items-center justify-between border-b border-white/10 pb-4">
            <div className="flex items-center gap-2.5">
              <img
                src="/images/app_icon.png"
                alt="Logo"
                width="32"
                height="32"
                className="h-8 w-8 rounded-lg object-cover border border-primary/30"
              />
              <span className="font-extrabold text-lg text-white">
                TheSpot<span className="text-primary">Market</span>
              </span>
            </div>
            <button
              type="button"
              onClick={() => setIsOpen(false)}
              className="p-2 rounded-lg text-muted hover:text-white hover:bg-white/5 focus-visible:ring-2 focus-visible:ring-primary focus-visible:outline-none"
              aria-label="Close drawer"
            >
              <X className="h-5 w-5" />
            </button>
          </div>

          {/* Staggered Nav Links List */}
          <nav
            ref={linksContainerRef}
            className="flex flex-col space-y-1.5"
            aria-label="Mobile Navigation"
          >
            {siteConfig.nav.map((link) => {
              if (link.isHash) {
                return (
                  <a
                    key={link.name}
                    href={link.path}
                    onClick={(e) => handleNavClick(e, link)}
                    className="flex items-center justify-between px-3.5 py-3 rounded-xl text-base font-medium text-muted hover:text-white hover:bg-white/5 transition-colors focus-visible:ring-2 focus-visible:ring-primary focus-visible:outline-none"
                  >
                    <span>{link.name}</span>
                    <ArrowRight className="h-4 w-4 text-subtle" />
                  </a>
                );
              }

              return (
                <NavLink
                  key={link.name}
                  to={link.path}
                  onClick={() => setIsOpen(false)}
                  className={({ isActive }) =>
                    `flex items-center justify-between px-3.5 py-3 rounded-xl text-base font-medium transition-colors focus-visible:ring-2 focus-visible:ring-primary focus-visible:outline-none ${
                      isActive
                        ? 'text-white bg-white/10 font-bold'
                        : 'text-muted hover:text-white hover:bg-white/5'
                    }`
                  }
                >
                  <span>{link.name}</span>
                  <ArrowRight className="h-4 w-4 text-subtle" />
                </NavLink>
              );
            })}
          </nav>
        </div>

        {/* Drawer Bottom CTA */}
        <div className="pt-6 border-t border-white/10 space-y-3">
          <Button
            href={siteConfig.links.playStore}
            variant="primary"
            size="md"
            className="w-full font-bold"
            icon={<Smartphone className="h-4 w-4" />}
          >
            Download Mobile App
          </Button>
          <p className="text-[11px] text-center text-subtle">
            Android & iOS • Real-Time Market Intelligence
          </p>
        </div>
      </div>
    </header>
  );
}

export default Navbar;
