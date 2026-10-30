import React, { useState, useRef, useEffect } from 'react';
import { Helmet } from 'react-helmet-async';
import { useForm } from 'react-hook-form';
import { zodResolver } from '@hookform/resolvers/zod';
import * as z from 'zod';
import { useGSAP } from '@gsap/react';
import gsap from 'gsap';
import { ScrollTrigger } from '@/lib/gsap';
import {
  Mail,
  Clock,
  MapPin,
  MessageSquare,
  Send,
  CheckCircle2,
  AlertCircle,
  Loader2,
  Twitter,
  Linkedin,
  Github,
  ExternalLink,
  ShieldCheck,
  RotateCcw,
  Sparkles,
  ChevronDown,
  Check,
} from 'lucide-react';
import { Container } from '@/components/ui/Container';
import { SectionHeading } from '@/components/ui/SectionHeading';
import { GradientText } from '@/components/ui/GradientText';
import { GlassCard } from '@/components/ui/GlassCard';
import { Badge } from '@/components/ui/Badge';
import { Button } from '@/components/ui/Button';
import { FaqAccordionSection } from '@/components/sections/FaqAccordionSection';
import { siteConfig } from '@/lib/site';

// API Base URL from Vite env with fallback to localhost:3000
const API_BASE_URL = (import.meta.env.VITE_API_URL || 'http://localhost:3000').replace(/\/$/, '');

// Contact Form Validation Schema
const contactSchema = z.object({
  name: z
    .string()
    .min(2, { message: 'Name must be at least 2 characters long.' })
    .max(100, { message: 'Name cannot exceed 100 characters.' }),
  email: z
    .string()
    .min(1, { message: 'Email address is required.' })
    .email({ message: 'Please enter a valid email address.' })
    .max(150, { message: 'Email cannot exceed 150 characters.' }),
  subject: z
    .string()
    .min(1, { message: 'Please select a subject category.' }),
  message: z
    .string()
    .min(10, { message: 'Message must be at least 10 characters long.' })
    .max(4000, { message: 'Message cannot exceed 4000 characters.' }),
  // Invisible honeypot field (must remain empty)
  hp: z.string().optional(),
});

const SUBJECT_OPTIONS = [
  'General Inquiry',
  'IPO Allotment Support',
  'SpotAI Feedback',
  'Bug Report / Feature Request',
  'Partnership & Press',
  'Other',
];

