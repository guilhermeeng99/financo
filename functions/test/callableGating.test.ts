import { readFileSync } from 'fs';
import { join } from 'path';

/**
 * Every exported callable must authenticate its caller before doing work.
 *
 * This reads `index.ts` as source rather than importing it: the module calls
 * `initializeApp()` at load time, and mocking the whole Admin SDK just to
 * assert a one-line guard would test the mock more than the code. The gate is a
 * syntactic property — "this handler calls one of the two gate helpers" — so a
 * syntactic check is honest about what it verifies.
 *
 * What it buys: a fifth callable cannot ship ungated. `assertAllowedCaller.ts`
 * is already unit-tested for *how* it gates; nothing previously asserted that
 * the callables actually call it.
 */
const INDEX_SOURCE = readFileSync(
  join(__dirname, '..', 'src', 'index.ts'),
  'utf8',
);

interface Callable {
  name: string;
  body: string;
}

/** Splits `index.ts` into one entry per `export const <name> = onCall...`. */
function exportedCallables(): Callable[] {
  const starts = [
    ...INDEX_SOURCE.matchAll(/export const (\w+) = onCall(?:<[^>]*>)?\(/g),
  ];
  return starts.map((match, i) => {
    const from = match.index ?? 0;
    const to = i + 1 < starts.length ? starts[i + 1].index : INDEX_SOURCE.length;
    return { name: match[1], body: INDEX_SOURCE.slice(from, to) };
  });
}

describe('callable auth gating', () => {
  const callables = exportedCallables();

  it('finds the callables it is meant to guard', () => {
    // Guard the guard: a regex that stops matching would make every
    // assertion below vacuous.
    expect(callables.map((c) => c.name).sort()).toEqual([
      'chatSend',
      'deleteUserAsAdmin',
      'fetchInvestmentQuotes',
      'transcribeChatAudio',
    ]);
  });

  it.each(exportedCallables().map((c) => [c.name, c.body]))(
    '%s authenticates its caller',
    (_name, body) => {
      const gated =
        body.includes('assertAllowedCaller(request)') ||
        body.includes('requireSignedInCaller(request)');
      expect(gated).toBe(true);
    },
  );

  // deleteUserAsAdmin is the one that only requires sign-in at the edge — the
  // master-only check lives inside the impl. Pin that split so a refactor
  // cannot quietly downgrade an allowlisted callable to signed-in-only.
  it('reserves the signed-in-only gate for deleteUserAsAdmin', () => {
    const signedInOnly = callables.filter(
      (c) =>
        c.body.includes('requireSignedInCaller(request)') &&
        !c.body.includes('assertAllowedCaller(request)'),
    );
    expect(signedInOnly.map((c) => c.name)).toEqual(['deleteUserAsAdmin']);
  });
});
