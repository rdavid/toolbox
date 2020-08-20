#!/bin/sh -e
# vi:ts=2 sw=2 tw=79 et lbr wrap
# Copyright 2020-current David Rabkin
# It watches Wi-Fi ESSID change and report.

IAM=$(basename -- "$0")
NME="${IAM%.*}"
LOG="/tmp/$NME-log"
LCK="/tmp/$NME-lck"
OLD="/tmp/$NME-old"
CUR="/tmp/$NME-cur"

log() {
  date +"%Y%m%d-%H:%M:%S $*" | tee -a "$LOG"
}

list() {
  iwlist wlan0 s | grep ESSID | tr -s ' ' | cut -d':' -f2 > "$CUR"
}

copy() {
  cp -f "$CUR" "$OLD"
}

wait() {
  sleep 5
}

comp() {
  out='ESSID list is'
  changed=$(diff -y --suppress-common-lines "$CUR" "$OLD" | wc -l)
  if [ "$changed" -ne '0' ]; then
    out="$out changed on $changed. Alert!"
  else
    out="$out not changed."
  fi
  log "$out"
}

# Entry point.

# Run as root only.
if [ "$(id -u)" -ne '0' ] ; then
  echo "$NME must be executed with root privileges."
  exit 0
fi

# Prevents multiple instances.
if [ -e "$LCK" ] && kill -0 "$(cat "$LCK")"; then
  log "$NME is already running."
  exit 0
fi

# Makes sure the temporary files are removed when the script exits.
# shellcheck disable=SC2064
trap "rm -f /tmp/$NME-*" INT TERM EXIT
echo $$ > "$LCK"
log "$NME says hi."
list
while true; do
  wait
  copy
  list
  comp
done
log "$NME says bye."
