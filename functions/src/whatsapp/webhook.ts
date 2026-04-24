import { v4 as uuid } from 'uuid';
import { logger } from 'firebase-functions/v2';
import { resolveUserIdByPhone } from '../config';
import { executeAction } from '../chat/actions';
import { loadHistory, loadMessageById, saveMessage } from '../chat/firestore';
import { runChatTurn } from '../chat/pipeline';
import type { ChatMessage, HistoryTurn } from '../chat/types';
import {
  sendInteractiveButtons,
  sendText,
  markAsRead,
  type WhatsAppConfig,
} from './client';
import { isDuplicate } from './dedupe';

interface WhatsAppIncomingMessage {
  id: string;
  from: string;
  type: string;
  text?: { body: string };
  interactive?: {
    type: string;
    button_reply?: { id: string; title: string };
  };
}

interface WhatsAppWebhookPayload {
  entry?: Array<{
    changes?: Array<{
      value?: {
        messages?: WhatsAppIncomingMessage[];
      };
    }>;
  }>;
}

const extractMessages = (payload: WhatsAppWebhookPayload): WhatsAppIncomingMessage[] => {
  const messages: WhatsAppIncomingMessage[] = [];
  for (const entry of payload.entry ?? []) {
    for (const change of entry.changes ?? []) {
      for (const msg of change.value?.messages ?? []) {
        messages.push(msg);
      }
    }
  }
  return messages;
};

const normalizePhone = (from: string): string =>
  from.startsWith('+') ? from : `+${from}`;

const buildHistoryTurns = (messages: ChatMessage[]): HistoryTurn[] =>
  messages.map((m) => ({ role: m.role, content: m.content }));

const handleTextMessage = async (
  message: WhatsAppIncomingMessage,
  userId: string,
  config: WhatsAppConfig,
): Promise<void> => {
  const text = message.text?.body?.trim();
  if (!text) return;

  const userMessage: ChatMessage = {
    id: uuid(),
    userId,
    role: 'user',
    content: text,
    metadata: null,
    channel: 'whatsapp',
    createdAt: new Date(),
  };
  await saveMessage(userMessage);

  const history = await loadHistory(userId);
  const historyBeforeCurrent = history
    .filter((m) => m.id !== userMessage.id)
    .slice(-50);

  let reply;
  try {
    reply = await runChatTurn({
      userId,
      content: text,
      history: buildHistoryTurns(historyBeforeCurrent),
      channel: 'whatsapp',
    });
  } catch (error) {
    logger.error('Gemini pipeline failed for WhatsApp message', error);
    await sendText(config, message.from, 'Desculpe, não consegui processar. Tente novamente.');
    return;
  }

  if (reply.metadata && reply.metadata.actionType) {
    await sendInteractiveButtons(config, message.from, reply.content, [
      { id: `confirm:${reply.id}`, title: 'Confirmar' },
      { id: `cancel:${reply.id}`, title: 'Cancelar' },
    ]);
  } else {
    await sendText(config, message.from, reply.content);
  }
};

const handleButtonReply = async (
  message: WhatsAppIncomingMessage,
  userId: string,
  config: WhatsAppConfig,
): Promise<void> => {
  const buttonId = message.interactive?.button_reply?.id ?? '';
  const [action, referenceId] = buttonId.split(':');

  if (action === 'cancel') {
    const cancelled: ChatMessage = {
      id: uuid(),
      userId,
      role: 'assistant',
      content: 'Ação cancelada.',
      metadata: null,
      channel: 'whatsapp',
      createdAt: new Date(),
    };
    await saveMessage(cancelled);
    await sendText(config, message.from, cancelled.content);
    return;
  }

  if (action !== 'confirm' || !referenceId) {
    await sendText(config, message.from, 'Não reconheci essa resposta.');
    return;
  }

  const original = await loadMessageById(referenceId);
  if (!original?.metadata) {
    await sendText(config, message.from, 'Essa ação expirou, peça novamente.');
    return;
  }

  let resultText: string;
  try {
    resultText = await executeAction(userId, original.metadata);
  } catch (error) {
    logger.error('Action executor failed', error);
    resultText = 'Não consegui executar a ação. Tente novamente.';
  }

  const resultMessage: ChatMessage = {
    id: uuid(),
    userId,
    role: 'assistant',
    content: resultText,
    metadata: null,
    channel: 'whatsapp',
    createdAt: new Date(),
  };
  await saveMessage(resultMessage);
  await sendText(config, message.from, resultText);
};

export const processIncomingMessage = async (
  message: WhatsAppIncomingMessage,
  config: WhatsAppConfig,
): Promise<void> => {
  if (isDuplicate(message.id)) {
    logger.info('Skipping duplicate WhatsApp message', { id: message.id });
    return;
  }

  const userId = resolveUserIdByPhone(normalizePhone(message.from));
  if (!userId) {
    logger.warn('Ignoring message from unknown phone', { from: message.from });
    return;
  }

  await markAsRead(config, message.id);

  if (message.type === 'text') {
    await handleTextMessage(message, userId, config);
    return;
  }

  if (
    message.type === 'interactive' &&
    message.interactive?.type === 'button_reply'
  ) {
    await handleButtonReply(message, userId, config);
    return;
  }

  await sendText(config, message.from, 'No momento só consigo processar mensagens de texto.');
};

const logStatuses = (payload: WhatsAppWebhookPayload): void => {
  for (const entry of payload.entry ?? []) {
    for (const change of entry.changes ?? []) {
      const statuses = (change.value as any)?.statuses;
      if (Array.isArray(statuses) && statuses.length > 0) {
        logger.info('WhatsApp delivery statuses', { statuses });
      }
    }
  }
};

export const processWebhookPayload = async (
  payload: WhatsAppWebhookPayload,
  config: WhatsAppConfig,
): Promise<void> => {
  logStatuses(payload);
  const messages = extractMessages(payload);
  for (const msg of messages) {
    try {
      await processIncomingMessage(msg, config);
    } catch (error) {
      logger.error('Failed to process WhatsApp message', { id: msg.id, error });
    }
  }
};
