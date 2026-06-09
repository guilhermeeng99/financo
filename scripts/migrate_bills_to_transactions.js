'use strict';

// One-time migration from legacy bills/{id} documents to transaction-backed
// payables/receivables. Dry-run by default.
//
// Run from repo root:
//   node scripts/migrate_bills_to_transactions.js
//   node scripts/migrate_bills_to_transactions.js --apply --account-map account-map.json
//
// Auth reuses the Firebase CLI refresh token. No service account key is needed.

const fs = require('fs');
const https = require('https');
const os = require('os');
const path = require('path');

const {
  billRecurrenceToTransactionRecurrence,
  buildLinkedPaidTransactionPatch,
  buildTransactionFromBill,
  normalizeTimestamp,
  transactionIdForBill,
} = require('./lib/bills_to_transactions_mapping');

const DEFAULT_PROJECT_ID = 'financo-app-2026';
const DEFAULT_DATABASE = '(default)';
const CLIENT_ID =
  '563584335869-fgrhgmd47bqnekij5i8b5pr03ho849e6.apps.googleusercontent.com';
const CLIENT_SECRET = 'j9iVZfS8kkCEFUPaAeJV0sAi';

function parseArgs(argv) {
  const options = {
    apply: false,
    createPaidUnlinked: false,
    projectId: DEFAULT_PROJECT_ID,
    database: DEFAULT_DATABASE,
    userId: null,
    defaultAccountId: null,
    accountMapPath: null,
    billAccountEntries: [],
    limit: null,
    showMissingAccounts: false,
    userAccountEntries: [],
  };

  for (let i = 2; i < argv.length; i += 1) {
    const arg = argv[i];
    if (arg === '--apply') {
      options.apply = true;
    } else if (arg === '--create-paid-unlinked') {
      options.createPaidUnlinked = true;
    } else if (arg === '--project') {
      options.projectId = requireValue(argv, ++i, arg);
    } else if (arg === '--database') {
      options.database = requireValue(argv, ++i, arg);
    } else if (arg === '--user-id') {
      options.userId = requireValue(argv, ++i, arg);
    } else if (arg === '--default-account-id') {
      options.defaultAccountId = requireValue(argv, ++i, arg);
    } else if (arg === '--account-map') {
      options.accountMapPath = requireValue(argv, ++i, arg);
    } else if (arg === '--bill-account') {
      options.billAccountEntries.push(parseAssignment(requireValue(argv, ++i, arg)));
    } else if (arg === '--user-account') {
      options.userAccountEntries.push(parseAssignment(requireValue(argv, ++i, arg)));
    } else if (arg === '--limit') {
      options.limit = Number(requireValue(argv, ++i, arg));
      if (!Number.isInteger(options.limit) || options.limit <= 0) {
        throw new Error('--limit must be a positive integer');
      }
    } else if (arg === '--show-missing-accounts') {
      options.showMissingAccounts = true;
    } else if (arg === '--help' || arg === '-h') {
      printUsage();
      process.exit(0);
    } else {
      throw new Error(`Unknown argument: ${arg}`);
    }
  }
  return options;
}

function parseAssignment(value) {
  const separator = value.indexOf('=');
  if (separator <= 0 || separator === value.length - 1) {
    throw new Error(`Expected id=value, received: ${value}`);
  }
  return [value.slice(0, separator), value.slice(separator + 1)];
}

function requireValue(argv, index, flag) {
  const value = argv[index];
  if (!value || value.startsWith('--')) {
    throw new Error(`${flag} requires a value`);
  }
  return value;
}

function printUsage() {
  console.log(`Usage:
  node scripts/migrate_bills_to_transactions.js [options]

Options:
  --apply                         Write changes. Omit for dry-run.
  --user-id <uid>                 Migrate one user only.
  --account-map <file.json>       Account mapping file.
  --bill-account <bill=account>   Account for one bill. Repeatable.
  --default-account-id <id>       Fallback account for unmapped bills.
  --user-account <user=account>   Account for one user. Repeatable.
  --create-paid-unlinked          Create paid transactions for paid bills
                                  without paidTransactionId.
  --limit <n>                     Process at most n bills.
  --show-missing-accounts         Print account choices for skipped bills.
  --project <projectId>           Default: ${DEFAULT_PROJECT_ID}
  --database <database>           Default: ${DEFAULT_DATABASE}
`);
}

