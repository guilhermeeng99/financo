import * as admin from 'firebase-admin';
import { HttpsError, onCall } from 'firebase-functions/v2/https';
import { onRequest } from 'firebase-functions/v2/https';
import { logger } from 'firebase-functions/v2';
import {
  META_APP_SECRET,
  WHATSAPP_ACCESS_TOKEN,
  WHATSAPP_PHONE_ID,
  WHATSAPP_VERIFY_TOKEN,
} from './config';
import { runChatTurn } from './chat/pipeline';
import { transcribeAudio } from './chat/transcribe';
import type { HistoryTurn } from './chat/types';
import { isEmailAllowed } from './access/allowlist';
import { deleteUserAsAdmin as deleteUserAsAdminImpl } from './admin/deleteUser';
import { verifySignature } from './whatsapp/signature';
import { processWebhookPayload } from './whatsapp/webhook';
import { notifyBillsDue } from './bills/notifyBillsDue';

admin.initializeApp();

export { notifyBillsDue };

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
        channel: 'app',
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

export const whatsappWebhook = onRequest(
  {
    region: 'us-central1',
    secrets: [
      META_APP_SECRET,
      WHATSAPP_ACCESS_TOKEN,
      WHATSAPP_PHONE_ID,
      WHATSAPP_VERIFY_TOKEN,
    ],
  },
  async (req, res) => {
    if (req.method === 'GET') {
      const mode = req.query['hub.mode'];
      const token = req.query['hub.verify_token'];
      const challenge = req.query['hub.challenge'];
      if (mode === 'subscribe' && token === WHATSAPP_VERIFY_TOKEN.value()) {
        res.status(200).send(String(challenge ?? ''));
        return;
      }
      res.status(403).send('Forbidden');
      return;
    }

    if (req.method !== 'POST') {
      res.status(405).send('Method Not Allowed');
      return;
    }

    const rawBody = (req as any).rawBody as Buffer | undefined;
    if (!rawBody) {
      logger.error('whatsappWebhook received request without rawBody');
      res.status(400).send('Bad Request');
      return;
    }

    const signature = req.header('x-hub-signature-256');
    if (!verifySignature(rawBody, signature, META_APP_SECRET.value())) {
      logger.warn('Rejecting webhook with invalid signature');
      res.status(403).send('Forbidden');
      return;
    }

    // Always ACK 200 to Meta. If we return 5xx repeatedly, Meta disables
    // the webhook. Log any unexpected failures for investigation.
    try {
      await processWebhookPayload(req.body, {
        accessToken: WHATSAPP_ACCESS_TOKEN.value(),
        phoneNumberId: WHATSAPP_PHONE_ID.value(),
      });
    } catch (error) {
      logger.error('whatsappWebhook processing failed', error);
    }
    res.status(200).send('OK');
  },
);
