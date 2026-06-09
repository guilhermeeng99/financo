'use strict';

const assert = require('assert/strict');
const {
  buildLinkedPaidTransactionPatch,
  buildTransactionFromBill,
  resolveAccountId,
  transactionIdForBill,
} = require('./lib/bills_to_transactions_mapping');

const baseBill = {
  id: 'bill-1',
  userId: 'user-1',
  type: 'payable',
  description: 'Internet',
  amount: 109.9,
  dueDate: '2026-06-10T00:00:00.000Z',
  status: 'pending',
  recurrence: 'monthly',
  categoryId: 'cat-internet',
  notes: 'Legacy note',
  createdAt: '2026-05-01T12:00:00.000Z',
  updatedAt: '2026-05-02T12:00:00.000Z',
};

function testPendingBillMapping() {
  const mapped = buildTransactionFromBill({
    bill: baseBill,
    accountId: 'acc-1',
    nowIso: '2026-06-09T12:00:00.000Z',
    parentTransactionId: 'tx-parent',
  });

  assert.equal(mapped.id, transactionIdForBill('bill-1'));
  assert.equal(mapped.data.userId, 'user-1');
  assert.equal(mapped.data.accountId, 'acc-1');
  assert.equal(mapped.data.type, 'expense');
  assert.equal(mapped.data.settlementStatus, 'pending');
  assert.equal(mapped.data.date, baseBill.dueDate);
  assert.equal(mapped.data.dueDate, baseBill.dueDate);
  assert.equal(mapped.data.settledAt, null);
  assert.equal(mapped.data.recurrence, 'monthly');
  assert.equal(mapped.data.sourceBillId, 'bill-1');
  assert.equal(mapped.data.parentTransactionId, 'tx-parent');
}

function testLinkedPaidPatch() {
  const mapped = buildLinkedPaidTransactionPatch({
    bill: {
      ...baseBill,
      status: 'paid',
      paidAt: '2026-06-12T00:00:00.000Z',
      paidTransactionId: 'tx-paid',
    },
    nowIso: '2026-06-13T12:00:00.000Z',
  });

  assert.equal(mapped.id, 'tx-paid');
  assert.deepEqual(mapped.data, {
    settlementStatus: 'paid',
    dueDate: '2026-06-10T00:00:00.000Z',
    settledAt: '2026-06-12T00:00:00.000Z',
    recurrence: 'monthly',
    sourceBillId: 'bill-1',
    updatedAt: '2026-06-13T12:00:00.000Z',
  });
}

function testAccountResolutionPriority() {
  const accountMap = {
    defaultAccountId: 'acc-default-file',
    users: {'user-1': 'acc-user'},
    bills: {'bill-1': 'acc-bill'},
  };

  assert.equal(
    resolveAccountId({
      bill: baseBill,
      accountMap,
      defaultAccountId: 'acc-default-cli',
    }),
    'acc-bill',
  );
  assert.equal(
    resolveAccountId({
      bill: {...baseBill, id: 'bill-2'},
      accountMap,
      defaultAccountId: 'acc-default-cli',
    }),
    'acc-user',
  );
  assert.equal(
    resolveAccountId({
      bill: {...baseBill, id: 'bill-2', userId: 'user-2'},
      accountMap,
      defaultAccountId: 'acc-default-cli',
    }),
    'acc-default-cli',
  );
}

testPendingBillMapping();
testLinkedPaidPatch();
testAccountResolutionPriority();

console.log('bills_to_transactions_mapping tests passed');