function readAccountMap(filePath) {
  if (!filePath) return {};
  const absolute = path.resolve(filePath);
  return JSON.parse(fs.readFileSync(absolute, 'utf8'));
}

function mergeAccountMap(baseMap, options) {
  const accountMap = {
    ...baseMap,
    bills: {...(baseMap.bills ?? {})},
    users: {...(baseMap.users ?? {})},
  };
  for (const [billId, accountId] of options.billAccountEntries) {
    accountMap.bills[billId] = accountId;
  }
  for (const [userId, accountId] of options.userAccountEntries) {
    accountMap.users[userId] = accountId;
  }
  return accountMap;
}

function readRefreshToken() {
  const candidates = [
    path.join(os.homedir(), '.config', 'configstore', 'firebase-tools.json'),
    process.env.APPDATA
      ? path.join(process.env.APPDATA, 'configstore', 'firebase-tools.json')
      : null,
  ].filter(Boolean);

  for (const candidate of candidates) {
    if (!fs.existsSync(candidate)) continue;
    const parsed = JSON.parse(fs.readFileSync(candidate, 'utf8'));
    const token = parsed.tokens?.refresh_token;
    if (token) return token;
  }
  throw new Error('No Firebase CLI refresh token found. Run `firebase login`.');
}

function postForm(host, requestPath, body) {
  return request(
    {
      host,
      path: requestPath,
      method: 'POST',
      headers: {'Content-Type': 'application/x-www-form-urlencoded'},
    },
    new URLSearchParams(body).toString(),
  );
}

function postJson(host, requestPath, body, accessToken) {
  return request(
    {
      host,
      path: requestPath,
      method: 'POST',
      headers: {
        'Content-Type': 'application/json',
        Authorization: `Bearer ${accessToken}`,
      },
    },
    JSON.stringify(body),
  );
}

function patchJson(host, requestPath, body, accessToken) {
  return request(
    {
      host,
      path: requestPath,
      method: 'PATCH',
      headers: {
        'Content-Type': 'application/json',
        Authorization: `Bearer ${accessToken}`,
      },
    },
    JSON.stringify(body),
  );
}

function getJson(host, requestPath, accessToken) {
  return request(
    {
      host,
      path: requestPath,
      method: 'GET',
      headers: {Authorization: `Bearer ${accessToken}`},
    },
    null,
    {allow404: true},
  );
}

function request(options, body, config = {}) {
  return new Promise((resolve, reject) => {
    const headers = {...options.headers};
    if (body != null) headers['Content-Length'] = Buffer.byteLength(body);
    const req = https.request({...options, headers}, (res) => {
      let buffer = '';
      res.on('data', (chunk) => (buffer += chunk));
      res.on('end', () => {
        if (res.statusCode === 404 && config.allow404) return resolve(null);
        if (res.statusCode >= 400) {
          return reject(new Error(`${res.statusCode}: ${buffer}`));
        }
        if (!buffer) return resolve(null);
        try {
          resolve(JSON.parse(buffer));
        } catch (e) {
          reject(e);
        }
      });
    });
    req.on('error', reject);
    if (body != null) req.write(body);
    req.end();
  });
}

async function mintAccessToken(refreshToken) {
  const response = await postForm('oauth2.googleapis.com', '/token', {
    client_id: CLIENT_ID,
    client_secret: CLIENT_SECRET,
    refresh_token: refreshToken,
    grant_type: 'refresh_token',
  });
  return response.access_token;
}

function documentBasePath(options) {
  return `/v1/projects/${options.projectId}/databases/${encodeURIComponent(
    options.database,
  )}/documents`;
}

