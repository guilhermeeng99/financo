# Chat Feature Spec

AI-powered financial assistant using Google Gemini. Users interact via natural language to create transactions, accounts, and categories.

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

Factories: `fromFirestore(DocumentSnapshot)`, `fromEntity(ChatMessageEntity)`, `toJson()`.

## Datasources

### GeminiDataSource (abstract)

```
sendMessage(userId, content, history) → Future<ChatMessageModel>
```

### GeminiDataSourceImpl

- **Model**: `gemini-2.5-flash` via `google_generative_ai`.
- **History construction**: system prompt → model ack → date injection → model ack → previous messages (alternating user/model roles).
- **Action extraction**: regex patterns extract metadata from response:
  - `[TRANSACTION_DATA]...[/TRANSACTION_DATA]` → `actionType: 'transaction'`
  - `[ACCOUNT_ACTION]...[/ACCOUNT_ACTION]` → `actionType: 'account'`
  - `[CATEGORY_ACTION]...[/CATEGORY_ACTION]` → `actionType: 'category'`
- JSON parse failures are silently caught — metadata stays null.
- Action blocks are stripped from display text via regex with backreference.
- All exceptions caught, logged, rethrown as `AiException`.

### ChatRemoteDataSource (abstract)

```
getChatHistory(userId) → Future<List<ChatMessageModel>>
saveChatMessage(ChatMessageModel) → Future<void>
```

### ChatRemoteDataSourceImpl

- Firestore collection: `chat_messages`.
- `getChatHistory`: query by userId, ordered by createdAt ascending.
- `saveChatMessage`: set doc by message.id.
- All exceptions caught, rethrown as `ServerException`.

## Repository: ChatRepository

| Method | Parameters | Return | Notes |
|--------|-----------|--------|-------|
| sendMessage | userId, content, history | `Either<Failure, ChatMessageEntity>` | Gemini call + auto-persist response |
| getChatHistory | userId | `Either<Failure, List<ChatMessageEntity>>` | From Firestore |
| saveChatMessage | ChatMessageEntity | `Either<Failure, void>` | Converts to model, persists |

### Error mapping

| Exception | Failure |
|-----------|---------|
| AiException | AiFailure |
| ServerException | ServerFailure |

### Business rules

1. `sendMessage` calls Gemini, then auto-persists the response to Firestore. If Gemini succeeds but persist fails, the ServerException is returned as failure (response lost).
2. `saveChatMessage` converts entity to model via `ChatMessageModel.fromEntity` before persisting.

## Use Cases

Three thin delegators:
- `SendMessageUseCase.call(userId, content, history)` → `repository.sendMessage(...)`
- `GetChatHistoryUseCase.call(userId)` → `repository.getChatHistory(...)`
- `SaveChatMessageUseCase.call(message)` → `repository.saveChatMessage(...)`

## ChatBloc State Machine

### Events

| Event | Fields | Trigger |
|-------|--------|---------|
| ChatLoadRequested | — | Page init |
| ChatMessageSent | content: String | User sends message |
| ChatActionConfirmed | metadata: Map<String,dynamic> | User taps Confirm button |

### States

| State | Fields | Notes |
|-------|--------|-------|
| ChatInitial | — | Before load |
| ChatLoading | — | Loading history |
| ChatLoaded | messages, isTyping, shouldRefreshTransactions | Main state |
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
2. Route to handler: `account` | `category` | `transaction` | default → "Unknown action type."
3. Create assistant message with result text
4. Add to list, persist (non-blocking — failure swallowed)
5. Emit `ChatLoaded(shouldRefreshTransactions: actionType == 'transaction')`

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
- Defaults: icon 58332, color 4280391411
- Call `createCategory` → success/failure message

**Category delete:**
- Lookup by name (case-insensitive) via `getCategories`
- Call `deleteCategory` or return "not found"

**Transaction create:**
1. Parse type, amount (validate > 0), description, date (ISO 8601 or now)
2. Resolve category by name (case-insensitive) — "not found" if missing
3. Resolve account by name (case-insensitive) — fallback to first account if no match
4. Call `createTransaction` → success message with description + formatted amount

## Edge Cases

1. **Empty history**: first message sends empty history list — valid.
2. **Null response text**: defaults to "Sorry, I could not process that."
3. **Malformed action JSON**: silently caught, metadata stays null, no Confirm button shown.
4. **Unknown action type**: returns "Unknown action type." as assistant message.
5. **Quota/rate limit**: detected by checking failure message for "quota" or "rate" keywords.
6. **Multiple action blocks**: only first match per type is extracted; if multiple types present, last one wins (category overwrites account).
7. **User message persist failure**: non-blocking, continues with AI call.
8. **Action confirm save failure**: non-blocking (post Bug 2 fix), state still emitted.
9. **Category not found for transaction**: returns descriptive error asking user to create first.
10. **No accounts for transaction**: returns "No accounts found. Please create an account first."
