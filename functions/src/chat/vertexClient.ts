import { GoogleGenAI } from '@google/genai';
import { GEMINI_LOCATION } from '../config';

let cachedClient: GoogleGenAI | null = null;

/**
 * Lazily-initialised, cached Vertex AI client. Shared by the chat and
 * transcription modules so the project-resolution + caching logic lives in
 * one place instead of being copy-pasted per module.
 *
 * `vertexai: true` pins the client to the Vertex AI backend instead of the
 * Gemini Developer API: the function authenticates as its Cloud Functions
 * service account via ADC, so there is no API key to supply and the project
 * below is what scopes the request.
 */
export const vertex = (): GoogleGenAI => {
  if (!cachedClient) {
    const project =
      process.env.GCLOUD_PROJECT ??
      process.env.GCP_PROJECT ??
      process.env.PROJECT_ID;
    if (!project) {
      throw new Error(
        'GCLOUD_PROJECT env var is required to initialise Vertex AI',
      );
    }
    cachedClient = new GoogleGenAI({
      vertexai: true,
      project,
      location: GEMINI_LOCATION,
    });
  }
  return cachedClient;
};
