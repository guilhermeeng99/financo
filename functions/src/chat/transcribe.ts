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

const TRANSCRIPTION_INSTRUCTION =
  'Transcreva fielmente o áudio para texto. ' +
  'Retorne APENAS a transcrição, sem comentários, prefixos ou explicações. ' +
  'Preserve pontuação natural (vírgulas, pontos). ' +
  'Se o áudio estiver em português, mantenha português brasileiro.';

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
