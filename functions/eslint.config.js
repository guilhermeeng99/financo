const js = require('@eslint/js');
const globals = require('globals');
const tsPlugin = require('@typescript-eslint/eslint-plugin');
const tsParser = require('@typescript-eslint/parser');

/**
 * Flat config (ESLint 10). Replaces the old `.eslintrc.js`, which extended
 * `eslint-config-google`.
 *
 * `eslint-config-google` was dropped because it was last published in 2019 and
 * never gained flat-config support, so it hard-blocked ESLint 9/10. Rather than
 * pull in a whole style guide for the handful of rules that were actually
 * reaching this code, the ones the project relies on are re-encoded inline
 * below, already merged with the overrides the old config layered on top.
 *
 * All of these still ship in ESLint 10 core. The two google rules that did not
 * survive — `require-jsdoc` and `valid-jsdoc` — were already explicitly
 * disabled by the previous config, so nothing is lost.
 */
module.exports = [
  {
    ignores: ['lib/**', 'generated/**', 'jest.config.js', 'eslint.config.js'],
  },
  js.configs.recommended,
  {
    files: ['**/*.ts'],
    languageOptions: {
      parser: tsParser,
      parserOptions: {
        project: ['tsconfig.json'],
        tsconfigRootDir: __dirname,
        sourceType: 'module',
      },
      globals: {
        ...globals.node,
        ...globals.es2022,
      },
    },
    plugins: {
      '@typescript-eslint': tsPlugin,
    },
    rules: {
      ...tsPlugin.configs.recommended.rules,

      // --- Correctness (from eslint-config-google) ---
      'curly': ['error', 'multi-line'],
      'guard-for-in': 'error',
      'no-caller': 'error',
      'no-extend-native': 'error',
      'no-extra-bind': 'error',
      'no-invalid-this': 'error',
      'no-irregular-whitespace': 'error',
      'no-multi-str': 'error',
      'no-new-wrappers': 'error',
      'no-throw-literal': 'error',
      'no-unexpected-multiline': 'error',
      'no-with': 'error',
      'prefer-promise-reject-errors': 'error',

      // --- Modern syntax (from eslint-config-google) ---
      'no-array-constructor': 'error',
      'no-object-constructor': 'error', // successor to the removed no-new-object
      'no-var': 'error',
      'one-var': ['error', { var: 'never', let: 'never', const: 'never' }],
      'prefer-const': ['error', { destructuring: 'all' }],
      'prefer-rest-params': 'error',
      'prefer-spread': 'error',

      // --- Formatting (google defaults, with the previous config's overrides
      // already folded in: object-curly-spacing was flipped to 'always',
      // max-len widened from 80 to 120, and indent simplified to a flat 2). ---
      'array-bracket-spacing': ['error', 'never'],
      'block-spacing': ['error', 'never'],
      'brace-style': 'error',
      'camelcase': ['error', { properties: 'never' }],
      'comma-dangle': ['error', 'always-multiline'],
      'comma-spacing': 'error',
      'comma-style': 'error',
      'computed-property-spacing': 'error',
      'eol-last': 'error',
      'func-call-spacing': 'error',
      'indent': ['error', 2],
      'key-spacing': 'error',
      'keyword-spacing': 'error',
      'linebreak-style': 'error',
      'max-len': [
        'error',
        {
          code: 120,
          ignoreUrls: true,
          ignoreStrings: true,
          ignoreTemplateLiterals: true,
        },
      ],
      'no-mixed-spaces-and-tabs': 'error',
      'no-multi-spaces': 'error',
      'no-multiple-empty-lines': ['error', { max: 2 }],
      'no-tabs': 'error',
      'no-trailing-spaces': 'error',
      'object-curly-spacing': ['error', 'always'],
      'padded-blocks': ['error', 'never'],
      'quote-props': ['error', 'consistent'],
      'quotes': ['error', 'single'],
      'semi': 'error',
      'semi-spacing': 'error',
      'space-before-blocks': 'error',
      'space-before-function-paren': [
        'error',
        { asyncArrow: 'always', anonymous: 'never', named: 'never' },
      ],
      'spaced-comment': ['error', 'always'],
      'switch-colon-spacing': 'error',
      'arrow-parens': ['error', 'always'],
      'generator-star-spacing': ['error', 'after'],
      'rest-spread-spacing': 'error',
      'yield-star-spacing': ['error', 'after'],

      // The TypeScript-aware version supersedes the core rule, which would
      // otherwise double-report on type-only identifiers.
      'no-unused-vars': 'off',
      '@typescript-eslint/no-unused-vars': ['error', { args: 'none' }],
    },
  },
];
