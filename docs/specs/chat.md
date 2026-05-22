# Chat Feature Spec

AI-powered financial assistant using Vertex AI Gemini via a Firebase Cloud Functions backend. Users interact via natural language inside the Flutter app to create transactions, accounts, and categories. The chat pipeline lives in the Cloud Function and persists messages to the `chat_messages` collection in Firestore.

## Entity: ChatMessageEntity

| Field | Type | Required | Notes |
|-------|------|----------|-------|
| id | String | yes | UUID v4 |
| userId | String | yes | Owner |
| role | ChatRole | yes | `user` or `assistant` |
| content | String | yes | Display text (action blocks stripped) |
| metadata | Map<String, dynamic>? | no | Extracted action data |
| createdAt | DateTime | yes | |

- Extends `Equatable` — props: all fields.
- `ChatRole` enum: `{ user, assistant }`.

## Model: ChatMessageModel

Extends `ChatMessageEntity`.

### Serialization

| Field | Firestore key | Dart → JSON | JSON → Dart |
|-------|---------------|-------------|-------------|
| id | _(doc.id)_ | excluded from toJson | `doc.id` |
| userId | `userId` | String | String |
| role | `role` | `role.name` (e.g. `"user"`) | `ChatRole.values.byName(data['role'])` |
| content | `content` | String | String |
| metadata | `metadata` | Map? (nullable) | `Map<String, dynamic>?` |
| createdAt | `createdAt` | `Timestamp.fromDate(createdAt)` | `(data['createdAt'] as Timestamp).toDate()` |

Factories: `fromFirestore(DocumentSnapshot)`, `fromEntity(ChatMessageEntity)`, `toJson()`. Legacy documents persisted with a `channel` field (from the discontinued WhatsApp integration) load fine — the field is ignored.

## Datasources

### ChatBackendDataSource (abstract)

```
sendMessage(userId, content, history) → Future<ChatMessageModel>
```

### ChatBackendDataSourceImpl

- Invokes the `chatSend` Firebase Cloud Function via `FirebaseFunctions.httpsCallable`.
- Request payload: `{ content: String, history: List<{ role, content }> }`. The callable auth context supplies `userId`.
- Response payload: `{ id: String, content: String, metadata: Map? }`.
- Wraps the response in `ChatMessageModel` with `role: assistant`, `createdAt: now`.
- Also exposes `transcribeAudio({ base64Data, mimeType })` which invokes the `transcribeChatAudio` callable. Response: `{ transcript: String }`.
- `FirebaseFunctionsException` → rethrown as `AiException`.
- All backend-side concerns (system prompt, Gemini call, action-block extraction, response persistence) live in the Cloud Function.

### ChatRemoteDataSource (abstract)

```
getChatHistory(userId) → Future<List<ChatMessageModel>>
saveChatMessage(ChatMessageModel) → Future<void>
```

### ChatRemoteDataSourceImpl

- Firestore collection: `chat_messages`.
- `getChatHistory`: query by userId, ordered by createdAt ascending.
- `saveChatMessage`: set doc by message.id. Called by the client only for user messages and app-side action-result messages. Assistant responses from `chatSend` are persisted by the backend.
- All exceptions caught, rethrown as `ServerException`.

## Repository: ChatRepository

| Method | Parameters | Return | Notes |
|--------|-----------|--------|-------|
| sendMessage | userId, content, history, image? | `Either<Failure, ChatMessageEntity>` | Calls `chatSend` Cloud Function (which also persists the response). Client does NOT persist the assistant response — avoids double-write. `image` is optional `ChatImageAttachment` (base64 + mimeType) that's forwarded inline to Gemini. |
| getChatHistory | userId | `Either<Failure, List<ChatMessageEntity>>` | From Firestore |
| saveChatMessage | ChatMessageEntity | `Either<Failure, void>` | Converts to model, persists |
| transcribeAudio | base64Data, mimeType | `Either<Failure, String>` | Calls `transcribeChatAudio` Cloud Function. Audio bytes are discarded after transcription. |

### Error mapping

| Exception | Failure |
|-----------|---------|
| AiException | AiFailure |
| ServerException | ServerFailure |

