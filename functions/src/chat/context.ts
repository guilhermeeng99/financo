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

interface BillContext {
  id: string;
  type: 'payable' | 'receivable';
  description: string;
  amount: number;
  dueDate: Date;
  status: 'pending' | 'paid' | string;
}

interface BudgetContext {
  // Resolved category name — the AI uses *names*, not ids, when referencing
  // budgets, so we resolve here and skip the snapshot id.
  categoryName: string;
  amount: number;
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

const fetchPendingBills = async (userId: string): Promise<BillContext[]> => {
  const snap = await db()
    .collection('transactions')
    .where('userId', '==', userId)
    .where('settlementStatus', '==', 'pending')
    .get();
  return snap.docs.map((d) => {
    const data = d.data();
    const due = data.dueDate ?? data.date;
    const rawType = data.type;
    return {
      id: d.id,
      // Legacy bills stored before BillType existed are payable by default.
      type: rawType === 'income' ? 'receivable' : 'payable',
      description: String(data.description ?? ''),
      amount: Number(data.amount ?? 0),
      // Firestore Timestamp → Date.
      dueDate: due && typeof due.toDate === 'function' ? due.toDate() : new Date(due),
      status: String(data.settlementStatus ?? 'pending'),
    };
  });
};

const startOfToday = (): Date => {
  const now = new Date();
  return new Date(now.getFullYear(), now.getMonth(), now.getDate());
};

const formatDate = (d: Date): string =>
  `${d.getFullYear()}-${String(d.getMonth() + 1).padStart(2, '0')}-${String(d.getDate()).padStart(2, '0')}`;

// Brazilian currency format: thousands grouped with `.`, decimals with `,`.
// `Intl.NumberFormat` produces a non-breaking space between the symbol and
// the number, which renders fine in chat bubbles. The AI mimics the
// formatting of values it sees in the user context, so keep this aligned
// with the in-app `formatCurrency()` helper (BRL, pt_BR).
const formatBrl = (value: number): string =>
  new Intl.NumberFormat('pt-BR', {
    style: 'currency',
    currency: 'BRL',
  }).format(value);

const formatBillLine = (b: BillContext): string => {
  const kind = b.type === 'receivable' ? 'a receber' : 'a pagar';
  return `- id=${b.id} type=${b.type} (${kind}) "${b.description}" ${formatBrl(b.amount)} (vence ${formatDate(b.dueDate)})`;
};

const formatBillsBlock = (bills: BillContext[]): string => {
  if (bills.length === 0) return '';
  const today = startOfToday();
  const overdue = bills.filter((b) => b.dueDate < today);
  const dueToday = bills.filter(
    (b) =>
      b.dueDate.getFullYear() === today.getFullYear() &&
      b.dueDate.getMonth() === today.getMonth() &&
      b.dueDate.getDate() === today.getDate(),
  );
  const sections: string[] = [];
  if (overdue.length > 0) {
    sections.push(`⚠ Contas em atraso (a pagar/receber):\n${overdue.map(formatBillLine).join('\n')}`);
  }
  if (dueToday.length > 0) {
    sections.push(`📌 Vencem hoje:\n${dueToday.map(formatBillLine).join('\n')}`);
  }
  return sections.length > 0 ? `\n\n${sections.join('\n\n')}` : '';
};

const fetchBudgets = async (
  userId: string,
  categories: CategoryContext[],
): Promise<BudgetContext[]> => {
  const snap = await db()
    .collection('budgets')
    .where('userId', '==', userId)
    .get();
  // Build an id→name map locally — the snapshot we already fetched gives us
  // names, but it's keyed by name. The budgets reference categories by id,
  // so we have to re-fetch with ids in this query. Cheaper path: do a second
  // tiny query for the categories we need.
  const categoryIds = snap.docs
    .map((d) => d.data().categoryId as string | undefined)
    .filter((v): v is string => typeof v === 'string' && v.length > 0);
  const idToName = new Map<string, string>();
  if (categoryIds.length > 0) {
    // Firestore `in` queries are capped at 30 ids per query; chunk if needed.
    const chunks: string[][] = [];
    for (let i = 0; i < categoryIds.length; i += 30) {
      chunks.push(categoryIds.slice(i, i + 30));
    }
    for (const chunk of chunks) {
      const catSnap = await db()
        .collection('categories')
        .where(admin.firestore.FieldPath.documentId(), 'in', chunk)
        .get();
      catSnap.docs.forEach((d) => {
        idToName.set(d.id, String(d.data().name ?? ''));
      });
    }
  }
  // Categories param kept in the signature so future changes can pivot to
  // a name-keyed map without touching the call-site — for now we only need
  // it to assert relevance and avoid emitting orphan budgets to the model.
  void categories;
  return snap.docs
    .map((d) => {
      const data = d.data();
      const categoryId = data.categoryId as string | undefined;
      if (!categoryId) return null;
      const name = idToName.get(categoryId);
      if (!name) return null; // orphan — category was deleted
      return {
        categoryName: name,
        amount: Number(data.amount ?? 0),
      } as BudgetContext;
    })
    .filter((b): b is BudgetContext => b !== null);
};

const formatBudgetLine = (b: BudgetContext): string =>
  `- "${b.categoryName}" → ${formatBrl(b.amount)}/mês`;

const formatBudgetsBlock = (budgets: BudgetContext[]): string => {
  if (budgets.length === 0) return '';
  return `\n\nOrçamentos mensais ativos:\n${budgets.map(formatBudgetLine).join('\n')}`;
};

export const buildUserContext = async (userId: string): Promise<string> => {
  const [accounts, categories, bills] = await Promise.all([
    fetchAccounts(userId),
    fetchCategories(userId),
    fetchPendingBills(userId),
  ]);
  // Budgets reference categories by id, so we need the resolved category list
  // before we can format them.
  const budgets = await fetchBudgets(userId, categories);

  const accountsBlock = accounts.length > 0
    ? accounts.map(formatAccountLine).join('\n')
    : '(nenhuma conta cadastrada)';

  const categoriesBlock = categories.length > 0
    ? categories.map(formatCategoryLine).join('\n')
    : '(nenhuma categoria cadastrada)';

  const billsBlock = formatBillsBlock(bills);
  const budgetsBlock = formatBudgetsBlock(budgets);

  return `=== USER CONTEXT (snapshot no início deste turno) ===
Contas do usuário:
${accountsBlock}

Categorias do usuário:
${categoriesBlock}${billsBlock}${budgetsBlock}
=== END USER CONTEXT ===`;
};
