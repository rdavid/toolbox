#!/bin/sh -eu
# vi:ts=2 sw=2 tw=79 et lbr wrap
# Copyright 2020 by David Rabkin
# Validates image files.

# shellcheck source=../../shellbase/inc/base
. "$(dirname "$(realpath "$0")")/../shellbase/inc/base"
validate 'convert'
[ "$#" -eq 1 ] || die "Usage: $BASE_IAM DIRECTORY"
[ -r "$1" ] || die "Unable to read $1."
find "$1" -type f \
  \( -name \*.jpg -o -name \*.nef -o -name \*.raf -o -name \*.heic \) |
  while read -r img; do
    convert "$img" null >/dev/null 2>&1 || loge "File is corrupted: $img."
  done
exit 0