### Business rules

1. `sendMessage` returns the assistant response; the backend already persisted it. The client does NOT re-save the response (prevents duplicate writes).
2. `saveChatMessage` converts entity to model via `ChatMessageModel.fromEntity` before persisting.
3. **Action confirmation flow**: the user taps the Confirm button → `ChatBloc._onActionConfirmed` runs the executor locally (keeps Drift cache coherent in one round-trip).
4. **User context injection (intelligence)**: on every `chatSend` turn, the backend builds a snapshot of the user's accounts and categories via `buildUserContext(userId)` and appends it to the system instruction. The snapshot is a point-in-time view at turn start — newly created entities (e.g. a category created in this same confirmation flow) are picked up on the NEXT turn.
5. **Verify-before-confirm**: the AI must NOT emit a `[TRANSACTION_DATA]` block if the referenced category or account is absent from the snapshot. It emits a `[CATEGORY_ACTION]` or `[ACCOUNT_ACTION]` create block first and resumes the transaction on the next turn once creation is confirmed.
6. **Exact-name discipline**: `account`, `category`, and `linkedAccountName` fields in any action block MUST contain the **exact name** as stored in the snapshot — not the user's shortened phrasing. Example: user typed `"cartão mila"`, snapshot has `"Cartão Nubank Mila"` → emit `"Cartão Nubank Mila"`. The bloc's word-set matcher (see edge case 10) is a safety net, not a license to guess.
7. **Ask over guess**: when any required field cannot be confidently determined, the AI asks a single specific question instead of fabricating a placeholder. Generic descriptions like `"Transação"`, `"Gasto"`, `"Compra"` are NOT acceptable — derive from the user's wording or the chosen category, or ask. Date defaults silently to today when unmentioned (do not ask for it). Account/category ambiguity is always resolved by asking with a numbered list of EXISTING options.
8. **Single-match auto-resolution**: when filters applied to the user's phrasing leave exactly one account (e.g. user said "cartão de crédito" and only one `creditCard` exists), the AI uses it without asking.
9. **Filtering signals**:
   - "cartão" / "crédito" / "cartão de crédito" → account type filter `creditCard`.
   - "conta" / "débito" / "corrente" → account type filter `checking`.
   - Bank name (e.g. "nubank") → filter accounts by `bank`.
10. **Option lists**: when multiple candidates remain after filtering, the AI presents a short numbered list of EXISTING accounts/categories (not generic examples).
11. **App-generated messages excluded from AI history**: assistant messages produced by the app/executor (e.g. "Transaction X created successfully!", "Ação cancelada.") are tagged with `metadata.kind = 'actionResult'` when persisted. The chat data source filters these out before sending the history to Gemini — otherwise the model mimics the result pattern in subsequent turns and emits fake success text without the action block, producing bubbles with no Confirm button and no actual write. Legacy messages without the tag are caught by a content-pattern fallback (regex matching the standard result phrasings).
12. **Action block reconstruction in AI history**: the Cloud Function strips action blocks (`[TRANSACTION_DATA]{...}[/TRANSACTION_DATA]`, etc.) from response text before persisting — only `metadata` survives. Before sending history back to Gemini, the data source reconstructs the block from `metadata.actionType` + the remaining metadata fields (excluding `kind`) and appends it to the message content. Without this, the model sees its own past replies as plain text without blocks, learns to skip the block in subsequent turns, and produces bubbles with no Confirm button.
13. **Action card persistence after decision**: the `ChatActionCard` stays visible after the user taps Confirm or Cancel; only the footer changes (buttons → status badge "Confirmed"/"Cancelled"). Confirmed status is derived by scanning messages for a result message whose `metadata.originActionId` points back at the proposal — survives chat reload. Cancelled status is page-level state only (a cancelled action never wrote anything, so re-pending after reload is benign).

## Use Cases

Thin delegators:
- `SendMessageUseCase.call(userId, content, history)` → `repository.sendMessage(...)`
- `GetChatHistoryUseCase.call(userId)` → `repository.getChatHistory(...)`
- `SaveChatMessageUseCase.call(message)` → `repository.saveChatMessage(...)`
- `TranscribeAudioUseCase.call(base64Data, mimeType)` → `repository.transcribeAudio(...)`

