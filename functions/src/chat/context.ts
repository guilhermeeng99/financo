import * as admin from 'firebase-admin';

interface AccountContext {
  name: string;
  type: 'checking' | 'creditCard';
  bank: string;
}

interface CategoryContext {
  name: string;
  type: 'expense' | 'income';
}

const db = (): admin.firestore.Firestore => admin.firestore();

const fetchAccounts = async (userId: string): Promise<AccountContext[]> => {
  const snap = await db().collection('accounts').where('userId', '==', userId).get();
  return snap.docs.map((d) => {
    const data = d.data();
    return {
      name: String(data.name ?? ''),
      type: (data.type as AccountContext['type']) ?? 'checking',
      bank: String(data.bank ?? 'others'),
    };
  });
};

const fetchCategories = async (userId: string): Promise<CategoryContext[]> => {
  const snap = await db().collection('categories').where('userId', '==', userId).get();
  return snap.docs.map((d) => {
    const data = d.data();
    return {
      name: String(data.name ?? ''),
      type: (data.type as CategoryContext['type']) ?? 'expense',
    };
  });
};

const formatAccountLine = (a: AccountContext): string => {
  const typeLabel = a.type === 'creditCard' ? 'cartão de crédito' : 'conta corrente';
  return `- "${a.name}" (${typeLabel}, banco: ${a.bank})`;
};

const formatCategoryLine = (c: CategoryContext): string =>
  `- "${c.name}" (${c.type === 'income' ? 'receita' : 'despesa'})`;

export const buildUserContext = async (userId: string): Promise<string> => {
  const [accounts, categories] = await Promise.all([
    fetchAccounts(userId),
    fetchCategories(userId),
  ]);

  const accountsBlock = accounts.length > 0
    ? accounts.map(formatAccountLine).join('\n')
    : '(nenhuma conta cadastrada)';

  const categoriesBlock = categories.length > 0
    ? categories.map(formatCategoryLine).join('\n')
    : '(nenhuma categoria cadastrada)';

  return `=== USER CONTEXT (snapshot no início deste turno) ===
Contas do usuário:
${accountsBlock}

Categorias do usuário:
${categoriesBlock}
=== END USER CONTEXT ===`;
};
