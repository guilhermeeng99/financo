import { logger } from 'firebase-functions/logger';
import { GEMINI_MODEL } from '../src/config';
import { transcribeAudio } from '../src/chat/transcribe';
import { vertex } from '../src/chat/vertexClient';

// The Vertex client is mocked at its module boundary so no GCP project or
// network is needed; tests drive generateContent results directly.
jest.mock('../src/chat/vertexClient', () => {
  const generateContent = jest.fn();
  return {
    vertex: jest.fn(() => ({ models: { generateContent } })),
    __mocks: { generateContent },
  };
});

// Silence the error log on the failure path while still letting us assert
// the failure was logged.
jest.mock('firebase-functions/logger', () => ({
  logger: { error: jest.fn() },
}));

const vertexMocks = (jest.requireMock('../src/chat/vertexClient') as {
  __mocks: { generateContent: jest.Mock };
}).__mocks;

const audio = { data: 'base64-audio-bytes', mimeType: 'audio/m4a' };

// @google/genai exposes the joined candidate text as a plain `.text` getter,
// so the stub response is just that field rather than the old SDK's
// candidates[0].content.parts[0] nesting.
const responseWithText = (text: string) => ({ text });

describe('transcribeAudio', () => {
  beforeEach(() => {
    jest.clearAllMocks();
    (vertex as jest.Mock).mockClear();
  });

  it('returns the trimmed transcript on success', async () => {
    vertexMocks.generateContent.mockResolvedValueOnce(
      responseWithText('  Gastei 45 reais no iFood.  '),
    );

    await expect(transcribeAudio(audio)).resolves.toBe(
      'Gastei 45 reais no iFood.',
    );
    // The model id now travels in the generateContent request itself rather
    // than in a separate getGenerativeModel() call.
    expect(vertexMocks.generateContent).toHaveBeenCalledWith(
      expect.objectContaining({ model: GEMINI_MODEL }),
    );
  });

  it('sends the instruction first and the audio as inline data', async () => {
    vertexMocks.generateContent.mockResolvedValueOnce(responseWithText('ok'));

    await transcribeAudio(audio);

    const request = vertexMocks.generateContent.mock.calls[0][0];
    expect(request.contents).toHaveLength(1);
    const parts = request.contents[0].parts;
    // Instruction must lead the parts and carry the brand glossary bias.
    expect(parts[0].text).toContain('Transcreva fielmente');
    expect(parts[0].text).toContain('Nubank');
    expect(parts[1].inlineData).toEqual({
      mimeType: 'audio/m4a',
      data: 'base64-audio-bytes',
    });
  });

  // The SDK collapses "no candidates" and "candidate carries no text part"
  // into a single undefined `.text`, so both upstream shapes are pinned here
  // as the two ways that field can come back empty.
  it('returns an empty string when the response carries no text', async () => {
    vertexMocks.generateContent.mockResolvedValueOnce({ text: undefined });

    await expect(transcribeAudio(audio)).resolves.toBe('');
  });

  it('returns an empty string when the response omits text entirely', async () => {
    vertexMocks.generateContent.mockResolvedValueOnce({});

    await expect(transcribeAudio(audio)).resolves.toBe('');
  });

  it('wraps and logs model failures', async () => {
    vertexMocks.generateContent.mockRejectedValueOnce(new Error('quota'));

    await expect(transcribeAudio(audio)).rejects.toThrow(
      'Transcription failed: quota',
    );
    expect(logger.error).toHaveBeenCalledWith(
      'Audio transcription failed',
      expect.any(Error),
    );
  });
});
