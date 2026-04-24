# Chat Feature Spec

AI-powered financial assistant using Vertex AI Gemini via a Firebase Cloud Functions backend. Users interact via natural language (from the Flutter app **or** from WhatsApp — see `specs/whatsapp.md`) to create transactions, accounts, and categories. Both channels share the same pipeline and the same `chat_messages` collection in Firestore.

## Entity: ChatMessageEntity

| Field | Type | Required | Notes |
|-------|------|----------|-------|
| id | String | yes | UUID v4 |
| userId | String | yes | Owner |
| role | ChatRole | yes | `user` or `assistant` |
| content | String | yes | Display text (action blocks stripped) |
| metadata | Map<String, dynamic>? | no | Extracted action data |
| channel | ChatChannel | yes | `app` (default) or `whatsapp` |
| createdAt | DateTime | yes | |

- Extends `Equatable` — props: all fields.
- `ChatRole` enum: `{ user, assistant }`.
- `ChatChannel` enum: `{ app, whatsapp }`.

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
| channel | `channel` | `channel.name` (default `"app"`) | `ChatChannel.values.byName(data['channel'] ?? 'app')` |
| createdAt | `createdAt` | `Timestamp.fromDate(createdAt)` | `(data['createdAt'] as Timestamp).toDate()` |

Factories: `fromFirestore(DocumentSnapshot)`, `fromEntity(ChatMessageEntity)`, `toJson()`.

`channel` defaults to `ChatChannel.app` in both the constructor and `fromFirestore` (backwards-compatible with pre-existing documents that lack the field).

## Datasources

### ChatBackendDataSource (abstract)

```
sendMessage(userId, content, history) → Future<ChatMessageModel>
```

### ChatBackendDataSourceImpl

- Invokes the `chatSend` Firebase Cloud Function via `FirebaseFunctions.httpsCallable`.
- Request payload: `{ content: String, history: List<{ role, content }> }`. The callable auth context supplies `userId`.
- Response payload: `{ id: String, content: String, metadata: Map? }`.
- Wraps the response in `ChatMessageModel` with `role: assistant`, `channel: app`, `createdAt: now`.
- Also exposes `transcribeAudio({ base64Data, mimeType })` which invokes the `transcribeChatAudio` callable. Response: `{ transcript: String }`.
- `FirebaseFunctionsException` → rethrown as `AiException`.
- All backend-side concerns (system prompt, Gemini call, action-block extraction, response persistence) live in the Cloud Function — see `specs/whatsapp.md` for the pipeline contract.

### ChatRemoteDataSource (abstract)

```
getChatHistory(userId) → Future<List<ChatMessageModel>>
saveChatMessage(ChatMessageModel) → Future<void>
```

### ChatRemoteDataSourceImpl

- Firestore collection: `chat_messages`.
- `getChatHistory`: query by userId, ordered by createdAt ascending — returns messages from **both** channels (app and whatsapp interleaved).
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
3. Action confirmation flow differs per channel:
   - **App**: user taps the Confirm button → `ChatBloc._onActionConfirmed` runs the executor locally (keeps Drift cache coherent in one round-trip).
   - **WhatsApp**: user taps the interactive reply button → backend runs the executor via Admin SDK (see `specs/whatsapp.md`).
4. **User context injection (intelligence)**: on every `chatSend` / WhatsApp turn, the backend builds a snapshot of the user's accounts and categories via `buildUserContext(userId)` and appends it to the system instruction. The snapshot is a point-in-time view at turn start — newly created entities (e.g. a category created in this same confirmation flow) are picked up on the NEXT turn.
5. **Verify-before-confirm**: the AI must NOT emit a `[TRANSACTION_DATA]` block if the referenced category or account is absent from the snapshot. It emits a `[CATEGORY_ACTION]` or `[ACCOUNT_ACTION]` create block first and resumes the transaction on the next turn once creation is confirmed.
6. **Single-match auto-resolution**: when filters applied to the user's phrasing leave exactly one account (e.g. user said "cartão de crédito" and only one `creditCard` exists), the AI uses it without asking.
7. **Filtering signals**:
   - "cartão" / "crédito" / "cartão de crédito" → account type filter `creditCard`.
   - "conta" / "débito" / "corrente" → account type filter `checking`.
   - Bank name (e.g. "nubank") → filter accounts by `bank`.
8. **Option lists**: when multiple candidates remain after filtering, the AI presents a short numbered list of EXISTING accounts/categories (not generic examples).

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
| ChatAudioTranscriptionRequested | base64Data: String, mimeType: String | User stopped voice recording |
| ChatTranscriptCancelled | — | User discarded the pending transcript preview |

### States

| State | Fields | Notes |
|-------|--------|-------|
| ChatInitial | — | Before load |
| ChatLoading | — | Loading history |
| ChatLoaded | messages, isTyping, shouldRefreshTransactions, isTranscribing, pendingTranscript? | Main state. `isTranscribing` shows transcribing spinner in the input. `pendingTranscript` non-null shows the editable preview with cancel/send. |
| ChatError | failure: Failure | Load failure only |

### Transitions