async function fetchBills(accessToken, options) {
  const filters = [];
  if (options.userId) {
    filters.push({
      fieldFilter: {
        field: {fieldPath: 'userId'},
        op: 'EQUAL',
        value: {stringValue: options.userId},
      },
    });
  }

  const structuredQuery = {
    from: [{collectionId: 'bills'}],
    orderBy: [{field: {fieldPath: 'dueDate'}, direction: 'ASCENDING'}],
  };
  if (filters.length === 1) structuredQuery.where = filters[0];
  if (filters.length > 1) {
    structuredQuery.where = {
      compositeFilter: {op: 'AND', filters},
    };
  }
  if (options.limit) structuredQuery.limit = options.limit;

  const response = await postJson(
    'firestore.googleapis.com',
    `${documentBasePath(options)}:runQuery`,
    {structuredQuery},
    accessToken,
  );
  return response
    .filter((entry) => entry.document)
    .map((entry) => decodeDocument(entry.document));
}

async function fetchAccountsByUserId(accessToken, options, userId) {
  const response = await postJson(
    'firestore.googleapis.com',
    `${documentBasePath(options)}:runQuery`,
    {
      structuredQuery: {
        from: [{collectionId: 'accounts'}],
        where: {
          fieldFilter: {
            field: {fieldPath: 'userId'},
            op: 'EQUAL',
            value: {stringValue: userId},
          },
        },
      },
    },
    accessToken,
  );
  return response
    .filter((entry) => entry.document)
    .map((entry) => decodeDocument(entry.document))
    .sort((a, b) => String(a.name ?? '').localeCompare(String(b.name ?? '')));
}

async function findTransactionBySourceBillId(accessToken, options, billId) {
  const response = await postJson(
    'firestore.googleapis.com',
    `${documentBasePath(options)}:runQuery`,
    {
      structuredQuery: {
        from: [{collectionId: 'transactions'}],
        where: {
          fieldFilter: {
            field: {fieldPath: 'sourceBillId'},
            op: 'EQUAL',
            value: {stringValue: billId},
          },
        },
        limit: 1,
      },
    },
    accessToken,
  );
  const hit = response.find((entry) => entry.document);
  return hit ? decodeDocument(hit.document) : null;
}

async function getTransaction(accessToken, options, id) {
  const doc = await getJson(
    'firestore.googleapis.com',
    `${documentBasePath(options)}/transactions/${encodeURIComponent(id)}`,
    accessToken,
  );
  return doc ? decodeDocument(doc) : null;
}

async function createTransaction(accessToken, options, id, data) {
  return postJson(
    'firestore.googleapis.com',
    `${documentBasePath(options)}/transactions?documentId=${encodeURIComponent(
      id,
    )}`,
    {fields: wrapFields(data)},
    accessToken,
  );
}

async function patchTransaction(accessToken, options, id, data) {
  const masks = Object.keys(data)
    .map((key) => `updateMask.fieldPaths=${encodeURIComponent(key)}`)
    .join('&');
  return patchJson(
    'firestore.googleapis.com',
    `${documentBasePath(options)}/transactions/${encodeURIComponent(id)}?${masks}`,
    {fields: wrapFields(data)},
    accessToken,
  );
}

function decodeDocument(document) {
  const data = {};
  for (const [key, value] of Object.entries(document.fields ?? {})) {
    data[key] = unwrap(value);
  }
  data.id = document.name.split('/').pop();
  data._name = document.name;
  return data;
}

function unwrap(value) {
  if (value == null) return null;
  if ('stringValue' in value) return value.stringValue;
  if ('integerValue' in value) return Number(value.integerValue);
  if ('doubleValue' in value) return Number(value.doubleValue);
  if ('booleanValue' in value) return value.booleanValue;
  if ('timestampValue' in value) return value.timestampValue;
  if ('nullValue' in value) return null;
  if ('arrayValue' in value) return (value.arrayValue.values ?? []).map(unwrap);
  if ('mapValue' in value) {
    const out = {};
    for (const [key, child] of Object.entries(value.mapValue.fields ?? {})) {
      out[key] = unwrap(child);
    }
    return out;
  }
  return value;
}

function wrapFields(data) {
  const fields = {};
  for (const [key, value] of Object.entries(data)) {
    fields[key] = wrapValue(key, value);
  }
  return fields;
}

