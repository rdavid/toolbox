# SPDX-FileCopyrightText: 2026 David Rabkin
# SPDX-License-Identifier: 0BSD

# AGENTS

Purpose: concise operating notes for humans and automation working in this repository.

## Project
- Name: `toolbox`
- Language: POSIX shell (`#!/bin/sh`) scripts in `app/`
- Build and lint entrypoint: `redo lint` (via `all.do` / `lint.do`)

## Repo Layout
- `app/`: executable utilities
- `cfg/`: configuration files used by scripts
- `*.do`: `redo` build/lint tasks
- `README.adoc`: user-facing docs

## Conventions
- Keep scripts POSIX-friendly for `sh`.
- Follow style that is compatible with `shellcheck` and `shfmt`.
- Preserve SPDX headers in edited files.
- Use Conventional Commits for commit subjects (for example: `fix: ...`,
  `style: ...`, `chore: ...`).
- Prefer minimal, focused commits.

## Common Commands
- Run lint: `redo lint`
- Run a shell syntax check on all apps:
  `for f in app/*; do sh -n "$f"; done`

## Safety
- Avoid destructive git/history operations unless explicitly requested.
- Do not rewrite unrelated files.
