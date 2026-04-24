import * as admin from 'firebase-admin';
import { HISTORY_LIMIT } from '../config';
import type { ChatChannel, ChatMessage, ChatRole } from './types';

const COLLECTION = 'chat_messages';

const db = (): admin.firestore.Firestore => admin.firestore();

const docToMessage = (doc: admin.firestore.QueryDocumentSnapshot): ChatMessage => {
  const data = doc.data();
  return {
    id: doc.id,
    userId: data.userId as string,
    role: data.role as ChatRole,
    content: data.content as string,
    metadata: (data.metadata as Record<string, any> | null) ?? null,
    channel: (data.channel as ChatChannel) ?? 'app',
    createdAt: (data.createdAt as admin.firestore.Timestamp).toDate(),
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
      channel: message.channel,
      createdAt: admin.firestore.Timestamp.fromDate(message.createdAt),
    });
};

export const loadMessageById = async (id: string): Promise<ChatMessage | null> => {
  const doc = await db().collection(COLLECTION).doc(id).get();
  if (!doc.exists) return null;
  return docToMessage(doc as admin.firestore.QueryDocumentSnapshot);
};
