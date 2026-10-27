import React from 'react';
import { Helmet } from 'react-helmet-async';
import { useLocation } from 'react-router-dom';
import { siteConfig } from '@/lib/site';

/**
 * Global & per-page SEO component using react-helmet-async.
 *
 * @param {Object} props
 * @param {string} [props.title]
 * @param {string} [props.description]
 * @param {string} [props.ogImage]
 * @param {string} [props.ogType='website']
 * @param {boolean} [props.noindex=false]
 */
export function SEO({
  title,
  description = siteConfig.description,
  ogImage = siteConfig.ogImage,
  ogType = 'website',
  noindex = false,
}) {
  const { pathname } = useLocation();
  const currentUrl = `${siteConfig.url}${pathname}`;
  const fullOgImage = ogImage.startsWith('http') ? ogImage : `${siteConfig.url}${ogImage}`;

  const defaultTitle = `${siteConfig.name} - ${siteConfig.tagline}`;
  const pageTitle = title || defaultTitle;

  return (
    <Helmet
      title={pageTitle}
      titleTemplate={title ? `%s | ${siteConfig.name}` : undefined}
    >
      <html lang="en" />
      <meta name="description" content={description} />
      <meta name="theme-color" content="#040A07" />
      <meta name="color-scheme" content="dark" />
      <link rel="canonical" href={currentUrl} />

      {noindex && <meta name="robots" content="noindex, nofollow" />}

      {/* OpenGraph / Facebook / LinkedIn */}
      <meta property="og:type" content={ogType} />
      <meta property="og:title" content={pageTitle} />
      <meta property="og:description" content={description} />
      <meta property="og:url" content={currentUrl} />
      <meta property="og:site_name" content={siteConfig.name} />
      <meta property="og:image" content={fullOgImage} />

      {/* Twitter Cards */}
      <meta name="twitter:card" content="summary_large_image" />
      <meta name="twitter:site" content="@thespotmarket" />
      <meta name="twitter:creator" content="@thespotmarket" />
      <meta name="twitter:title" content={pageTitle} />
      <meta name="twitter:description" content={description} />
      <meta name="twitter:image" content={fullOgImage} />

      {/* Financial App Schema Structured Data */}
      <script type="application/ld+json">
        {JSON.stringify({
          '@context': 'https://schema.org',
          '@type': 'SoftwareApplication',
          name: siteConfig.name,
          operatingSystem: 'ANDROID, IOS',
          applicationCategory: 'FinanceApplication',
          description: siteConfig.description,
          url: siteConfig.url,
          offers: {
            '@type': 'Offer',
            price: '0',
            priceCurrency: 'INR',
          },
        })}
      </script>
    </Helmet>
  );
}

export default SEO;
