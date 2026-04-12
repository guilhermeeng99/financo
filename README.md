# Financo

Personal finance manager with AI-powered data entry (Gemini).

## Features

- Dashboard with financial summary by period
- Account management (checking and credit card)
- Transaction tracking with categories
- Cumulative balance per account
- Global month/year filter
- AI chat to create transactions, accounts and categories via natural language
- Reports with category breakdown and monthly evolution charts
- Firebase sync (Firestore + Auth)
- Local SQLite cache via Drift
- Google Sign-In support

## Stack

- **Flutter** 3.x (Android, iOS, Web)
- **Firebase** — Auth + Firestore
- **Drift** — local SQLite cache
- **flutter_bloc** — state management
- **get_it** — dependency injection
- **go_router** — declarative routing
- **Gemini API** — generative AI for data entry
- **slang** — type-safe i18n

## Running locally

```bash
flutter pub get
dart run build_runner build --delete-conflicting-outputs
dart run slang
flutter run
```

## Environment variables

Pass via `--dart-define` when running or building:

| Variable | Description |
|---|---|
| `GEMINI_API_KEY` | Google AI Studio API key |
| `GOOGLE_WEB_CLIENT_ID` | OAuth 2.0 Web Client ID for Google Sign-In |

## Web deploy

Deploy to GitHub Pages is automated via GitHub Actions on every push to `main`.
