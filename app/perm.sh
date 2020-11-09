#!/bin/sh -eu
# vi:ts=2 sw=2 tw=79 et lbr wrap
# Copyright 2019-present David Rabkin
# Sets owner to foobar user, set right permitions for files and directories.

# shellcheck source=./base
. "$(dirname "$(realpath "$0")")/base"
be_root
if [ "$#" -ne 1 ] || ! [ -d "$1" ] || ! [ -w "$1" ]; then
  die "Usage: $BASE_IAM DIRECTORY"
fi
yes_to_continue
chown -R foobar "$1"
find "$1" -type d -exec chmod 755 {} \;
find "$1" -type f -exec chmod 644 {} \;
exit 0
