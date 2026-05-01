import * as admin from 'firebase-admin';
import { colorForIndex } from './categoryColors';

type ActionMetadata = Record<string, any>;

const Timestamp = () => admin.firestore.Timestamp;
const db = (): admin.firestore.Firestore => admin.firestore();

const now = () => Timestamp().fromDate(new Date());

const caseInsensitiveFind = <T extends { name: string }>(
  items: T[],
  needle: string,
): T | undefined => items.find((i) => i.name.toLowerCase() === needle.toLowerCase());

interface AccountDoc {
  id: string;
  name: string;
}

interface CategoryDoc {
  id: string;
  name: string;
}

const fetchAccounts = async (userId: string): Promise<AccountDoc[]> => {
  const snap = await db().collection('accounts').where('userId', '==', userId).get();
  return snap.docs.map((d) => ({ id: d.id, name: (d.data().name as string) ?? '' }));
};

const fetchCategories = async (userId: string): Promise<CategoryDoc[]> => {
  const snap = await db().collection('categories').where('userId', '==', userId).get();
  return snap.docs.map((d) => ({ id: d.id, name: (d.data().name as string) ?? '' }));
};

export const executeAccountAction = async (
  userId: string,
  meta: ActionMetadata,
): Promise<string> => {
  const action = meta.action as string | undefined;

  if (action === 'create') {
    const name = (meta.name as string | undefined) ?? 'Account';
    const bankStr = ((meta.bank as string | undefined) ?? 'others').toLowerCase();
    const bank = bankStr === 'nubank' ? 'nubank' : 'others';
    const type = meta.type === 'creditCard' ? 'creditCard' : 'checking';

    let linkedAccountId: string | null = null;
    if (type === 'creditCard' && meta.linkedAccountName) {
      const accounts = await fetchAccounts(userId);
      const linked = caseInsensitiveFind(accounts, meta.linkedAccountName as string);
      if (linked) linkedAccountId = linked.id;
    }

    const payload: Record<string, any> = {
      userId,
      name,
      type,
      bank,
      balance: Number(meta.balance ?? 0),
      creditLimit: meta.creditLimit != null ? Number(meta.creditLimit) : null,
      closingDay: meta.closingDay != null ? Number(meta.closingDay) : null,
      dueDay: meta.dueDay != null ? Number(meta.dueDay) : null,
      linkedAccountId,
      createdAt: now(),
    };

    await db().collection('accounts').add(payload);
    return `Conta "${name}" criada com sucesso!`;
  }

  if (action === 'delete') {
    const name = (meta.name as string | undefined) ?? '';
    const accounts = await fetchAccounts(userId);
    const match = caseInsensitiveFind(accounts, name);
    if (!match) return `Nenhuma conta chamada "${name}" encontrada.`;
    await db().collection('accounts').doc(match.id).delete();
    return `Conta "${name}" removida com sucesso!`;
  }

  return 'Ação de conta desconhecida.';
};

export const executeCategoryAction = async (
  userId: string,
  meta: ActionMetadata,
): Promise<string> => {
  const action = meta.action as string | undefined;

  if (action === 'create') {
    const name = (meta.name as string | undefined) ?? 'Category';
    const type = meta.type === 'income' ? 'income' : 'expense';
    const icon = meta.icon != null ? Number(meta.icon) : 58332;

    const existing = await fetchCategories(userId);
    const color = colorForIndex(existing.length);

    const payload = { userId, name, icon, color, type };
    await db().collection('categories').add(payload);
    return `Categoria "${name}" criada com sucesso!`;
  }

  if (action === 'delete') {
    const name = (meta.name as string | undefined) ?? '';
    const categories = await fetchCategories(userId);
    const match = caseInsensitiveFind(categories, name);
    if (!match) return `Nenhuma categoria chamada "${name}" encontrada.`;
    await db().collection('categories').doc(match.id).delete();
    return `Categoria "${name}" removida com sucesso!`;
  }

  return 'Ação de categoria desconhecida.';
};

export const executeTransactionAction = async (
  userId: string,
  meta: ActionMetadata,
): Promise<string> => {
  const type = meta.type === 'income' ? 'income' : 'expense';
  const amount = Number(meta.amount ?? 0);
  if (!(amount > 0)) return 'Valor inválido.';

  const description = (meta.description as string | undefined) ?? '';
  const rawDate = meta.date as string | undefined;
  const date = rawDate ? new Date(rawDate) : new Date();
  const safeDate = Number.isNaN(date.getTime()) ? new Date() : date;

  const categoryName = (meta.category as string | undefined) ?? '';
  const categories = await fetchCategories(userId);
  const matchedCategory = caseInsensitiveFind(categories, categoryName);
  if (!matchedCategory) {
    return `Categoria "${categoryName}" não encontrada. Crie-a primeiro.`;
  }

  const accounts = await fetchAccounts(userId);
  if (accounts.length === 0) {
    return 'Nenhuma conta encontrada. Crie uma conta primeiro.';
  }

  const accountName = (meta.account as string | undefined) ?? '';
  const matchedAccount = accountName
    ? caseInsensitiveFind(accounts, accountName) ?? accounts[0]
    : accounts[0];

  const createdAt = now();
  const payload: Record<string, any> = {
    userId,
    accountId: matchedAccount.id,
    categoryId: matchedCategory.id,
    type,
    amount,
    description,
    date: Timestamp().fromDate(safeDate),
    notes: null,
    linkedTransactionId: null,
    createdAt,
    updatedAt: createdAt,
  };

  await db().collection('transactions').add(payload);
  return `Transação "${description}" de R$ ${amount.toFixed(2)} criada com sucesso!`;
};

