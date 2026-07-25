import { fetchInvestmentQuotes } from '../src/quotes/fetchInvestmentQuotes';

// The quote proxy routes each item to brapi (BR, free tier by default) or
// finnhub (US, gated behind a secret) using the global `fetch`. These tests
// stub `fetch` and control BRAPI_TOKEN (env) and FINNHUB_TOKEN (a secret backed
// by process.env at runtime), restoring both plus `fetch` after every test so
// the cases stay independent.

const okJson = (body: unknown) => ({
  ok: true,
  json: async () => body,
});

describe('fetchInvestmentQuotes', () => {
  const realFetch = global.fetch;
  const realBrapi = process.env.BRAPI_TOKEN;
  const realFinnhub = process.env.FINNHUB_TOKEN;
  let fetchMock: jest.Mock;

  const restoreEnv = (key: string, value: string | undefined): void => {
    if (value === undefined) {
      delete process.env[key];
      return;
    }
    process.env[key] = value;
  };

  beforeEach(() => {
    fetchMock = jest.fn();
    global.fetch = fetchMock as unknown as typeof fetch;
    delete process.env.BRAPI_TOKEN;
    delete process.env.FINNHUB_TOKEN;
  });

  afterEach(() => {
    global.fetch = realFetch;
    restoreEnv('BRAPI_TOKEN', realBrapi);
    restoreEnv('FINNHUB_TOKEN', realFinnhub);
    jest.restoreAllMocks();
  });

  describe('brapi routing', () => {
    it('hits the free-tier URL (no token param) when BRAPI_TOKEN is unset', async () => {
      fetchMock.mockResolvedValue(
        okJson({
          results: [
            {
              symbol: 'PETR4',
              regularMarketPrice: 30.5,
              regularMarketPreviousClose: 29.5,
            },
          ],
        }),
      );

      const { quotes } = await fetchInvestmentQuotes([
        { assetId: 'a1', ticker: 'PETR4', source: 'brapi' },
      ]);

      const url = fetchMock.mock.calls[0][0] as string;
      expect(url).toBe('https://brapi.dev/api/quote/PETR4');
      expect(url).not.toContain('token');
      expect(quotes).toEqual([
        { assetId: 'a1', price: 30.5, previousClose: 29.5, currency: 'BRL' },
      ]);
    });

    it('appends ?token= when BRAPI_TOKEN is set', async () => {
      process.env.BRAPI_TOKEN = 'tok123';
      fetchMock.mockResolvedValue(okJson({ results: [] }));

      await fetchInvestmentQuotes([
        { assetId: 'a1', ticker: 'PETR4', source: 'brapi' },
      ]);

      const url = fetchMock.mock.calls[0][0] as string;
      expect(url).toBe('https://brapi.dev/api/quote/PETR4?token=tok123');
    });

    it('maps each result back to its assetId by symbol, case-insensitively', async () => {
      fetchMock.mockResolvedValue(
        okJson({
          results: [
            {
              symbol: 'vale3',
              regularMarketPrice: 10,
              regularMarketPreviousClose: 9,
            },
            {
              symbol: 'PETR4',
              regularMarketPrice: 20,
              regularMarketPreviousClose: 19,
            },
          ],
        }),
      );

      const { quotes } = await fetchInvestmentQuotes([
        { assetId: 'a1', ticker: 'PETR4', source: 'brapi' },
        { assetId: 'a2', ticker: 'VALE3', source: 'brapi' },
      ]);

      expect(quotes).toContainEqual({
        assetId: 'a1',
        price: 20,
        previousClose: 19,
        currency: 'BRL',
      });
      expect(quotes).toContainEqual({
        assetId: 'a2',
        price: 10,
        previousClose: 9,
        currency: 'BRL',
      });
    });
  });

  describe('finnhub routing', () => {
    it('returns no quote and skips the network when FINNHUB_TOKEN is unset', async () => {
      const { quotes } = await fetchInvestmentQuotes([
        { assetId: 'u1', ticker: 'AAPL', source: 'finnhub' },
      ]);

      expect(quotes).toEqual([]);
      expect(fetchMock).not.toHaveBeenCalled();
    });

    it('prices via finnhub (token appended, USD) when the secret is set', async () => {
      process.env.FINNHUB_TOKEN = 'fh-secret';
      fetchMock.mockResolvedValue(okJson({ c: 190.25, pc: 188.0 }));

      const { quotes } = await fetchInvestmentQuotes([
        { assetId: 'u1', ticker: 'AAPL', source: 'finnhub' },
      ]);

      const url = fetchMock.mock.calls[0][0] as string;
      expect(url).toContain('symbol=AAPL');
      expect(url).toContain('token=fh-secret');
      expect(quotes).toEqual([
        { assetId: 'u1', price: 190.25, previousClose: 188.0, currency: 'USD' },
      ]);
    });
  });
});
