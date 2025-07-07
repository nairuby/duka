const defaultTheme = require('tailwindcss/defaultTheme')

module.exports = {
  content: [
    './public/*.html',
    './app/helpers/**/*.rb',
    './app/javascript/**/*.js',
    './app/views/**/*.{erb,haml,html,slim}'
  ],
  theme: {
    extend: {
      fontFamily: {
        sans: ['Inter var', ...defaultTheme.fontFamily.sans],
        courier: ['"Courier Prime", monospace'],
        geist: ['"Geist", sans-serif'],
      },
      colors: {
        primary: '#dc2626',   // red-600
        secondary: '#166534', // green-800
        accent: '#2563eb',    // blue-600
        neutral: '#9ca3af',   // gray-400
      },
    },
  },
  plugins: [
    require('@tailwindcss/forms'),
    require('@tailwindcss/typography'),
    require('@tailwindcss/container-queries'),
  ]
}
