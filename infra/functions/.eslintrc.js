module.exports = {
  root: true,
  env: {
    es6: true,
    node: true,
  },
  extends: ['eslint:recommended', 'google'],
  parser: '@typescript-eslint/parser',
  parserOptions: {
    project: ['tsconfig.json'],
  },
  plugins: ['@typescript-eslint'],
  rules: {
    'quotes': ['error', 'single'],
    'max-len': ['error', { 'code': 100 }],
  },
};
