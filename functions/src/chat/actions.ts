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
  default:
    return 'Tipo de ação desconhecido.';
  }
};