## ChatBloc State Machine

### Events

| Event | Fields | Trigger |
|-------|--------|---------|
| ChatLoadRequested | — | Page init |
| ChatMessageSent | content: String, image: ChatImageAttachment? | User sends message (optionally with attached image) |
| ChatActionConfirmed | metadata: Map<String,dynamic> | User taps Confirm button |
| ChatAudioTranscriptionRequested | base64Data: String, mimeType: String | User stopped voice recording — transcribes and forwards as a regular user turn in one shot |

### States

| State | Fields | Notes |
|-------|--------|-------|
| ChatInitial | — | Before load |
| ChatLoading | — | Loading history |
| ChatLoaded | messages, isTyping, shouldRefreshTransactions, isTranscribing | Main state. `isTranscribing` shows transcribing spinner in the input while the audio is being converted to text; once the transcript is ready it is dispatched as a regular `ChatMessageSent` turn — there is no editable preview. |
| ChatError | failure: Failure | Load failure only |

### Transitions

**ChatLoadRequested:**
1. Emit `ChatLoading`
2. Call `getChatHistory(userId)`
3. Success → clear + addAll messages, emit `ChatLoaded(messages)`
4. Failure → emit `ChatError(failure)`

**ChatMessageSent:**
1. Create user message entity (UUID, user role, now)
2. Add to internal list, emit `ChatLoaded(messages, isTyping: true)`
3. Persist user message (non-blocking — failure swallowed)
4. Build history WITHOUT current message (avoid duplicate in Gemini context)
5. Call `sendMessage(userId, content, history)`
6. On failure:
   - Check if quota/rate limit in message → specific error text
   - Create assistant error message, add to list, emit `ChatLoaded`
7. On success: add response to list, emit `ChatLoaded`

**ChatActionConfirmed:**
1. Extract `actionType` from metadata
2. Route to handler: `account` | `category` | `transaction` | `bill` | `budget` | `transfer` | default → "Unknown action type." (handlers registered in `injection_container.dart`)
3. Create assistant message with result text
4. Add to list, persist (non-blocking — failure swallowed)
5. Emit `ChatLoaded(shouldRefreshTransactions: actionType == 'transaction')`

**ChatAudioTranscriptionRequested:**
1. Emit `ChatLoaded(isTranscribing: true)`
2. Call `TranscribeAudioUseCase(base64Data, mimeType)`
3. On failure → log and emit plain `ChatLoaded` (no message added).
4. On success with empty/whitespace transcript → emit plain `ChatLoaded` (nothing was understood; do not dispatch an empty turn that the AI would reject).
5. On success with non-empty transcript → invoke the `ChatMessageSent(transcript)` handler **inline** with the same emitter (not via `add()` — that would queue behind the current handler and the user bubble would only appear after the AI typing-indicator already started). The transcript becomes the user's bubble, the AI processes it normally and confirms what it understood. "Fire and trust" — there is no review step.

### Action Handlers

**Account create:**
- Parse bank: lowercase → `nubank` or `others`
- Parse type: `creditCard` → `AccountType.creditCard`, else `checking`
- For credit cards: parse `creditLimit`, `closingDay`, `dueDay`, resolve `linkedAccountName` → `linkedAccountId` via `getAccounts` lookup
- Call `createAccount` → success/failure message

**Account delete:**
- Lookup by name (case-insensitive) via `getAccounts`
- Call `deleteAccount` or return "not found"

**Category create:**
- Parse type: `income` | `expense`
- Defaults: icon 58332, color assigned by `CategoryColors.forIndex(existingCount)`
- Call `createCategory` → success/failure message

**Category delete:**
- Lookup by name (case-insensitive) via `getCategories`
- Call `deleteCategory` or return "not found"

