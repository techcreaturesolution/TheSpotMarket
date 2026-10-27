import React, { forwardRef } from 'react';

/**
 * Standard Card component adhering to TheSpotMarket design tokens:
 * - Surface color (#0C1610) or Surface-2 (#0B1711)
 * - 16px corner radius
 * - 10% white border (border-white/10)
 * - Optional gradient background (#0C2016 40% -> #030D08 70%)
 */
export const Card = forwardRef(function Card(
  {
    children,
    variant = 'surface', // 'surface' | 'surface-2' | 'gradient'
    hover = false,
    className = '',
    padding = 'p-6',
    ...props
  },
  ref
) {
  const variantStyles = {
    surface: 'bg-surface border border-white/10',
    'surface-2': 'bg-surface-2 border border-white/10',
    gradient: 'bg-card-gradient border border-white/10',
  };

  const hoverStyles = hover
    ? 'transition-all duration-300 hover:border-white/20 hover:shadow-card-glow hover:-translate-y-1'
    : '';

  return (
    <div
      ref={ref}
      className={`rounded-card ${variantStyles[variant] || variantStyles.surface} ${padding} ${hoverStyles} ${className}`}
      {...props}
    >
      {children}
    </div>
  );
});

export default Card;
