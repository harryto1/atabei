module.exports = {
  env: {
    node: true,
    es2021: true,
  },
  extends: [
    "eslint:recommended",
  ],
  parserOptions: {
    ecmaVersion: 12,
    sourceType: "module",
  },
  rules: {
    "quotes": ["error", "double"],
    "indent": ["error", 2],
    "eol-last": ["error", "always"],
  },
};
