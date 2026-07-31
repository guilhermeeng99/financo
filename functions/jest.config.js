/** @type {import('jest').Config} */
module.exports = {
  testEnvironment: 'node',
  testMatch: ['**/test/**/*.test.ts'],
  moduleFileExtensions: ['ts', 'js'],
  collectCoverageFrom: ['src/**/*.ts'],
  // Replaces `preset: 'ts-jest'` so `.js` is transformed alongside `.ts` and
  // the one ESM-only dependency below can be rewritten to CommonJS.
  // `module: 'commonjs'` is forced here because tsconfig.json uses `node16`,
  // under which TypeScript would preserve the ESM syntax of a
  // `"type": "module"` package and defeat the whole point.
  transform: {
    '^.+\\.[tj]s$': [
      'ts-jest',
      { tsconfig: { allowJs: true, module: 'commonjs' } },
    ],
  },
  // firebase-admin 14 reaches `jose` (via jwks-rsa) for ID-token verification.
  // jose 6 ships ESM only; production is fine because Node 22 supports
  // `require(esm)`, but Jest's CommonJS module runtime does not, so the raw
  // `export {` syntax reaches the parser and every suite that transitively
  // loads firebase-admin/auth dies. Un-ignoring just jose lets ts-jest
  // down-level it. Keep this list minimal — each entry slows the suite.
  transformIgnorePatterns: ['/node_modules/(?!jose/)'],
};
