import {
  getFirestore,
  Timestamp,
  type Firestore,
  type QueryDocumentSnapshot,
} from 'firebase-admin/firestore';
import { HISTORY_LIMIT } from '../config';
import type { ChatMessage, ChatRole } from './types';

const COLLECTION = 'chat_messages';

const db = (): Firestore => getFirestore();

const docToMessage = (doc: QueryDocumentSnapshot): ChatMessage => {
  const data = doc.data();
  return {
    id: doc.id,
    userId: data.userId as string,
    role: data.role as ChatRole,
    content: data.content as string,
    metadata: (data.metadata as Record<string, unknown> | null) ?? null,
    createdAt: (data.createdAt as Timestamp).toDate(),
  };
};

export const loadHistory = async (userId: string): Promise<ChatMessage[]> => {
  const snapshot = await db()
    .collection(COLLECTION)
    .where('userId', '==', userId)
    .orderBy('createdAt', 'desc')
    .limit(HISTORY_LIMIT)
    .get();

  return snapshot.docs.map(docToMessage).reverse();
};

export const saveMessage = async (message: ChatMessage): Promise<void> => {
  await db()
    .collection(COLLECTION)
    .doc(message.id)
    .set({
      userId: message.userId,
      role: message.role,
      content: message.content,
      metadata: message.metadata ?? null,
      createdAt: Timestamp.fromDate(message.createdAt),
    });
};

export const loadMessageById = async (id: string): Promise<ChatMessage | null> => {
  const doc = await db().collection(COLLECTION).doc(id).get();
  if (!doc.exists) return null;
  return docToMessage(doc as QueryDocumentSnapshot);
};
