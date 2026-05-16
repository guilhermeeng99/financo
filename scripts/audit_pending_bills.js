// One-off audit: lists every bill in Firestore with status=pending and
// dueDate <= end-of-today, grouped by userId, and flags userIds whose
// users/{userId} doc no longer exists (orphans). Read-only.
//
// Authenticates by reusing the OAuth refresh token already stored by the
// `firebase` CLI (~/.config/configstore/firebase-tools.json), so no service
// account key is required. Run from the repo root:
//   node scripts/audit_pending_bills.js
//
// Project is hard-coded to financo-app-2026 / (default) database.

const os = require('os');
const path = require('path');
const fs = require('fs');
const https = require('https');

const PROJECT_ID = 'financo-app-2026';
const DATABASE = '(default)';

// Public client ID/secret shipped with firebase-tools. Same values the CLI
// uses when refreshing tokens, so we can reuse the user's existing grant.
const CLIENT_ID =
  '563584335869-fgrhgmd47bqnekij5i8b5pr03ho849e6.apps.googleusercontent.com';
const CLIENT_SECRET = 'j9iVZfS8kkCEFUPaAeJV0sAi';

function readRefreshToken() {
  const p = path.join(
    os.homedir(),
    '.config',
    'configstore',
    'firebase-tools.json',
  );
  const c = JSON.parse(fs.readFileSync(p, 'utf8'));
  if (!c.tokens || !c.tokens.refresh_token) {
    throw new Error('No refresh token in configstore — run `firebase login`.');
  }
  return c.tokens.refresh_token;
}

function postForm(host, path, body) {
  return new Promise((resolve, reject) => {
    const data = new URLSearchParams(body).toString();
    const req = https.request(
      {
        host,
        path,
        method: 'POST',
        headers: {
          'Content-Type': 'application/x-www-form-urlencoded',
          'Content-Length': Buffer.byteLength(data),
        },
      },
      (res) => {
        let buf = '';
        res.on('data', (chunk) => (buf += chunk));
        res.on('end', () => {
          if (res.statusCode >= 400) {
            return reject(new Error(`${res.statusCode}: ${buf}`));
          }
          try {
            resolve(JSON.parse(buf));
          } catch (e) {
            reject(e);
          }
        });
      },
    );
    req.on('error', reject);
    req.write(data);
    req.end();
  });
}

function postJson(host, path, body, accessToken) {
  return new Promise((resolve, reject) => {
    const data = JSON.stringify(body);
    const req = https.request(
      {
        host,
        path,
        method: 'POST',
        headers: {
          'Content-Type': 'application/json',
          'Content-Length': Buffer.byteLength(data),
          Authorization: `Bearer ${accessToken}`,
        },
      },
      (res) => {
        let buf = '';
        res.on('data', (chunk) => (buf += chunk));
        res.on('end', () => {
          if (res.statusCode >= 400) {
            return reject(new Error(`${res.statusCode}: ${buf}`));
          }
          try {
            resolve(JSON.parse(buf));
          } catch (e) {
            reject(e);
          }
        });
      },
    );
    req.on('error', reject);
    req.write(data);
    req.end();
  });
}

function getJson(host, path, accessToken) {
  return new Promise((resolve, reject) => {
    const req = https.request(
      {
        host,
        path,
        method: 'GET',
        headers: { Authorization: `Bearer ${accessToken}` },
      },
      (res) => {
        let buf = '';
        res.on('data', (chunk) => (buf += chunk));
        res.on('end', () => {
          if (res.statusCode === 404) return resolve(null);
          if (res.statusCode >= 400) {
            return reject(new Error(`${res.statusCode}: ${buf}`));
          }
          try {
            resolve(JSON.parse(buf));
          } catch (e) {
            reject(e);
          }
        });
      },
    );
    req.on('error', reject);
    req.end();
  });
}

async function mintAccessToken(refreshToken) {
  const resp = await postForm('oauth2.googleapis.com', '/token', {
    client_id: CLIENT_ID,
    client_secret: CLIENT_SECRET,
    refresh_token: refreshToken,
    grant_type: 'refresh_token',
  });
  return resp.access_token;
}

