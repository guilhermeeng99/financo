import * as admin from 'firebase-admin';
import { HttpsError, onCall } from 'firebase-functions/v2/https';
import { logger } from 'firebase-functions/v2';
import { runChatTurn } from './chat/pipeline';
import { transcribeAudio } from './chat/transcribe';
import type { HistoryTurn } from './chat/types';
import { isEmailAllowed } from './access/allowlist';
import { deleteUserAsAdmin as deleteUserAsAdminImpl } from './admin/deleteUser';
import { notifyTransactionsDue } from './transactions/notifyTransactionsDue';

admin.initializeApp();

export { notifyTransactionsDue };

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
    const userId = request.auth?.uid;
    const email = request.auth?.token?.email as string | undefined;
    if (!userId) {
      throw new HttpsError('unauthenticated', 'Sign-in required to use chat.');
    }
    if (!(await isEmailAllowed(email))) {
      throw new HttpsError('permission-denied', 'Not allowed.');
    }

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

    try {
      const reply = await runChatTurn({
        userId,
        content,
        history,
        image,
      });
      return reply;
    } catch (error) {
      logger.error('chatSend failed', error);
      throw new HttpsError('internal', (error as Error).message ?? 'Chat failed');
    }
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
    if (!request.auth?.uid) {
      throw new HttpsError('unauthenticated', 'Sign-in required.');
    }
    const callerEmail = request.auth.token?.email as string | undefined;
    return deleteUserAsAdminImpl(
      request.data,
      callerEmail,
      request.auth.uid,
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
    if (!request.auth?.uid) {
      throw new HttpsError('unauthenticated', 'Sign-in required.');
    }
    const email = request.auth.token?.email as string | undefined;
    if (!(await isEmailAllowed(email))) {
      throw new HttpsError('permission-denied', 'Not allowed.');
    }
    const audio = request.data?.audio;
    if (!audio?.data || !audio.mimeType) {
      throw new HttpsError('invalid-argument', 'audio.data and audio.mimeType are required.');
    }
    try {
      const transcript = await transcribeAudio(audio);
      return { transcript };
    } catch (error) {
      logger.error('transcribeChatAudio failed', error);
      throw new HttpsError('internal', (error as Error).message ?? 'Transcription failed');
    }
  },
);
