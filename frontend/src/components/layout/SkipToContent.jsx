import React from 'react';

/**
 * Accessible skip navigation link for keyboard & screen reader users.
 */
export function SkipToContent() {
  return (
    <a
      href="#main-content"
      className="sr-only focus:not-sr-only focus:fixed focus:top-4 focus:left-4 focus:z-50 focus:px-4 focus:py-2.5 focus:bg-primary focus:text-white focus:font-semibold focus:rounded-xl focus:shadow-btn-glow focus:outline-none focus:ring-2 focus:ring-accent transition-transform duration-150"
    >
      Skip to main content
    </a>
  );
}

export default SkipToContent;
