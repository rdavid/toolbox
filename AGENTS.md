# SPDX-FileCopyrightText: 2026 David Rabkin
# SPDX-License-Identifier: 0BSD

# Repository Guidelines

`toolbox` is a collection of POSIX Unix shell utilities for everyday use. Each
utility is a `#!/bin/sh` script built on the external Shellbase framework.
The scripts source its `base.sh` for shared helpers such as `cmd_exists`,
`map_get`/`map_put`, logging, and argument handling.

Read the shared rules at
https://raw.githubusercontent.com/rdavid/prompt/master/README.txt
before starting any task, unless they are already loaded.

## Project Structure & Module Organization

- `app/` holds the executable utilities, for example `install`, `ival`,
  `myip`, and `sift`.
- `cfg/` holds the configuration files these utilities consume.
- `all.do`, `clean.do`, and `lint.do` are the `redo` build and lint tasks.
- `README.adoc` is the user-facing documentation.
- `.github/workflows/` and `.github/styles/` hold the CI and lint
  configuration.
- `.redo/` is build metadata for `redo`. Do not edit it by hand.

The scripts expect Shellbase's `base.sh` on `PATH`. Install it with
`brew install rdavid/tap/shellbase`.

## Build, Test, and Development Commands

The project uses `redo` (or `goredo`) as its task runner.

- `redo all`: run the default target, which runs `lint`.
- `redo lint`: run `actionlint`, `shellcheck`, `shfmt`, `reuse`, `typos`,
  `vale`, and `yamllint`.
- `redo clean`: remove generated files.

Check the syntax of all apps quickly with
`for f in app/*; do sh -n "$f"; done`.

## Coding Style & Naming Conventions

Indent with tabs that display two columns wide, as the modeline sets. Each
script opens with a fixed header:

1. The `#!/bin/sh` shebang.
2. The `# vi: lbr noet sw=2 ts=2 tw=79 wrap` modeline.
3. The two SPDX lines.
4. A short description comment.
5. `readonly BASE_APP_VERSION=0.9.YYYYMMDD` and `. base.sh`.

Match this layout when adding a new utility.

## Commit & Pull Request Guidelines

Before committing, update `BASE_APP_VERSION` in every changed app file that
declares it. Also update the `SPDX-FileCopyrightText` year in every changed
file. Favor commit scopes such as `feat(sift): ...` and `style(lint): ...`.
In a pull request, confirm the relevant `redo lint` results.
