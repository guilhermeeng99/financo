export type ChatRole = 'user' | 'assistant';

// `metadata` below is the action block the model emitted, parsed straight from
// JSON, so its shape is only known to the Flutter client that consumes it.
// It is typed `unknown` rather than `any` on purpose: nothing on the server
// reads into it, and `unknown` makes that a compile error instead of a silent
// one if that ever changes.

export interface ChatMessage {
  id: string;
  userId: string;
  role: ChatRole;
  content: string;
  metadata?: Record<string, unknown> | null;
  createdAt: Date;
}

export interface HistoryTurn {
  role: ChatRole;
  content: string;
}

export interface AssistantReply {
  id: string;
  content: string;
  metadata: Record<string, unknown> | null;
}

export type ActionType =
  | 'transaction'
  | 'transfer'
  | 'account'
  | 'category'
  | 'budget';
