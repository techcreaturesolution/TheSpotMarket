// NOTE: This legal document template reflects actual technical implementation and is for informational transparency.
// It should be reviewed by a qualified Indian cyber/securities lawyer before official commercial publication.

import React from 'react';
import { Helmet } from 'react-helmet-async';
import { Link } from 'react-router-dom';
import { Trash2, CheckCircle2, ShieldCheck, Mail, Smartphone, ArrowRight, AlertTriangle } from 'lucide-react';
import LegalLayout from '@/components/layout/LegalLayout';
import { siteConfig } from '@/lib/site';

const TOC = [
  { id: 'compliance-commitment', title: '1. Compliance Commitment (Play Store & App Store)' },
  { id: 'in-app-deletion', title: '2. Method 1: Instant In-App Deletion' },
  { id: 'web-email-deletion', title: '3. Method 2: Web & Email Deletion Request' },
  { id: 'what-is-deleted', title: '4. What Data Is Permanently Erased' },
  { id: 'what-was-never-stored', title: '5. What Data Was NEVER Stored (PAN Privacy)' },
  { id: 'retention-periods', title: '6. Retention Periods & Security Logs' },
  { id: 'contact-help', title: '7. Assistance & Contact Desk' },
];

export function DataDeletionPage() {
  const breadcrumbJsonLd = {
    '@context': 'https://schema.org',
    '@type': 'BreadcrumbList',
    itemListElement: [
      { '@type': 'ListItem', position: 1, name: 'Home', item: siteConfig.url },
      { '@type': 'ListItem', position: 2, name: 'Data Deletion', item: `${siteConfig.url}/data-deletion` },
    ],
  };

  return (
    <>
      <Helmet>
        <title>Account & Data Deletion Instructions - TheSpotMarket</title>
        <meta
          name="description"
          content="Official Google Play Store public data deletion instructions for TheSpotMarket. Learn how to instantly delete your account and personal data."
        />
        <meta property="og:title" content="TheSpotMarket Account & Data Deletion Instructions" />
        <meta property="og:url" content={`${siteConfig.url}/data-deletion`} />
        <link rel="canonical" href={`${siteConfig.url}/data-deletion`} />
        <script type="application/ld+json">{JSON.stringify(breadcrumbJsonLd)}</script>
      </Helmet>

      <LegalLayout
        badge="Account Deletion & Privacy"
        title="User Data Deletion Instructions"
        subtitle="Full transparency on how to permanently erase your TheSpotMarket account, preferences, and authentication credentials."
        lastUpdated="October 27, 2026"
        toc={TOC}
      >
        {/* Play Store Compliance Callout */}
        <div className="p-4 sm:p-5 rounded-2xl bg-primary/10 border border-primary/30 flex items-start gap-3.5 text-accent">
          <Trash2 className="w-6 h-6 shrink-0 mt-0.5 text-accent" />
          <div className="text-xs sm:text-sm space-y-1">
            <span className="font-bold text-white block">Google Play & App Store Compliance</span>
            <p className="text-emerald-200/90 leading-relaxed">
              In accordance with Google Play Developer Policy and Apple App Store Review Guidelines,
              TheSpotMarket provides all users with direct, unconditional account and data deletion
              capabilities — both inside the mobile app and via public web request.
            </p>
          </div>
        </div>

        {/* Section 1 */}
        <section id="compliance-commitment" className="space-y-3 pt-2">
          <h2 className="text-xl font-bold text-white">1. Compliance Commitment</h2>
          <p>
            {siteConfig.legalName} believes that users must retain full ownership of their digital
            identities. If you decide to stop using TheSpotMarket, we make it effortless to permanently
            and irreversibly erase your account and associated data records.
          </p>
        </section>

        {/* Section 2 */}
        <section id="in-app-deletion" className="space-y-4 pt-4 border-t border-white/5">
          <h2 className="text-xl font-bold text-white flex items-center gap-2">
            <Smartphone className="w-5 h-5 text-accent" />
            <span>2. Method 1: Instant In-App Deletion (Recommended)</span>
          </h2>
          <p>
            If you have TheSpotMarket application installed on your Android or iOS device, you can
            delete your account immediately in under 30 seconds:
          </p>

          {/* Step-by-Step Flow */}
          <div className="space-y-2.5 pl-1">
            <div className="p-3.5 rounded-xl bg-surface/80 border border-white/5 flex items-start gap-3 text-xs sm:text-sm">
              <span className="w-6 h-6 rounded-lg bg-primary/20 border border-primary/30 text-accent font-mono font-bold flex items-center justify-center shrink-0">
                1
              </span>
              <div>
                <strong className="text-white block">Open Application:</strong>
                <span className="text-muted">Launch TheSpotMarket on your mobile device.</span>
              </div>
            </div>

            <div className="p-3.5 rounded-xl bg-surface/80 border border-white/5 flex items-start gap-3 text-xs sm:text-sm">
              <span className="w-6 h-6 rounded-lg bg-primary/20 border border-primary/30 text-accent font-mono font-bold flex items-center justify-center shrink-0">
                2
              </span>
              <div>
                <strong className="text-white block">Go to Settings:</strong>
                <span className="text-muted">Tap the <em>Settings</em> gear icon located at the bottom-right of the navigation bar.</span>
              </div>
            </div>

            <div className="p-3.5 rounded-xl bg-surface/80 border border-white/5 flex items-start gap-3 text-xs sm:text-sm">
              <span className="w-6 h-6 rounded-lg bg-primary/20 border border-primary/30 text-accent font-mono font-bold flex items-center justify-center shrink-0">
                3
              </span>
              <div>
                <strong className="text-white block">Navigate to Account Profile:</strong>
                <span className="text-muted">Select <em>Account Details & Security</em>.</span>
              </div>
            </div>

            <div className="p-3.5 rounded-xl bg-surface/80 border border-white/5 flex items-start gap-3 text-xs sm:text-sm">
              <span className="w-6 h-6 rounded-lg bg-primary/20 border border-primary/30 text-accent font-mono font-bold flex items-center justify-center shrink-0">
                4
              </span>
              <div>
                <strong className="text-white block">Select Delete Account:</strong>
                <span className="text-muted">Scroll down to the danger zone and tap <em className="text-red-400 font-semibold">&ldquo;Delete Account&rdquo;</em>.</span>
              </div>
            </div>

            <div className="p-3.5 rounded-xl bg-surface/80 border border-white/5 flex items-start gap-3 text-xs sm:text-sm">
              <span className="w-6 h-6 rounded-lg bg-primary/20 border border-primary/30 text-accent font-mono font-bold flex items-center justify-center shrink-0">
                5
              </span>
              <div>
                <strong className="text-white block">Confirm Deletion:</strong>
                <span className="text-muted">Confirm the final warning modal. Your Firebase auth credentials and session keys will be purged instantly, and you will be signed out.</span>
              </div>
            </div>
          </div>
        </section>

        {/* Section 3 */}
        <section id="web-email-deletion" className="space-y-3 pt-4 border-t border-white/5">
          <h2 className="text-xl font-bold text-white flex items-center gap-2">
            <Mail className="w-5 h-5 text-accent" />
            <span>3. Method 2: Web & Email Deletion Request</span>
          </h2>
          <p>
            If you have already uninstalled the mobile app, lost access to your smartphone, or prefer
            to submit a manual deletion request, our privacy team will process it for you:
          </p>

          <div className="p-4 rounded-xl bg-surface-2 border border-white/10 space-y-2 text-xs sm:text-sm">
            <p className="font-semibold text-white">Manual Request Instructions:</p>
            <p className="text-muted leading-relaxed">
              Send an email from your registered email address to{' '}
              <a
                href={`mailto:${siteConfig.contactEmail}?subject=Account%20and%20Data%20Deletion%20Request`}
                className="text-accent underline font-mono"
              >
                {siteConfig.contactEmail}
              </a>{' '}
              with the subject line: <strong>&ldquo;Account and Data Deletion Request&rdquo;</strong>.
            </p>
            <p className="text-muted leading-relaxed">
              Please include your registered phone number or email address. Our security team will verify
              the request and confirm complete deletion within <strong>48 business hours</strong>.
            </p>
          </div>
        </section>

        {/* Section 4 */}
        <section id="what-is-deleted" className="space-y-3 pt-4 border-t border-white/5">
          <h2 className="text-xl font-bold text-white">4. What Data Is Permanently Erased</h2>
          <p>Upon account deletion, the following data is permanently purged from our infrastructure:</p>

          <div className="grid grid-cols-1 sm:grid-cols-2 gap-3 text-xs pt-1">
            <div className="p-3.5 rounded-xl bg-surface border border-white/5 space-y-1">
              <span className="font-bold text-white block">Authentication Credentials</span>
              <span className="text-subtle">Firebase UID, email address, and verified phone number.</span>
            </div>
            <div className="p-3.5 rounded-xl bg-surface border border-white/5 space-y-1">
              <span className="font-bold text-white block">User Session Tokens</span>
              <span className="text-subtle">All active JWT authorization tokens and refresh cookies.</span>
            </div>
            <div className="p-3.5 rounded-xl bg-surface border border-white/5 space-y-1">
              <span className="font-bold text-white block">Custom Watchlists</span>
              <span className="text-subtle">Saved stock symbols and tracked IPO notifications.</span>
            </div>
            <div className="p-3.5 rounded-xl bg-surface border border-white/5 space-y-1">
              <span className="font-bold text-white block">SpotAI Saved Query Logs</span>
              <span className="text-subtle">Any user-specific AI interaction history.</span>
            </div>
          </div>
        </section>

        {/* Section 5 */}
        <section id="what-was-never-stored" className="space-y-3 pt-4 border-t border-white/5">
          <h2 className="text-xl font-bold text-white">5. What Data Was NEVER Stored (PAN Privacy)</h2>
          <div className="p-4 rounded-xl bg-primary/10 border border-primary/20 space-y-2 text-xs sm:text-sm">
            <span className="font-mono text-accent uppercase font-bold block">
              [ZERO-STORAGE ARCHITECTURE]
            </span>
            <p className="text-muted leading-relaxed">
              We remind our users that <strong>Permanent Account Numbers (PANs) were never stored on
              our servers in the first place</strong>. If you entered a PAN in the mobile app, it was
              stored solely in your device&rsquo;s hardware keystore.
            </p>
            <p className="text-muted leading-relaxed">
              Uninstalling the application or clearing your phone&rsquo;s app storage cache immediately
              and permanently eradicates the local PAN record with zero residual footprint.
            </p>
          </div>
        </section>

        {/* Section 6 */}
        <section id="retention-periods" className="space-y-3 pt-4 border-t border-white/5">
          <h2 className="text-xl font-bold text-white">6. Retention Periods & Security Logs</h2>
          <p>
            Once an account deletion request is processed:
          </p>
          <ul className="list-disc list-inside space-y-1.5 text-xs sm:text-sm pl-1">
            <li>Your account profile is immediately removed and cannot be reactivated.</li>
            <li>Aggregated, anonymous technical diagnostics (e.g. past crash stack traces with no user identifiers) cannot be reverse-linked to you.</li>
            <li>Security firewalls and IP rate-limiting cache entries expire automatically within 15 to 30 days.</li>
            <li>No user information is backed up to secondary cold storage after the standard 30-day recycling window.</li>
          </ul>
        </section>

        {/* Section 7 */}
        <section id="contact-help" className="space-y-3 pt-4 border-t border-white/5">
          <h2 className="text-xl font-bold text-white">7. Assistance & Contact Desk</h2>
          <p>
            If you have questions regarding the data deletion process or require assistance, our
            support desk is available:
          </p>
          <div className="p-4 rounded-xl bg-surface-2 border border-white/10 text-xs text-muted space-y-1 font-mono">
            <p className="text-white font-bold">{siteConfig.legalName} — Privacy Desk</p>
            <p>Support Email: support@thespotmarket.com</p>
            <p>Privacy Email: privacy@thespotmarket.com</p>
            <p>Website Contact Form: <Link to="/contact" className="text-accent underline font-sans">thespotmarket.com/contact</Link></p>
          </div>
        </section>
      </LegalLayout>
    </>
  );
}

export default DataDeletionPage;
