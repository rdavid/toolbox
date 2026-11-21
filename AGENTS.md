# Guidelines

`toolbox` is a collection of Unix shell utilities for backups, media,
networking, and everyday tasks.
Each utility is a POSIX `#!/bin/sh` script built on the external Shellbase
framework.
Every script sources the framework's `base.sh` for shared helpers such as
`cmd_exists`, `cmd_run`, `map_get`/`map_put`, logging, and argument handling.
Read the shared rules at
https://raw.githubusercontent.com/rdavid/prompt/master/README.txt
before starting any task, unless they are already loaded.

## Structure

`app/` holds the executable utilities, one script per tool, for example
`bak`, `ival`, `myip`, and `sift`.
`cfg/` holds the configuration files these utilities read.
`README.adoc` is the user-facing documentation.
CI and lint configuration lives in `.github/workflows/` and
`.github/styles/`.
Build targets live in `all.do`, `clean.do`, and `lint.do`, which `redo`
runs directly.
Treat `.redo/` as build metadata and never edit it by hand.
The scripts expect Shellbase's `base.sh` on `PATH`.
Install Shellbase with `brew install rdavid/tap/shellbase`.

## Build

This project uses `redo` (or `goredo`) as its task runner.

- `redo all`: run the default target, which runs `lint`.
- `redo lint`: run every installed linter and skip the missing ones.
  The set includes `actionlint`, `agent-rules-lint`, `checkbashisms`,
  `conform`, `dash`, `gitleaks`, `lychee`, `mksh`, `reuse`, `shellcheck`,
  `shfmt`, `tombi`, `typos`, `vale`, `yamllint`, and `zizmor`.
- `redo clean`: remove generated files.

## Style

After its header each script declares
`readonly BASE_APP_VERSION=0.9.YYYYMMDD` and runs `. base.sh`.
Declare function variables with `local`.
POSIX does not define it, but `dash`, `mksh`, and Bash support it.
Keep local variable names to one to three letters, for example `i`,
`ip`, or `fle`.
Capitalize script-level variables, for example `SRC` or `TGT`.
Run external commands through `cmd_run`, which logs each command and its
failures.
Call a command directly only where `cmd_run` cannot fit, such as in pipes
and command substitutions.

## Testing

The project has no test suite, so `redo lint` is the verification step.
