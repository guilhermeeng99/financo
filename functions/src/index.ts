import * as admin from 'firebase-admin';
import { HttpsError, onCall } from 'firebase-functions/v2/https';
import { logger } from 'firebase-functions/v2';
import { runChatTurn } from './chat/pipeline';
import { transcribeAudio } from './chat/transcribe';
import type { HistoryTurn } from './chat/types';
import {
  assertAllowedCaller,
  requireSignedInCaller,
} from './access/assertAllowedCaller';
import { deleteUserAsAdmin as deleteUserAsAdminImpl } from './admin/deleteUser';
import { notifyTransactionsDue } from './transactions/notifyTransactionsDue';

admin.initializeApp();

export { notifyTransactionsDue };

/**
 * Runs a callable's core work, converting any throw into the logged
 * `HttpsError('internal')` shape the Flutter client maps to a localized
 * failure. Validation must happen *before* entering `work` so that only
 * genuine server-side failures end up logged here.
 *
 * @param callableName Used as the log prefix (`<name> failed`).
 * @param fallbackMessage Client-facing message when the error has none.
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
    logger.error(`${callableName} failed`, error);
    throw new HttpsError('internal', (error as Error).message ?? fallbackMessage);
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

    const content = (request.data?.content ?? '').toString();
    const rawImage = request.data?.image;
    const image =
      rawImage && typeof rawImage.data === 'string' && typeof rawImage.mimeType === 'string'
        ? { data: rawImage.data, mimeType: rawImage.mimeType }
        : undefined;

    if (!content.trim() && !image) {
      throw new HttpsError(
        'invalid-argument',
        'Content cannot be empty without an image.',
      );
    }

    const history: HistoryTurn[] = Array.isArray(request.data?.history)
      ? request.data.history
        .filter((t) => t && typeof t.content === 'string' && (t.role === 'user' || t.role === 'assistant'))
        .slice(-50)
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
    const audio = request.data?.audio;
    if (!audio?.data || !audio.mimeType) {
      throw new HttpsError('invalid-argument', 'audio.data and audio.mimeType are required.');
    }
    return wrapCallableErrors('transcribeChatAudio', 'Transcription failed', async () => {
      const transcript = await transcribeAudio(audio);
      return { transcript };
    });
  },
);
