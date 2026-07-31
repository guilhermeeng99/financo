import { initializeApp } from 'firebase-admin/app';
import { HttpsError, onCall } from 'firebase-functions/v2/https';
import { logger } from 'firebase-functions/logger';
import { runChatTurn } from './chat/pipeline';
import { transcribeAudio } from './chat/transcribe';
import type { HistoryTurn } from './chat/types';
import {
  assertAllowedCaller,
  requireSignedInCaller,
} from './access/assertAllowedCaller';
import { deleteUserAsAdmin as deleteUserAsAdminImpl } from './admin/deleteUser';
import { notifyTransactionsDue } from './transactions/notifyTransactionsDue';
import {
  fetchInvestmentQuotes as fetchInvestmentQuotesImpl,
  FINNHUB_TOKEN,
  type QuoteItem,
} from './quotes/fetchInvestmentQuotes';
import {
  ALLOWED_AUDIO_MIME_TYPES,
  ALLOWED_IMAGE_MIME_TYPES,
  assertChatContentWithinLimit,
  MAX_AUDIO_BASE64_CHARS,
  MAX_HISTORY_TURN_CHARS,
  MAX_HISTORY_TURNS,
  MAX_IMAGE_BASE64_CHARS,
  validateInlineData,
} from './limits';

initializeApp();

export { notifyTransactionsDue };

/**
 * Runs a callable's core work, converting any throw into the logged
 * `HttpsError('internal')` shape the Flutter client maps to a localized
 * failure. Validation must happen *before* entering `work` so that only
 * genuine server-side failures end up logged here.
 *
 * The upstream error text is logged but **never** forwarded to the client:
 * these callables sit in front of Vertex and the market-data proxy, whose
 * errors quote request URLs carrying `FINNHUB_TOKEN` / `BRAPI_TOKEN`. The
 * client only ever sees [fallbackMessage], which it maps to a localized
 * failure anyway — it never rendered the upstream string.
 *
 * An `HttpsError` thrown by [work] passes through untouched, so deliberate
 * `invalid-argument` / `permission-denied` codes still reach the client.
 *
 * @param callableName Used as the log prefix (`<name> failed`).
 * @param fallbackMessage The only message the client receives.
 * @param work The callable's core async work.
 * @returns Whatever `work` resolves to.
 * @example
 *   return wrapCallableErrors('chatSend', 'Chat failed', () => run());
 */
async function wrapCallableErrors<T>(
  callableName: string,
  fallbackMessage: string,
  work: () => Promise<T>,
): Promise<T> {
  try {
    return await work();
  } catch (error) {
    if (error instanceof HttpsError) throw error;
    logger.error(`${callableName} failed`, error);
    throw new HttpsError('internal', fallbackMessage);
  }
}

interface ChatSendRequest {
  content: string;
  history: HistoryTurn[];
  image?: { data: string; mimeType: string };
}

export const chatSend = onCall<ChatSendRequest>(
  {
    region: 'us-central1',
    memory: '512MiB',
    timeoutSeconds: 60,
    invoker: 'public',
  },
  async (request) => {
    const { uid: userId } = await assertAllowedCaller(request);

    const content = assertChatContentWithinLimit(
      (request.data?.content ?? '').toString(),
    );
    const image = validateInlineData(
      request.data?.image,
      'image',
      ALLOWED_IMAGE_MIME_TYPES,
      MAX_IMAGE_BASE64_CHARS,
    );

    if (!content.trim() && !image) {
      throw new HttpsError(
        'invalid-argument',
        'Content cannot be empty without an image.',
      );
    }

    // History is replayed verbatim into the model, so it is capped on both
    // axes: turn count and per-turn length. Only the count was bounded before,
    // which left the total payload unbounded.
    const history: HistoryTurn[] = Array.isArray(request.data?.history)
      ? request.data.history
        .filter((t) => t && typeof t.content === 'string' && (t.role === 'user' || t.role === 'assistant'))
        .slice(-MAX_HISTORY_TURNS)
        .map((t) => ({ ...t, content: t.content.slice(0, MAX_HISTORY_TURN_CHARS) }))
      : [];

    return wrapCallableErrors('chatSend', 'Chat failed', () =>
      runChatTurn({
        userId,
        content,
        history,
        image,
      }),
    );
  },
);

interface DeleteUserAsAdminCallableRequest {
  targetUid: string;
}

export const deleteUserAsAdmin = onCall<DeleteUserAsAdminCallableRequest>(
  {
    region: 'us-central1',
    memory: '256MiB',
    timeoutSeconds: 120,
    invoker: 'public',
  },
  async (request) => {
    // Master-only guard lives inside the impl — only the signed-in check
    // is shared with the allowlisted user-facing callables.
    const caller = requireSignedInCaller(request);
    return deleteUserAsAdminImpl(request.data, caller.email, caller.uid);
  },
);

interface FetchInvestmentQuotesRequest {
  items: QuoteItem[];
}

/**
 * Proxies the keyed market-data sources (brapi, Finnhub) so their API tokens
 * stay backend secrets instead of shipping in the web bundle. Keyless sources
 * (CoinGecko, Tesouro, BCB, AwesomeAPI FX) are fetched directly on the client.
 * See docs/specs/quotes.md.
 */
export const fetchInvestmentQuotes = onCall<FetchInvestmentQuotesRequest>(
  {
    region: 'us-central1',
    memory: '256MiB',
    timeoutSeconds: 30,
    invoker: 'public',
    secrets: [FINNHUB_TOKEN],
  },
  async (request) => {
    await assertAllowedCaller(request);
    const rawItems = Array.isArray(request.data?.items) ? request.data.items : [];
    const items: QuoteItem[] = rawItems
      .filter(
        (i): i is QuoteItem =>
          !!i &&
          typeof i.assetId === 'string' &&
          typeof i.ticker === 'string' &&
          (i.source === 'brapi' || i.source === 'finnhub'),
      )
      .slice(0, 100);
    if (items.length === 0) return { quotes: [] };
    return wrapCallableErrors('fetchInvestmentQuotes', 'Quote fetch failed', () =>
      fetchInvestmentQuotesImpl(items),
    );
  },
);

interface TranscribeRequest {
  audio: { data: string; mimeType: string };
}

export const transcribeChatAudio = onCall<TranscribeRequest>(
  {
    region: 'us-central1',
    memory: '512MiB',
    timeoutSeconds: 60,
    invoker: 'public',
  },
  async (request) => {
    await assertAllowedCaller(request);
    const audio = validateInlineData(
      request.data?.audio,
      'audio',
      ALLOWED_AUDIO_MIME_TYPES,
      MAX_AUDIO_BASE64_CHARS,
    );
    if (!audio) {
      throw new HttpsError('invalid-argument', 'audio.data and audio.mimeType are required.');
    }
    return wrapCallableErrors('transcribeChatAudio', 'Transcription failed', async () => {
      const transcript = await transcribeAudio(audio);
      return { transcript };
    });
  },
);
