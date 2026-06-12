import { logger } from 'firebase-functions/v2';
import { GEMINI_MODEL } from '../src/config';
import { transcribeAudio } from '../src/chat/transcribe';
import { vertex } from '../src/chat/vertexClient';

// The Vertex client is mocked at its module boundary so no GCP project or
// network is needed; tests drive generateContent results directly.
jest.mock('../src/chat/vertexClient', () => {
  const generateContent = jest.fn();
  const getGenerativeModel = jest.fn(() => ({ generateContent }));
  return {
    vertex: jest.fn(() => ({ getGenerativeModel })),
    __mocks: { generateContent, getGenerativeModel },
  };
});

// Silence the error log on the failure path while still letting us assert
// the failure was logged.
jest.mock('firebase-functions/v2', () => ({
  logger: { error: jest.fn() },
}));

const vertexMocks = (jest.requireMock('../src/chat/vertexClient') as {
  __mocks: { generateContent: jest.Mock; getGenerativeModel: jest.Mock };
}).__mocks;

const audio = { data: 'base64-audio-bytes', mimeType: 'audio/m4a' };

const responseWithText = (text: string) => ({
  response: {
    candidates: [{ content: { parts: [{ text }] } }],
  },
});

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
    expect(vertexMocks.getGenerativeModel).toHaveBeenCalledWith({
      model: GEMINI_MODEL,
    });
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

  it('returns an empty string when the model yields no candidates', async () => {
    vertexMocks.generateContent.mockResolvedValueOnce({ response: {} });

    await expect(transcribeAudio(audio)).resolves.toBe('');
  });

  it('returns an empty string when the candidate has no text part', async () => {
    vertexMocks.generateContent.mockResolvedValueOnce({
      response: { candidates: [{ content: { parts: [{}] } }] },
    });

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
