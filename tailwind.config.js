/** @type {import('tailwindcss').Config} */
module.exports = {
  content: [
    './_layouts/**/*.html',
    './_includes/**/*.html',
    './_posts/**/*.{md,html}',
    './*.html',
    './*.md',
    './assets/css/main.css',
  ],
  safelist: [
    'photo-carousel',
    'carousel-track',
    'carousel-item',
    'glitch',
    'glow',
    'pulse',
    'float',
    'duotone',
    'halftone',
  ],
  darkMode: 'class',
  theme: {
    extend: {
      colors: {
        primary: '#00E5FF',
        'primary-dark': '#4DEEEA',
        accent: '#74EE15',
        dark: '#050505',
        'dark-card': '#0a0d10',
        'dark-border': '#1a2024',
        light: '#F0F0F0',
        'light-card': '#0a0d10',
        'light-border': '#1a2024',
        muted: '#6b7785',
        'muted-light': '#8a97a5',
      },
      fontFamily: {
        display: ['Space Grotesk', 'system-ui', 'sans-serif'],
        sans: ['DM Sans', 'system-ui', 'sans-serif'],
        mono: ['JetBrains Mono', 'ui-monospace', 'monospace'],
      },
      boxShadow: {
        glow: '0 0 20px rgba(0, 229, 255, 0.35), 0 0 40px rgba(0, 229, 255, 0.15)',
        'glow-sm': '0 0 12px rgba(0, 229, 255, 0.3)',
      },
      animation: {
        'fade-in': 'fade-in 0.6s ease-out forwards',
        'slide-up': 'slide-up 0.6s ease-out forwards',
        'sidechain-pulse': 'sidechain-pulse 0.9375s ease-in-out infinite',
        'ambient-float': 'ambient-float 12s ease-in-out infinite',
      },
      keyframes: {
        'fade-in': {
          from: { opacity: '0' },
          to: { opacity: '1' },
        },
        'slide-up': {
          from: { opacity: '0', transform: 'translateY(20px)' },
          to: { opacity: '1', transform: 'translateY(0)' },
        },
        'sidechain-pulse': {
          '0%, 100%': { opacity: '0.8' },
          '40%': { opacity: '0.35' },
        },
        'ambient-float': {
          '0%, 100%': { transform: 'translateY(0)' },
          '50%': { transform: 'translateY(-16px)' },
        },
      },
    },
  },
  plugins: [require('@tailwindcss/typography')],
};
