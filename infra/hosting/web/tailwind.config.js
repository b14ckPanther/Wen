const { fontFamily } = require('tailwindcss/defaultTheme');

/** @type {import('tailwindcss').Config} */
module.exports = {
  content: [
    './src/app/**/*.{js,ts,jsx,tsx}',
    './src/components/**/*.{js,ts,jsx,tsx}',
    './src/hooks/**/*.{js,ts,jsx,tsx}',
  ],
  theme: {
    extend: {
      fontFamily: {
        sans: ['Inter', ...fontFamily.sans],
      },
      backgroundImage: {
        'admin-gradient': 'radial-gradient(circle at top left, #1e3a8a 0%, #0f172a 45%, #020617 100%)',
      },
    },
  },
  plugins: [],
};
