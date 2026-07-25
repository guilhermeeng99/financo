import { defineSecret } from 'firebase-functions/params';

/**
 * Finnhub token for US pricing, kept as a backend secret so it never ships in
 * the web bundle. Set it once with:
 *   firebase functions:secrets:set FINNHUB_TOKEN
 * An empty/absent FINNHUB_TOKEN disables US pricing (those holdings then show
 * cost basis on the client — no crash).
 *
 * brapi (BR equities/FIIs/ETFs/BDRs) needs NO secret: its free tier prices
 * popular tickers without a key, so we read an OPTIONAL `BRAPI_TOKEN` from the
 * environment (unset → free tier). Bind it as a secret only if you outgrow the
 * free tier and need a keyed plan — that's why it isn't a required deploy
 * secret here.
 */
export const FINNHUB_TOKEN = defineSecret('FINNHUB_TOKEN');

/** One requested quote: which asset, its ticker, and which source prices it. */
export interface QuoteItem {
  assetId: string;
  ticker: string;
  source: 'brapi' | 'finnhub';
}

/** A resolved quote in major units (the client rebuilds Money from it). */
export interface QuoteResult {
  assetId: string;
  price: number;
  previousClose: number | null;
  currency: 'BRL' | 'USD';
}

/**
 * Routes each item to its source and returns the resolved quotes. brapi
 * (BR equities/FIIs/ETFs/BDRs) is batched in one request; Finnhub (US) is one
 * request per symbol (its free tier has no batch endpoint). A source failure
 * yields fewer quotes, never a throw — the client degrades to cached/cost.
 *
 * @param items The quotes to resolve.
 * @returns The resolved quotes (a partial set on partial failure).
 * @example
 *   await fetchInvestmentQuotes([
 *     { assetId: 'a1', ticker: 'PETR4', source: 'brapi' },
 *   ]);
 */
export async function fetchInvestmentQuotes(
  items: QuoteItem[],
): Promise<{ quotes: QuoteResult[] }> {
  const brapi = items.filter((i) => i.source === 'brapi');
  const finnhub = items.filter((i) => i.source === 'finnhub');

  const quotes: QuoteResult[] = [];
  if (brapi.length > 0) quotes.push(...(await fetchBrapi(brapi)));
  for (const item of finnhub) {
    const quote = await fetchFinnhubOne(item);
    if (quote) quotes.push(quote);
  }
  return { quotes };
}

/** Batched brapi request; maps regularMarketPrice/PreviousClose per symbol. */
async function fetchBrapi(items: QuoteItem[]): Promise<QuoteResult[]> {
  const byTicker = new Map(
    items.map((i): [string, QuoteItem] => [i.ticker.toUpperCase(), i]),
  );
  const token = process.env.BRAPI_TOKEN ?? '';
  const tickers = Array.from(byTicker.keys()).join(',');
  const url =
    `https://brapi.dev/api/quote/${tickers}` + (token ? `?token=${token}` : '');

  const response = await fetch(url);
  if (!response.ok) return [];
  const data = (await response.json()) as {
    results?: Array<Record<string, unknown>>;
  };

  const out: QuoteResult[] = [];
  for (const row of data.results ?? []) {
    const item = byTicker.get(String(row['symbol'] ?? '').toUpperCase());
    const price = asNumber(row['regularMarketPrice']);
    if (!item || price === null) continue;
    out.push({
      assetId: item.assetId,
      price,
      previousClose: asNumber(row['regularMarketPreviousClose']),
      currency: 'BRL',
    });
  }
  return out;
}

/** One Finnhub symbol; `c` = current price, `pc` = previous close. */
async function fetchFinnhubOne(item: QuoteItem): Promise<QuoteResult | null> {
  const token = FINNHUB_TOKEN.value();
  if (!token) return null;
  const url =
    `https://finnhub.io/api/v1/quote?symbol=${encodeURIComponent(item.ticker)}` +
    `&token=${token}`;

  const response = await fetch(url);
  if (!response.ok) return null;
  const data = (await response.json()) as { c?: unknown; pc?: unknown };
  const current = asNumber(data.c);
  if (current === null || current === 0) return null;
  const previous = asNumber(data.pc);
  return {
    assetId: item.assetId,
    price: current,
    previousClose: previous === 0 ? null : previous,
    currency: 'USD',
  };
}

function asNumber(value: unknown): number | null {
  return typeof value === 'number' && Number.isFinite(value) ? value : null;
}
