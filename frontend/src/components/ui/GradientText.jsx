import React from 'react';

/**
 * GradientText component for vibrant emerald headings and emphasized typography.
 *
 * @param {Object} props
 * @param {'emerald' | 'white-emerald' | 'silver' | 'bull'} [props.variant='emerald']
 * @param {keyof JSX.IntrinsicElements} [props.as='span']
 * @param {string} [props.className]
 */
export function GradientText({
  children,
  variant = 'emerald',
  as: Component = 'span',
  className = '',
  ...props
}) {
  const variants = {
    emerald: 'from-accent via-[#10B981] to-[#059669]',
    'white-emerald': 'from-white via-[#E6FFF2] to-accent',
    silver: 'from-white via-white/90 to-white/60',
    bull: 'from-[#4ade80] to-[#16a34a]',
  };

  return (
    <Component
      className={`bg-gradient-to-r ${
        variants[variant] || variants.emerald
      } bg-clip-text text-transparent font-extrabold tracking-heading inline-block ${className}`}
      {...props}
    >
      {children}
    </Component>
  );
}

export default GradientText;
