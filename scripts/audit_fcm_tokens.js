// Lists fcmTokens for the candidate users, and cross-references them to
// see if the same physical device token is registered under more than one
// uid (which would confirm "this device is receiving notifications for an
// account other than the currently signed-in one").

const os = require('os');
const path = require('path');
const fs = require('fs');
const https = require('https');

const PROJECT_ID = 'financo-app-2026';
const DATABASE = '(default)';
const CLIENT_ID =
  '563584335869-fgrhgmd47bqnekij5i8b5pr03ho849e6.apps.googleusercontent.com';
const CLIENT_SECRET = 'j9iVZfS8kkCEFUPaAeJV0sAi';

// Read uids to inspect from CLI args, fall back to the two we know about.
const TARGET_UIDS = process.argv.slice(2);

function readRefreshToken() {
  const p = path.join(
    os.homedir(),
    '.config',
    'configstore',
    'firebase-tools.json',
  );
  const c = JSON.parse(fs.readFileSync(p, 'utf8'));
  return c.tokens.refresh_token;
}

function postForm(host, p, body) {
  return new Promise((resolve, reject) => {
    const data = new URLSearchParams(body).toString();
    const req = https.request(
      {
        host,
        path: p,
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
          resolve(JSON.parse(buf));
        });
      },
    );
    req.on('error', reject);
    req.write(data);
    req.end();
  });
}

function getJson(host, p, accessToken) {
  return new Promise((resolve, reject) => {
    const req = https.request(
      {
        host,
        path: p,
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
          resolve(JSON.parse(buf));
        });
      },
    );
    req.on('error', reject);
    req.end();
  });
}

function postJson(host, p, body, accessToken) {
  return new Promise((resolve, reject) => {
    const data = JSON.stringify(body);
    const req = https.request(
      {
        host,
        path: p,
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
          resolve(JSON.parse(buf));
        });
      },
    );
    req.on('error', reject);
    req.write(data);
    req.end();
  });
}

function unwrap(v) {
  if (v == null) return null;
  if ('stringValue' in v) return v.stringValue;
  if ('integerValue' in v) return Number(v.integerValue);
  if ('timestampValue' in v) return v.timestampValue;
  if ('mapValue' in v) {
    const out = {};
    for (const [k, x] of Object.entries(v.mapValue.fields ?? {})) out[k] = unwrap(x);
    return out;
  }
  if ('booleanValue' in v) return v.booleanValue;
  return v;
}

async function mintAccessToken(refresh) {
  const r = await postForm('oauth2.googleapis.com', '/token', {
    client_id: CLIENT_ID,
    client_secret: CLIENT_SECRET,
    refresh_token: refresh,
    grant_type: 'refresh_token',
  });
  return r.access_token;
}

async function listTokens(accessToken, uid) {
  const p =
    `/v1/projects/${PROJECT_ID}/databases/${DATABASE}/documents/users/${encodeURIComponent(uid)}/fcmTokens`;
  const r = await getJson('firestore.googleapis.com', p, accessToken);
  if (!r || !r.documents) return [];
  return r.documents.map((d) => {
    const fields = d.fields ?? {};
    const out = { _id: d.name.split('/').pop() };
    for (const [k, v] of Object.entries(fields)) out[k] = unwrap(v);
    return out;
  });
}

async function findUserIdByEmail(accessToken, email) {
  const body = {
    structuredQuery: {
      from: [{ collectionId: 'users' }],
      where: {
        fieldFilter: {
          field: { fieldPath: 'email' },
          op: 'EQUAL',
          value: { stringValue: email },
        },
      },
      limit: 5,
    },
  };
  const p = `/v1/projects/${PROJECT_ID}/databases/${DATABASE}/documents:runQuery`;
  const r = await postJson('firestore.googleapis.com', p, body, accessToken);
  const out = [];
  for (const e of r) {
    if (!e.document) continue;
    out.push(e.document.name.split('/').pop());
  }
  return out;
}

(async () => {
  const token = await mintAccessToken(readRefreshToken());

  // Resolve uids from emails if no args were given.
  let uids = TARGET_UIDS;
  if (uids.length === 0) {
    console.log('Resolving uids for guilhermeeng99@gmail.com, guigapasocax@gmail.com, gigiolobato@gmail.com…');
    const all = [];
    for (const email of [
      'guilhermeeng99@gmail.com',
      'guigapasocax@gmail.com',
      'gigiolobato@gmail.com',
    ]) {
      const found = await findUserIdByEmail(token, email);
      for (const u of found) all.push({ email, uid: u });
      console.log(`  ${email}: ${found.length ? found.join(', ') : '(none)'}`);
    }
    uids = all.map((x) => x.uid);
    console.log('');
  }

  // For each uid, list fcm tokens.
  const tokenIndex = new Map(); // token string -> [uids]
  for (const uid of uids) {
    const list = await listTokens(token, uid);
    console.log(`uid=${uid} → ${list.length} fcmToken doc(s)`);
    for (const t of list) {
      const tok = String(t.token ?? t._id);
      const tail = tok.slice(-10);
      console.log(
        `  - doc=${t._id} platform=${t.platform} updatedAt=${t.updatedAt} tail=…${tail}`,
      );
      if (!tokenIndex.has(tok)) tokenIndex.set(tok, []);
      tokenIndex.get(tok).push(uid);
    }
    console.log('');
  }

  // Cross-reference duplicates.
  let dupCount = 0;
  for (const [tok, list] of tokenIndex) {
    if (list.length > 1) {
      dupCount++;
      console.log(
        `DUPLICATE token (tail …${tok.slice(-10)}) registered under ${list.length} uids: ${list.join(', ')}`,
      );
    }
  }
  if (dupCount === 0) console.log('No duplicated tokens across the inspected uids.');
})().catch((e) => {
  console.error('ERROR:', e.message);
  process.exit(1);
});