function wrapValue(key, value) {
  if (value == null) return {nullValue: null};
  if (typeof value === 'string') {
    if (isTimestampField(key)) return {timestampValue: value};
    return {stringValue: value};
  }
  if (typeof value === 'number') {
    return Number.isInteger(value)
      ? {integerValue: String(value)}
      : {doubleValue: value};
  }
  if (typeof value === 'boolean') return {booleanValue: value};
  if (Array.isArray(value)) {
    return {arrayValue: {values: value.map((item) => wrapValue(key, item))}};
  }
  if (value instanceof Date) return {timestampValue: value.toISOString()};
  const fields = wrapFields(value);
  return {mapValue: {fields}};
}

function isTimestampField(key) {
  return ['date', 'dueDate', 'settledAt', 'createdAt', 'updatedAt'].includes(
    key,
  );
}

async function buildExistingBillMap(accessToken, options, bills) {
  const map = new Map();
  for (const bill of bills) {
    const bySource = await findTransactionBySourceBillId(
      accessToken,
      options,
      bill.id,
    );
    if (bySource) {
      map.set(bill.id, bySource.id);
      continue;
    }
    const deterministic = await getTransaction(
      accessToken,
      options,
      transactionIdForBill(bill.id),
    );
    if (deterministic) {
      map.set(bill.id, deterministic.id);
      continue;
    }
    if (bill.paidTransactionId) {
      map.set(bill.id, bill.paidTransactionId);
    }
  }
  return map;
}

async function run() {
  const options = parseArgs(process.argv);
  const accountMap = mergeAccountMap(readAccountMap(options.accountMapPath), options);
  const token = await mintAccessToken(readRefreshToken());
  const bills = await fetchBills(token, options);
  const existingByBill = await buildExistingBillMap(token, options, bills);
  const nowIso = new Date().toISOString();
  const stats = {
    bills: bills.length,
    created: 0,
    updated: 0,
    skipped: 0,
    errors: 0,
  };
  const missingAccountBills = [];

  console.log(
    `${options.apply ? 'APPLY' : 'DRY RUN'}: ${bills.length} bill(s) found.`,
  );

  for (const bill of bills) {
    try {
      const existingId = existingByBill.get(bill.id);
      if (existingId && existingId !== bill.paidTransactionId) {
        logSkip(stats, bill, 'alreadyMigrated', existingId);
        continue;
      }

      if (bill.status === 'paid' && bill.paidTransactionId) {
        const linked = await getTransaction(token, options, bill.paidTransactionId);
        if (!linked) {
          logSkip(stats, bill, 'missingPaidTransaction', bill.paidTransactionId);
          continue;
        }
        if (isLinkedPaidBillMigrated(linked, bill)) {
          logSkip(stats, bill, 'alreadyMigrated', bill.paidTransactionId);
          continue;
        }
        const patch = buildLinkedPaidTransactionPatch({bill, nowIso});
        await maybeApply(options, () =>
          patchTransaction(token, options, patch.id, patch.data),
        );
        existingByBill.set(bill.id, patch.id);
        stats.updated += 1;
        console.log(`UPDATE tx=${patch.id} sourceBillId=${bill.id}`);
        continue;
      }

      if (bill.status === 'paid' && !options.createPaidUnlinked) {
        logSkip(stats, bill, 'paidUnlinkedNeedsReview');
        continue;
      }

      const mappedAccountId =
        accountMap.bills?.[bill.id] ?? accountMap.users?.[bill.userId] ?? null;
      const inheritedAccountId = mappedAccountId
        ? null
        : await resolveParentAccountId(token, options, bill, existingByBill);
      const accountId =
        mappedAccountId ??
        inheritedAccountId ??
        options.defaultAccountId ??
        accountMap.defaultAccountId ??
        null;
      if (!accountId) {
        missingAccountBills.push(bill);
        logSkip(stats, bill, 'missingAccount');
        continue;
      }

      const parentTransactionId = bill.parentBillId
        ? existingByBill.get(bill.parentBillId) ?? null
        : null;
      const created = buildTransactionFromBill({
        bill,
        accountId,
        nowIso,
        parentTransactionId,
      });
      await maybeApply(options, () =>
        createTransaction(token, options, created.id, created.data),
      );
      existingByBill.set(bill.id, created.id);
      stats.created += 1;
      console.log(
        `CREATE tx=${created.id} sourceBillId=${bill.id} status=${created.data.settlementStatus}`,
      );
    } catch (e) {
      stats.errors += 1;
      console.error(`ERROR bill=${bill.id}: ${e.message}`);
    }
  }

  console.log('\nSummary');
  console.log(JSON.stringify(stats, null, 2));
  if (missingAccountBills.length > 0) {
    if (options.showMissingAccounts) {
      await printMissingAccountReport(token, options, missingAccountBills);
    } else if (!options.apply) {
      console.log(
        '\nRun again with --show-missing-accounts to print account choices.',
      );
    }
  }
  if (!options.apply) {
    console.log('\nDry-run only. Re-run with --apply to write changes.');
  }
}

