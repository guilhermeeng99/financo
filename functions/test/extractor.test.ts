import { extractAction } from '../src/chat/extractor';

describe('extractAction', () => {
  it('returns null metadata for plain text', () => {
    const result = extractAction('Hello, how can I help?');
    expect(result.metadata).toBeNull();
    expect(result.cleanText).toBe('Hello, how can I help?');
  });

  it('extracts transaction metadata and strips the block', () => {
    const input = [
      'Ok, aqui está:',
      '[TRANSACTION_DATA]',
      '{"type": "expense", "amount": 45, "category": "Alimentação", "date": "2026-04-11", "description": "Almoço", "account": "Nubank"}',
      '[/TRANSACTION_DATA]',
      'Confirma?',
    ].join('\n');

    const result = extractAction(input);
    expect(result.metadata).toMatchObject({
      actionType: 'transaction',
      type: 'expense',
      amount: 45,
      category: 'Alimentação',
      account: 'Nubank',
    });
    expect(result.cleanText).not.toContain('[TRANSACTION_DATA]');
    expect(result.cleanText).toContain('Confirma?');
  });

  it('extracts account action', () => {
    const input =
      '[ACCOUNT_ACTION]{"action":"create","name":"Nubank","type":"checking","bank":"nubank","balance":0}[/ACCOUNT_ACTION]';
    const result = extractAction(input);
    expect(result.metadata?.actionType).toBe('account');
    expect(result.metadata?.name).toBe('Nubank');
  });

  it('extracts category action', () => {
    const input =
      '[CATEGORY_ACTION]{"action":"create","name":"Groceries","type":"expense","icon":58835}[/CATEGORY_ACTION]';
    const result = extractAction(input);
    expect(result.metadata?.actionType).toBe('category');
    expect(result.metadata?.icon).toBe(58835);
  });

  it('returns null metadata on malformed JSON', () => {
    const input = '[TRANSACTION_DATA]{not valid json}[/TRANSACTION_DATA]';
    const result = extractAction(input);
    expect(result.metadata).toBeNull();
    expect(result.cleanText).toBe('');
  });

  it('last extracted block wins when multiple types present', () => {
    const input =
      '[ACCOUNT_ACTION]{"action":"create","name":"A"}[/ACCOUNT_ACTION]' +
      '[CATEGORY_ACTION]{"action":"create","name":"B","type":"expense","icon":1}[/CATEGORY_ACTION]';
    const result = extractAction(input);
    expect(result.metadata?.actionType).toBe('category');
    expect(result.metadata?.name).toBe('B');
  });
});
