import { VertexAI } from '@google-cloud/vertexai';
import { logger } from 'firebase-functions/v2';
import { GEMINI_LOCATION, GEMINI_MODEL } from '../config';

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

// Glossary of brand and finance terms the speech model frequently breaks
// apart phonetically (e.g. "Nubank" → "No Bank Geek", "PicPay" → "Pic Pai").
// Spelling them out in the prompt biases the decoder toward the correct
// canonical form. Keep this list short and high-signal — long glossaries
// dilute the prompt and slow down the model.
const FINANCIAL_GLOSSARY = [
  'Nubank',
  'Itaú',
  'Bradesco',
  'Santander',
  'Caixa',
  'Banco do Brasil',
  'BB',
  'Inter',
  'C6',
  'BTG',
  'PicPay',
  'PagBank',
  'Mercado Pago',
  'Will',
  'Neon',
  'Next',
  'Original',
  'Sicoob',
  'Sicredi',
  'XP',
  'Pix',
  'iFood',
  'Uber',
  '99',
  'Rappi',
];

const TRANSCRIPTION_INSTRUCTION =
  'Transcreva fielmente o áudio para texto em português brasileiro. ' +
  'Retorne APENAS a transcrição, sem comentários, prefixos ou explicações. ' +
  'Preserve pontuação natural (vírgulas, pontos). ' +
  'Contexto: o usuário está falando sobre finanças pessoais — ' +
  'transações, contas bancárias, cartões, categorias, orçamentos. ' +
  'Use a grafia canônica destes termos quando aparecerem ' +
  '(mesmo que a pronúncia divirja): ' +
  FINANCIAL_GLOSSARY.join(', ') + '.';

export interface AudioPayload {
  data: string;
  mimeType: string;
}

export const transcribeAudio = async (audio: AudioPayload): Promise<string> => {
  try {
    const model = vertex().getGenerativeModel({ model: GEMINI_MODEL });
    const result = await model.generateContent({
      contents: [
        {
          role: 'user',
          parts: [
            { text: TRANSCRIPTION_INSTRUCTION },
            {
              inlineData: {
                mimeType: audio.mimeType,
                data: audio.data,
              },
            },
          ],
        },
      ],
    });
    const text = result.response.candidates?.[0]?.content?.parts?.[0]?.text;
    return (text ?? '').trim();
  } catch (error) {
    logger.error('Audio transcription failed', error);
    throw new Error(`Transcription failed: ${(error as Error).message}`);
  }
};
