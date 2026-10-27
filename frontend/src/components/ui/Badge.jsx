import React from 'react';

/**
 * Reusable Badge component for financial indicators:
 * Supports Live, SME, Bullish, Bearish, Primary, and Neutral variants.
 *
 * @param {Object} props
 * @param {'live' | 'sme' | 'bullish' | 'bearish' | 'primary' | 'neutral'} [props.variant='primary']
 * @param {'sm' | 'md'} [props.size='sm']
 * @param {boolean} [props.pulse=false] - Animated glowing status dot
 * @param {React.ReactNode} [props.icon]
 * @param {string} [props.className]
 */
export function Badge({
  children,
  variant = 'primary',
  size = 'sm',
  pulse = false,
  icon,
  className = '',
  ...props
}) {
  const variants = {
    live: 'bg-emerald-500/15 text-accent border-emerald-500/30',
    sme: 'bg-amber-500/15 text-amber-300 border-amber-500/30',
    bullish: 'bg-bull/20 text-[#4ade80] border-bull/40',
    bearish: 'bg-bear/20 text-red-400 border-bear/40',
    primary: 'bg-primary/15 text-accent border-primary/30',
    neutral: 'bg-white/5 text-muted border-white/10',
  };

  const sizes = {
    sm: 'text-xs px-2.5 py-0.5 gap-1.5 font-semibold',
    md: 'text-sm px-3.5 py-1 gap-2 font-semibold',
  };

  const dotColors = {
    live: 'bg-accent',
    sme: 'bg-amber-400',
    bullish: 'bg-bull',
    bearish: 'bg-bear',
    primary: 'bg-primary',
    neutral: 'bg-muted',
  };

  return (
    <span
      className={`inline-flex items-center rounded-full border tracking-wide uppercase font-mono ${
        variants[variant] || variants.primary
      } ${sizes[size] || sizes.sm} ${className}`}
      {...props}
    >
      {pulse && (
        <span className="relative flex h-2 w-2">
          <span
            className={`animate-ping absolute inline-flex h-full w-full rounded-full opacity-75 ${
              dotColors[variant] || 'bg-primary'
            }`}
          />
          <span
            className={`relative inline-flex rounded-full h-2 w-2 ${
              dotColors[variant] || 'bg-primary'
            }`}
          />
        </span>
      )}

      {icon && !pulse && <span className="shrink-0">{icon}</span>}
      <span>{children}</span>
    </span>
  );
}

export default Badge;