// Maps a Firestore REST "document" payload (typed values like
// {stringValue, integerValue, timestampValue}) back into plain JS.
function unwrap(value) {
  if (value == null) return null;
  if ('stringValue' in value) return value.stringValue;
  if ('integerValue' in value) return Number(value.integerValue);
  if ('doubleValue' in value) return Number(value.doubleValue);
  if ('booleanValue' in value) return value.booleanValue;
  if ('timestampValue' in value) return value.timestampValue;
  if ('nullValue' in value) return null;
  if ('mapValue' in value) {
    const out = {};
    for (const [k, v] of Object.entries(value.mapValue.fields ?? {})) {
      out[k] = unwrap(v);
    }
    return out;
  }
  if ('arrayValue' in value) {
    return (value.arrayValue.values ?? []).map(unwrap);
  }
  return value;
}

function endOfTodayIso() {
  const d = new Date();
  return new Date(
    d.getFullYear(),
    d.getMonth(),
    d.getDate(),
    23,
    59,
    59,
    999,
  ).toISOString();
}

async function runStructuredQuery(accessToken) {
  const endOfToday = endOfTodayIso();
  const body = {
    structuredQuery: {
      from: [{ collectionId: 'bills' }],
      where: {
        compositeFilter: {
          op: 'AND',
          filters: [
            {
              fieldFilter: {
                field: { fieldPath: 'status' },
                op: 'EQUAL',
                value: { stringValue: 'pending' },
              },
            },
            {
              fieldFilter: {
                field: { fieldPath: 'dueDate' },
                op: 'LESS_THAN_OR_EQUAL',
                value: { timestampValue: endOfToday },
              },
            },
          ],
        },
      },
      orderBy: [{ field: { fieldPath: 'dueDate' }, direction: 'ASCENDING' }],
    },
  };
  const path = `/v1/projects/${PROJECT_ID}/databases/${DATABASE}/documents:runQuery`;
  const resp = await postJson(
    'firestore.googleapis.com',
    path,
    body,
    accessToken,
  );
  const docs = [];
  for (const entry of resp) {
    if (!entry.document) continue;
    const fields = entry.document.fields ?? {};
    const data = {};
    for (const [k, v] of Object.entries(fields)) data[k] = unwrap(v);
    data._docName = entry.document.name;
    data._id = entry.document.name.split('/').pop();
    docs.push(data);
  }
  return docs;
}

async function userExists(accessToken, userId) {
  const path =
    `/v1/projects/${PROJECT_ID}/databases/${DATABASE}/documents/users/${encodeURIComponent(userId)}`;
  const doc = await getJson('firestore.googleapis.com', path, accessToken);
  if (!doc) return null;
  const fields = doc.fields ?? {};
  const out = {};
  for (const [k, v] of Object.entries(fields)) out[k] = unwrap(v);
  return out;
}

(async () => {
  console.log('Auditing pending overdue bills…');
  const refresh = readRefreshToken();
  const token = await mintAccessToken(refresh);
  const bills = await runStructuredQuery(token);
  console.log(`Found ${bills.length} bill(s) with status=pending AND dueDate<=endOfToday.\n`);

  // Group by userId
  const byUser = new Map();
  for (const b of bills) {
    const uid = b.userId || '<no userId>';
    if (!byUser.has(uid)) byUser.set(uid, []);
    byUser.get(uid).push(b);
  }

  // Resolve each owner
  for (const [uid, items] of byUser) {
    const owner = uid === '<no userId>' ? null : await userExists(token, uid);
    const ownerLabel = owner
      ? `${owner.email ?? '(no email)'} | ${owner.name ?? '(no name)'}`
      : 'ORPHAN — users/{uid} does not exist';
    console.log(`userId: ${uid}`);
    console.log(`  owner: ${ownerLabel}`);
    console.log(`  count: ${items.length}`);
    for (const b of items) {
      console.log(
        `    - id=${b._id} desc="${(b.description ?? '').toString().slice(0, 40)}" amount=${b.amount} dueDate=${b.dueDate} parent=${b.parentBillId ?? '-'}`,
      );
    }
    console.log('');
  }
})().catch((e) => {
  console.error('ERROR:', e.message);
  process.exit(1);
});
