# WhatsApp Integration Spec

Second channel for the existing AI chat. Users send messages from WhatsApp, a Firebase Cloud Functions webhook processes them through the same pipeline as the in-app chat, and replies are sent back via the Meta WhatsApp Cloud API. Personal-use only — a single hardcoded phone→userId mapping is the entire access control.

Runs entirely server-side in the `functions/` directory (TypeScript). The Flutter app is not involved in the WhatsApp flow.

## Entity: PhoneMapping

Not persisted. Lives in `functions/src/config.ts` as a constant:

```ts
export const PHONE_TO_UID: Record<string, string> = {
  '+5511XXXXXXXXX': 'firebase-uid-here',
};
```

Messages from any phone not listed are ignored silently (webhook returns 200, but does nothing).

## Datasources

### WhatsAppClient (interface)

```ts
sendText(to: string, body: string): Promise<void>
sendInteractiveButtons(to: string, body: string, buttons: Button[]): Promise<void>
markAsRead(messageId: string): Promise<void>
```

Where `Button = { id: string; title: string }`. Used to send the confirmation `[Confirmar] [Cancelar]` pair after an action is extracted.

### WhatsAppClientImpl

- Graph API v20+ endpoint: `https://graph.facebook.com/v20.0/{phoneNumberId}/messages`.
- Auth: `Authorization: Bearer {accessToken}` header.
- All errors logged with full payload (sanitized — access token stripped) and rethrown as `WhatsAppException`.

## Cloud Functions

### chatSend (callable)

Shared by the Flutter app and the WhatsApp webhook. Signature:

```
Input: { content: string, history: Array<{ role: 'user'|'assistant', content: string }> }
Auth:  request.auth.uid (required)
Output: { id: string, content: string, metadata: Record<string, any> | null }
```

Internally:
1. Build `chat_messages/{id}` document for the assistant response.
2. Call Gemini (Vertex AI `gemini-2.5-flash`) with the same system prompt as the legacy client.
3. Extract `[TRANSACTION_DATA]`, `[ACCOUNT_ACTION]`, `[CATEGORY_ACTION]` blocks via regex (1:1 port of the old client logic).
4. Strip action blocks from the display text.
5. Persist the assistant message to Firestore (`channel: 'app'` when called by Flutter app; `channel: 'whatsapp'` when called by the webhook via internal helper).
6. Return `{ id, content, metadata }`.

### whatsappWebhook (HTTPS)

Single endpoint handling both Meta's verification handshake (GET) and message events (POST):

- **GET**: read `hub.mode`, `hub.verify_token`, `hub.challenge` from query params. If `hub.mode == 'subscribe'` AND token matches `WHATSAPP_VERIFY_TOKEN` → respond 200 with `hub.challenge`. Otherwise 403.
- **POST**: receives message events from Meta — see business rules below.

## Business rules

1. **Signature verification**: compute HMAC SHA-256 of the raw request body using `META_APP_SECRET`, compare with `X-Hub-Signature-256` header (strip `sha256=` prefix). Mismatch → respond 403, no processing. Timing-safe compare required.
2. **Phone allowlist**: the sender phone (`messages[0].from`, E.164 without `+` prefix in Meta payloads — normalize to `+XXX...` before lookup) must be in `PHONE_TO_UID`. Unknown phones → respond 200 (ACK), no reply, no persistence.
3. **Idempotency**: dedupe by `messages[0].id`. Keep an in-memory LRU cache of processed IDs (TTL 5 min). Already-seen IDs → respond 200, skip processing.
4. **Text messages** (`type == 'text'`):
   a. Persist `chat_messages/{uuid}` with `role: 'user'`, `channel: 'whatsapp'`, `content: text.body`.
   b. Load history for `userId` (full history, cap at last 50 by `createdAt` desc, reverse before use).
   c. Call the same chat pipeline used by `chatSend` — it persists the assistant response with `channel: 'whatsapp'`.
   d. If the response has `metadata`, send `sendInteractiveButtons` with body=clean text and buttons `[{ id: 'confirm:<msgId>', title: 'Confirmar' }, { id: 'cancel:<msgId>', title: 'Cancelar' }]`.
   e. Otherwise send `sendText(to, cleanText)`.
5. **Button reply** (`type == 'interactive'`, `interactive.type == 'button_reply'`):
   a. Parse `interactive.button_reply.id` as `"<action>:<messageId>"`.
   b. `action == 'cancel'` → persist assistant message "Ação cancelada." (channel: whatsapp), send text "Ação cancelada.".
   c. `action == 'confirm'` → load the original assistant message by id, read its `metadata`, dispatch to the server-side action executor.
