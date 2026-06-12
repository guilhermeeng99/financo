import * as admin from 'firebase-admin';
import { buildUserContext } from '../src/chat/context';

interface SeedDoc {
  id: string;
  data: Record<string, unknown>;
}

interface WhereCall {
  collection: string;
  field: string;
  op: string;
  value: unknown;
}

// Minimal firebase-admin stub: only the
// firestore().collection().where().get() chain the context builder touches.
// Docs are seeded per collection name so each test controls its snapshot.
jest.mock('firebase-admin', () => {
  const state = {
    seeded: {} as Record<string, SeedDoc[]>,
    whereCalls: [] as WhereCall[],
  };
  const collection = jest.fn((name: string) => ({
    where: (field: string, op: string, value: unknown) => {
      state.whereCalls.push({ collection: name, field, op, value });
      return {
        get: async () => ({
          docs: (state.seeded[name] ?? []).map((row) => ({
            id: row.id,
            data: () => row.data,
          })),
        }),
      };
    },
  }));
  const firestore = jest.fn(() => ({ collection }));
  return { firestore, __mocks: { firestore, collection, state } };
});

// Typed handle on the stub created above so tests can seed collections and
// inspect the where() filters the builder applied.
const mocks = (admin as unknown as {
  __mocks: {
    firestore: jest.Mock;
    collection: jest.Mock;
    state: { seeded: Record<string, SeedDoc[]>; whereCalls: WhereCall[] };
  };
}).__mocks;

const seed = (name: string, rows: SeedDoc[]): void => {
  mocks.state.seeded[name] = rows;
};

describe('buildUserContext', () => {
  beforeEach(() => {
    jest.clearAllMocks();
    mocks.state.seeded = {};
    mocks.state.whereCalls = [];
  });

  it('scopes every collection query to the given userId', async () => {
    await buildUserContext('user-1');

    const queried = mocks.state.whereCalls.map((call) => call.collection).sort();
    expect(queried).toEqual(['accounts', 'budgets', 'categories']);
    for (const call of mocks.state.whereCalls) {
      expect(call.field).toBe('userId');
      expect(call.op).toBe('==');
      expect(call.value).toBe('user-1');
    }
  });

  it('renders placeholders and no budget block when all collections are empty', async () => {
    const context = await buildUserContext('user-1');

    expect(context).toContain('=== USER CONTEXT');
    expect(context).toContain('=== END USER CONTEXT ===');
    expect(context).toContain('(nenhuma conta cadastrada)');
    expect(context).toContain('(nenhuma categoria cadastrada)');
    expect(context).not.toContain('Orcamentos mensais ativos:');
  });

  it('summarises accounts with localized type labels and bank', async () => {
    seed('accounts', [
      { id: 'a1', data: { name: 'Nubank', type: 'checking', bank: 'nubank' } },
      { id: 'a2', data: { name: 'Cartão Inter', type: 'creditCard', bank: 'inter' } },
    ]);

    const context = await buildUserContext('user-1');

    expect(context).toContain('- "Nubank" (conta corrente, banco: nubank)');
    expect(context).toContain('- "Cartão Inter" (cartao de credito, banco: inter)');
  });

  it('falls back to checking/others for accounts missing type and bank', async () => {
    seed('accounts', [{ id: 'a1', data: { name: 'Velha' } }]);

    const context = await buildUserContext('user-1');

    expect(context).toContain('- "Velha" (conta corrente, banco: others)');
  });

  it('summarises categories as despesa/receita', async () => {
    seed('categories', [
      { id: 'c1', data: { name: 'Alimentação', type: 'expense' } },
      { id: 'c2', data: { name: 'Salário', type: 'income' } },
    ]);

    const context = await buildUserContext('user-1');

    expect(context).toContain('- "Alimentação" (despesa)');
    expect(context).toContain('- "Salário" (receita)');
  });

  it('joins budgets to category names and formats BRL amounts', async () => {
    seed('categories', [
      { id: 'c1', data: { name: 'Alimentação', type: 'expense' } },
    ]);
    seed('budgets', [{ id: 'b1', data: { categoryId: 'c1', amount: 500 } }]);

    const context = await buildUserContext('user-1');

    expect(context).toContain('Orcamentos mensais ativos:');
    // The space between R$ and digits may be a regular or non-breaking
    // space depending on the ICU build, so match either via \s.
    expect(context).toMatch(/- "Alimentação" -> R\$\s500,00\/mes/);
  });

  it('skips budgets whose category is missing or unknown', async () => {
    seed('categories', [
      { id: 'c1', data: { name: 'Alimentação', type: 'expense' } },
    ]);
    seed('budgets', [
      { id: 'b1', data: { amount: 100 } }, // no categoryId
      { id: 'b2', data: { categoryId: 'ghost', amount: 200 } }, // unknown id
    ]);

    const context = await buildUserContext('user-1');

    // All budget rows were filtered out, so the block must not render at all.
    expect(context).not.toContain('Orcamentos mensais ativos:');
  });
});
