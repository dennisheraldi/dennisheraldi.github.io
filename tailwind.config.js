/** @type {import('tailwindcss').Config} */
module.exports = {
  content: [
    "./_layouts/**/*.html",
    "./_includes/**/*.html",
    "./_posts/**/*.md",
    "./*.html",
    "./*.md",
  ],
  darkMode: "class",
  theme: {
    extend: {
      colors: {
        primary: "#2563eb",
        "primary-dark": "#1d4ed8",
        accent: "#06b6d4",
        dark: "#0a0a0a",
        "dark-card": "#141414",
        "dark-border": "#262626",
        light: "#fafafa",
        "light-card": "#ffffff",
        "light-border": "#e5e5e5",
        muted: "#737373",
        "muted-light": "#a3a3a3",
      },
      fontFamily: {
        sans: ["DM Sans", "system-ui", "sans-serif"],
        mono: ["JetBrains Mono", "ui-monospace", "monospace"],
      },
      animation: {
        "fade-in": "fade-in 0.6s ease-out forwards",
        "slide-up": "slide-up 0.6s ease-out forwards",
      },
      keyframes: {
        "fade-in": {
          from: { opacity: "0" },
          to: { opacity: "1" },
        },
        "slide-up": {
          from: { opacity: "0", transform: "translateY(20px)" },
          to: { opacity: "1", transform: "translateY(0)" },
        },
      },
    },
  },
  plugins: [require("@tailwindcss/typography")],
};

