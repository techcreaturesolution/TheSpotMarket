import React from 'react';

/**
 * Standard layout Container component.
 *
 * @param {Object} props
 * @param {'sm' | 'md' | 'lg' | 'xl' | 'full'} [props.size='xl']
 * @param {string} [props.className]
 */
export function Container({
  children,
  size = 'xl',
  className = '',
  ...props
}) {
  const sizes = {
    sm: 'max-w-3xl',
    md: 'max-w-5xl',
    lg: 'max-w-6xl',
    xl: 'max-w-7xl',
    full: 'max-w-full',
  };

  return (
    <div
      className={`mx-auto w-full px-4 sm:px-6 lg:px-8 ${sizes[size] || sizes.xl} ${className}`}
      {...props}
    >
      {children}
    </div>
  );
}

export default Container;
