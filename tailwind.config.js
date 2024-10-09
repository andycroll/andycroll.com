module.exports = {
  content: ["./**/*.html"],
  theme: {
    extend: {
      aspectRatio: {
        '4/1': '4 / 1'
      }
    },
    fontFamily: {
      "serif": ["merriweatherregular", "Constantia", "Palatino", "Palatino Linotype", 'Georgia', 'serif']
    },
    screens: {
      'sm': '400px',
      'md': '600px',
      'lg': '800px',
    },
  },
  plugins: [
    require("@tailwindcss/typography"),
    require("@tailwindcss/forms")
  ],
}
