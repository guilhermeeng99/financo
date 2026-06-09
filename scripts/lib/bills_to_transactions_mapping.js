'use strict';

function transactionIdForBill(billId) {
  if (!billId || typeof billId !== 'string') {
    throw new Error('billId is required');
  }
  return `legacy_bill_${billId}`;
}

function billTypeToTransactionType(type) {
  if (type === 'payable' || type == null) return 'expense';
  if (type === 'receivable') return 'income';
  throw new Error(`Unsupported bill type: ${type}`);
}

function billRecurrenceToTransactionRecurrence(recurrence) {
  if (recurrence === 'monthly') return 'monthly';
  return 'oneShot';
}

function normalizeTimestamp(value, fallback) {
  if (value == null) {
    if (fallback == null) throw new Error('timestamp is required');
    return normalizeTimestamp(fallback);
  }
  const date = value instanceof Date ? value : new Date(value);
  if (Number.isNaN(date.getTime())) {
    throw new Error(`Invalid timestamp: ${value}`);
  }
  return date.toISOString();
}

function resolveAccountId({ bill, accountMap = {}, defaultAccountId }) {
  if (!bill) throw new Error('bill is required');
  const billMap = accountMap.bills ?? {};
  const userMap = accountMap.users ?? {};
  return (
    billMap[bill.id] ??
    userMap[bill.userId] ??
    defaultAccountId ??
    accountMap.defaultAccountId ??
    null
  );
}

function buildTransactionFromBill({
  bill,
  accountId,
  nowIso,
  parentTransactionId,
}) {
  if (!bill) throw new Error('bill is required');
  if (!accountId) throw new Error(`Missing accountId for bill ${bill.id}`);

  const status = bill.status === 'paid' ? 'paid' : 'pending';
  const dueDate = normalizeTimestamp(bill.dueDate);
  const settledAt = status === 'paid'
    ? normalizeTimestamp(bill.paidAt, bill.dueDate)
    : null;
  const date = status === 'paid' ? settledAt : dueDate;
  const updatedAt = nowIso ?? new Date().toISOString();

  return {
    id: transactionIdForBill(bill.id),
    data: {
      userId: bill.userId,
      accountId,
      categoryId: bill.categoryId ?? '',
      type: billTypeToTransactionType(bill.type),
      amount: Number(bill.amount),
      description: bill.description ?? '',
      date,
      settlementStatus: status,
      dueDate,
      settledAt,
      recurrence: billRecurrenceToTransactionRecurrence(bill.recurrence),
      notes: bill.notes ?? null,
      linkedTransactionId: null,
      sourceBillId: bill.id,
      parentTransactionId: parentTransactionId ?? null,
      createdAt: normalizeTimestamp(bill.createdAt, updatedAt),
      updatedAt,
    },
  };
}

function buildLinkedPaidTransactionPatch({ bill, nowIso }) {
  if (!bill) throw new Error('bill is required');
  if (!bill.paidTransactionId) {
    throw new Error(`Bill ${bill.id} has no paidTransactionId`);
  }
  return {
    id: bill.paidTransactionId,
    data: {
      settlementStatus: 'paid',
      dueDate: normalizeTimestamp(bill.dueDate),
      settledAt: normalizeTimestamp(bill.paidAt, bill.dueDate),
      recurrence: billRecurrenceToTransactionRecurrence(bill.recurrence),
      sourceBillId: bill.id,
      updatedAt: nowIso ?? new Date().toISOString(),
    },
  };
}

module.exports = {
  billRecurrenceToTransactionRecurrence,
  billTypeToTransactionType,
  buildLinkedPaidTransactionPatch,
  buildTransactionFromBill,
  normalizeTimestamp,
  resolveAccountId,
  transactionIdForBill,
};
