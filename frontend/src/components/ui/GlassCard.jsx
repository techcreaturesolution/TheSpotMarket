import React, { forwardRef } from 'react';

/**
 * Premium GlassCard component:
 * - Backdrop blur filter
 * - 10% translucent white border
 * - 16px corner radius
 * - Translucent surface/gradient base
 */
export const GlassCard = forwardRef(function GlassCard(
  {
    children,
    blur = 'backdrop-blur-xl',
    hover = false,
    gradient = true,
    padding = 'p-6',
    className = '',
    ...props
  },
  ref
) {
  const baseBg = gradient
    ? 'bg-gradient-to-b from-[#0C2016]/50 to-[#030D08]/80'
    : 'bg-surface/60';

  const hoverStyles = hover
    ? 'transition-all duration-300 hover:border-white/25 hover:shadow-card-glow hover:-translate-y-1'
    : 'transition-colors duration-200';

  return (
    <div
      ref={ref}
      className={`rounded-card ${baseBg} ${blur} border border-white/10 shadow-lg ${padding} ${hoverStyles} ${className}`}
      {...props}
    >
      {children}
    </div>
  );
});

export default GlassCard;