**Transaction create:**
1. Parse type, amount (validate > 0), description, date (ISO 8601 or now)
2. Resolve category by name (case-insensitive) — "not found" if missing
3. Resolve account by name with two-tier matching: exact case-insensitive first, then substring either direction (covers AI emitting `"Cartão Mila"` for `"Cartão Nubank Mila"`). Returns an error if zero matches OR multiple substring matches — NEVER falls back silently to another account, since that would write the transaction to the wrong card and still emit a success message.
4. Call `createTransaction` → success message with description + formatted amount

**Transfer create:** (action block `[TRANSFER_DATA]`, actionType `'transfer'`)
1. Parse amount (validate > 0), description (default empty), date (ISO 8601 or now).
2. Validate `from` and `to` are both present (non-empty).
3. Resolve `from` and `to` accounts using the same two-tier matcher as transactions. Reject if either is unresolvable or ambiguous.
4. Reject if resolved `from.id == to.id` (must be different accounts).
5. Build linked expense (in `from`, `categoryId: ''`) + income (in `to`, `categoryId: ''`) and call `createTransfer`. The repository links them with `linkedTransactionId` on each side.
6. Success message: `Transfer of R$ X from "From Account" to "To Account" created successfully!`. The action triggers `shouldRefreshTransactions: true`.

## Image input (receipts, notifications, invoices)

