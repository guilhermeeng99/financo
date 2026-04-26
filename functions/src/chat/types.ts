export type ChatRole = 'user' | 'assistant';
export type ChatChannel = 'app' | 'whatsapp';

export interface ChatMessage {
  id: string;
  userId: string;
  role: ChatRole;
  content: string;
  metadata?: Record<string, any> | null;
  channel: ChatChannel;
  createdAt: Date;
}

export interface HistoryTurn {
  role: ChatRole;
  content: string;
}

export interface AssistantReply {
  id: string;
  content: string;
  metadata: Record<string, any> | null;
}

export type ActionType = 'transaction' | 'account' | 'category' | 'bill';
