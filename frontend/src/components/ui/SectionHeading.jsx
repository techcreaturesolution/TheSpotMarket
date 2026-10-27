import React from 'react';
import Badge from './Badge';

/**
 * Standard SectionHeading component for marketing sections.
 * Features:
 * - Eyebrow badge or text
 * - Heading with font-weight 800 and -0.5px letter spacing
 * - Subtitle with muted text color (white/70)
 * - Alignment controls
 *
 * @param {Object} props
 * @param {string | React.ReactNode} [props.badge] - Optional badge label or Badge component
 * @param {string | React.ReactNode} props.title - Primary heading
 * @param {string | React.ReactNode} [props.subtitle] - Explanatory subtext
 * @param {'center' | 'left' | 'right'} [props.align='center']
 * @param {'sm' | 'md' | 'lg'} [props.size='md']
 * @param {string} [props.className]
 */
export function SectionHeading({
  badge,
  title,
  subtitle,
  align = 'center',
  size = 'md',
  className = '',
  ...props
}) {
  const alignments = {
    left: 'text-left items-start',
    center: 'text-center items-center',
    right: 'text-right items-end',
  };

  const titleSizes = {
    sm: 'text-2xl sm:text-3xl',
    md: 'text-3xl sm:text-4xl lg:text-5xl',
    lg: 'text-4xl sm:text-5xl lg:text-6xl',
  };

  return (
    <div
      className={`flex flex-col ${alignments[align] || alignments.center} max-w-3xl ${
        align === 'center' ? 'mx-auto' : ''
      } ${className}`}
      {...props}
    >
      {badge && (
        <div className="mb-3">
          {typeof badge === 'string' ? (
            <Badge variant="primary" size="md">
              {badge}
            </Badge>
          ) : (
            badge
          )}
        </div>
      )}

      <h2
        className={`font-extrabold text-white tracking-heading leading-[1.15] ${
          titleSizes[size] || titleSizes.md
        }`}
      >
        {title}
      </h2>

      {subtitle && (
        <p className="mt-4 text-base sm:text-lg text-muted font-normal leading-relaxed">
          {subtitle}
        </p>
      )}
    </div>
  );
}

export default SectionHeading;