1. User taps the paperclip/attach button in the message input. A bottom sheet offers "Take photo" (camera) and "Choose from gallery".
2. The widget uses `image_picker` to capture a JPEG (`imageQuality: 75`, `maxWidth: 1920`) — reasonable for receipts while keeping the payload under 1-2 MB base64.
3. A thumbnail preview appears above the text field with an `X` to remove. User may type an optional caption.
4. On send, the picked image is base64-encoded for the backend AND the original `Uint8List` bytes are attached to `ChatMessageSent` (`imageBytes`) so the user-bubble can render the thumbnail without re-decoding base64 on every rebuild. The bloc stores the bytes on the user `ChatMessageEntity.inlineImageBytes` (transient, in-memory only) and forwards the base64 payload through `SendMessageUseCase → ChatRepository → ChatBackendDataSource → chatSend`.
5. Backend `chatSend` accepts an optional `image: { data, mimeType }` and forwards it as an inline `inlineData` part to Gemini alongside the text content. The system prompt's "Image input" section explicitly tells Gemini that **image + caption are complementary, not exclusive** — image is the source-of-truth for amount/merchant/date, the caption fills in account/category/payment-method context. Conflicts (e.g. caption says R$50 but receipt shows R$30) are surfaced in the reply rather than silently picked.
6. The user-bubble renders the thumbnail flush to the bubble edges with the optional caption below it. With no caption, only the image shows (no `📷 Image attached.` placeholder). The placeholder is only used as a defensive fallback when an image somehow arrives without bytes (shouldn't happen in normal flow).
7. The user's message is persisted with the typed caption AND a `metadata.hadImage = true` flag. Image bytes never reach Firestore. After a chat reload, when `inlineImageBytes` is gone, the bubble checks `metadata.hadImage` and renders a small placeholder tile (photo icon + "Image not available") instead of an empty bubble — honest signal that an image was sent without trying to fake the original content. The flag is `metadata`-only — it is NOT an `actionType` so the AI history filter (`_historyContent`) ignores it; the AI never sees this tag.
8. When the image is NOT a recognizable receipt/notification, Gemini politely says it couldn't identify a transaction and asks what the user wants to record.
9. Platform permissions: Android `CAMERA`, iOS `NSCameraUsageDescription` + `NSPhotoLibraryUsageDescription`, macOS `com.apple.security.device.camera`.
10. Web is supported — `image_picker_for_web` opens a file picker (mobile browsers expose camera capture inside it, desktop browsers show file chooser).

## Voice input (audio)

1. The user taps the microphone button in the message input. The widget uses the `record` package to capture AAC audio to a temp file.
2. User taps stop. The widget reads the file bytes, base64-encodes them, fires `ChatAudioTranscriptionRequested`, and deletes the temp file.
3. Backend `transcribeChatAudio` callable passes the audio inline to Gemini (multimodal) with a transcription-only instruction; returns the transcript text. The instruction includes a small glossary of canonical Brazilian-finance terms (Nubank, Itaú, Bradesco, PicPay, etc.) that the speech model frequently breaks apart phonetically (e.g. "Nubank" → "No Bank Geek") — biasing the decoder toward the right spelling.
4. Bloc dispatches the transcript as a regular `ChatMessageSent` turn (see ChatAudioTranscriptionRequested transition). The user sees their bubble appear with the transcript, and the AI replies normally — including any action card needed to confirm the request.
5. The audio bytes are never persisted; only the transcript text hits Firestore via the regular user-message save path. There is no review/edit step — if the transcript is wrong, the user can send a follow-up message correcting it.
6. Web is supported — `record_web` uses `MediaRecorder`. On web `AudioRecorder.start` ignores the `path` parameter and `stop()` returns a blob URL; the widget fetches the bytes via `http.get(Uri.parse(blobUrl))` and tags them as `audio/webm`. On mobile/desktop the widget writes to a temp file (`path_provider` + `dart:io File`) and deletes it after reading, tagging the mimetype as `audio/mp4`.
7. Platform permissions: Android `RECORD_AUDIO`, iOS `NSMicrophoneUsageDescription`, macOS `com.apple.security.device.audio-input`.

## Edge Cases

1. **Empty history**: first message sends empty history list — valid.
2. **Null response text**: defaults to "Sorry, I could not process that."
3. **Malformed action JSON**: silently caught, metadata stays null, no Confirm button shown.
4. **Unknown action type**: returns "Unknown action type." as assistant message.
5. **Quota/rate limit**: detected by checking failure message for "quota" or "rate" keywords.
6. **Multiple action blocks**: only first match per type is extracted; if multiple types present, last one wins (category overwrites account).
7. **User message persist failure**: non-blocking, continues with AI call.
8. **Action confirm save failure**: non-blocking, state still emitted.
9. **Category not found for transaction**: returns descriptive error asking user to create first.
10. **Transaction account not resolvable**:
    - User has zero accounts → "No accounts found. Please create an account first."
    - AI-emitted name doesn't match any account (exact or word-set fuzzy: every query word appears as a substring of some account-name word, or vice-versa) → "Account 'X' not found. Please create it first or use the exact name."
    - Word-set match is ambiguous (multiple accounts match) → "Multiple accounts match 'X': ...". Asks the user to be more specific.
    - NEVER silently falls back to another account — that masks wrong-account writes and produces misleading success messages.
11. **Audio transcription failure**: snack/no-op — the user can retry or type manually.
12. **Microphone permission denied**: show SnackBar asking the user to grant it in system settings.
13. **Pending transcript + user types over it**: the edited text takes precedence; sending uses whatever is in the text field.
14. **Image + empty caption**: content saved as `📷 Imagem anexada`; backend still processes the image and extracts transaction info.
15. **Image larger than callable 10MB limit**: `image_picker` compression (quality 75, maxWidth 1920) keeps typical receipt photos under 1MB base64; heavier cases would bubble up as `AiFailure` via `FirebaseFunctionsException`.
16. **Non-receipt image**: Gemini returns a polite "couldn't identify" message; no `[TRANSACTION_DATA]` emitted.
17. **AI mimics result text**: would-be regression — Gemini learns from history that "Pronto, confirma o gasto?" is followed by "Transaction X created successfully!" and emits BOTH in one assistant message without the action block. Mitigated by (a) tagging app-generated messages with `metadata.kind = 'actionResult'` and stripping them from history before the AI call, (b) explicit "Never echo app result text" rule in the system prompt, (c) regex fallback for legacy untagged messages.
18. **Preflight on AI-proposed actions**: when an assistant message arrives with `metadata.actionType`, the bloc validates the action against current data BEFORE the action card is rendered (transactions: category exists, account resolvable; transfers: both accounts resolvable, distinct). On failure, a rejection bubble is appended with `metadata = { kind: 'actionRejected', originActionId: <proposalId> }` and the timeline suppresses the card for that proposal. Rationale: confirming a card and then seeing a "not found" error breaks the contract the card sets up — if the card is shown, Confirm should always succeed (modulo network/server failures). Rejection bubbles are filtered from the AI history (same rule as action results) to avoid the model mimicking them.
