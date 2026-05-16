// One-off: delete a single fcmToken doc from a user's subcollection.
// Usage:
//   node scripts/delete_orphan_fcm_token.js <uid> <docId>
//
// Reuses the firebase CLI OAuth refresh token — no service account needed.

const os = require('os');
const path = require('path');
const fs = require('fs');
const https = require('https');

const PROJECT_ID = 'financo-app-2026';
const DATABASE = '(default)';
const CLIENT_ID =
  '563584335869-fgrhgmd47bqnekij5i8b5pr03ho849e6.apps.googleusercontent.com';
const CLIENT_SECRET = 'j9iVZfS8kkCEFUPaAeJV0sAi';

const [uid, docId] = process.argv.slice(2);
if (!uid || !docId) {
  console.error('Usage: node scripts/delete_orphan_fcm_token.js <uid> <docId>');
  process.exit(1);
}

function readRefreshToken() {
  const p = path.join(os.homedir(), '.config', 'configstore', 'firebase-tools.json');
  return JSON.parse(fs.readFileSync(p, 'utf8')).tokens.refresh_token;
}

function postForm(host, p, body) {
  return new Promise((resolve, reject) => {
    const data = new URLSearchParams(body).toString();
    const req = https.request(
      { host, path: p, method: 'POST', headers: { 'Content-Type': 'application/x-www-form-urlencoded', 'Content-Length': Buffer.byteLength(data) } },
      (res) => {
        let buf = '';
        res.on('data', (c) => (buf += c));
        res.on('end', () => res.statusCode >= 400 ? reject(new Error(`${res.statusCode}: ${buf}`)) : resolve(JSON.parse(buf)));
      },
    );
    req.on('error', reject);
    req.write(data);
    req.end();
  });
}

function del(host, p, accessToken) {
  return new Promise((resolve, reject) => {
    const req = https.request(
      { host, path: p, method: 'DELETE', headers: { Authorization: `Bearer ${accessToken}` } },
      (res) => {
        let buf = '';
        res.on('data', (c) => (buf += c));
        res.on('end', () => res.statusCode >= 400 ? reject(new Error(`${res.statusCode}: ${buf}`)) : resolve(buf));
      },
    );
    req.on('error', reject);
    req.end();
  });
}

(async () => {
  const tokenResp = await postForm('oauth2.googleapis.com', '/token', {
    client_id: CLIENT_ID,
    client_secret: CLIENT_SECRET,
    refresh_token: readRefreshToken(),
    grant_type: 'refresh_token',
  });
  const accessToken = tokenResp.access_token;

  const p = `/v1/projects/${PROJECT_ID}/databases/${DATABASE}/documents/users/${encodeURIComponent(uid)}/fcmTokens/${encodeURIComponent(docId)}`;
  await del('firestore.googleapis.com', p, accessToken);
  console.log(`Deleted users/${uid}/fcmTokens/${docId}`);
})().catch((e) => {
  console.error('ERROR:', e.message);
  process.exit(1);
});
