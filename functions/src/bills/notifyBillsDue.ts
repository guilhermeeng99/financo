import * as admin from 'firebase-admin';
import { logger } from 'firebase-functions/v2';
import { onSchedule } from 'firebase-functions/v2/scheduler';

interface PendingBill {
  id: string;
  userId: string;
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
  return new Date(now.getFullYear(), now.getMonth(), now.getDate(), 23, 59, 59, 999);
};

const fetchDueBills = async (): Promise<PendingBill[]> => {
  // Pending bills with dueDate <= end of today (overdue + due today).
  const snap = await db()
    .collection('bills')
    .where('status', '==', 'pending')
    .where('dueDate', '<=', admin.firestore.Timestamp.fromDate(endOfToday()))
    .get();

  return snap.docs.map((d) => {
    const data = d.data();
    const due = data.dueDate;
    return {
      id: d.id,
      userId: String(data.userId ?? ''),
      description: String(data.description ?? ''),
      amount: Number(data.amount ?? 0),
      dueDate:
        due && typeof due.toDate === 'function' ? due.toDate() : new Date(due),
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

const buildMessage = (
  bills: PendingBill[],
): { title: string; body: string } => {
  const today = startOfToday();
  const overdue = bills.filter((b) => b.dueDate < today);

  if (bills.length === 1) {
    const bill = bills[0];
    const isOverdue = bill.dueDate < today;
    const amount = `R$ ${bill.amount.toFixed(2)}`;
    return {
      title: isOverdue ? 'Conta atrasada' : 'Conta vence hoje',
      body: isOverdue
        ? `${bill.description} (${amount}) está atrasada.`
        : `${bill.description} (${amount}) vence hoje.`,
    };
  }

  return {
    title: `Você tem ${bills.length} contas a pagar`,
    body:
      overdue.length > 0
        ? `${overdue.length} atrasada(s) e ${bills.length - overdue.length} vencendo hoje.`
        : `${bills.length} contas vencem hoje.`,
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

export const notifyBillsDue = onSchedule(
  {
    schedule: 'every day 09:00',
    timeZone: 'America/Sao_Paulo',
    region: 'us-central1',
    memory: '256MiB',
    timeoutSeconds: 120,
  },
  async () => {
    const allBills = await fetchDueBills();
    if (allBills.length === 0) {
      logger.info('notifyBillsDue: no due/overdue bills');
      return;
    }

    // Group by user.
    const byUser = new Map<string, PendingBill[]>();
    for (const bill of allBills) {
      if (!bill.userId) continue;
      const list = byUser.get(bill.userId) ?? [];
      list.push(bill);
      byUser.set(bill.userId, list);
    }

    const messaging = admin.messaging();
    let totalSent = 0;
    let totalFailed = 0;

    await Promise.all(
      Array.from(byUser.entries()).map(async ([userId, bills]) => {
        const tokens = await fetchUserTokens(userId);
        if (tokens.length === 0) return;

        const { title, body } = buildMessage(bills);
        const response = await messaging.sendEachForMulticast({
          tokens,
          notification: { title, body },
          data: {
            route: '/bills',
            count: String(bills.length),
            type: 'bills_due',
          },
          android: {
            notification: { channelId: 'bills_due', priority: 'high' },
          },
          apns: {
            payload: {
              aps: { sound: 'default', badge: bills.length },
            },
          },
        });

        totalSent += response.successCount;
        totalFailed += response.failureCount;
        if (response.failureCount > 0) {
          await cleanupInvalidTokens(userId, tokens, response.responses);
        }
      }),
    );

    logger.info('notifyBillsDue completed', {
      users: byUser.size,
      bills: allBills.length,
      sent: totalSent,
      failed: totalFailed,
    });
  },
);
