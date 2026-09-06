/** @type {import('tailwindcss').Config} */
export default {
  content: [
    "./index.html",
    "./src/**/*.{vue,js,ts,jsx,tsx}",
  ],
  darkMode: 'class',
  theme: {
    extend: {
      fontFamily: {
        sans: ['Plus Jakarta Sans', 'Inter', 'sans-serif'],
        mono: ['JetBrains Mono', 'monospace'],
        display: ['Orbitron', 'Plus Jakarta Sans', 'sans-serif'],
      },
      colors: {
        cyber: {
          bg: '#05070e',
          card: 'rgba(11, 15, 25, 0.75)',
          border: 'rgba(255, 255, 255, 0.08)',
          cyan: '#00f0ff',
          neon: '#00ffa3',
          pink: '#ff007f',
          purple: '#8a2be2',
          yellow: '#ffe600',
        }
      },
      boxShadow: {
        'neon-cyan': '0 0 25px -5px rgba(0, 240, 255, 0.35)',
        'neon-pink': '0 0 25px -5px rgba(255, 0, 127, 0.35)',
        'neon-green': '0 0 25px -5px rgba(0, 255, 163, 0.35)',
        'glass': '0 8px 32px 0 rgba(0, 0, 0, 0.37)',
      },
      animation: {
        'pulse-glow': 'pulseGlow 2s cubic-bezier(0.4, 0, 0.6, 1) infinite',
        'scanline': 'scanline 8s linear infinite',
      },
      keyframes: {
        pulseGlow: {
          '0%, 100%': { opacity: '1', transform: 'scale(1)' },
          '50%': { opacity: '0.85', transform: 'scale(1.02)' },
        },
        scanline: {
          '0%': { transform: 'translateY(-100%)' },
          '100%': { transform: 'translateY(1000%)' },
        }
      }
    },
  },
  plugins: [],
}
