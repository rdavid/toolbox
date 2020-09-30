#!/bin/sh -e
# vi:ts=2 sw=2 tw=79 et lbr wrap
# Copyright 2016-current David Rabkin
# bak.sh <arc|box>

# shellcheck source=./base
. "$(dirname "$0")/base"
SRC="/home/david/nas-$1/"
DST="/media/usb-bak/bak-$1"

be_root
validate 'rdiff-backup'
[ -d "$SRC" ] || die "There is no source directory $SRC."
[ -d "$DST" ] || die "There is no destination directory $DST."
rdiff-backup --print-statistics \
             --terminal-verbosity 4 \
             --preserve-numerical-ids \
             --force \
             "$SRC" "$DST" \
             2>&1 | tee -a "$LOG"
exit 0