async function maybeApply(options, operation) {
  if (!options.apply) return;
  await operation();
}

function isLinkedPaidBillMigrated(transaction, bill) {
  return (
    transaction.sourceBillId === bill.id &&
    transaction.settlementStatus === 'paid' &&
    sameTimestamp(transaction.dueDate, normalizeTimestamp(bill.dueDate)) &&
    sameTimestamp(
      transaction.settledAt,
      normalizeTimestamp(bill.paidAt, bill.dueDate),
    ) &&
    transaction.recurrence ===
      billRecurrenceToTransactionRecurrence(bill.recurrence)
  );
}

function sameTimestamp(left, right) {
  if (!left || !right) return left === right;
  return new Date(left).getTime() === new Date(right).getTime();
}

async function resolveParentAccountId(accessToken, options, bill, existingByBill) {
  if (!bill.parentBillId) return null;
  const parentTransactionId = existingByBill.get(bill.parentBillId);
  if (!parentTransactionId) return null;
  const parent = await getTransaction(accessToken, options, parentTransactionId);
  return parent?.accountId ?? null;
}

async function printMissingAccountReport(accessToken, options, bills) {
  const billsByUser = groupBy(bills, (bill) => bill.userId);
  console.log('\nMissing account report');
  for (const [userId, userBills] of billsByUser.entries()) {
    const accounts = await fetchAccountsByUserId(accessToken, options, userId);
    console.log(`\nUser ${userId}`);
    console.log('Accounts');
    for (const account of accounts) {
      const bank = account.bank ? ` bank=${account.bank}` : '';
      console.log(
        `  - ${account.id} | ${account.name ?? '(no name)'} | ${account.type ?? 'unknown'}${bank}`,
      );
    }
    console.log('Bills missing account');
    for (const bill of userBills) {
      console.log(
        `  - ${bill.id} | ${bill.type} | ${bill.status} | ${formatDate(
          bill.dueDate,
        )} | ${formatAmount(bill.amount)} | ${truncate(bill.description, 72)}`,
      );
    }
  }

  console.log('\nAccount map template');
  console.log(
    JSON.stringify(
      {
        bills: Object.fromEntries(bills.map((bill) => [bill.id, 'ACCOUNT_ID'])),
      },
      null,
      2,
    ),
  );
}

function groupBy(items, keyForItem) {
  const map = new Map();
  for (const item of items) {
    const key = keyForItem(item);
    const bucket = map.get(key) ?? [];
    bucket.push(item);
    map.set(key, bucket);
  }
  return map;
}

function formatDate(value) {
  if (!value) return 'no-date';
  return value.slice(0, 10);
}

function formatAmount(value) {
  return Number(value ?? 0).toFixed(2);
}

function truncate(value, maxLength) {
  const text = String(value ?? '');
  if (text.length <= maxLength) return text;
  return `${text.slice(0, maxLength - 3)}...`;
}

function logSkip(stats, bill, reason, detail) {
  stats.skipped += 1;
  const suffix = detail ? ` (${detail})` : '';
  console.log(`SKIP bill=${bill.id} reason=${reason}${suffix}`);
}

run().catch((e) => {
  console.error('ERROR:', e.message);
  process.exit(1);
});
