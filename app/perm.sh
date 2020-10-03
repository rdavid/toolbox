#!/bin/sh -eu
# vi:ts=2 sw=2 tw=79 et lbr wrap
# Copyright 2019-present David Rabkin
# Sets owner to foobar user, set right permitions for files and directories.

# shellcheck source=./base
. "$(dirname "$(realpath "$0")")/base"

be_root
if [ "$#" -ne 1 ] || ! [ -d "$1" ] || ! [ -w "$1" ]; then
  die "Usage: $IAM DIRECTORY"
fi
DIR=$1
printf 'Run %s, are you sure? [y/N] ' "$DIR"
keep=$(stty -g)
stty raw -echo; ans=$(head -c 1); stty "$keep"
printf '\n'
if ! printf '%s' "$ans" | grep -iq '^y'; then
  exit 0
fi
chown -R foobar "$DIR"
find "$DIR" -type d -exec chmod 755 {} \;
find "$DIR" -type f -exec chmod 644 {} \;
exit 0
