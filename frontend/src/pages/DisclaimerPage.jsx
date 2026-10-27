// NOTE: This legal document template reflects actual technical implementation and is for informational transparency.
// It should be reviewed by a qualified Indian cyber/securities lawyer before official commercial publication.

import React from 'react';
import { Helmet } from 'react-helmet-async';
import { ShieldAlert, AlertTriangle, TrendingUp, Cpu, Layers, HelpCircle } from 'lucide-react';
import LegalLayout from '@/components/layout/LegalLayout';
import { siteConfig } from '@/lib/site';

const TOC = [
  { id: 'sebi-status', title: '1. Non-Registration with SEBI' },
  { id: 'educational-nature', title: '2. Educational & Research Scope' },
  { id: 'algorithmic-suggestions', title: '3. Buy / Sell / Hold Suggestions' },
  { id: 'spotai-ai-disclaimer', title: '4. SpotAI Output & Model Limitations' },
  { id: 'gmp-sentiment', title: '5. Grey Market Premium (GMP) Notice' },
  { id: 'market-volatility', title: '6. High Market Volatility & Capital Risk' },
  { id: 'data-feed-latency', title: '7. Data Feed Latency & Discrepancies' },
  { id: 'allotment-queries', title: '8. Registrar Allotment Status Queries' },
  { id: 'certified-planner', title: '9. Duty to Consult a Certified Planner' },
];

