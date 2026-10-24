# SPDX-FileCopyrightText: 2026 David Rabkin
# SPDX-License-Identifier: 0BSD

# Repository Guidelines

`toolbox` is a collection of POSIX Unix shell utilities for everyday use. Each
utility is a `#!/bin/sh` script built on the external Shellbase framework
(`base.sh`), which the scripts source for shared helpers such as `cmd_exists`,
`map_get`/`map_put`, logging, and argument handling.

Read the shared rules at
https://raw.githubusercontent.com/rdavid/prompt/master/README.txt
before starting any task, unless they are already loaded.

## Project Structure & Module Organization

`app/` holds the executable utilities shipped by this repository (for example
`install`, `ival`, `myip`, `sift`). `cfg/` holds configuration files consumed
by those scripts. `*.do` files (`all.do`, `clean.do`, `lint.do`) are the
`redo` build/lint tasks. `README.adoc` is the user-facing documentation. CI
and lint configuration lives in `.github/workflows/` and `.github/styles/`.
Treat `.redo/` as build metadata for the `redo` workflow, not hand-edited
source. The scripts expect Shellbase's `base.sh` on `PATH`. Install it with
`brew install rdavid/tap/shellbase`.

## Build, Test, and Development Commands

This project uses `redo` (or `goredo`) as the task runner.

- `redo all`: run the default build target (runs `lint`).
- `redo lint`: run `actionlint`, `shellcheck`, `shfmt`, `reuse`, `typos`,
  `vale`, and `yamllint`.
- `redo clean`: remove generated files.

A quick syntax check across all apps:
`for f in app/*; do sh -n "$f"; done`.

## Coding Style & Naming Conventions

Use 2-space indentation and no tabs. Each script opens with a fixed header:
the `#!/bin/sh` shebang, the `# vi: lbr noet sw=2 ts=2 tw=79 wrap` modeline,
the two SPDX lines, a short description comment, then
`readonly BASE_APP_VERSION=0.9.YYYYMMDD` and `. base.sh`. Match this layout
when adding a new utility.

## Commit & Pull Request Guidelines

Before committing, update `BASE_APP_VERSION` in every changed app file that
declares it and the `SPDX-FileCopyrightText` year in every changed file.
Favor commit scopes such as `feat(sift): ...` and `style(lint): ...`. Pull
requests confirm the relevant `redo lint` results.
