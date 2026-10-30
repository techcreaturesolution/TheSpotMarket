// NOTE: This legal document template reflects actual technical implementation and is for informational transparency.
// It should be reviewed by a qualified Indian cyber/securities lawyer before official commercial publication.

import React from 'react';
import { Helmet } from 'react-helmet-async';
import { Link } from 'react-router-dom';
import { Scale, AlertTriangle, ShieldCheck, CheckCircle2, ExternalLink } from 'lucide-react';
import LegalLayout from '@/components/layout/LegalLayout';
import { siteConfig } from '@/lib/site';

const TOC = [
  { id: 'acceptance', title: '1. Acceptance of Terms' },
  { id: 'eligibility', title: '2. Eligibility (18+ Age Restriction)' },
  { id: 'services-description', title: '3. Description of Platform Services' },
  { id: 'non-sebi-agreement', title: '4. Non-Advisory Agreement & No Tips' },
  { id: 'accounts', title: '5. Accounts & Authentication' },
  { id: 'acceptable-use', title: '6. Acceptable Use & Conduct' },
  { id: 'intellectual-property', title: '7. Intellectual Property Rights' },
  { id: 'third-parties-ads', title: '8. Third Parties & AdMob Advertising' },
  { id: 'disclaimer-warranties', title: '9. Disclaimer of Warranties & Feed Latency' },
  { id: 'limitation-liability', title: '10. Limitation of Liability' },
  { id: 'indemnification', title: '11. Indemnification' },
  { id: 'account-termination', title: '12. Termination & Account Deletion' },
  { id: 'governing-law', title: '13. Governing Law & Dispute Resolution' },
  { id: 'contact', title: '14. Contact & Legal Notices' },
];