export function DisclaimerPage() {
  const breadcrumbJsonLd = {
    '@context': 'https://schema.org',
    '@type': 'BreadcrumbList',
    itemListElement: [
      { '@type': 'ListItem', position: 1, name: 'Home', item: siteConfig.url },
      { '@type': 'ListItem', position: 2, name: 'SEBI Disclaimer', item: `${siteConfig.url}/disclaimer` },
    ],
  };

  return (
    <>
      <Helmet>
        <title>SEBI Regulatory Disclaimer & Risk Warning - TheSpotMarket</title>
        <meta
          name="description"
          content="SEBI compliance statement, non-advisory declaration, and financial market risk disclosures for TheSpotMarket platform."
        />
        <meta property="og:title" content="TheSpotMarket SEBI Regulatory Disclaimer" />
        <meta property="og:url" content={`${siteConfig.url}/disclaimer`} />
        <link rel="canonical" href={`${siteConfig.url}/disclaimer`} />
        <script type="application/ld+json">{JSON.stringify(breadcrumbJsonLd)}</script>
      </Helmet>

      <LegalLayout
        badge="Regulatory Compliance"
        title="SEBI Regulatory Disclaimer"
        subtitle="Mandatory disclosures regarding our non-advisory status, market volatility, data latency, and algorithmic heuristics."
        lastUpdated="October 27, 2026"
        toc={TOC}
      >
        {/* Prominent High-Visibility Warning Banner */}
        <div className="p-5 rounded-2xl bg-red-950/40 border-2 border-red-500/50 flex items-start gap-4 text-red-200">
          <ShieldAlert className="w-8 h-8 text-red-400 shrink-0 mt-0.5" />
          <div className="space-y-1.5 text-xs sm:text-sm">
            <span className="text-base font-extrabold text-white block">
              NOT SEBI REGISTERED AS AN INVESTMENT ADVISOR OR RESEARCH ANALYST
            </span>
            <p className="text-red-200 leading-relaxed">
              {siteConfig.legalName} operates purely as a financial data aggregator, technology portal,
              and educational software utility. We do not provide stock recommendations, investment tips,
              portfolio management services, or guarantees of IPO allotment or listing gains.
            </p>
          </div>
        </div>

        {/* Section 1 */}
        <section id="sebi-status" className="space-y-3 pt-2">
          <h2 className="text-xl font-bold text-white">1. Non-Registration with SEBI</h2>
          <p>
            {siteConfig.legalName} (&ldquo;TheSpotMarket&rdquo;) and its authors, developers, and data
            contributors are <strong className="text-white">NOT registered</strong> with the Securities
            and Exchange Board of India (SEBI) as:
          </p>
          <ul className="list-disc list-inside space-y-1 text-xs sm:text-sm pl-1">
            <li>Investment Advisers under SEBI (Investment Advisers) Regulations, 2013; or</li>
            <li>Research Analysts under SEBI (Research Analysts) Regulations, 2014; or</li>
            <li>Stock Brokers or Depository Participants under SEBI regulations.</li>
          </ul>
          <p>
            No communication from TheSpotMarket should be interpreted as an official SEBI research report,
            formal valuation, or regulated securities advisory.
          </p>
        </section>

        {/* Section 2 */}
        <section id="educational-nature" className="space-y-3 pt-4 border-t border-white/5">
          <h2 className="text-xl font-bold text-white">2. Educational & Research Scope</h2>
          <p>
            All information published on TheSpotMarket website and mobile application — including IPO
            issue timelines, subscription numbers, lot sizes, price bands, financial statements, and news
            summaries — is compiled from publicly available disclosures (such as SEBI DRHP/RHP prospectuses,
            exchange filings, and news circulars) strictly for informational tracking and personal research.
          </p>
        </section>

        {/* Section 3 */}
        <section id="algorithmic-suggestions" className="space-y-3 pt-4 border-t border-white/5">
          <h2 className="text-xl font-bold text-white">3. Buy / Sell / Hold Suggestions Disclosure</h2>
          <p>
            Any badges, filters, or technical suggestions (such as &ldquo;Buy&rdquo;, &ldquo;Hold&rdquo;,
            or &ldquo;Sell&rdquo; indicators, target ranges, or stop-loss markers) displayed within the app:
          </p>
          <div className="p-4 rounded-xl bg-surface/80 border border-white/5 space-y-1.5 text-xs text-muted">
            <p className="text-white font-semibold">Important Clarification on Heuristic Badges:</p>
            <ul className="list-disc list-inside space-y-1 pl-1">
              <li>Are purely rule-based technical algorithms and mathematical momentum filters.</li>
              <li>Do not consider your personal risk tolerance, financial health, or liquidity needs.</li>
              <li>Must never be relied upon as execution advice or guaranteed trading calls.</li>
            </ul>
          </div>
        </section>

        {/* Section 4 */}
        <section id="spotai-ai-disclaimer" className="space-y-3 pt-4 border-t border-white/5">
          <h2 className="text-xl font-bold text-white">4. SpotAI Output & Model Limitations</h2>
          <p>
            SpotAI is powered by large language model artificial intelligence (Google Gemini API) trained
            to parse regulatory prospectus text. While we continuously refine its accuracy:
          </p>
          <ul className="list-disc list-inside space-y-1.5 text-xs sm:text-sm pl-1">
            <li>Artificial intelligence models may occasionally generate erroneous or hallucinated figures.</li>
            <li>SpotAI summaries are not audited by certified accountants or securities lawyers.</li>
            <li>Users must verify all financial metrics, promoter litigation, and debt numbers against the
            official DRHP and RHP documents filed on the SEBI portal before applying to any IPO.</li>
          </ul>
        </section>

        {/* Section 5 */}
        <section id="gmp-sentiment" className="space-y-3 pt-4 border-t border-white/5">
          <h2 className="text-xl font-bold text-white">5. Grey Market Premium (GMP) Notice</h2>
          <p>
            The Grey Market Premium (&ldquo;GMP&rdquo;) quotes provided on this platform are compiled
            from informal dealer surveys and primary market desks across major trading centers:
          </p>
          <div className="p-4 rounded-xl bg-surface-2 border border-white/10 space-y-2 text-xs">
            <span className="font-mono text-accent uppercase font-bold block">[UNREGULATED METRIC]</span>
            <p className="text-muted leading-relaxed">
              Grey market trading is unofficial, off-exchange, and unregulated by SEBI or stock exchanges.
              GMP numbers can swing violently within hours based on market sentiment and do not guarantee
              actual listing day opening prices. Applying to an IPO solely based on high GMP is dangerous
              and may result in severe capital losses.
            </p>
          </div>
        </section>

        {/* Section 6 */}
        <section id="market-volatility" className="space-y-3 pt-4 border-t border-white/5">
          <h2 className="text-xl font-bold text-white">6. High Market Volatility & Capital Risk</h2>
          <p>
            Investment in securities markets — particularly Initial Public Offerings, Small and Medium
            Enterprise (SME) IPOs, and equity stocks — is subject to significant market risks.
            Stock prices can fluctuate dramatically due to macroeconomic conditions, corporate actions,
            and regulatory shifts. You may lose some or all of your invested capital.
          </p>
        </section>

        {/* Section 7 */}
        <section id="data-feed-latency" className="space-y-3 pt-4 border-t border-white/5">
          <h2 className="text-xl font-bold text-white">7. Data Feed Latency & Discrepancies</h2>
          <p>
            Exchange quotations (NSE and BSE), market mood indexes, and subscription percentages originate
            from third-party data providers and official exchange circulars. Data may be delayed by
            several minutes depending on network bandwidth and provider refresh intervals. TheSpotMarket
            is not liable for financial losses caused by quote delays or connection timeouts.
          </p>
        </section>

        {/* Section 8 */}
        <section id="allotment-queries" className="space-y-3 pt-4 border-t border-white/5">
          <h2 className="text-xl font-bold text-white">8. Registrar Allotment Status Queries</h2>
          <p>
            Our mobile application connects directly to SEBI-registered registrar portals (Link Intime,
            KFintech, Bigshare, Skyline) to check allotment results. Allotment finalization timing and
            server response speeds are under the exclusive control of the respective registrar.
            TheSpotMarket does not decide or influence IPO share allotment.
          </p>
        </section>

        {/* Section 9 */}
        <section id="certified-planner" className="space-y-3 pt-4 border-t border-white/5">
          <h2 className="text-xl font-bold text-white">9. Duty to Consult a Certified Planner</h2>
          <p>
            Every investor&rsquo;s risk appetite, tax bracket, and financial goals are unique.
            We strongly advise you to consult an independent SEBI-registered Investment Adviser (RIA)
            or certified financial planner before executing any financial market transactions.
          </p>
        </section>
      </LegalLayout>
    </>
  );
}

export default DisclaimerPage;
