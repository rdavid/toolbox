# SPDX-FileCopyrightText: 2026 David Rabkin
# SPDX-License-Identifier: 0BSD

# AGENTS

Purpose: quick operating notes for humans and automation working in this repo.

## Project
- Name: `toolbox`
- Language: POSIX shell (`#!/bin/sh`) scripts in `app/`
- Build/lint entrypoint: `redo lint` (via `all.do` / `lint.do`)

## Repo Layout
- `app/`: executable utilities
- `cfg/`: configuration files used by scripts
- `*.do`: `redo` build/lint tasks
- `README.adoc`: user-facing docs

## Conventions
- Keep scripts POSIX-friendly for `sh`.
- Use `shellcheck` + `shfmt` compatible style.
- Preserve SPDX headers in edited files.
- Use Conventional Commits for commit subjects (for example: `fix: ...`,
  `style: ...`, `chore: ...`).
- Prefer minimal, focused commits.

## Common Commands
- Run lint: `redo lint`
- Run shell syntax check on all apps:
  `for f in app/*; do sh -n "$f"; done`

## Safety
- Avoid destructive git/history operations unless explicitly requested.
- Do not rewrite unrelated files.
