# Repository Guidelines

`toolbox` is a collection of POSIX Unix shell utilities for everyday use.
Each utility is a `#!/bin/sh` script built on the external Shellbase
framework.
The scripts source its `base.sh` for shared helpers such as `cmd_exists`,
`map_get`/`map_put`, logging, and argument handling.

Read the shared rules at
https://raw.githubusercontent.com/rdavid/prompt/master/README.txt
before starting any task, unless they are already loaded.

## Project Structure & Module Organization

- `app/` holds the executable utilities, one script per tool, for example
  `bak`, `ival`, `myip`, and `sift`.
- `cfg/` holds the configuration files these utilities consume.
- `all.do`, `clean.do`, and `lint.do` are the `redo` build and lint tasks.
- `README.adoc` is the user-facing documentation.
- `.github/workflows/` and `.github/styles/` hold the CI and lint
  configuration.
- `.redo/` is build metadata for `redo`.
  Do not edit it by hand.

The scripts expect Shellbase's `base.sh` on `PATH`.
Install it with `brew install rdavid/tap/shellbase`.

## Build, Test, and Development Commands

The project uses `redo` (or `goredo`) as its task runner.

- `redo all`: run the default target, which runs `lint`.
- `redo lint`: run every installed linter and skip the missing ones.
  The set includes `actionlint`, `checkbashisms`, `conform`, `dash`,
  `mksh`, `gitleaks`, `reuse`, `shellcheck`, `shfmt`, `typos`, `vale`,
  `yamllint`, and `zizmor`.
- `redo clean`: remove generated files.

Check the syntax of all apps quickly with
`for f in app/*; do sh -n "$f"; done`.
The project has no test suite, so `redo lint` is the verification step.

## Coding Style & Naming Conventions

After the header and description comment, each script declares
`readonly BASE_APP_VERSION=0.9.YYYYMMDD` and sources `. base.sh`.
Declare local variables with `local`, which most POSIX shells support.
Silence the matching shellcheck warnings as the existing apps do.
Match the layout of a similar app when adding a new utility.

## Commit & Pull Request Guidelines

Name the changed app as the scope, as in `feat(sift): ...`.
Use `style(lint): ...` for lint-only fixes.
The `conform` linter checks the latest commit message.
