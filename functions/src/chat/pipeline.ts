import { v4 as uuid } from 'uuid';
import { buildUserContext } from './context';
import { extractAction } from './extractor';
import { saveMessage } from './firestore';
import { callGemini, type ImagePayload } from './gemini';
import type { AssistantReply, ChatChannel, ChatMessage, HistoryTurn } from './types';

export interface ChatTurnInput {
  userId: string;
  content: string;
  history: HistoryTurn[];
  channel: ChatChannel;
  image?: ImagePayload;
}

export const runChatTurn = async (input: ChatTurnInput): Promise<AssistantReply> => {
  const userContext = await buildUserContext(input.userId);
  const rawResponse = await callGemini(
    input.content,
    input.history,
    userContext,
    input.image,
  );
  const { cleanText, metadata } = extractAction(rawResponse);

  const assistantMessage: ChatMessage = {
    id: uuid(),
    userId: input.userId,
    role: 'assistant',
    content: cleanText,
    metadata,
    channel: input.channel,
    createdAt: new Date(),
  };

  await saveMessage(assistantMessage);

  return {
    id: assistantMessage.id,
    content: cleanText,
    metadata,
  };
};
