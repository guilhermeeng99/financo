import type { ActionType } from './types';

interface ActionDefinition {
  type: ActionType;
  pattern: RegExp;
}

const ACTIONS: ActionDefinition[] = [
  {
    type: 'transaction',
    pattern: /\[TRANSACTION_DATA\]\s*([\s\S]*?)\s*\[\/TRANSACTION_DATA\]/,
  },
  {
    type: 'transfer',
    pattern: /\[TRANSFER_DATA\]\s*([\s\S]*?)\s*\[\/TRANSFER_DATA\]/,
  },
  {
    type: 'account',
    pattern: /\[ACCOUNT_ACTION\]\s*([\s\S]*?)\s*\[\/ACCOUNT_ACTION\]/,
  },
  {
    type: 'category',
    pattern: /\[CATEGORY_ACTION\]\s*([\s\S]*?)\s*\[\/CATEGORY_ACTION\]/,
  },
  {
    type: 'bill',
    pattern: /\[BILL_ACTION\]\s*([\s\S]*?)\s*\[\/BILL_ACTION\]/,
  },
];

const STRIP_PATTERN =
  /\[(TRANSACTION_DATA|TRANSFER_DATA|ACCOUNT_ACTION|CATEGORY_ACTION|BILL_ACTION)\][\s\S]*?\[\/\1\]/g;

export interface ExtractionResult {
  cleanText: string;
  metadata: Record<string, any> | null;
}

export const extractAction = (responseText: string): ExtractionResult => {
  let metadata: Record<string, any> | null = null;

  for (const { type, pattern } of ACTIONS) {
    const match = pattern.exec(responseText);
    if (!match) continue;
    try {
      const parsed = JSON.parse(match[1]) as Record<string, any>;
      metadata = { actionType: type, ...parsed };
    } catch {
      // Malformed JSON — keep current metadata (possibly from earlier action).
    }
  }

  const cleanText = responseText.replace(STRIP_PATTERN, '').trim();
  return { cleanText, metadata };
};
