import { buildMessage, PendingTransaction } from '../src/bills/notifyBillsDue';

// `buildMessage` is pure: it derives notification copy from a list of pending
// bills with no I/O, so we test it directly (no firebase-admin mock needed).
// Overdue = dueDate strictly before the local start-of-today; due-today = on
// or after start-of-today (the fetch layer already caps at end-of-today).

const startOfToday = (): Date => {
  const now = new Date();
  return new Date(now.getFullYear(), now.getMonth(), now.getDate());
};

const makeBill = (
  overrides: Partial<PendingTransaction> = {},
): PendingTransaction => ({
  id: 'bill-1',
  userId: 'user-1',
  type: 'expense',
  description: 'Internet',
  amount: 2000,
  dueDate: startOfToday(),
  ...overrides,
});

// Clearly in the past — guaranteed < startOfToday regardless of run time.
const yesterday = (): Date => {
  const t = startOfToday();
  t.setDate(t.getDate() - 1);
  return t;
};

// Later today — still >= startOfToday, so classified as due-today.
const laterToday = (): Date => {
  const t = startOfToday();
  t.setHours(23, 0, 0, 0);
  return t;
};

describe('buildMessage', () => {
  describe('single bill', () => {
    it('renders an overdue title/body for a past dueDate', () => {
      const result = buildMessage([
        makeBill({ description: 'Internet', amount: 2000, dueDate: yesterday() }),
      ]);

      expect(result.title).toBe('Conta atrasada');
      expect(result.body).toContain('Internet');
      expect(result.body).toContain('está atrasada.');
      expect(result.body).not.toContain('vence hoje');
    });

    it('renders a due-today title/body for a dueDate later today', () => {
      const result = buildMessage([
        makeBill({ description: 'Internet', amount: 2000, dueDate: laterToday() }),
      ]);

      expect(result.title).toBe('Conta vence hoje');
      expect(result.body).toContain('Internet');
      expect(result.body).toContain('vence hoje.');
      expect(result.body).not.toContain('atrasada');
    });

    it('formats the amount as BRL (R$ 2.000,00 style)', () => {
      const result = buildMessage([
        makeBill({ description: 'Internet', amount: 2000, dueDate: laterToday() }),
      ]);

      // Intl pt-BR yields a thousands dot + decimal comma. The space between
      // the R$ symbol and the digits may be a regular or non-breaking space
      // depending on the ICU build, so assert the numeric portion explicitly
      // and the currency symbol separately.
      expect(result.body).toMatch(/R\$\s2\.000,00/);
      expect(result.body).toContain('2.000,00');
    });

    it("falls back to 'Sua conta' when the description is blank", () => {
      const result = buildMessage([
        makeBill({ description: '   ', amount: 2000, dueDate: laterToday() }),
      ]);

      expect(result.body).toContain('Sua conta');
      expect(result.body).toMatch(/Sua conta \(R\$\s2\.000,00\) vence hoje\./);
    });
  });

  describe('multiple bills', () => {
    it('summarises when all bills are due today', () => {
      const result = buildMessage([
        makeBill({ id: 'a', dueDate: laterToday() }),
        makeBill({ id: 'b', dueDate: startOfToday() }),
        makeBill({ id: 'c', dueDate: laterToday() }),
      ]);

      expect(result.title).toBe('Você tem 3 contas a pagar');
      expect(result.body).toBe('3 contas vencem hoje.');
      expect(result.body).not.toContain('atrasada');
    });

    it('summarises a mix of overdue and due-today bills', () => {
      const result = buildMessage([
        makeBill({ id: 'a', dueDate: yesterday() }),
        makeBill({ id: 'b', dueDate: yesterday() }),
        makeBill({ id: 'c', dueDate: laterToday() }),
      ]);

      expect(result.title).toBe('Você tem 3 contas a pagar');
      // 2 overdue, 1 due today.
      expect(result.body).toBe('2 atrasada(s) e 1 vencendo hoje.');
    });
  });
});
