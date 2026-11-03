# Guidelines

`toolbox` is a collection of POSIX Unix shell utilities for everyday use.
Each utility is a `#!/bin/sh` script built on the external Shellbase
framework.
Every script sources the framework's `base.sh` for shared helpers such as
`cmd_exists`, `cmd_run`, `map_get`/`map_put`, logging, and argument handling.
Read the shared rules at
https://raw.githubusercontent.com/rdavid/prompt/master/README.txt
before starting any task, unless they are already loaded.

## Structure

`app/` holds the executable utilities, one script per tool, for example
`bak`, `ival`, `myip`, and `sift`.
`cfg/` holds the configuration files these utilities consume.
`README.adoc` is the user-facing documentation.
CI and lint configuration lives in `.github/workflows/` and
`.github/styles/`.
Build targets live in `all.do`, `clean.do`, and `lint.do`, which `redo`
executes directly.
Treat `.redo/` as build metadata, not as source to edit by hand.
The scripts expect Shellbase's `base.sh` on `PATH`.
Install Shellbase with `brew install rdavid/tap/shellbase`.

## Build

This project uses `redo` (or `goredo`) as the primary task runner.

- `redo all`: run the default target, which runs `lint`.
- `redo lint`: run every installed linter and skip the missing ones.
  The set includes `actionlint`, `checkbashisms`, `conform`, `dash`,
  `mksh`, `gitleaks`, `reuse`, `shellcheck`, `shfmt`, `typos`, `vale`,
  `yamllint`, and `zizmor`.
- `redo clean`: remove generated files.

Check the syntax of every app quickly with
`for f in app/*; do sh -n "$f"; done`.

## Style

Each script starts with the shared header and a description comment.
It then declares `readonly BASE_APP_VERSION=0.9.YYYYMMDD` and sources
`. base.sh`.
Use tab indentation, as the existing apps do.
Declare local variables with `local`, which most POSIX shells support.
Limit local variable names in functions to three letters, for example `fle`,
`sze`, or `dst`.
Keep script-level variables capitalized, for example `SRC` or `TGT`.
Run external commands through `cmd_run`, which logs each command and its
failures.
Use a plain call only where `cmd_run` cannot fit, such as in pipes and
command substitutions.
Silence shellcheck warnings the way the existing apps do.
Match the layout of a similar app when adding a new utility.

## Testing

The project has no test suite, so `redo lint` is the verification step.
Run it and the syntax check above after every change to an app.
Do this before committing.
