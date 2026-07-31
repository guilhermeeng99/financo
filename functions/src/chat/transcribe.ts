import { logger } from 'firebase-functions/logger';
import { GEMINI_MODEL } from '../config';
import { vertex } from './vertexClient';

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
    const response = await vertex().models.generateContent({
      model: GEMINI_MODEL,
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
    // `.text` concatenates the candidate's text parts for us, replacing the
    // manual candidates[0].content.parts[0] walk the old SDK required.
    return (response.text ?? '').trim();
  } catch (error) {
    logger.error('Audio transcription failed', error);
    // `cause` keeps the upstream Vertex error attached for logs; the callable
    // wrapper in index.ts is what stops it reaching the client.
    throw new Error(`Transcription failed: ${(error as Error).message}`, {
      cause: error,
    });
  }
};
