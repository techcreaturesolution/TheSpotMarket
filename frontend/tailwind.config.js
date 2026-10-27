/** @type {import('tailwindcss').Config} */
export default {
  content: [
    "./index.html",
    "./src/**/*.{js,ts,jsx,tsx}",
  ],
  darkMode: 'class',
  theme: {
    extend: {
      colors: {
        background: '#040A07',
        surface: {
          DEFAULT: '#0C1610',
          2: '#0B1711',
        },
        primary: {
          DEFAULT: '#10B981',
          dark: '#059669',
        },
        accent: '#34D399',
        bull: '#16A34A',
        bear: '#DC2626',
        text: '#FFFFFF',
        muted: 'rgba(255, 255, 255, 0.70)',
        subtle: 'rgba(255, 255, 255, 0.50)',
        border: 'rgba(255, 255, 255, 0.10)',
      },
      borderRadius: {
        card: '16px',
        '2xl': '16px',
      },
      letterSpacing: {
        heading: '-0.5px',
      },
      fontWeight: {
        heading: '800',
      },
      fontFamily: {
        sans: ['Inter', 'Roboto', 'system-ui', '-apple-system', 'sans-serif'],
      },
      backgroundImage: {
        'card-gradient': 'linear-gradient(180deg, rgba(12, 32, 22, 0.40) 0%, rgba(3, 13, 8, 0.70) 100%)',
        'emerald-glow': 'radial-gradient(circle at 50% 0%, rgba(16, 185, 129, 0.18) 0%, rgba(4, 10, 7, 0) 70%)',
        'emerald-radial-center': 'radial-gradient(circle at center, rgba(16, 185, 129, 0.15) 0%, rgba(4, 10, 7, 0) 70%)',
      },
      boxShadow: {
        'card-glow': '0 0 40px -10px rgba(16, 185, 129, 0.15)',
        'btn-glow': '0 0 20px -3px rgba(16, 185, 129, 0.4)',
      },
    },
  },
  plugins: [],
};
