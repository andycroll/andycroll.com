module.exports = {
  content: ["./_site/**/*.html"],
  theme: {
    extend: {},
    fontFamily: {
      "serif": ["merriweatherregular", "Constantia", "Palatino", "Palatino Linotype", 'Georgia', 'serif']
    }
  },
  plugins: [
    require("@tailwindcss/typography"),
    require("@tailwindcss/forms")
  ],
}
