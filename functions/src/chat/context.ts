import * as admin from 'firebase-admin';

interface AccountContext {
  name: string;
  type: 'checking' | 'creditCard';
  bank: string;
}

interface CategoryContext {
  id: string;
  name: string;
  type: 'expense' | 'income';
}

interface BudgetContext {
  categoryName: string;
  amount: number;
}

const db = (): admin.firestore.Firestore => admin.firestore();

const fetchAccounts = async (userId: string): Promise<AccountContext[]> => {
  const snap = await db()
    .collection('accounts')
    .where('userId', '==', userId)
    .get();
  return snap.docs.map((doc) => {
    const data = doc.data();
    return {
      name: String(data.name ?? ''),
      type: (data.type as AccountContext['type']) ?? 'checking',
      bank: String(data.bank ?? 'others'),
    };
  });
};

const fetchCategories = async (userId: string): Promise<CategoryContext[]> => {
  const snap = await db()
    .collection('categories')
    .where('userId', '==', userId)
    .get();
  return snap.docs.map((doc) => {
    const data = doc.data();
    return {
      id: doc.id,
      name: String(data.name ?? ''),
      type: (data.type as CategoryContext['type']) ?? 'expense',
    };
  });
};

const formatAccountLine = (account: AccountContext): string => {
  const typeLabel = account.type === 'creditCard'
    ? 'cartao de credito'
    : 'conta corrente';
  return `- "${account.name}" (${typeLabel}, banco: ${account.bank})`;
};

const formatCategoryLine = (category: CategoryContext): string =>
  `- "${category.name}" (${category.type === 'income' ? 'receita' : 'despesa'})`;

const formatBrl = (value: number): string =>
  new Intl.NumberFormat('pt-BR', {
    style: 'currency',
    currency: 'BRL',
  }).format(value);

const fetchBudgets = async (
  userId: string,
  categories: CategoryContext[],
): Promise<BudgetContext[]> => {
  const snap = await db()
    .collection('budgets')
    .where('userId', '==', userId)
    .get();
  const idToName = new Map(categories.map((c) => [c.id, c.name]));

  return snap.docs
    .map((doc) => {
      const data = doc.data();
      const categoryId = data.categoryId as string | undefined;
      if (!categoryId) return null;
      const name = idToName.get(categoryId);
      if (!name) return null;
      return {
        categoryName: name,
        amount: Number(data.amount ?? 0),
      } as BudgetContext;
    })
    .filter((budget): budget is BudgetContext => budget !== null);
};

const formatBudgetLine = (budget: BudgetContext): string =>
  `- "${budget.categoryName}" -> ${formatBrl(budget.amount)}/mes`;

const formatBudgetsBlock = (budgets: BudgetContext[]): string => {
  if (budgets.length === 0) return '';
  return `\n\nOrcamentos mensais ativos:\n${budgets
    .map(formatBudgetLine)
    .join('\n')}`;
};

export const buildUserContext = async (userId: string): Promise<string> => {
  const [accounts, categories] = await Promise.all([
    fetchAccounts(userId),
    fetchCategories(userId),
  ]);
  const budgets = await fetchBudgets(userId, categories);

  const accountsBlock = accounts.length > 0
    ? accounts.map(formatAccountLine).join('\n')
    : '(nenhuma conta cadastrada)';

  const categoriesBlock = categories.length > 0
    ? categories.map(formatCategoryLine).join('\n')
    : '(nenhuma categoria cadastrada)';

  const budgetsBlock = formatBudgetsBlock(budgets);

  return `=== USER CONTEXT (snapshot no inicio deste turno) ===
Contas do usuario:
${accountsBlock}

Categorias do usuario:
${categoriesBlock}${budgetsBlock}
=== END USER CONTEXT ===`;
};
