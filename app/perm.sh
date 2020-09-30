#!/bin/sh -e
# vi:ts=2 sw=2 tw=79 et lbr wrap
# Copyright 2019-present David Rabkin
# Sets owner to foobar user, set right permitions for files and directories.

# shellcheck source=./base
. "$(dirname "$0")/base"

if [ 0 -eq $# ]; then
  die 'perm.sh <directory name>'
fi
DIR=$1
if [ ! -d "$DIR" ]; then
  die "Directory $DIR does not exist."
fi
printf 'Run %s, are you sure? [y/N] ' "$DIR"
CFG=$(stty -g)
stty raw -echo; ans=$(head -c 1); stty "$CFG"
printf '\n'
if ! echo "$ans" | grep -iq "^y"; then
  exit 0
fi
chown -R foobar "$DIR"
find "$DIR" -type d -exec chmod 755 {} \;
find "$DIR" -type f -exec chmod 644 {} \;