6. **Server-side action executor** (`functions/src/chat/actions.ts`) mirrors `ChatBloc._handleAccountAction`/`_handleCategoryAction`/`_handleTransactionAction` exactly, but:
   - Uses the Firebase Admin SDK directly on the `accounts`/`categories`/`transactions` collections (rules bypassed).
   - Writes the document with `userId` set from the resolved mapping (never from client input).
   - Returns a localized result string (PT-BR default — the user is a PT-BR speaker) that is persisted as a new assistant message with `channel: 'whatsapp'` and sent via `sendText`.
7. **Media / unsupported message types**: reply "No momento só consigo processar mensagens de texto." — do not persist to chat history.
8. **Gemini failure**: send "Desculpe, não consegui processar. Tente novamente." — do NOT persist an assistant message (keeps history clean).
9. **Action executor failure**: persist the error message as an assistant message (channel: whatsapp) and send via `sendText` — this is useful context next turn.
10. **Always respond 200** to the webhook once processing is kicked off (except on signature failure → 403, or unexpected crashes → 500). Meta retries non-2xx responses, so any 5xx causes duplicate processing.

## State machine — webhook request lifecycle

Linear, no state storage other than the dedup cache:

```
request → verify signature ─fail→ 403
            │
            ▼
         parse body ─not-messages-change→ 200 (ignore)
            │
            ▼
         dedupe (msg.id) ─hit→ 200
            │
            ▼
         phone in allowlist ─miss→ 200 (silent)
            │
            ▼
         type switch
           ├─ text → run chat pipeline → reply (text or buttons)
           ├─ interactive.button_reply → route confirm|cancel
           └─ other → reply "text only"
            │
            ▼
         200
```

## Edge cases

1. **Message body missing**: `messages[0].text.body` is empty → ignore, respond 200.
2. **History > 50 messages**: truncate to last 50 (matches the implicit cap the app has — no pagination today).
3. **Button clicked twice**: idempotency cache (rule 3) covers it — the second click has the same `message.id` since Meta re-delivers the same interactive event until it gets 200.
4. **Original message deleted before confirm**: load returns null → send "Essa ação expirou, peça novamente.".
5. **Access token expired (401 from Graph API)**: log, respond 500 to let Meta retry (giving the user time to rotate the token). Do NOT retry in-process.
6. **Category not found on transaction confirm**: mirror app behavior — reply "Categoria '<name>' não encontrada. Crie-a primeiro.".
7. **`chatSend` callable invoked without auth**: throw `HttpsError('unauthenticated')` — Flutter client never has this problem because `FirebaseAuth` is required before the chat page renders.
8. **Long assistant response (> 4096 chars, WA text limit)**: split on newline boundary before sending.
9. **Concurrent messages from same user**: Firestore `createdAt` ordering is monotonic at millisecond precision — rare conflicts acceptable for personal use.
10. **Verification token rotation**: both `whatsappVerify` and Meta dashboard must be updated in lockstep; secrets live in Firebase `functions:secrets`.

## Secrets & config

Managed via Firebase Functions secrets (`firebase functions:secrets:set`):

| Secret | Purpose |
|--------|---------|
| `WHATSAPP_ACCESS_TOKEN` | Permanent system-user token for Graph API |
| `WHATSAPP_PHONE_ID` | Phone-number-id for the Cloud API endpoint path |
| `WHATSAPP_VERIFY_TOKEN` | Arbitrary string, matches Meta webhook config |
| `META_APP_SECRET` | App secret used for HMAC signature verification |

Hardcoded in `functions/src/config.ts`:
- `PHONE_TO_UID` map

## Deployment

1. Upgrade Firebase project to Blaze plan (required for Cloud Functions).
2. Create Meta app at developers.facebook.com → add WhatsApp product.
3. Deploy: `firebase deploy --only functions`.
4. In Meta dashboard → WhatsApp → Configuration:
   - Webhook URL: `https://us-central1-<projectId>.cloudfunctions.net/whatsappWebhook`
   - Verify token: same value as `WHATSAPP_VERIFY_TOKEN`
   - Subscribe to `messages` field.
5. Hardcode the user's phone + uid in `functions/src/config.ts` and re-deploy.

## Verification

1. **Unit tests** (`functions/test/`): signature verification, dedup, allowlist rejection, text-path pipeline call, button-path action dispatch, media reply.
2. **Local integration** via `firebase emulators:start --only functions` + `ngrok`:
   - Send "gastei 25 reais no mercado hoje" from the allowlisted WhatsApp number.
   - Verify: user message in `chat_messages` with `channel: 'whatsapp'`; assistant reply with metadata + buttons appears on WhatsApp.
   - Tap "Confirmar" → transaction doc appears in `transactions/` → open the app → dashboard reflects the new transaction after refresh.
3. **Cross-channel**: open the Flutter chat page — WhatsApp-originated messages appear in history, ordered by `createdAt`.
