module.exports = {
  content: ["./_site/**/*.html"],
  theme: {
    extend: {
      aspectRatio: {
        '4/1': '4 / 1'
      }
    },
    fontFamily: {
      "serif": ["merriweatherregular", "Constantia", "Palatino", "Palatino Linotype", 'Georgia', 'serif']
    }
  },
  plugins: [
    require("@tailwindcss/typography"),
    require("@tailwindcss/forms")
  ],
}
