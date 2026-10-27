// NOTE: This legal document template reflects actual technical implementation and is for informational transparency.
// It should be reviewed by a qualified Indian cyber/securities lawyer before official commercial publication.

import React from 'react';
import { Helmet } from 'react-helmet-async';
import { Link } from 'react-router-dom';
import { ShieldCheck, Lock, Smartphone, Eye, Server, ExternalLink, AlertTriangle } from 'lucide-react';
import LegalLayout from '@/components/layout/LegalLayout';
import { siteConfig } from '@/lib/site';

const TOC = [
  { id: 'overview', title: '1. Overview & Applicability' },
  { id: 'data-collected', title: '2. Information We Collect' },
  { id: 'pan-security', title: '3. PAN & Local On-Device Security' },
  { id: 'spotai-queries', title: '4. SpotAI & AI Processing' },
  { id: 'how-we-use', title: '5. How We Use Information' },
  { id: 'third-parties', title: '6. Third-Party Integrations' },
  { id: 'admob-advertising', title: '7. Advertising & AdMob Disclosures' },
  { id: 'cookies', title: '8. Website Cookies & Tracking' },
  { id: 'children', title: '9. Children\'s Privacy (Under 18)' },
  { id: 'security-retention', title: '10. Security & Data Retention' },
  { id: 'user-rights', title: '11. Your Rights under DPDP Act 2023' },
  { id: 'account-deletion', title: '12. Account & Data Deletion' },
  { id: 'governing-law', title: '13. Governing Law & Jurisdiction' },
  { id: 'policy-changes', title: '14. Changes to This Policy' },
  { id: 'grievance-contact', title: '15. Grievance Officer & Contact' },
];

