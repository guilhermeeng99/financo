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
  description: string;
  amount: number;
  dueDate: Date;
  status: 'pending' | 'paid' | string;
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
    .collection('bills')
    .where('userId', '==', userId)
    .where('status', '==', 'pending')
    .get();
  return snap.docs.map((d) => {
    const data = d.data();
    const due = data.dueDate;
    return {
      id: d.id,
      description: String(data.description ?? ''),
      amount: Number(data.amount ?? 0),
      // Firestore Timestamp → Date.
      dueDate: due && typeof due.toDate === 'function' ? due.toDate() : new Date(due),
      status: String(data.status ?? 'pending'),
    };
  });
};

const startOfToday = (): Date => {
  const now = new Date();
  return new Date(now.getFullYear(), now.getMonth(), now.getDate());
};

const formatDate = (d: Date): string =>
  `${d.getFullYear()}-${String(d.getMonth() + 1).padStart(2, '0')}-${String(d.getDate()).padStart(2, '0')}`;

const formatBillLine = (b: BillContext): string =>
  `- id=${b.id} "${b.description}" R$${b.amount.toFixed(2)} (vence ${formatDate(b.dueDate)})`;

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
    sections.push(`⚠ Contas em atraso:\n${overdue.map(formatBillLine).join('\n')}`);
  }
  if (dueToday.length > 0) {
    sections.push(`📌 Vencem hoje:\n${dueToday.map(formatBillLine).join('\n')}`);
  }
  return sections.length > 0 ? `\n\n${sections.join('\n\n')}` : '';
};

export const buildUserContext = async (userId: string): Promise<string> => {
  const [accounts, categories, bills] = await Promise.all([
    fetchAccounts(userId),
    fetchCategories(userId),
    fetchPendingBills(userId),
  ]);

  const accountsBlock = accounts.length > 0
    ? accounts.map(formatAccountLine).join('\n')
    : '(nenhuma conta cadastrada)';

  const categoriesBlock = categories.length > 0
    ? categories.map(formatCategoryLine).join('\n')
    : '(nenhuma categoria cadastrada)';

  const billsBlock = formatBillsBlock(bills);

  return `=== USER CONTEXT (snapshot no início deste turno) ===
Contas do usuário:
${accountsBlock}

Categorias do usuário:
${categoriesBlock}${billsBlock}
=== END USER CONTEXT ===`;
};
