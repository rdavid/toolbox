#!/bin/sh -eu
# vi:ts=2 sw=2 tw=79 et lbr wrap
# Copyright 2016 by David Rabkin
# Makes incremental backups from the first parameter to the second.

# shellcheck source=./base
. "$(dirname "$(realpath "$0")")/base"
validate 'rdiff-backup'
[ "$#" -eq 2 ] || die "Usage: $BASE_IAM [source] [destination]"
[ -r "$1" ] || die "Unable to read from source $1."
[ -w "$2" ] || die "Unable to write to destination $2."
rdiff-backup \
  --print-statistics \
  --terminal-verbosity 4 \
  --preserve-numerical-ids \
  --force \
  "$1" "$2" \
  2>&1 | tee -a "$BASE_LOG"
exit 0