// Two-tier account name resolution: exact case-insensitive, then word-set
// match (every query word appears as substring of some account-name word
// or vice-versa). Mirrors the app-side helper in chat_bloc.dart so the AI
// emitting "cartão mila" still resolves to "Cartão Nubank Mila", but
// without silently writing to a wrong account when the name is
// unrecognizable.
const resolveAccount = (
  accounts: AccountDoc[],
  rawQuery: string,
): { match?: AccountDoc; error?: string } => {
  const query = rawQuery.trim().toLowerCase();
  if (!query) {
    return { error: 'Qual conta? Por favor diga o nome da conta.' };
  }
  const exact = accounts.filter((a) => a.name.toLowerCase() === query);
  if (exact.length === 1) return { match: exact[0] };
  const tokens = (s: string) => s.split(/\s+/).filter(Boolean);
  const queryWords = tokens(query);
  const fuzzy = accounts.filter((a) => {
    const accWords = tokens(a.name.toLowerCase());
    if (!queryWords.length || !accWords.length) return false;
    const qInA = queryWords.every((w) => accWords.some((aw) => aw.includes(w)));
    const aInQ = accWords.every((aw) => queryWords.some((w) => w.includes(aw)));
    return qInA || aInQ;
  });
  if (fuzzy.length === 1) return { match: fuzzy[0] };
  if (fuzzy.length === 0) {
    return {
      error:
        `Conta "${rawQuery}" não encontrada. Crie-a primeiro ou use o nome exato.`,
    };
  }
  const names = fuzzy.map((a) => `"${a.name}"`).join(', ');
  return {
    error: `Múltiplas contas correspondem a "${rawQuery}": ${names}. Seja mais específico.`,
  };
};

export const executeTransferAction = async (
  userId: string,
  meta: ActionMetadata,
): Promise<string> => {
  const amount = Number(meta.amount ?? 0);
  if (!(amount > 0)) return 'Valor inválido.';

  const fromName = (meta.from as string | undefined) ?? '';
  const toName = (meta.to as string | undefined) ?? '';
  if (!fromName || !toName) {
    return 'Transferência precisa de conta de origem e destino.';
  }

  const accounts = await fetchAccounts(userId);
  if (accounts.length < 2) {
    return 'Transferência requer ao menos duas contas.';
  }

  const fromR = resolveAccount(accounts, fromName);
  if (fromR.error || !fromR.match) return fromR.error ?? 'Conta de origem não encontrada.';
  const toR = resolveAccount(accounts, toName);
  if (toR.error || !toR.match) return toR.error ?? 'Conta de destino não encontrada.';
  if (fromR.match.id === toR.match.id) {
    return 'Origem e destino devem ser contas diferentes.';
  }

  const description = (meta.description as string | undefined) ?? '';
  const rawDate = meta.date as string | undefined;
  const date = rawDate ? new Date(rawDate) : new Date();
  const safeDate = Number.isNaN(date.getTime()) ? new Date() : date;
  const createdAt = now();
  const dateTs = Timestamp().fromDate(safeDate);

  const expenseRef = await db().collection('transactions').add({
    userId,
    accountId: fromR.match.id,
    categoryId: '',
    type: 'expense',
    amount,
    description,
    date: dateTs,
    notes: null,
    linkedTransactionId: null,
    createdAt,
    updatedAt: createdAt,
  });
  const incomeRef = await db().collection('transactions').add({
    userId,
    accountId: toR.match.id,
    categoryId: '',
    type: 'income',
    amount,
    description,
    date: dateTs,
    notes: null,
    linkedTransactionId: expenseRef.id,
    createdAt,
    updatedAt: createdAt,
  });
  await expenseRef.update({ linkedTransactionId: incomeRef.id });

  return `Transferência de R$ ${amount.toFixed(2)} de "${fromR.match.name}" para "${toR.match.name}" criada com sucesso!`;
};

export const executeAction = async (
  userId: string,
  metadata: ActionMetadata,
): Promise<string> => {
  switch (metadata.actionType) {
  case 'account':
    return executeAccountAction(userId, metadata);
  case 'category':
    return executeCategoryAction(userId, metadata);
  case 'transaction':
    return executeTransactionAction(userId, metadata);
  case 'transfer':
    return executeTransferAction(userId, metadata);
  default:
    return 'Tipo de ação desconhecido.';
  }
};
