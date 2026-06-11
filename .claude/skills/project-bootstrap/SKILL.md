---
name: project-bootstrap
description: >-
  Documentation-first kickoff for a NEW project. Takes the path of a reference
  project (one with a strong CLAUDE.md and a Docs/ folder full of specs),
  learns its conventions and document templates, then sets up the current
  project the same way: merges the reference's good parts into the current
  CLAUDE.md, scaffolds a Docs/ folder of specs, and writes a roadmap (done /
  in progress / planned). Goal is solid structured docs BEFORE any code. Use
  when the user says "estou começando um projeto", "iniciar/novo projeto",
  "bootstrap the project docs", "estruturar a documentação", "aproveitar o
  CLAUDE.md de outro projeto", "criar specs e roadmap", or invokes
  /project-bootstrap. The reference project path is passed every time.
---

# Project Bootstrap (docs-first)

Set up a **new project's documentation** by learning from a **reference
project** the user already trusts. The deliverable is documentation, not code:
a strong `CLAUDE.md`, a `Docs/` folder of specs, and a roadmap. **Write no
application code** in this skill — stop after the docs and let the user review.

Reply in the user's language. Match the **reference project's** language and
conventions in every file you generate (if its docs are in Portuguese, write
Portuguese; if English, English).

**Style rule:** never use em-dashes (`—`) in any generated doc. Use commas,
parentheses, or two sentences. This is a standing user preference.

## Core principle: transfer structure, not stack

The reference is a template for **structure, rules, organization, and good
practices** — not for a language or tech stack. It is often in a **different
programming language** than the new project (e.g. the reference is Flutter, the
new project is a TypeScript API or a Rust CLI). That is expected and fine — the
value is language-agnostic.

**Transfer the meta-level:**
- How docs are organized (e.g. `docs/specs/`, one spec per feature, the naming
  convention).
- Which **rule categories** the reference's CLAUDE.md defines (code style,
  comments policy, testing rules, post-change checklist, spec-driven workflow,
  quality bar, dependencies). Keep the categories; **translate their contents**
  to the new project's stack.
- The overall rigor and documentation philosophy.

**Do not carry over stack-specific content** unless the new project genuinely
uses it: framework and library names, databases, build/test commands, tooling,
language idioms. For each stack-bound rule, find the new project's **equivalent**:
reference "Post-Change Checklist: `flutter analyze` + `flutter test`" becomes the
new project's own lint + test commands; reference "State Management: Riverpod"
becomes the new stack's solution, or is dropped if it doesn't apply.

## 0. Inputs and guardrails

- **Reference project path** is **required and passed every time**. If the user
  didn't give it, ask for the absolute path before doing anything else.
- **Current working directory = the new (target) project.** Everything you
  create or merge lands here, never in the reference project.
- **Doc-first:** do not scaffold source code, install deps, or run builds. Only
  produce/merge docs. Offer to start code **after** the user approves the docs.
- Read-only on the reference project. Treat it as a template, not a place to edit.

## 1. Validate the reference

Confirm the reference path exists and inspect what it actually has:

- A `CLAUDE.md` (or `AGENTS.md`) at its root.
- A docs folder (`Docs/`, `docs/`, or similar) and how it is organized.
- Whether it already keeps a roadmap (e.g. `Docs/roadmap.md`, `ROADMAP.md`).

If a piece is missing, say so and fall back to sensible defaults instead of
failing. Note the **exact casing** the reference uses (`Docs/` vs `docs/`) and
reuse it for the new project so both match.

## 2. Analyze the reference (build a template model)

Read the reference's docs and extract the **reusable shape**, not the content:

- **CLAUDE.md** — its section layout and which parts are *general* (code style,
  commit/test rules, project structure conventions, run/build commands, quality
  bar, workflow rules) versus *project-specific* (its domain, file paths,
  feature names, stack). Only the general parts transfer; the specific parts are
  examples of *how* to write the new project's own.
- **Docs/ layout** — folder structure (a `specs/` subfolder? flat files?), file
  naming convention (e.g. `001-feature.md`, `feature-name.md`), and the
  **internal structure of one spec** (typical sections: Overview, Goals,
  Non-goals, Design, Data model, API, Open questions, etc.). This becomes your
  spec template.
- **Roadmap** — if present, mirror its format. If not, you'll use the default in
  step 7.

## 3. Analyze the new project (current dir)

Build a model of what the target project already is:

- Existing `CLAUDE.md` / `README.md` / any notes — keep every true fact in them.
- Manifests to detect the stack: `package.json`, `Cargo.toml`, `pyproject.toml`,
  `go.mod`, `pubspec.yaml`, `*.csproj`, etc. A repo may have several.
- Existing source layout, if any, to infer domain and architecture.
- `git log --oneline -20` and `git status` if it's a git repo, for direction and
  what's in flight (feeds the roadmap's "in progress").

## 4. Interview for the gaps

Whatever you could **not** infer from step 3, ask the user. Batch the questions
(use the question tool). Cover only what's missing, typically:

- **Purpose / problem** the project solves, and target users.
- **Core features** to spec (each meaningful one becomes a spec file).
- **Current status:** what is already done, what is being worked on right now.
- **Near-term milestones** and rough priority/order.
- Any **fixed tech decisions** (framework, DB, hosting) not visible in manifests.

Don't ask what the code already answers. Keep it to the few real unknowns.

## 5. CLAUDE.md — merge the reference, adapt to here

Produce the new project's `CLAUDE.md` by **merging**:

1. Start from the new project's true facts (stack, real paths, domain from steps
   3 and 4). These are authoritative; never overwrite a correct fact with the
   reference's.
2. Graft the reference's **general** sections and overall structure (style rules,
   commit/test conventions, run commands layout, quality bar, workflow). Rewrite
   them for this project's stack and wording, not copy-paste.
3. If the new project already had a `CLAUDE.md`, preserve its good content and
   only add/upgrade what the reference does better. Show what changed.

The result should read like it was written for *this* project, with the
reference's rigor.

## 6. Scaffold Docs/ and the specs

Recreate the reference's docs shape in the new project:

- Create the docs folder with the **same casing and layout** as the reference
  (e.g. `Docs/specs/`).
- For each core feature/area from step 4, write a spec file using the **template
  learned in step 2** (same sections, same naming convention). Fill what's known
  from analysis + interview; mark genuine unknowns explicitly as
  `TODO:` / open questions rather than inventing detail.
- Keep specs focused: one feature/area per file. A short index (e.g.
  `Docs/specs/README.md`) listing them helps if the reference has one.

## 7. Roadmap

Create the roadmap in the docs folder (mirror the reference's filename/location
if it has one, else `Docs/roadmap.md`). Three states, in the project's language:

- **Done** — already shipped/implemented (from git history + interview).
- **In progress** — being worked on now.
- **Planned** — next, ordered by priority, tied to the specs from step 6.

Use **absolute dates** (today is available in context), never "next week"/"in 2
days". Keep each item one line linking to its spec where relevant.

## 8. Review, then offer to start

Summarize what you created/changed as a short file list:

```
CLAUDE.md            merged: +<n> sections from reference, kept <m> existing
Docs/specs/...       <k> spec files (x filled, y TODO)
Docs/roadmap.md      done <a> / in progress <b> / planned <c>
```

Then **stop and ask** before any code. Offer to: (a) adjust any generated doc,
(b) deepen a specific spec, or (c) once docs are approved, start implementing the
first roadmap item. Do **not** begin coding until the user approves the docs.
