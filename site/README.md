# Financo — landing site

A tiny static page presenting the app and linking to the live web app, the
Android APK, and the GitHub repo.
Stack: **Vite + Tailwind v4** (no framework). One page, no backend. Design tokens
mirror the app's light palette (`lib/app/theme/app_colors.dart`).

Standalone (not in the repo's Flutter build):

```bash
pnpm install   # run inside site/
pnpm dev       # local preview
pnpm build     # static output → dist/
```

Deploys to **GitHub Pages** together with the app via the repo's deploy workflow:
the landing page is served at the Pages root (`/financo/`) and the Flutter web
app one level down (`/financo/app/`). The "Abrir o app" links point at `./app/`
and the Android button at `./financo.apk`.