export function TermsPage() {
  const breadcrumbJsonLd = {
    '@context': 'https://schema.org',
    '@type': 'BreadcrumbList',
    itemListElement: [
      { '@type': 'ListItem', position: 1, name: 'Home', item: siteConfig.url },
      { '@type': 'ListItem', position: 2, name: 'Terms of Service', item: `${siteConfig.url}/terms` },
    ],
  };

  return (
    <>
      <Helmet>
        <title>Terms of Service - TheSpotMarket | User Agreement</title>
        <meta
          name="description"
          content="Terms of Service for TheSpotMarket. Review user eligibility, educational scope, non-advisory agreements, and platform terms."
        />
        <meta property="og:title" content="TheSpotMarket Terms of Service" />
        <meta property="og:url" content={`${siteConfig.url}/terms`} />
        <link rel="canonical" href={`${siteConfig.url}/terms`} />
        <script type="application/ld+json">{JSON.stringify(breadcrumbJsonLd)}</script>
      </Helmet>

      <LegalLayout
        badge="User Agreement"
        title="Terms of Service"
        subtitle="Please review these terms and conditions carefully before utilizing TheSpotMarket mobile app or website."
        lastUpdated="October 27, 2026"
        toc={TOC}
      >
        {/* Crucial Non-Advisory Notice */}
        <div className="p-4 sm:p-5 rounded-2xl bg-warning/10 border border-warning/30 flex items-start gap-3.5 text-warning-muted">
          <AlertTriangle className="w-6 h-6 text-warning shrink-0 mt-0.5" />
          <div className="text-xs sm:text-sm space-y-1">
            <span className="font-bold text-white block">Strict Non-Advisory Notice</span>
            <p className="text-muted leading-relaxed">
              TheSpotMarket is <strong>NOT a SEBI-registered Investment Advisor or Research Analyst</strong>.
              Nothing on this platform constitutes an offer to buy or sell securities, stock tips, or
              guaranteed IPO allotment strategies. All data is for informational and research purposes only.
            </p>
          </div>
        </div>

        {/* Section 1 */}
        <section id="acceptance" className="space-y-3 pt-2">
          <h2 className="text-xl font-bold text-white">1. Acceptance of Terms</h2>
          <p>
            These Terms of Service (&ldquo;Terms&rdquo;) constitute a legally binding agreement between you
            (&ldquo;User&rdquo; or &ldquo;you&rdquo;) and {siteConfig.legalName} (&ldquo;TheSpotMarket&rdquo;,
            &ldquo;we&rdquo;, &ldquo;us&rdquo;). By accessing, downloading, or using our mobile application or
            website, you agree to comply with and be bound by these Terms.
          </p>
          <p>
            If you do not agree with any part of these Terms, you must immediately uninstall the application
            and refrain from accessing our digital portals.
          </p>
        </section>

        {/* Section 2 */}
        <section id="eligibility" className="space-y-3 pt-4 border-t border-white/5">
          <h2 className="text-xl font-bold text-white">2. Eligibility (18+ Age Restriction)</h2>
          <p>
            The services offered by TheSpotMarket are available only to individuals who are at least
            <strong> 18 years of age</strong> and are legally competent to enter into binding contracts under
            the Indian Contract Act, 1872. By utilizing this service, you warrant and represent that you are
            at least 18 years old.
          </p>
        </section>

        {/* Section 3 */}
        <section id="services-description" className="space-y-3 pt-4 border-t border-white/5">
          <h2 className="text-xl font-bold text-white">3. Description of Platform Services</h2>
          <p>TheSpotMarket provides financial information aggregation tools, including:</p>
          <ul className="list-disc list-inside space-y-1.5 text-xs sm:text-sm pl-1">
            <li>Indian Mainline and SME Initial Public Offering (IPO) schedules, bid dates, and lot sizes.</li>
            <li>Real-time subscription ratios aggregated across retail, QIB, and HNI categories.</li>
            <li>Live Grey Market Premium (GMP) dealer surveys and historical listing gain estimates.</li>
            <li>Indian stock market breadth, top gainers, losers, and sectoral snapshot feeds.</li>
            <li>Direct client-side allotment status lookups connecting to designated registrar portals.</li>
            <li>SpotAI: An AI-assisted conversational query tool for reviewing SEBI DRHP prospectus filings.</li>
          </ul>
        </section>

        {/* Section 4 */}
        <section id="non-sebi-agreement" className="space-y-3 pt-4 border-t border-white/5">
          <h2 className="text-xl font-bold text-white">4. Non-Advisory Agreement & No Tips</h2>
          <p>
            You explicitly acknowledge and agree that:
          </p>
          <div className="p-4 rounded-xl bg-surface/80 border border-white/5 space-y-2 text-xs sm:text-sm">
            <p>
              1. <strong>No SEBI Registration:</strong> TheSpotMarket and its creators are not registered with
              the Securities and Exchange Board of India (SEBI) as Investment Advisors (RIA) or Research Analysts
              (RA) under SEBI (Investment Advisers) Regulations, 2013 or SEBI (Research Analysts) Regulations, 2014.
            </p>
            <p>
              2. <strong>No Buy/Sell Recommendations:</strong> Algorithmic suggestions, sentiment badges, and
              target/stop-loss filters are technical indicators and mathematical heuristics, NOT investment
              recommendations or financial advice.
            </p>
            <p>
              3. <strong>Capital Risk:</strong> Equity and IPO investments carry high risk, including loss of principal.
              You are solely responsible for your investment decisions and should consult a certified SEBI-registered
              financial planner before allocating capital.
            </p>
          </div>
        </section>

        {/* Section 5 */}
        <section id="accounts" className="space-y-3 pt-4 border-t border-white/5">
          <h2 className="text-xl font-bold text-white">5. Accounts & Authentication</h2>
          <p>
            To personalize your experience, you may create an account using your email address or mobile
            phone number via Firebase Authentication. You are responsible for maintaining the confidentiality
            of your login OTPs and restricting physical access to your device.
          </p>
        </section>

        {/* Section 6 */}
        <section id="acceptable-use" className="space-y-3 pt-4 border-t border-white/5">
          <h2 className="text-xl font-bold text-white">6. Acceptable Use & Conduct</h2>
          <p>You agree not to engage in any of the following prohibited activities:</p>
          <ul className="list-disc list-inside space-y-1.5 text-xs sm:text-sm pl-1">
            <li>Scraping, crawling, or extracting platform data via automated bots or spiders.</li>
            <li>Attempting to bypass our API rate limits, DDoS defenses, or server firewalls.</li>
            <li>Decompiling, reverse-engineering, or disassembling the Flutter mobile application binary.</li>
            <li>Submitting malicious prompt injections, spam, or abusive scripts to SpotAI.</li>
            <li>Using the platform to promote fraudulent penny stock schemes or pump-and-dump operations.</li>
          </ul>
        </section>

        {/* Section 7 */}
        <section id="intellectual-property" className="space-y-3 pt-4 border-t border-white/5">
          <h2 className="text-xl font-bold text-white">7. Intellectual Property Rights</h2>
          <p>
            The software, UI designs, graphics, branding, trademarks, algorithms, and SpotAI interface
            are the exclusive intellectual property of {siteConfig.legalName} and are protected under
            Indian copyright and trademark laws.
          </p>
        </section>

        {/* Section 8 */}
        <section id="third-parties-ads" className="space-y-3 pt-4 border-t border-white/5">
          <h2 className="text-xl font-bold text-white">8. Third Parties & AdMob Advertising</h2>
          <p>
            Our mobile application displays third-party advertisements delivered by Google AdMob.
            We do not endorse or guarantee the products, loans, or services promoted in third-party advertisements.
            Furthermore, when checking allotment status, your device communicates directly with registrar websites
            (Link Intime, KFintech, Bigshare, Skyline); we are not responsible for the availability or uptime
            of these third-party registrar portals.
          </p>
        </section>

        {/* Section 9 */}
        <section id="disclaimer-warranties" className="space-y-3 pt-4 border-t border-white/5">
          <h2 className="text-xl font-bold text-white">9. Disclaimer of Warranties & Feed Latency</h2>
          <p>
            The services are provided on an &ldquo;AS IS&rdquo; and &ldquo;AS AVAILABLE&rdquo; basis without
            warranties of any kind. Market quotes, GMP estimates, and exchange indicators are subject to
            network latency, upstream exchange maintenance windows, and dealer survey variances. We do not
            warrant that data feeds will be uninterrupted, error-free, or 100% real-time.
          </p>
        </section>

        {/* Section 10 */}
        <section id="limitation-liability" className="space-y-3 pt-4 border-t border-white/5">
          <h2 className="text-xl font-bold text-white">10. Limitation of Liability</h2>
          <p>
            To the maximum extent permitted by applicable Indian law, in no event shall {siteConfig.legalName},
            its directors, employees, or developers be liable for any direct, indirect, incidental, punitive,
            or consequential damages, including loss of profits, trading losses, loss of data, or business
            interruption arising from your use of or inability to use the platform.
          </p>
          <p>
            Because TheSpotMarket is provided free of charge, our total cumulative liability to you for any
            and all claims shall not exceed ₹0 (Zero Indian Rupees).
          </p>
        </section>

        {/* Section 11 */}
        <section id="indemnification" className="space-y-3 pt-4 border-t border-white/5">
          <h2 className="text-xl font-bold text-white">11. Indemnification</h2>
          <p>
            You agree to defend, indemnify, and hold harmless {siteConfig.legalName} and its affiliates from
            and against any claims, liabilities, damages, judgments, or legal expenses arising out of your
            violation of these Terms or your investment activities.
          </p>
        </section>

        {/* Section 12 */}
        <section id="account-termination" className="space-y-3 pt-4 border-t border-white/5">
          <h2 className="text-xl font-bold text-white">12. Termination & Account Deletion</h2>
          <p>
            We reserve the right to suspend or terminate accounts that violate our acceptable use policy or
            engage in automated scraping. You may terminate your account at any time by selecting
            &ldquo;Delete Account&rdquo; in the mobile app settings or visiting our{' '}
            <Link to="/data-deletion" className="text-accent underline font-semibold">
              Data Deletion Instructions Page
            </Link>.
          </p>
        </section>

        {/* Section 13 */}
        <section id="governing-law" className="space-y-3 pt-4 border-t border-white/5">
          <h2 className="text-xl font-bold text-white">13. Governing Law & Dispute Resolution</h2>
          <p>
            These Terms shall be governed by and construed in accordance with the substantive laws of
            the Republic of India. Any controversy or claim arising out of these Terms shall be subject
            to the exclusive jurisdiction of the competent civil courts situated in
            <strong> Mumbai, Maharashtra, India</strong>.
          </p>
        </section>

        {/* Section 14 */}
        <section id="contact" className="space-y-3 pt-4 border-t border-white/5">
          <h2 className="text-xl font-bold text-white">14. Contact & Legal Notices</h2>
          <p>
            For legal notices, questions regarding these Terms, or compliance inquiries:
          </p>
          <div className="p-4 rounded-xl bg-surface-2 border border-white/10 text-xs text-muted space-y-1 font-mono">
            <p className="text-white font-bold">{siteConfig.legalName}</p>
            <p>Attn: Legal & Compliance Department</p>
            <p>Email: {siteConfig.contactEmail}</p>
            <p>Address: {siteConfig.address}</p>
          </div>
        </section>
      </LegalLayout>
    </>
  );
}

export default TermsPage;
