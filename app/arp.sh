#!/bin/sh -eu
# vi:ts=2 sw=2 tw=79 et lbr wrap
# Copyright 2020 by David Rabkin
# Detects if a device with a certain MAC address is in the local network.

# shellcheck source=../../shellbase/inc/base
. "$(dirname "$(realpath "$0")")/../shellbase/inc/base"
MINV=1
MAXV=10
MIDL=$(((MAXV-MINV+1)/2))
CNTR=$MIDL
NAME=''
ADDR=''
SCAN='arp-scan --localnet --interface=wlan0'

scan() {
  line=$($SCAN | grep "$MACA" | head -1) || :
  if [ -n "$line" ]; then
    [ -z "$NAME" ] && NAME=$(printf '%s' "$line" | cut -f1)
    [ -z "$ADDR" ] && ADDR=$(printf '%s' "$line" | cut -f3 | xargs -0)
    # Each success has much more value than a failure.
    CNTR=$MAXV
  else
    if [ $CNTR -ne $MINV ]; then
      CNTR=$((CNTR-1))
    fi
  fi
}

report() {
  if [ $CNTR -gt $MIDL ]; then
    log "Master $NAME $ADDR is home: $CNTR!"
  else
    log "Master $MACA is not home: $CNTR."
  fi
}

wait() {
  sleep 1
}

is_mac() {
  echo "$1" | \
    grep -E '^([0-9a-f]{2}:){5}[0-9a-f]{2}$' 1>/dev/null || \
    die "MAC address $1 is invalid."
}

be_root
validate 'arp-scan'
[ "$#" -eq 1 ] || die "Usage: $BASE_IAM [MAC-ADDRESS:list]"
[ "$1" = 'list' ] && ($SCAN; exit 0)
is_mac "$1"
MACA="$1"
while :; do
  scan
  report
  wait
done
exit 0