export function PrivacyPage() {
  const breadcrumbJsonLd = {
    '@context': 'https://schema.org',
    '@type': 'BreadcrumbList',
    itemListElement: [
      { '@type': 'ListItem', position: 1, name: 'Home', item: siteConfig.url },
      { '@type': 'ListItem', position: 2, name: 'Privacy Policy', item: `${siteConfig.url}/privacy-policy` },
    ],
  };

  return (
    <>
      <Helmet>
        <title>Privacy Policy - TheSpotMarket | DPDP Act & Data Protection</title>
        <meta
          name="description"
          content="Privacy Policy for TheSpotMarket. Learn how we collect, handle, and isolate your data. PAN details stay strictly on-device with zero server logging."
        />
        <meta property="og:title" content="TheSpotMarket Privacy Policy" />
        <meta property="og:url" content={`${siteConfig.url}/privacy-policy`} />
        <link rel="canonical" href={`${siteConfig.url}/privacy-policy`} />
        <script type="application/ld+json">{JSON.stringify(breadcrumbJsonLd)}</script>
      </Helmet>

      <LegalLayout
        badge="DPDP Act & Privacy Standards"
        title="Privacy Policy"
        subtitle="We believe in absolute data transparency. Learn how your data is handled across our mobile application and public marketing website."
        lastUpdated="October 27, 2026"
        toc={TOC}
      >
        {/* Important Callout Box */}
        <div className="p-4 sm:p-5 rounded-2xl bg-primary/10 border border-primary/30 flex items-start gap-3.5 text-accent">
          <ShieldCheck className="w-6 h-6 shrink-0 mt-0.5" />
          <div className="text-xs sm:text-sm space-y-1">
            <span className="font-bold text-white block">Core Privacy Guarantee</span>
            <p className="text-emerald-200/90 leading-relaxed">
              Your Permanent Account Number (PAN) used for IPO allotment checks is stored
              <strong> strictly inside your device’s local hardware keystore</strong>. It is never
              transmitted, saved, or logged to TheSpotMarket servers.
            </p>
          </div>
        </div>

        {/* Section 1 */}
        <section id="overview" className="space-y-3 pt-2">
          <h2 className="text-xl font-bold text-white flex items-center gap-2">
            <span>1. Overview & Applicability</span>
          </h2>
          <p>
            This Privacy Policy applies to {siteConfig.legalName} (&ldquo;TheSpotMarket&rdquo;,
            &ldquo;we&rdquo;, &ldquo;us&rdquo;, or &ldquo;our&rdquo;) and governs data collection,
            processing, and storage practices across our Android mobile app (distributed on Google
            Play Store), iOS mobile app (Apple App Store), and our web companion at {siteConfig.domain}.
          </p>
          <p>
            By installing the mobile app or browsing our website, you consent to the data collection
            and usage practices described in this policy, crafted in accordance with the
            <strong> Digital Personal Data Protection Act, 2023 (DPDP Act)</strong> of India and
            applicable developer guidelines of Google Play and Apple.
          </p>
        </section>

        {/* Section 2 */}
        <section id="data-collected" className="space-y-3 pt-4 border-t border-white/5">
          <h2 className="text-xl font-bold text-white">2. Information We Collect</h2>
          <p>We collect only the minimal data required to deliver real-time financial tracking:</p>

          <div className="space-y-3 pl-1">
            <div className="p-4 rounded-xl bg-surface/80 border border-white/5 space-y-1.5">
              <h3 className="text-sm font-bold text-white">A. Account Credentials (Firebase Authentication)</h3>
              <p className="text-xs text-muted leading-relaxed">
                When you create an account or sign in to save cross-device preferences, we collect your
                <strong> email address</strong> or <strong>phone number</strong> via Firebase Authentication
                (Google LLC) through secure One-Time Password (OTP) verification. We do not store plain-text
                passwords on our servers.
              </p>
            </div>

            <div className="p-4 rounded-xl bg-surface/80 border border-white/5 space-y-1.5">
              <h3 className="text-sm font-bold text-white">B. On-Device Investor Data (PAN & Local Watchlists)</h3>
              <p className="text-xs text-muted leading-relaxed">
                If you save your Permanent Account Number (PAN) to automate IPO allotment status checks,
                this information is encrypted and retained <strong>strictly on your physical device</strong>.
                It is never synchronized to our cloud servers or third-party advertising databases.
              </p>
            </div>

            <div className="p-4 rounded-xl bg-surface/80 border border-white/5 space-y-1.5">
              <h3 className="text-sm font-bold text-white">C. Advertising Identifiers & Analytics (Google AdMob)</h3>
              <p className="text-xs text-muted leading-relaxed">
                To keep core platform features 100% free, our mobile application integrates Google AdMob.
                AdMob collects pseudonymous device advertising identifiers (such as Google Advertising ID /
                GAID on Android or IDFA on iOS), coarse IP address, and interaction metrics to display relevant
                non-intrusive banner or interstitial advertisements.
              </p>
            </div>

            <div className="p-4 rounded-xl bg-surface/80 border border-white/5 space-y-1.5">
              <h3 className="text-sm font-bold text-white">D. Diagnostics & Crash Reporting</h3>
              <p className="text-xs text-muted leading-relaxed">
                We collect anonymous technical telemetry through Google Crashlytics, including device model,
                operating system version, crash stack traces, and app launch performance. These logs contain
                no personally identifiable financial information.
              </p>
            </div>
          </div>
        </section>

        {/* Section 3 */}
        <section id="pan-security" className="space-y-3 pt-4 border-t border-white/5">
          <h2 className="text-xl font-bold text-white">3. PAN & Local On-Device Security</h2>
          <p>
            Indian share transfer registrars (Link Intime India Pvt. Ltd., KFin Technologies Ltd.,
            Bigshare Services Pvt. Ltd., Skyline Financial Services) require an applicant&rsquo;s PAN
            to query IPO allotment status.
          </p>
          <div className="p-4 rounded-xl bg-surface-2 border border-accent/20 space-y-2">
            <p className="text-xs text-emerald-200 font-mono">
              [CLIENT-SIDE ISOLATION PROTOCOL]
            </p>
            <p className="text-xs text-muted leading-relaxed">
              When you initiate an allotment query, your device sends a direct HTTPS request to the
              designated registrar&rsquo;s official portal. The response (allotted shares, refund status)
              is displayed directly on your screen. The PAN number never traverses our backend API,
              is not written to disk logs, and is wiped from memory as soon as the session concludes.
            </p>
          </div>
        </section>

        {/* Section 4 */}
        <section id="spotai-queries" className="space-y-3 pt-4 border-t border-white/5">
          <h2 className="text-xl font-bold text-white">4. SpotAI & AI Processing</h2>
          <p>
            Our conversational assistant, SpotAI, allows users to ask questions regarding Draft Red
            Herring Prospectuses (DRHP), financial statements, and stock disclosures.
          </p>
          <p>
            When you submit a query to SpotAI, the text of your question is proxied securely through
            our backend server to our AI inference provider (Google Gemini API).
            <strong> No personal account details, phone numbers, or PANs are bundled with these queries.</strong>
            We do not use your proprietary private questions to train foundational public models.
          </p>
        </section>

        {/* Section 5 */}
        <section id="how-we-use" className="space-y-3 pt-4 border-t border-white/5">
          <h2 className="text-xl font-bold text-white">5. How We Use Information</h2>
          <ul className="list-disc list-inside space-y-1.5 text-xs sm:text-sm pl-1">
            <li>To authenticate you and restore your saved preferences across device changes.</li>
            <li>To deliver real-time IPO timelines, live Grey Market Premiums, and market breadth data.</li>
            <li>To proxy and answer complex prospectus queries via SpotAI.</li>
            <li>To detect application crashes and optimize client-side rendering speed.</li>
            <li>To display contextual, non-intrusive ads via Google AdMob supporting free tier usage.</li>
            <li>To protect our infrastructure against automated DDoS floods and bot scrapers.</li>
          </ul>
        </section>

        {/* Section 6 */}
        <section id="third-parties" className="space-y-3 pt-4 border-t border-white/5">
          <h2 className="text-xl font-bold text-white">6. Third-Party Integrations</h2>
          <p>
            TheSpotMarket collaborates with reliable, enterprise-grade third-party service providers.
            Each provider processes data under their independent privacy policies:
          </p>
          <div className="grid grid-cols-1 sm:grid-cols-2 gap-3 text-xs">
            <div className="p-3.5 rounded-xl bg-surface border border-white/5">
              <span className="font-bold text-white block">Google Firebase & Crashlytics</span>
              <span className="text-subtle">Authentication, crash logs, database security rules.</span>
            </div>
            <div className="p-3.5 rounded-xl bg-surface border border-white/5">
              <span className="font-bold text-white block">Google AdMob</span>
              <span className="text-subtle">In-app advertising delivery & measurement.</span>
            </div>
            <div className="p-3.5 rounded-xl bg-surface border border-white/5">
              <span className="font-bold text-white block">Google Gemini AI</span>
              <span className="text-subtle">Large language model backend for SpotAI document queries.</span>
            </div>
            <div className="p-3.5 rounded-xl bg-surface border border-white/5">
              <span className="font-bold text-white block">Angel One SmartAPI & IndianAPI</span>
              <span className="text-subtle">Live Indian equity quotes, market indices & feeds.</span>
            </div>
            <div className="p-3.5 rounded-xl bg-surface border border-white/5 sm:col-span-2">
              <span className="font-bold text-white block">Official Registrars (Link Intime, KFintech, Bigshare, Skyline)</span>
              <span className="text-subtle">Third-party registrar endpoints queried directly by the mobile client for allotment status.</span>
            </div>
          </div>
        </section>

        {/* Section 7 */}
        <section id="admob-advertising" className="space-y-3 pt-4 border-t border-white/5">
          <h2 className="text-xl font-bold text-white">7. Advertising & AdMob Disclosures</h2>
          <p>
            The mobile application displays advertisements served by Google AdMob. Google and its
            partners use cookies and device advertising identifiers (e.g., Android Advertising ID) to serve
            ads based on your prior visits to our app and other digital applications.
          </p>
          <p>
            You can opt out of personalized advertising at any time by navigating to your device
            settings: <em>Android Settings &rarr; Google &rarr; Ads &rarr; Reset or Delete Advertising ID</em>,
            or on iOS via <em>Settings &rarr; Privacy & Security &rarr; Tracking</em>.
          </p>
        </section>

        {/* Section 8 */}
        <section id="cookies" className="space-y-3 pt-4 border-t border-white/5">
          <h2 className="text-xl font-bold text-white">8. Website Cookies & Tracking</h2>
          <p>
            Our public marketing website ({siteConfig.domain}) uses minimal, strictly essential browser
            storage (such as local preference flags for dark mode theme selection).
            <strong> We do not deploy third-party advertising tracking cookies on the marketing website.</strong>
          </p>
        </section>

        {/* Section 9 */}
        <section id="children" className="space-y-3 pt-4 border-t border-white/5">
          <h2 className="text-xl font-bold text-white">9. Children&rsquo;s Privacy (Not for Under 18)</h2>
          <p>
            TheSpotMarket is intended strictly for individuals who are at least 18 years of age.
            Under Indian regulatory frameworks, participating in equity markets and opening trading/Demat
            accounts requires legal majority. We do not knowingly collect personal information from minors.
            If we discover that a minor under 18 has registered an account, we will immediately purge the
            account and associated credentials.
          </p>
        </section>

        {/* Section 10 */}
        <section id="security-retention" className="space-y-3 pt-4 border-t border-white/5">
          <h2 className="text-xl font-bold text-white">10. Security & Data Retention</h2>
          <p>
            All communications between your device and our servers are encrypted using Transport Layer
            Security (TLS 1.3). We enforce strict CORS whitelisting, IP rate-limiting, and sanitized
            database queries.
          </p>
          <p>
            We retain account data (email/phone UID) only for as long as your account remains active.
            Ephemeral server logs (IP rate limit records) are automatically recycled every 15 to 30 days.
          </p>
        </section>

        {/* Section 11 */}
        <section id="user-rights" className="space-y-3 pt-4 border-t border-white/5">
          <h2 className="text-xl font-bold text-white">11. Your Rights under DPDP Act 2023</h2>
          <p>As a data principal under Indian law, you have the following rights:</p>
          <ul className="list-disc list-inside space-y-1.5 text-xs sm:text-sm pl-1">
            <li><strong>Right to Access:</strong> Request a summary of personal data held about you.</li>
            <li><strong>Right to Correction:</strong> Rectify inaccurate or incomplete contact information.</li>
            <li><strong>Right to Erasure:</strong> Request permanent deletion of your account and credentials.</li>
            <li><strong>Right to Grievance Redressal:</strong> File a complaint with our Grievance Officer.</li>
          </ul>
        </section>

        {/* Section 12 */}
        <section id="account-deletion" className="space-y-3 pt-4 border-t border-white/5">
          <h2 className="text-xl font-bold text-white">12. Account & Data Deletion</h2>
          <p>
            You have total control over your account. You can permanently erase your account at any
            time directly within the mobile application:
          </p>
          <div className="p-4 rounded-xl bg-surface/70 border border-white/5 text-xs text-muted space-y-1">
            <p className="font-semibold text-white">In-App Deletion Path:</p>
            <p>Settings Tab &rarr; Account Profile &rarr; Tap &ldquo;Delete Account&rdquo; &rarr; Confirm deletion.</p>
          </div>
          <p>
            For complete instructions or to submit a manual deletion request if you have already
            uninstalled the app, visit our dedicated{' '}
            <Link to="/data-deletion" className="text-accent underline font-semibold">
              Data Deletion Instructions Page
            </Link>.
          </p>
        </section>

        {/* Section 13 */}
        <section id="governing-law" className="space-y-3 pt-4 border-t border-white/5">
          <h2 className="text-xl font-bold text-white">13. Governing Law & Jurisdiction</h2>
          <p>
            This Privacy Policy and any disputes arising out of your use of TheSpotMarket shall be
            governed by and construed in accordance with the laws of the Republic of India. Any legal
            proceedings shall be subject to the exclusive jurisdiction of the competent courts in
            <strong> Mumbai, Maharashtra, India</strong>.
          </p>
        </section>

        {/* Section 14 */}
        <section id="policy-changes" className="space-y-3 pt-4 border-t border-white/5">
          <h2 className="text-xl font-bold text-white">14. Changes to This Policy</h2>
          <p>
            We may revise this Privacy Policy periodically to reflect app updates, new regulatory
            guidelines, or enhanced privacy features. Material modifications will be announced via
            in-app notification or by updating the &ldquo;Last Updated&rdquo; date at the top of this page.
          </p>
        </section>

        {/* Section 15 */}
        <section id="grievance-contact" className="space-y-3 pt-4 border-t border-white/5">
          <h2 className="text-xl font-bold text-white">15. Grievance Officer & Contact</h2>
          <p>
            In accordance with the Information Technology Act, 2000 and the DPDP Act, 2023, the details
            of our Grievance Officer are provided below:
          </p>
          <div className="p-4 rounded-xl bg-surface-2 border border-white/10 text-xs text-muted space-y-1 font-mono">
            <p className="text-white font-bold">Grievance Officer: Legal & Compliance Desk</p>
            <p>Entity: {siteConfig.legalName}</p>
            <p>Email: privacy@thespotmarket.com / support@thespotmarket.com</p>
            <p>Address: {siteConfig.address}</p>
          </div>
        </section>
      </LegalLayout>
    </>
  );
}

export default PrivacyPage;
