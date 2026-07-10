# SPDX-FileCopyrightText: 2026 David Rabkin
# SPDX-License-Identifier: 0BSD

# Repository Guidelines

`toolbox` is a collection of POSIX Unix shell utilities for everyday use. Each
utility is a `#!/bin/sh` script built on the external Shellbase framework
(`base.sh`), which the scripts source for shared helpers such as `cmd_exists`,
`map_get`/`map_put`, logging, and argument handling.

## Project Structure & Module Organization

`app/` holds the executable utilities shipped by this repository (for example
`install`, `ival`, `myip`, `sift`). `cfg/` holds configuration files consumed
by those scripts. `*.do` files (`all.do`, `clean.do`, `lint.do`) are the
`redo` build/lint tasks. `README.adoc` is the user-facing documentation. CI
and lint configuration lives in `.github/workflows/` and `.github/styles/`.
Treat `.redo/` as build metadata for the `redo` workflow, not hand-edited
source. The scripts expect Shellbase's `base.sh` on `PATH`, typically at
`/usr/local/bin/base.sh`.

## Build, Test, and Development Commands

This project uses `redo` (or `goredo`) as the task runner.

- `redo all`: run the default build target (runs `lint`).
- `redo lint`: run `actionlint`, `shellcheck`, `shfmt`, `reuse`, `typos`,
  `vale`, and `yamllint`.
- `redo clean`: remove generated files.

A quick syntax check across all apps:
`for f in app/*; do sh -n "$f"; done`.

## Coding Style & Naming Conventions

Write shell as portable `sh` first. Keep Bash-specific features out unless the
file already depends on them. Use 2-space indentation, no tabs, and an
approximately 79-character text width. Write comments in third-person
singular and start every comment with a capital letter. Do not place comments
inside function bodies; keep all of a function's commentary in the single
comment block immediately above its name.

Each script opens with a fixed header: the `#!/bin/sh` shebang, the
`# vi: lbr noet sw=2 ts=2 tw=79 wrap` modeline, the two SPDX lines, a short
description comment, then `readonly BASE_APP_VERSION=0.9.YYYYMMDD` and
`. base.sh`. Match this layout when adding a new utility.

For `printf` format strings, stay with backslash-escape form (e.g.
`printf %s\\n`) only when it takes fewer source characters than the
single-quoted form (e.g. `printf '%s\n'`). When both forms are the same
length or the quoted form is shorter, prefer the quoted form for
readability.

Order function definitions with `main()` first (immediately after the
script-level setup), then the remaining functions in strict alphabetical
order by name.

## Commit & Pull Request Guidelines

Before committing, update `BASE_APP_VERSION` in every changed app file that
declares it (format `0.9.YYYYMMDD`, the date of the change) and the
`SPDX-FileCopyrightText` year in every changed file. Only when the file has a
substantive change — never bump the year or version by itself. If a refactor
pass ends up making no meaningful change to a file, revert the year/version
edit too; a metadata-only diff is noise.

Use Conventional Commits for all commits, especially scoped forms such as
`feat(sift): ...`, `style(lint): ...`, and `build(deps): ...`. Prefer concise,
imperative subjects with a meaningful scope when one exists. Do not add AI
attribution, tool signatures, generated-by trailers, or AI co-author metadata
to commits, pull requests, issues, or code comments. Pull requests should
explain the user-visible change, note any portability implications, and
confirm the relevant `redo lint` results. Link related issues when applicable;
UI screenshots are usually unnecessary for this repository.