export function ContactPage() {
  const containerRef = useRef(null);
  const successRef = useRef(null);
  const formCardRef = useRef(null);

  // Form submission state: 'idle' | 'loading' | 'success' | 'error'
  const [formStatus, setFormStatus] = useState('idle');
  const [serverMessage, setServerMessage] = useState('');
  const [isServiceUnavailable, setIsServiceUnavailable] = useState(false);

  const [isDropdownOpen, setIsDropdownOpen] = useState(false);
  const dropdownRef = useRef(null);

  const {
    register,
    handleSubmit,
    reset,
    setValue,
    watch,
    formState: { errors, isSubmitting },
  } = useForm({
    resolver: zodResolver(contactSchema),
    defaultValues: {
      name: '',
      email: '',
      subject: 'General Inquiry',
      message: '',
      hp: '',
    },
  });

  const currentSubject = watch('subject') || 'General Inquiry';

  // Close dropdown on click outside
  useEffect(() => {
    function handleClickOutside(event) {
      if (dropdownRef.current && !dropdownRef.current.contains(event.target)) {
        setIsDropdownOpen(false);
      }
    }
    if (isDropdownOpen) {
      document.addEventListener('mousedown', handleClickOutside);
    }
    return () => {
      document.removeEventListener('mousedown', handleClickOutside);
    };
  }, [isDropdownOpen]);

  useEffect(() => {
    const timer = setTimeout(() => {
      ScrollTrigger.refresh();
    }, 150);
    return () => clearTimeout(timer);
  }, []);

  // GSAP animation for success card entry
  useGSAP(
    () => {
      if (formStatus === 'success' && successRef.current) {
        const prefersReduced = window.matchMedia('(prefers-reduced-motion: reduce)').matches;
        if (prefersReduced) return;

        gsap.fromTo(
          successRef.current,
          { scale: 0.9, opacity: 0 },
          { scale: 1, opacity: 1, duration: 0.5, ease: 'back.out(1.6)' }
        );

        gsap.fromTo(
          '.success-badge-icon',
          { scale: 0, rotate: -45 },
          { scale: 1, rotate: 0, duration: 0.6, delay: 0.15, ease: 'back.out(2)' }
        );

        gsap.fromTo(
          '.success-text-line',
          { opacity: 0, y: 15 },
          { opacity: 1, y: 0, duration: 0.45, stagger: 0.1, delay: 0.25, ease: 'power2.out' }
        );
      }
    },
    { dependencies: [formStatus], scope: containerRef }
  );

  const onSubmit = async (formData) => {
    setFormStatus('loading');
    setServerMessage('');
    setIsServiceUnavailable(false);

    try {
      const response = await fetch(`${API_BASE_URL}/api/contact`, {
        method: 'POST',
        headers: {
          'Content-Type': 'application/json',
          Accept: 'application/json',
        },
        body: JSON.stringify(formData),
      });

      const data = await response.json().catch(() => ({}));

      if (response.ok && data.success) {
        setFormStatus('success');
        setServerMessage(
          data.message ||
            'Thank you for reaching out! Your message has been received, and our team will get back to you shortly.'
        );
        reset();
      } else if (response.status === 503) {
        // SMTP unconfigured friendly fallback
        setFormStatus('error');
        setIsServiceUnavailable(true);
        setServerMessage(
          data.message ||
            'Contact email delivery is currently unconfigured or unavailable. Please write directly to thespotmarket29@gmail.com.'
        );
      } else if (response.status === 429) {
        // Rate limit reached
        setFormStatus('error');
        setServerMessage(
          data.message ||
            'You have made too many contact submissions recently. Please wait 15 minutes before submitting again.'
        );
      } else {
        // Validation / honeypot error
        setFormStatus('error');
        setServerMessage(
          data.message || 'Unable to submit your message. Please review the form and try again.'
        );
      }
    } catch (err) {
      console.error('[CONTACT_SUBMISSION_ERROR]', err);
      setFormStatus('error');
      setServerMessage(
        'Unable to reach the server. Please check your network connection or email us directly at ' +
          siteConfig.contactEmail
      );
    }
  };

  const handleResetForm = () => {
    setFormStatus('idle');
    setServerMessage('');
    setIsServiceUnavailable(false);
    reset();
  };

  // Schema.org BreadcrumbList JSON-LD
  const breadcrumbJsonLd = {
    '@context': 'https://schema.org',
    '@type': 'BreadcrumbList',
    itemListElement: [
      {
        '@type': 'ListItem',
        position: 1,
        name: 'Home',
        item: siteConfig.url,
      },
      {
        '@type': 'ListItem',
        position: 2,
        name: 'Contact',
        item: `${siteConfig.url}/contact`,
      },
    ],
  };

  return (
    <div ref={containerRef} className="space-y-8 sm:space-y-12 pb-12 overflow-hidden">
      {/* SEO Helmet */}
      <Helmet>
        <title>Contact Us - TheSpotMarket | Support, Inquiries & Feedback</title>
        <meta
          name="description"
          content="Get in touch with TheSpotMarket team for inquiries regarding IPO data, SpotAI analysis, bug reports, and partnership opportunities."
        />
        <meta property="og:title" content="Contact TheSpotMarket Team" />
        <meta
          property="og:description"
          content="Reach out directly to our engineering, product, and market intelligence researchers."
        />
        <meta property="og:url" content={`${siteConfig.url}/contact`} />
        <meta property="og:type" content="website" />
        <link rel="canonical" href={`${siteConfig.url}/contact`} />
        <script type="application/ld+json">{JSON.stringify(breadcrumbJsonLd)}</script>
      </Helmet>

      {/* 1. Hero Header */}
      <section className="relative pt-10 sm:pt-14 pb-4 bg-radial-glow">
        <Container>
          <div className="max-w-4xl mx-auto text-center space-y-6">
            <div className="inline-flex">
              <Badge variant="primary" size="md">
                Get in Touch
              </Badge>
            </div>

            <h1 className="text-4xl sm:text-5xl lg:text-6xl font-extrabold text-white tracking-tight leading-[1.15]">
              We'd Love to <GradientText>Hear From You</GradientText>
            </h1>

            <p className="text-lg sm:text-xl text-muted max-w-2xl mx-auto leading-relaxed">
              Have questions about live IPO data, SpotAI prospectus queries, bug reports, or
              partnerships? Send us a message and we'll reply promptly.
            </p>
          </div>
        </Container>
      </section>

      {/* 2. Main Layout: Left Info Cards + Right Interactive Form */}
      <section className="relative">
        <Container>
          <div className="grid grid-cols-1 lg:grid-cols-12 gap-8 lg:gap-10 max-w-6xl mx-auto items-stretch">
            {/* LEFT COLUMN: Contact Info & Support Channels (5 Cols) */}
            <div className="lg:col-span-5 flex flex-col justify-between gap-5">
              {/* Card 1: Direct Email Support & Operating Hours */}
              <GlassCard hover className="p-6 border-white/10 hover:border-primary/40 flex-1 flex flex-col justify-between">
                <div>
                  <div className="flex items-center justify-between mb-4">
                    <div className="w-11 h-11 rounded-xl bg-primary/20 border border-primary/30 flex items-center justify-center text-accent">
                      <Mail className="w-5 h-5" />
                    </div>
                    <Badge variant="primary" size="sm" className="font-mono text-[11px]">
                      &lt; 24h Response
                    </Badge>
                  </div>

                  <div>
                    <h3 className="text-lg font-bold text-white">Direct Email Support</h3>
                    <p className="text-xs text-subtle mt-0.5">
                      For technical inquiries, bug reports, and feedback
                    </p>
                  </div>

                  <div className="mt-3.5 p-3 rounded-xl bg-surface/60 border border-white/5 space-y-1">
                    <a
                      href={`mailto:${siteConfig.contactEmail}`}
                      className="text-sm font-mono text-accent hover:underline block font-semibold"
                    >
                      {siteConfig.contactEmail}
                    </a>
                    <a
                      href={`mailto:${siteConfig.pressEmail}`}
                      className="text-xs font-mono text-muted hover:underline block"
                    >
                      Press & Partnerships: {siteConfig.pressEmail}
                    </a>
                  </div>
                </div>

                <div className="mt-5 pt-4 border-t border-white/5 flex items-start gap-3.5">
                  <div className="w-9 h-9 rounded-lg bg-accent/20 border border-accent/30 flex items-center justify-center text-accent shrink-0 mt-0.5">
                    <Clock className="w-4 h-4" />
                  </div>
                  <div className="text-xs space-y-0.5">
                    <p className="font-bold text-white">Monday – Friday: 9:00 AM – 6:30 PM IST</p>
                    <p className="text-subtle">
                      Active during Indian exchange trading sessions. Weekend inquiries are answered on the following business day.
                    </p>
                  </div>
                </div>
              </GlassCard>

              {/* Card 2: Registered Presence, Official Channels & Privacy */}
              <GlassCard hover className="p-6 border-white/10 hover:border-accent/40 flex-1 flex flex-col justify-between">
                <div className="space-y-4">
                  {/* Location & Entity */}
                  <div className="flex items-start gap-3.5">
                    <div className="w-11 h-11 rounded-xl bg-surface-2 border border-white/10 flex items-center justify-center text-accent shrink-0">
                      <MapPin className="w-5 h-5" />
                    </div>
                    <div>
                      <h3 className="text-base font-bold text-white">Registered Presence</h3>
                      <p className="text-xs text-subtle mt-0.5">{siteConfig.legalName}</p>
                      <p className="text-xs text-muted mt-1 leading-relaxed">
                        {siteConfig.address}
                      </p>
                    </div>
                  </div>

                  {/* Social Channels */}
                  <div className="pt-3 border-t border-white/5">
                    <h4 className="text-xs font-bold uppercase tracking-wider text-white/80 font-mono mb-2.5">
                      Official Channels
                    </h4>
                    <div className="flex items-center gap-2.5">
                      <a
                        href={siteConfig.links.telegram}
                        target="_blank"
                        rel="noopener noreferrer"
                        aria-label="Telegram"
                        className="flex-1 p-2.5 rounded-xl bg-surface border border-white/5 hover:border-primary/40 hover:bg-primary/10 flex items-center justify-center gap-2 text-xs font-medium text-white transition-colors"
                      >
                        <MessageSquare className="w-4 h-4 text-accent" />
                        <span>Telegram</span>
                      </a>
                      <a
                        href={siteConfig.socials.twitter}
                        target="_blank"
                        rel="noopener noreferrer"
                        aria-label="Twitter / X"
                        className="w-10 h-10 rounded-xl bg-surface border border-white/5 hover:border-primary/40 hover:bg-primary/10 flex items-center justify-center text-subtle hover:text-white transition-colors"
                      >
                        <Twitter className="w-4 h-4" />
                      </a>
                      <a
                        href={siteConfig.socials.linkedin}
                        target="_blank"
                        rel="noopener noreferrer"
                        aria-label="LinkedIn"
                        className="w-10 h-10 rounded-xl bg-surface border border-white/5 hover:border-primary/40 hover:bg-primary/10 flex items-center justify-center text-subtle hover:text-white transition-colors"
                      >
                        <Linkedin className="w-4 h-4" />
                      </a>
                      <a
                        href={siteConfig.socials.github}
                        target="_blank"
                        rel="noopener noreferrer"
                        aria-label="GitHub"
                        className="w-10 h-10 rounded-xl bg-surface border border-white/5 hover:border-primary/40 hover:bg-primary/10 flex items-center justify-center text-subtle hover:text-white transition-colors"
                      >
                        <Github className="w-4 h-4" />
                      </a>
                    </div>
                  </div>
                </div>

                {/* Privacy Guarantee Note */}
                <div className="mt-4 pt-3 border-t border-white/5 flex items-center gap-2.5 text-[11px] text-subtle">
                  <ShieldCheck className="w-4 h-4 text-accent shrink-0" />
                  <span>
                    We strictly respect your privacy. Contact details are never shared or sold.
                  </span>
                </div>
              </GlassCard>
            </div>

            {/* RIGHT COLUMN: Interactive Form / Success Card (7 Cols) */}
            <div className="lg:col-span-7 flex flex-col">
              <GlassCard
                ref={formCardRef}
                className="p-8 sm:p-10 border-white/10 relative overflow-hidden flex-1 flex flex-col justify-between"
              >
                {/* Visual Ambient Glow */}
                <div className="absolute top-0 right-0 w-48 h-48 bg-primary/10 rounded-full blur-3xl pointer-events-none" />

                {formStatus === 'success' ? (
                  /* SUCCESS ANIMATED STATE */
                  <div
                    ref={successRef}
                    className="py-12 px-4 text-center space-y-6 max-w-lg mx-auto"
                  >
                    <div className="success-badge-icon w-20 h-20 rounded-3xl bg-primary/20 border-2 border-primary mx-auto flex items-center justify-center shadow-[0_0_30px_rgba(16,185,129,0.4)]">
                      <CheckCircle2 className="w-10 h-10 text-accent" />
                    </div>

                    <div className="space-y-2">
                      <h3 className="success-text-line text-2xl sm:text-3xl font-extrabold text-white">
                        Message Sent Successfully!
                      </h3>
                      <p className="success-text-line text-sm sm:text-base text-muted leading-relaxed">
                        {serverMessage}
                      </p>
                    </div>

                    <div className="success-text-line p-4 rounded-2xl bg-surface-2 border border-white/5 text-xs text-subtle font-mono">
                      A confirmation ticket has been dispatched to our engineering team. Expect a
                      reply within 24 business hours.
                    </div>

                    <div className="success-text-line pt-2">
                      <Button
                        type="button"
                        variant="primary"
                        size="md"
                        onClick={handleResetForm}
                        className="inline-flex items-center gap-2"
                      >
                        <RotateCcw className="w-4 h-4" />
                        <span>Send Another Message</span>
                      </Button>
                    </div>
                  </div>
                ) : (
                  /* INTERACTIVE FORM STATE */
                  <form onSubmit={handleSubmit(onSubmit)} noValidate className="space-y-6">
                    <div>
                      <h2 className="text-2xl font-bold text-white tracking-tight">
                        Send Us a Message
                      </h2>
                      <p className="text-sm text-muted mt-1">
                        Fill in your details below and our team will get back to you shortly.
                      </p>
                    </div>

                    {/* Server Error Alert Banner */}
                    {formStatus === 'error' && (
                      <div
                        role="alert"
                        className="p-4 rounded-2xl bg-red-950/40 border border-red-500/40 flex items-start gap-3 text-red-200 text-sm"
                      >
                        <AlertCircle className="w-5 h-5 text-red-400 shrink-0 mt-0.5" />
                        <div className="space-y-1">
                          <p className="font-semibold text-white">Submission Notice</p>
                          <p className="text-xs text-red-300 leading-relaxed">{serverMessage}</p>
                          {isServiceUnavailable && (
                            <div className="pt-1">
                              <a
                                href={`mailto:${siteConfig.contactEmail}?subject=Direct%20Inquiry%20via%20Website`}
                                className="inline-flex items-center gap-1.5 text-xs font-mono text-accent hover:underline font-bold"
                              >
                                <span>Click here to send direct email</span>
                                <ExternalLink className="w-3 h-3" />
                              </a>
                            </div>
                          )}
                        </div>
                      </div>
                    )}

                    {/* Hidden Honeypot Input (Spam prevention) */}
                    <div
                      aria-hidden="true"
                      style={{
                        position: 'absolute',
                        left: '-9999px',
                        top: '-9999px',
                        opacity: 0,
                        height: 0,
                        width: 0,
                        pointerEvents: 'none',
                      }}
                    >
                      <label htmlFor="hp_field">Leave this field blank</label>
                      <input
                        id="hp_field"
                        type="text"
                        tabIndex={-1}
                        autoComplete="off"
                        {...register('hp')}
                      />
                    </div>

                    {/* Name & Email Fields */}
                    <div className="grid grid-cols-1 sm:grid-cols-2 gap-5">
                      {/* Name */}
                      <div className="space-y-1.5">
                        <label
                          htmlFor="contact_name"
                          className="block text-xs font-mono font-medium text-white/90 uppercase tracking-wider"
                        >
                          Full Name <span className="text-accent">*</span>
                        </label>
                        <input
                          id="contact_name"
                          type="text"
                          placeholder="Ravi Sharma"
                          aria-invalid={errors.name ? 'true' : 'false'}
                          disabled={isSubmitting}
                          {...register('name')}
                          className={`w-full px-4 py-3 rounded-xl bg-surface-2 border text-white text-sm placeholder:text-white/30 focus:outline-none transition-all duration-200 ${
                            errors.name
                              ? 'border-red-500/80 focus:border-red-400 focus:ring-1 focus:ring-red-400'
                              : 'border-white/10 hover:border-white/20 focus:border-primary focus:ring-1 focus:ring-primary'
                          }`}
                        />
                        {errors.name && (
                          <p role="alert" className="text-xs text-red-400 mt-1">
                            {errors.name.message}
                          </p>
                        )}
                      </div>

                      {/* Email */}
                      <div className="space-y-1.5">
                        <label
                          htmlFor="contact_email"
                          className="block text-xs font-mono font-medium text-white/90 uppercase tracking-wider"
                        >
                          Email Address <span className="text-accent">*</span>
                        </label>
                        <input
                          id="contact_email"
                          type="email"
                          placeholder="ravi@example.com"
                          aria-invalid={errors.email ? 'true' : 'false'}
                          disabled={isSubmitting}
                          {...register('email')}
                          className={`w-full px-4 py-3 rounded-xl bg-surface-2 border text-white text-sm placeholder:text-white/30 focus:outline-none transition-all duration-200 ${
                            errors.email
                              ? 'border-red-500/80 focus:border-red-400 focus:ring-1 focus:ring-red-400'
                              : 'border-white/10 hover:border-white/20 focus:border-primary focus:ring-1 focus:ring-primary'
                          }`}
                        />
                        {errors.email && (
                          <p role="alert" className="text-xs text-red-400 mt-1">
                            {errors.email.message}
                          </p>
                        )}
                      </div>
                    </div>

                    {/* Subject Select (Theme-Styled Custom Dropdown) */}
                    <div className="space-y-1.5 relative" ref={dropdownRef}>
                      <label
                        htmlFor="contact_subject_btn"
                        className="block text-xs font-mono font-medium text-white/90 uppercase tracking-wider"
                      >
                        Inquiry Topic <span className="text-accent">*</span>
                      </label>

                      {/* Hidden registered input for form submission & validation */}
                      <input type="hidden" {...register('subject')} value={currentSubject} />

                      {/* Theme-Styled Trigger Button */}
                      <button
                        id="contact_subject_btn"
                        type="button"
                        disabled={isSubmitting}
                        onClick={() => setIsDropdownOpen(!isDropdownOpen)}
                        aria-haspopup="listbox"
                        aria-expanded={isDropdownOpen}
                        className={`w-full px-4 py-3 rounded-xl bg-surface-2 border text-sm flex items-center justify-between text-left transition-all duration-200 focus:outline-none ${
                          errors.subject
                            ? 'border-red-500/80 focus:border-red-400'
                            : isDropdownOpen
                            ? 'border-primary ring-1 ring-primary shadow-[0_0_20px_rgba(16,185,129,0.25)] text-white'
                            : 'border-white/10 hover:border-white/20 text-white focus:border-primary focus:ring-1 focus:ring-primary'
                        }`}
                      >
                        <span className="font-medium text-white flex items-center gap-2.5">
                          <span className="w-2 h-2 rounded-full bg-accent shadow-[0_0_8px_rgba(16,185,129,0.8)]" />
                          {currentSubject}
                        </span>
                        <ChevronDown
                          className={`w-4 h-4 text-accent transition-transform duration-200 ${
                            isDropdownOpen ? 'rotate-180' : ''
                          }`}
                        />
                      </button>

                      {/* Theme-Styled Options Menu */}
                      {isDropdownOpen && (
                        <div
                          role="listbox"
                          tabIndex={-1}
                          className="absolute left-0 right-0 top-full mt-2 z-50 p-1.5 rounded-xl bg-[#06120B]/95 backdrop-blur-xl border border-primary/30 shadow-[0_15px_50px_rgba(0,0,0,0.95),0_0_30px_rgba(16,185,129,0.2)] overflow-hidden animate-in fade-in zoom-in-95 duration-150"
                        >
                          <div className="space-y-1">
                            {SUBJECT_OPTIONS.map((sub, idx) => {
                              const isSelected = currentSubject === sub;
                              return (
                                <button
                                  key={idx}
                                  type="button"
                                  role="option"
                                  aria-selected={isSelected}
                                  onClick={() => {
                                    setValue('subject', sub, { shouldValidate: true });
                                    setIsDropdownOpen(false);
                                  }}
                                  className={`w-full px-3.5 py-2.5 rounded-lg text-sm text-left flex items-center justify-between transition-all duration-150 group ${
                                    isSelected
                                      ? 'bg-primary/25 text-white font-semibold border border-primary/40 shadow-sm'
                                      : 'text-muted hover:text-white hover:bg-primary/15 hover:pl-4'
                                  }`}
                                >
                                  <span className="flex items-center gap-2.5">
                                    <span
                                      className={`w-1.5 h-1.5 rounded-full transition-all ${
                                        isSelected
                                          ? 'bg-accent shadow-[0_0_6px_rgba(16,185,129,0.8)]'
                                          : 'bg-transparent group-hover:bg-accent/60'
                                      }`}
                                    />
                                    {sub}
                                  </span>
                                  {isSelected && (
                                    <Check className="w-4 h-4 text-accent animate-in fade-in" />
                                  )}
                                </button>
                              );
                            })}
                          </div>
                        </div>
                      )}

                      {errors.subject && (
                        <p role="alert" className="text-xs text-red-400 mt-1">
                          {errors.subject.message}
                        </p>
                      )}
                    </div>

                    {/* Message Area */}
                    <div className="space-y-1.5">
                      <label
                        htmlFor="contact_message"
                        className="block text-xs font-mono font-medium text-white/90 uppercase tracking-wider"
                      >
                        Message <span className="text-accent">*</span>
                      </label>
                      <textarea
                        id="contact_message"
                        rows={5}
                        placeholder="Please describe your question, feedback, or report with as much detail as possible..."
                        aria-invalid={errors.message ? 'true' : 'false'}
                        disabled={isSubmitting}
                        {...register('message')}
                        className={`w-full px-4 py-3 rounded-xl bg-surface-2 border text-white text-sm placeholder:text-white/30 focus:outline-none transition-all duration-200 resize-y min-h-[120px] ${
                          errors.message
                            ? 'border-red-500/80 focus:border-red-400 focus:ring-1 focus:ring-red-400'
                            : 'border-white/10 hover:border-white/20 focus:border-primary focus:ring-1 focus:ring-primary'
                        }`}
                      />
                      {errors.message && (
                        <p role="alert" className="text-xs text-red-400 mt-1">
                          {errors.message.message}
                        </p>
                      )}
                    </div>

                    {/* Submit Button */}
                    <div className="pt-2">
                      <Button
                        type="submit"
                        variant="primary"
                        size="lg"
                        disabled={isSubmitting}
                        className="w-full justify-center group"
                      >
                        {isSubmitting ? (
                          <>
                            <Loader2 className="w-4 h-4 mr-2 animate-spin text-accent" />
                            <span>Sending Message...</span>
                          </>
                        ) : (
                          <>
                            <Send className="w-4 h-4 mr-2 transition-transform duration-300 group-hover:translate-x-0.5" />
                            <span>Send Message</span>
                          </>
                        )}
                      </Button>
                    </div>

                    <p className="text-[11px] text-center text-subtle font-mono">
                      Submissions are protected by client-side verification and rate limiting.
                    </p>
                  </form>
                )}
              </GlassCard>
            </div>
          </div>
        </Container>
      </section>

      {/* Frequently Asked Questions (FAQ) Section */}
      <div className="border-t border-white/5 pt-4 pb-8">
        <FaqAccordionSection />
      </div>
    </div>
  );
}

export default ContactPage;