**ChatLoadRequested:**
1. Emit `ChatLoading`
2. Call `getChatHistory(userId)`
3. Success → clear + addAll messages, emit `ChatLoaded(messages)`
4. Failure → emit `ChatError(failure)`

**ChatMessageSent:**
1. Create user message entity (UUID, user role, channel: app, now)
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
2. Route to handler: `account` | `category` | `transaction` | default → "Unknown action type."
3. Create assistant message with result text (channel: app)
4. Add to list, persist (non-blocking — failure swallowed)
5. Emit `ChatLoaded(shouldRefreshTransactions: actionType == 'transaction')`

**ChatAudioTranscriptionRequested:**
1. Emit `ChatLoaded(isTranscribing: true)`
2. Call `TranscribeAudioUseCase(base64Data, mimeType)`
3. On success → emit `ChatLoaded(pendingTranscript: transcript)` — the view fills the input field with the transcript so the user can edit/send
4. On failure → log and emit plain `ChatLoaded` (no pending transcript; no extra message added)

**ChatTranscriptCancelled:**
1. Emit plain `ChatLoaded` — clears `pendingTranscript`.
2. The view clears the text field.

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
3. Resolve account by name (case-insensitive) — fallback to first account if no match
4. Call `createTransaction` → success message with description + formatted amount

## Image input (receipts, notifications, invoices)

1. User taps the paperclip/attach button in the message input. A bottom sheet offers "Take photo" (camera) and "Choose from gallery".
2. The widget uses `image_picker` to capture a JPEG (`imageQuality: 75`, `maxWidth: 1920`) — reasonable for receipts while keeping the payload under 1-2 MB base64.
3. A thumbnail preview appears above the text field with an `X` to remove. User may type an optional caption.
4. On send, the picked image is base64-encoded and attached to `ChatMessageSent`. The bloc forwards it through `SendMessageUseCase → ChatRepository → ChatBackendDataSource → chatSend` callable.
5. Backend `chatSend` accepts an optional `image: { data, mimeType }` and forwards it as an inline `inlineData` part to Gemini alongside the text content. System prompt instructs Gemini to extract amount/description/date/category from receipt/notification/invoice images.
6. The user's message is persisted with the user's typed caption, or `📷 Imagem anexada` if caption was empty. The image bytes are NOT persisted — they're used for the single turn and discarded.
7. When the image is NOT a recognizable receipt/notification, Gemini politely says it couldn't identify a transaction and asks what the user wants to record.
8. Platform permissions: Android `CAMERA`, iOS `NSCameraUsageDescription` + `NSPhotoLibraryUsageDescription`, macOS `com.apple.security.device.camera`.
9. Web is supported — `image_picker_for_web` opens a file picker (mobile browsers expose camera capture inside it, desktop browsers show file chooser).

## Voice input (audio)

1. The user taps the microphone button in the message input. The widget uses the `record` package to capture AAC audio to a temp file.
2. User taps stop. The widget reads the file bytes, base64-encodes them, fires `ChatAudioTranscriptionRequested`, and deletes the temp file.
3. Backend `transcribeChatAudio` callable passes the audio inline to Gemini (multimodal) with a transcription-only instruction; returns the transcript text.
4. Bloc emits `ChatLoaded(pendingTranscript: text)`. The view fills the message text field with the transcript and shows a red `X` (cancel) button on the left.
5. User can edit the text and tap the send icon — that triggers the normal `ChatMessageSent` flow. The audio is never persisted anywhere; only the final (possibly edited) text hits Firestore via the regular user-message save path.
6. Tapping cancel fires `ChatTranscriptCancelled` which clears the pending transcript state and the text field.
7. Web is supported — `record_web` uses `MediaRecorder`. On web `AudioRecorder.start` ignores the `path` parameter and `stop()` returns a blob URL; the widget fetches the bytes via `http.get(Uri.parse(blobUrl))` and tags them as `audio/webm`. On mobile/desktop the widget writes to a temp file (`path_provider` + `dart:io File`) and deletes it after reading, tagging the mimetype as `audio/mp4`.
8. Platform permissions: Android `RECORD_AUDIO`, iOS `NSMicrophoneUsageDescription`, macOS `com.apple.security.device.audio-input`.

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
10. **No accounts for transaction**: returns "No accounts found. Please create an account first."
11. **Legacy messages without `channel` field**: load as `ChatChannel.app` (default).
12. **Cross-channel history**: messages from WhatsApp and app appear interleaved in `ChatLoaded.messages`, ordered by `createdAt`.
13. **Audio transcription failure**: snack/no-op — the user can retry or type manually.
14. **Microphone permission denied**: show SnackBar asking the user to grant it in system settings.
15. **Pending transcript + user types over it**: the edited text takes precedence; sending uses whatever is in the text field.
16. **Image + empty caption**: content saved as `📷 Imagem anexada`; backend still processes the image and extracts transaction info.
17. **Image larger than callable 10MB limit**: `image_picker` compression (quality 75, maxWidth 1920) keeps typical receipt photos under 1MB base64; heavier cases would bubble up as `AiFailure` via `FirebaseFunctionsException`.
18. **Non-receipt image**: Gemini returns a polite "couldn't identify" message; no `[TRANSACTION_DATA]` emitted.
