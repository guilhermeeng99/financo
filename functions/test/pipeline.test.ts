import { buildUserContext } from '../src/chat/context';
import { saveMessage } from '../src/chat/firestore';
import { callGemini } from '../src/chat/gemini';
import { runChatTurn } from '../src/chat/pipeline';
import type { ChatMessage, HistoryTurn } from '../src/chat/types';

// The pipeline is pure orchestration, so each collaborator is mocked at its
// import boundary: context (Firestore reads), gemini (Vertex AI) and
// firestore (persistence). The extractor stays real — it is pure and the
// pipeline's action wiring is exactly what we want covered end to end.
jest.mock('../src/chat/context', () => ({
  buildUserContext: jest.fn(),
}));
jest.mock('../src/chat/firestore', () => ({
  saveMessage: jest.fn(),
}));
jest.mock('../src/chat/gemini', () => ({
  callGemini: jest.fn(),
}));
// Pin the generated message id so assertions are deterministic.
jest.mock('uuid', () => ({
  v4: jest.fn(() => 'assistant-msg-1'),
}));

const mockBuildUserContext = buildUserContext as jest.MockedFunction<
  typeof buildUserContext
>;
const mockSaveMessage = saveMessage as jest.MockedFunction<typeof saveMessage>;
const mockCallGemini = callGemini as jest.MockedFunction<typeof callGemini>;

const history: HistoryTurn[] = [
  { role: 'user', content: 'Oi' },
  { role: 'assistant', content: 'Olá! Como posso ajudar?' },
];

const baseInput = {
  userId: 'user-1',
  content: 'Gastei 45 no almoço',
  history,
};

describe('runChatTurn', () => {
  beforeEach(() => {
    jest.clearAllMocks();
    mockBuildUserContext.mockResolvedValue('CTX');
    mockCallGemini.mockResolvedValue('Tudo certo!');
    mockSaveMessage.mockResolvedValue(undefined);
  });

  it('returns the assistant reply for a plain-text response', async () => {
    const reply = await runChatTurn(baseInput);

    expect(reply).toEqual({
      id: 'assistant-msg-1',
      content: 'Tudo certo!',
      metadata: null,
    });
  });

  it('passes content, history, built context and image through to Gemini', async () => {
    const image = { data: 'base64-bytes', mimeType: 'image/jpeg' };

    await runChatTurn({ ...baseInput, image });

    expect(mockBuildUserContext).toHaveBeenCalledWith('user-1');
    expect(mockCallGemini).toHaveBeenCalledWith(
      'Gastei 45 no almoço',
      history,
      'CTX',
      image,
    );
  });

  it('forwards no image argument when the turn is text-only', async () => {
    await runChatTurn(baseInput);

    expect(mockCallGemini).toHaveBeenCalledWith(
      'Gastei 45 no almoço',
      history,
      'CTX',
      undefined,
    );
  });

  it('persists the assistant message with the expected shape', async () => {
    await runChatTurn(baseInput);

    expect(mockSaveMessage).toHaveBeenCalledTimes(1);
    const saved = mockSaveMessage.mock.calls[0][0] as ChatMessage;
    expect(saved.id).toBe('assistant-msg-1');
    expect(saved.userId).toBe('user-1');
    expect(saved.role).toBe('assistant');
    expect(saved.content).toBe('Tudo certo!');
    expect(saved.metadata).toBeNull();
    expect(saved.createdAt).toBeInstanceOf(Date);
  });

  it('extracts an action block, persisting and returning clean text + metadata', async () => {
    mockCallGemini.mockResolvedValue(
      [
        'Anotei a despesa:',
        '[TRANSACTION_DATA]',
        '{"type": "expense", "amount": 45, "category": "Alimentação", "date": "2026-06-12", "description": "Almoço", "account": "Nubank"}',
        '[/TRANSACTION_DATA]',
        'Confirma?',
      ].join('\n'),
    );

    const reply = await runChatTurn(baseInput);

    expect(reply.metadata).toMatchObject({
      actionType: 'transaction',
      type: 'expense',
      amount: 45,
    });
    expect(reply.content).not.toContain('[TRANSACTION_DATA]');
    expect(reply.content).toContain('Confirma?');

    // The persisted message must mirror the reply (same cleaned content and
    // proposed-action metadata) so history replays stay consistent.
    const saved = mockSaveMessage.mock.calls[0][0] as ChatMessage;
    expect(saved.content).toBe(reply.content);
    expect(saved.metadata).toEqual(reply.metadata);
  });

  it('surfaces Gemini failures and persists nothing', async () => {
    mockCallGemini.mockRejectedValue(new Error('AI processing failed: quota'));

    await expect(runChatTurn(baseInput)).rejects.toThrow(
      'AI processing failed: quota',
    );
    expect(mockSaveMessage).not.toHaveBeenCalled();
  });

  it('surfaces context-build failures without calling Gemini', async () => {
    mockBuildUserContext.mockRejectedValue(new Error('firestore down'));

    await expect(runChatTurn(baseInput)).rejects.toThrow('firestore down');
    expect(mockCallGemini).not.toHaveBeenCalled();
    expect(mockSaveMessage).not.toHaveBeenCalled();
  });

  it('surfaces persistence failures to the caller', async () => {
    mockSaveMessage.mockRejectedValue(new Error('write failed'));

    await expect(runChatTurn(baseInput)).rejects.toThrow('write failed');
  });
});
