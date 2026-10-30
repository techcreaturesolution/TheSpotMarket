import React from 'react';
import { Link } from 'react-router-dom';

/**
 * Reusable Button component supporting primary, ghost, and glass variants.
 *
 * @param {Object} props
 * @param {'primary' | 'ghost' | 'glass' | 'outline'} [props.variant='primary']
 * @param {'sm' | 'md' | 'lg'} [props.size='md']
 * @param {string} [props.to] - If provided, renders as react-router-dom Link
 * @param {string} [props.href] - If provided, renders as <a> anchor
 * @param {React.ReactNode} [props.icon] - Optional icon element
 * @param {'left' | 'right'} [props.iconPosition='left']
 * @param {boolean} [props.loading]
 * @param {boolean} [props.disabled]
 * @param {string} [props.className]
 */
export function Button({
  children,
  variant = 'primary',
  size = 'md',
  to,
  href,
  icon,
  iconPosition = 'left',
  loading = false,
  disabled = false,
  className = '',
  ...props
}) {
  const baseStyles =
    'inline-flex items-center justify-center whitespace-nowrap font-medium transition-all duration-200 select-none focus:outline-none focus-visible:ring-2 focus-visible:ring-primary focus-visible:ring-offset-2 focus-visible:ring-offset-background active:scale-[0.98] disabled:opacity-50 disabled:pointer-events-none disabled:active:scale-100';

  const variants = {
    primary:
      'bg-primary hover:bg-primary-dark text-white shadow-btn-glow hover:shadow-card-glow font-semibold',
    ghost:
      'bg-transparent hover:bg-white/5 text-muted hover:text-text border border-transparent',
    glass:
      'bg-white/[0.04] hover:bg-white/[0.08] text-white border border-white/10 hover:border-white/20 backdrop-blur-md shadow-sm',
    outline:
      'bg-white/[0.03] hover:bg-white/[0.08] text-white border border-white/15 hover:border-primary/50 backdrop-blur-sm shadow-sm',
  };

  const sizes = {
    sm: 'text-xs px-3.5 py-1.5 rounded-lg gap-1.5',
    md: 'text-sm px-5 py-2.5 rounded-xl gap-2',
    lg: 'text-base px-6 py-3.5 rounded-xl gap-2.5 font-semibold',
  };

  const combinedClasses = `${baseStyles} ${variants[variant] || variants.primary} ${
    sizes[size] || sizes.md
  } ${className}`;

  const content = (
    <>
      {loading ? (
        <svg
          className="animate-spin -ml-1 mr-2 h-4 w-4 text-current"
          xmlns="http://www.w3.org/2000/svg"
          fill="none"
          viewBox="0 0 24 24"
        >
          <circle
            className="opacity-25"
            cx="12"
            cy="12"
            r="10"
            stroke="currentColor"
            strokeWidth="4"
          />
          <path
            className="opacity-75"
            fill="currentColor"
            d="M4 12a8 8 0 018-8v4a4 4 0 00-4 4H4z"
          />
        </svg>
      ) : icon && iconPosition === 'left' ? (
        <span className="shrink-0 inline-flex items-center">{icon}</span>
      ) : null}

      <span className="inline-flex items-center gap-1.5">{children}</span>

      {!loading && icon && iconPosition === 'right' ? (
        <span className="shrink-0 inline-flex items-center">{icon}</span>
      ) : null}
    </>
  );

  if (to) {
    return (
      <Link to={to} className={combinedClasses} {...props}>
        {content}
      </Link>
    );
  }

  if (href) {
    return (
      <a
        href={href}
        className={combinedClasses}
        target={href.startsWith('http') ? '_blank' : undefined}
        rel={href.startsWith('http') ? 'noopener noreferrer' : undefined}
        {...props}
      >
        {content}
      </a>
    );
  }

  return (
    <button
      type={props.type || 'button'}
      className={combinedClasses}
      disabled={disabled || loading}
      {...props}
    >
      {content}
    </button>
  );
}

export default Button;
