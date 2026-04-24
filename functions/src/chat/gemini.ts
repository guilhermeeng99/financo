import { VertexAI, type Content, type Part } from '@google-cloud/vertexai';
import { logger } from 'firebase-functions/v2';
import { GEMINI_LOCATION, GEMINI_MODEL } from '../config';
import { GEMINI_SYSTEM_PROMPT } from './systemPrompt';
import type { HistoryTurn } from './types';

export interface ImagePayload {
  data: string;
  mimeType: string;
}

let cachedClient: VertexAI | null = null;

const vertex = (): VertexAI => {
  if (!cachedClient) {
    const project =
      process.env.GCLOUD_PROJECT ?? process.env.GCP_PROJECT ?? process.env.PROJECT_ID;
    if (!project) {
      throw new Error('GCLOUD_PROJECT env var is required to initialise Vertex AI');
    }
    cachedClient = new VertexAI({ project, location: GEMINI_LOCATION });
  }
  return cachedClient;
};

const buildModel = (userContext: string) =>
  vertex().getGenerativeModel({
    model: GEMINI_MODEL,
    systemInstruction: {
      role: 'system',
      parts: [{ text: `${GEMINI_SYSTEM_PROMPT}\n\n${userContext}` }],
    },
  });

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
    const model = buildModel(userContext);
    const chat = model.startChat({ history: buildHistoryContents(history) });

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

    const result = await chat.sendMessage(parts);
    const text = result.response.candidates?.[0]?.content?.parts?.[0]?.text;
    return text ?? 'Sorry, I could not process that.';
  } catch (error) {
    logger.error('Gemini call failed', error);
    throw new Error(`AI processing failed: ${(error as Error).message}`);
  }
};
