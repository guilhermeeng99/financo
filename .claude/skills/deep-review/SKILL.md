---
name: deep-review
description: >-
  Comprehensive, take-your-time code audit of the whole project. Covers four
  areas: documentation freshness, test health, code cleanliness (duplication /
  dead code / smells), and dependency status (outdated + security advisories +
  whether each upgrade is safe). Produces a severity-tagged report; fixes only
  on explicit request. Use when the user asks for a "big / deep / full / general
  code review", "audit the app", "review everything", "check that docs and tests
  are up to date", or "check if dependencies are updated and safe to update".
---

# Deep Review

A thorough, whole-project audit. The user has explicitly given you time — **be
exhaustive, not fast**. Default output is a **report**: find and explain
problems, do **not** edit code until the user approves a fix list (see step 6).

Reply in the user's language. Keep the report scannable.

## 0. Orient first (don't skip)

Before reviewing, build a model of the project:

1. Read `CLAUDE.md` / `AGENTS.md`, `README.md`, and anything in `docs/` — these
   define the project's own conventions, checklists, and quality bar. **Judge the
   code against the project's stated rules, not generic ones.**
2. Detect the stack(s) from manifests: `package.json`, `Cargo.toml`,
   `pyproject.toml` / `requirements.txt`, `go.mod`, `pom.xml` / `build.gradle`,
   `Gemfile`, `composer.json`, `*.csproj` / `*.sln`, `mix.exs`, `pubspec.yaml`,
   etc. **A repo often has several** (e.g. a Tauri app = Rust + JS) — review every
   one you find, don't assume a single language.
3. Note the build/test/lint commands the project documents — you'll run them.
4. `git log --oneline -20` and `git status` for recent direction and uncommitted work.

## 1. Fan out with subagents (parallel)

The four areas are independent. Launch them **concurrently** as subagents (one
message, multiple `Agent` calls) so the audit runs in parallel and keeps your
own context lean. Give each a tight brief and ask for a findings list, not prose.
Use read-only investigator agents for locating issues; reserve edits for step 6.

## 2. Documentation freshness

- Do README / docs / specs match what the code actually does now? Hunt for drift:
  renamed commands, removed features still documented, changed config/flags,
  stale setup steps, dead links, outdated screenshots/paths.
- Are there new modules / commands / public APIs with **no** docs?
- If the project keeps specs or a roadmap (e.g. `docs/specs/`, `docs/ROADMAP.md`),
  is each one in sync with its implementation? Flag spec-vs-code divergence.
- Code comments: stale "WHY" comments that now lie about the code.

## 3. Test health

- Do the tests **run and pass**? Run the project's test command. Quote failures
  verbatim.
- Coverage of the **important** logic — especially safety-/money-/auth-critical
  paths. Flag critical logic with **no** test (per the project's own rules if it
  states any).
- Tests that assert nothing, are skipped/`xfail`/commented out, or test
  implementation detail instead of behavior.
- Tests out of sync with current code (testing removed behavior, stale fixtures).

## 4. Code cleanliness

- **Duplication**: copy-pasted blocks, near-identical functions, logic that should
  be one helper. Point to each clone set by `file:line`.
- **Dead code**: unused exports, unreachable branches, commented-out code,
  unused deps/imports.
- **Smells vs. the project's style rules**: oversized functions/files, deep
  nesting, generic names the conventions forbid, missing error handling,
  `panic!`/`unwrap`/`as any` escape hatches, `Result`/error-shape violations.
- **Consistency**: same task done two different ways across the codebase.

## 5. Dependencies — outdated + safe to update

For **each** ecosystem present, do two passes:

**a) What's outdated** — run the right tool:

| Stack | Outdated | Security audit |
|---|---|---|
| Bun | `bun outdated` | `bun audit` |
| npm | `npm outdated` | `npm audit` |
| pnpm/yarn | `pnpm outdated` / `yarn outdated` | `pnpm audit` / `yarn npm audit` |
| Cargo (Rust) | `cargo outdated` | `cargo audit` |
| Python | `pip list --outdated` / `uv pip list --outdated` | `pip-audit` |
| Go | `go list -u -m all` | `govulncheck ./...` |
| Maven (Java) | `mvn versions:display-dependency-updates` | `mvn org.owasp:dependency-check-maven:check` |
| Gradle (Java/Kotlin) | `gradle dependencyUpdates` (ben-manes plugin) | `gradle dependencyCheckAnalyze` |
| Bundler (Ruby) | `bundle outdated` | `bundle audit` (bundler-audit) |
| Composer (PHP) | `composer outdated` | `composer audit` |
| .NET (C#) | `dotnet list package --outdated` | `dotnet list package --vulnerable` |
| Mix (Elixir) | `mix hex.outdated` | `mix deps.audit` |
| Pub (Dart/Flutter) | `dart pub outdated` / `flutter pub outdated` | `dart pub outdated` (shows advisories) |

This table is a starting set, not a whitelist — for any ecosystem not listed,
find its standard outdated + advisory tooling and use it. If a tool isn't
installed, say so and fall back to checking the registry + advisory DB via web
instead of guessing. Don't fabricate version numbers. **Run the dependency pass
once per ecosystem** in a polyglot repo (e.g. JS deps *and* Rust crates).

**b) Is the upgrade safe** — for each meaningful outdated dep, classify and judge:

- **Patch / minor** → usually safe; note it.
- **Major** → potential breaking change. Check the CHANGELOG / release notes /
  migration guide (fetch from web if needed), and whether it's a **direct** dep
  or transitive. Summarize what breaks and the migration effort.
- **Security advisory** (any severity) → flag as priority regardless of bump size;
  cite the advisory (CVE / RUSTSEC / GHSA id) and the fixed version.
- Watch for ecosystem traps: peer-dep conflicts, lockfile pinning, a bump that
  forces a toolchain/runtime upgrade.

Output a table: `dep · current → latest · bump type · safe? · note/advisory`.

## 6. Report, then offer to fix

Single consolidated report, grouped by the four areas, each finding one line:

```
path:line  <emoji> <severity>: <problem>. <suggested fix>.
```

Severity: 🔴 critical · 🟠 high · 🟡 medium · 🔵 low/nit. No praise padding, no
scope creep. End with a short **prioritized** action list (what to fix first).

Then **ask** before changing anything: offer to (a) apply safe fixes, (b) do the
safe dependency bumps and run the project's verification (tests + build + lint),
and/or (c) open issues/TODOs for the bigger items. Do the project's full
post-change checklist after any fix you're approved to make.
