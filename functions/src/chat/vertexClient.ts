import { VertexAI } from '@google-cloud/vertexai';
import { GEMINI_LOCATION } from '../config';

let cachedClient: VertexAI | null = null;

/**
 * Lazily-initialised, cached Vertex AI client. Shared by the chat and
 * transcription modules so the project-resolution + caching logic lives in
 * one place instead of being copy-pasted per module.
 */
export const vertex = (): VertexAI => {
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
    cachedClient = new VertexAI({ project, location: GEMINI_LOCATION });
  }
  return cachedClient;
};
