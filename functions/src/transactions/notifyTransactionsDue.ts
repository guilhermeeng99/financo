import * as admin from 'firebase-admin';
import { logger } from 'firebase-functions/v2';
import { onSchedule } from 'firebase-functions/v2/scheduler';

export interface PendingTransaction {
  id: string;
  userId: string;
  type: 'income' | 'expense' | string;
  description: string;
  amount: number;
  dueDate: Date;
}

const db = (): admin.firestore.Firestore => admin.firestore();

const startOfToday = (): Date => {
  const now = new Date();
  return new Date(now.getFullYear(), now.getMonth(), now.getDate());
};

const endOfToday = (): Date => {
  const now = new Date();
  return new Date(
    now.getFullYear(),
    now.getMonth(),
    now.getDate(),
    23,
    59,
    59,
    999,
  );
};

const toDate = (value: unknown): Date => {
  if (value && typeof (value as { toDate?: unknown }).toDate === 'function') {
    return (value as admin.firestore.Timestamp).toDate();
  }
  return new Date(value as string | number | Date);
};

const fetchDueTransactions = async (): Promise<PendingTransaction[]> => {
  const snap = await db()
    .collection('transactions')
    .where('settlementStatus', '==', 'pending')
    .where('dueDate', '<=', admin.firestore.Timestamp.fromDate(endOfToday()))
    .get();

  return snap.docs.map((d) => {
    const data = d.data();
    return {
      id: d.id,
      userId: String(data.userId ?? ''),
      type: String(data.type ?? 'expense'),
      description: String(data.description ?? ''),
      amount: Number(data.amount ?? 0),
      dueDate: toDate(data.dueDate ?? data.date),
    };
  });
};

const fetchUserTokens = async (userId: string): Promise<string[]> => {
  const snap = await db()
    .collection('users')
    .doc(userId)
    .collection('fcmTokens')
    .get();
  return snap.docs.map((d) => String(d.data().token ?? d.id)).filter(Boolean);
};

const brCurrency = new Intl.NumberFormat('pt-BR', {
  style: 'currency',
  currency: 'BRL',
});

// Notification copy is hardcoded pt-BR because push payloads are built
// server-side, where the app's slang i18n is unavailable.
const singleTransactionTitle = (
  isOverdue: boolean,
  isReceivable: boolean,
): string => {
  if (isOverdue && isReceivable) return 'Recebimento atrasado';
  if (isOverdue) return 'Conta atrasada';
  if (isReceivable) return 'Recebimento vence hoje';
  return 'Conta vence hoje';
};

// Plural noun for the "N <x> vencem hoje" summary: the specific word only
// when the batch is homogeneous, the neutral 'itens' for mixed batches.
const dueTodaySummaryLabel = (
  payableCount: number,
  receivableCount: number,
  total: number,
): string => {
  if (payableCount === total) return 'contas';
  if (receivableCount === total) return 'recebimentos';
  return 'itens';
};

export const buildMessage = (
  transactions: PendingTransaction[],
): { title: string; body: string } => {
  const today = startOfToday();
  const overdue = transactions.filter((t) => t.dueDate < today);
  const payableCount = transactions.filter((t) => t.type !== 'income').length;
  const receivableCount = transactions.length - payableCount;

  if (transactions.length === 1) {
    const transaction = transactions[0];
    const isOverdue = transaction.dueDate < today;
    const isReceivable = transaction.type === 'income';
    const amount = brCurrency.format(transaction.amount);
    const desc = transaction.description.trim() || 'Sua conta';
    return {
      title: singleTransactionTitle(isOverdue, isReceivable),
      body: isOverdue
        ? `${desc} (${amount}) está atrasada.`
        : `${desc} (${amount}) vence hoje.`,
    };
  }

  const payableLabel = payableCount === 1 ? 'conta' : 'contas';
  const receivableLabel = receivableCount === 1
    ? 'recebimento'
    : 'recebimentos';
  const titleParts = [
    payableCount > 0 ? `${payableCount} ${payableLabel} a pagar` : '',
    receivableCount > 0
      ? `${receivableCount} ${receivableLabel} a receber`
      : '',
  ].filter(Boolean);
  const dueTodayCount = transactions.length - overdue.length;
  const dueTodayLabel = dueTodaySummaryLabel(
    payableCount,
    receivableCount,
    transactions.length,
  );

  return {
    title: `Você tem ${titleParts.join(' e ')}`,
    body:
      overdue.length > 0
        ? `${overdue.length} atrasada(s) e ${dueTodayCount} vencendo hoje.`
        : `${transactions.length} ${dueTodayLabel} vencem hoje.`,
  };
};

const cleanupInvalidTokens = async (
  userId: string,
  tokens: string[],
  responses: admin.messaging.SendResponse[],
): Promise<void> => {
  const toDelete: Promise<unknown>[] = [];
  responses.forEach((resp, idx) => {
    if (resp.success) return;
    const code = resp.error?.code;
    if (
      code === 'messaging/registration-token-not-registered' ||
      code === 'messaging/invalid-registration-token'
    ) {
      const token = tokens[idx];
      toDelete.push(
        db()
          .collection('users')
          .doc(userId)
          .collection('fcmTokens')
          .doc(token)
          .delete()
          .catch(() => undefined),
      );
    }
  });
  await Promise.all(toDelete);
};

export const notifyTransactionsDue = onSchedule(
  {
    schedule: 'every day 09:00',
    timeZone: 'America/Sao_Paulo',
    region: 'us-central1',
    memory: '256MiB',
    timeoutSeconds: 120,
  },
  async () => {
    const allTransactions = await fetchDueTransactions();
    if (allTransactions.length === 0) {
      logger.info('notifyTransactionsDue: no due/overdue transactions');
      return;
    }

    const byUser = new Map<string, PendingTransaction[]>();
    for (const transaction of allTransactions) {
      if (!transaction.userId) continue;
      const list = byUser.get(transaction.userId) ?? [];
      list.push(transaction);
      byUser.set(transaction.userId, list);
    }

    const messaging = admin.messaging();
    let totalSent = 0;
    let totalFailed = 0;

    await Promise.all(
      Array.from(byUser.entries()).map(async ([userId, transactions]) => {
        const tokens = await fetchUserTokens(userId);
        if (tokens.length === 0) return;

        const { title, body } = buildMessage(transactions);
        // Data-only message: clients render the notification themselves
        // from `data`. Only Android and web are targets, so there is no
        // apns config.
        const response = await messaging.sendEachForMulticast({
          tokens,
          data: {
            route: '/payables-receivables',
            count: String(transactions.length),
            type: 'transactions_due',
            userId,
            title,
            body,
          },
          android: {
            priority: 'high',
          },
        });

        totalSent += response.successCount;
        totalFailed += response.failureCount;
        if (response.failureCount > 0) {
          await cleanupInvalidTokens(userId, tokens, response.responses);
        }
      }),
    );

    logger.info('notifyTransactionsDue completed', {
      users: byUser.size,
      transactions: allTransactions.length,
      sent: totalSent,
      failed: totalFailed,
    });
  },
);
