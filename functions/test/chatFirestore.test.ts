import * as admin from 'firebase-admin';
import {
  loadHistory,
  loadMessageById,
  saveMessage,
} from '../src/chat/firestore';
import type { ChatMessage } from '../src/chat/types';
import { HISTORY_LIMIT } from '../src/config';

// Minimal firebase-admin stub covering both chains the module uses:
//   firestore().collection().where().orderBy().limit().get()  (history)
//   firestore().collection().doc().set()/.get()               (save/load by id)
// `firestore` doubles as namespace, so Timestamp.fromDate is attached to it.
jest.mock('firebase-admin', () => {
  const queryGet = jest.fn();
  const limit = jest.fn(() => ({ get: queryGet }));
  const orderBy = jest.fn(() => ({ limit }));
  const where = jest.fn(() => ({ orderBy }));
  const set = jest.fn();
  const docGet = jest.fn();
  const doc = jest.fn(() => ({ set, get: docGet }));
  const collection = jest.fn(() => ({ where, doc }));
  const fromDate = jest.fn((date: Date) => ({ toDate: () => date }));
  const firestore = Object.assign(jest.fn(() => ({ collection })), {
    Timestamp: { fromDate },
  });
  return {
    firestore,
    __mocks: {
      collection,
      where,
      orderBy,
      limit,
      queryGet,
      doc,
      set,
      docGet,
      fromDate,
    },
  };
});

// Typed handle on the stub created above so tests can drive query results
// and assert the arguments forwarded down each chain.
const mocks = (admin as unknown as {
  __mocks: {
    collection: jest.Mock;
    where: jest.Mock;
    orderBy: jest.Mock;
    limit: jest.Mock;
    queryGet: jest.Mock;
    doc: jest.Mock;
    set: jest.Mock;
    docGet: jest.Mock;
    fromDate: jest.Mock;
  };
}).__mocks;

const makeMessage = (overrides: Partial<ChatMessage> = {}): ChatMessage => ({
  id: 'msg-1',
  userId: 'user-1',
  role: 'assistant',
  content: 'Olá!',
  metadata: null,
  createdAt: new Date('2026-06-12T10:00:00Z'),
  ...overrides,
});

// Firestore docs expose data() and a Timestamp-like createdAt.
const makeDoc = (
  id: string,
  data: Record<string, unknown>,
  createdAt: Date,
) => ({
  id,
  exists: true,
  data: () => ({ ...data, createdAt: { toDate: () => createdAt } }),
});

describe('saveMessage', () => {
  beforeEach(() => {
    jest.clearAllMocks();
    mocks.set.mockResolvedValue(undefined);
  });

  it('writes the message under chat_messages/{id} with the persisted shape', async () => {
    const message = makeMessage({
      metadata: { actionType: 'transaction', amount: 45 },
    });

    await saveMessage(message);

    expect(mocks.collection).toHaveBeenCalledWith('chat_messages');
    expect(mocks.doc).toHaveBeenCalledWith('msg-1');
    expect(mocks.fromDate).toHaveBeenCalledWith(message.createdAt);
    expect(mocks.set).toHaveBeenCalledWith({
      userId: 'user-1',
      role: 'assistant',
      content: 'Olá!',
      metadata: { actionType: 'transaction', amount: 45 },
      createdAt: mocks.fromDate.mock.results[0].value,
    });
  });

  it('normalises missing metadata to null in the stored document', async () => {
    await saveMessage(makeMessage({ metadata: undefined }));

    expect(mocks.set).toHaveBeenCalledWith(
      expect.objectContaining({ metadata: null }),
    );
  });
});

describe('loadHistory', () => {
  beforeEach(() => {
    jest.clearAllMocks();
  });

  it('queries by userId, newest-first, capped at HISTORY_LIMIT', async () => {
    mocks.queryGet.mockResolvedValueOnce({ docs: [] });

    await loadHistory('user-1');

    expect(mocks.collection).toHaveBeenCalledWith('chat_messages');
    expect(mocks.where).toHaveBeenCalledWith('userId', '==', 'user-1');
    expect(mocks.orderBy).toHaveBeenCalledWith('createdAt', 'desc');
    expect(mocks.limit).toHaveBeenCalledWith(HISTORY_LIMIT);
  });

  it('reverses the desc snapshot so callers get chronological order', async () => {
    // Snapshot arrives newest-first (desc); the chat needs oldest-first.
    mocks.queryGet.mockResolvedValueOnce({
      docs: [
        makeDoc(
          'newest',
          { userId: 'user-1', role: 'assistant', content: 'B', metadata: null },
          new Date('2026-06-12T10:01:00Z'),
        ),
        makeDoc(
          'oldest',
          { userId: 'user-1', role: 'user', content: 'A', metadata: null },
          new Date('2026-06-12T10:00:00Z'),
        ),
      ],
    });

    const history = await loadHistory('user-1');

    expect(history.map((m) => m.id)).toEqual(['oldest', 'newest']);
    expect(history[0].content).toBe('A');
    expect(history[1].content).toBe('B');
  });

  it('maps document fields onto ChatMessage, defaulting metadata to null', async () => {
    const createdAt = new Date('2026-06-12T10:00:00Z');
    mocks.queryGet.mockResolvedValueOnce({
      docs: [
        makeDoc(
          'msg-1',
          { userId: 'user-1', role: 'user', content: 'Oi' },
          createdAt,
        ),
      ],
    });

    const [message] = await loadHistory('user-1');

    expect(message).toEqual({
      id: 'msg-1',
      userId: 'user-1',
      role: 'user',
      content: 'Oi',
      metadata: null,
      createdAt,
    });
  });
});

describe('loadMessageById', () => {
  beforeEach(() => {
    jest.clearAllMocks();
  });

  it('returns null when the document does not exist', async () => {
    mocks.docGet.mockResolvedValueOnce({ exists: false });

    await expect(loadMessageById('missing')).resolves.toBeNull();
    expect(mocks.doc).toHaveBeenCalledWith('missing');
  });

  it('maps the document onto ChatMessage when it exists', async () => {
    const createdAt = new Date('2026-06-12T10:00:00Z');
    mocks.docGet.mockResolvedValueOnce(
      makeDoc(
        'msg-9',
        {
          userId: 'user-1',
          role: 'assistant',
          content: 'Feito!',
          metadata: { actionType: 'account' },
        },
        createdAt,
      ),
    );

    await expect(loadMessageById('msg-9')).resolves.toEqual({
      id: 'msg-9',
      userId: 'user-1',
      role: 'assistant',
      content: 'Feito!',
      metadata: { actionType: 'account' },
      createdAt,
    });
  });
});
