#!/bin/sh -e
# vi:ts=2 sw=2 tw=79 et lbr wrap
# Copyright 2016-current David Rabkin
# bak.sh <arc|box>

IAM=$(basename -- "$0")
IAM="${IAM%.*}"
LOG="/tmp/$IAM-log"
LCK="/tmp/$IAM-lck"
SRC="/home/david/nas-$1/"
DST="/media/usb-bak/bak-$1"

log() {
  date +"%Y%m%d-%H:%M:%S $*" | tee -a "$LOG"
}

if [ ! -d "$SRC" ]; then
  log "There is no source directory $SRC."
  exit 1
fi

if [ ! -d "$DST" ]; then
  log "There is no destination directory $DST."
  exit 1
fi

# Prevents multiple instances.
if [ -e "$LCK" ] && kill -0 "$(cat "$LCK")"; then
  log "$IAM is already running."
  exit 1
fi

# Makes sure the lockfile is removed when we exit and then claim it.
# shellcheck disable=SC2064
trap "rm -f $LCK" INT TERM EXIT
echo $$ > "$LCK"
log "$IAM says hi, $SRC->$DST."
rdiff-backup --print-statistics \
             --terminal-verbosity 4 \
             --preserve-numerical-ids \
             --force \
             "$SRC" "$DST" \
             2>&1 | tee -a "$LOG"
log "$IAM says bye, $SRC->$DST."
exit 0
