export type ChatRole = 'user' | 'assistant';

export interface ChatMessage {
  id: string;
  userId: string;
  role: ChatRole;
  content: string;
  metadata?: Record<string, any> | null;
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

export type ActionType =
  | 'transaction'
  | 'transfer'
  | 'account'
  | 'category'
  | 'bill'
  | 'budget';
