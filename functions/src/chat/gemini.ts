import { type Content, type Part } from '@google/genai';
import { logger } from 'firebase-functions/logger';
import { GEMINI_MODEL } from '../config';
import { GEMINI_SYSTEM_PROMPT } from './systemPrompt';
import type { HistoryTurn } from './types';
import { vertex } from './vertexClient';

export interface ImagePayload {
  data: string;
  mimeType: string;
}

const todayIsoDate = (): string => new Date().toISOString().split('T')[0];

const buildHistoryContents = (history: HistoryTurn[]): Content[] => [
  {
    role: 'user',
    parts: [
      {
        text:
          `Current date (today): ${todayIsoDate()}. ` +
          'Always use this date when the user says "hoje", "today", or similar.',
      },
    ],
  },
  {
    role: 'model',
    parts: [{ text: 'Got it. I will use this date for all date references.' }],
  },
  ...history.map<Content>((turn) => ({
    role: turn.role === 'user' ? 'user' : 'model',
    parts: [{ text: turn.content }],
  })),
];

export const callGemini = async (
  userMessage: string,
  history: HistoryTurn[],
  userContext: string,
  image?: ImagePayload,
): Promise<string> => {
  try {
    // The system prompt is passed as a plain string: `systemInstruction`
    // accepts a ContentUnion, and a bare string is the documented form since
    // the role on a system instruction is implicit.
    const chat = vertex().chats.create({
      model: GEMINI_MODEL,
      config: {
        systemInstruction: `${GEMINI_SYSTEM_PROMPT}\n\n${userContext}`,
      },
      history: buildHistoryContents(history),
    });

    const parts: Part[] = [];
    if (image) {
      parts.push({
        inlineData: { mimeType: image.mimeType, data: image.data },
      });
    }
    if (userMessage && userMessage.trim().length > 0) {
      parts.push({ text: userMessage });
    } else if (image) {
      // If user sent only an image with no caption, nudge Gemini to extract.
      parts.push({
        text:
          'O usuário enviou esta imagem. Se for comprovante, recibo, nota fiscal ' +
          'ou print de notificação de compra, extraia tudo que conseguir ' +
          '(valor, descrição, data, possível categoria) e siga o fluxo normal ' +
          'de confirmação de transação. Pergunte apenas o que não der pra inferir.',
      });
    }

    const response = await chat.sendMessage({ message: parts });
    // `.text` concatenates the candidate's text parts for us, replacing the
    // manual candidates[0].content.parts[0] walk the old SDK required.
    return response.text ?? 'Sorry, I could not process that.';
  } catch (error) {
    logger.error('Gemini call failed', error);
    // `cause` keeps the upstream Vertex error attached for logs; the callable
    // wrapper in index.ts is what stops it reaching the client.
    throw new Error(`AI processing failed: ${(error as Error).message}`, {
      cause: error,
    });
  }
};
