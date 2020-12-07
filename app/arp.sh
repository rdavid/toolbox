#!/bin/sh -eu
# vi:ts=2 sw=2 tw=79 et lbr wrap
# Copyright 2020-current David Rabkin
# Detects if a device with a certain MAC address is in the local network.

# shellcheck source=./base
. "$(dirname "$(realpath "$0")")/base"

find() {
  line=$(arp-scan --localnet | grep "$1") || :
  if [ -n "$line" ]; then
    #shellcheck disable=SC2039
    name="${line:33}";
    #shellcheck disable=SC2039
    addr="${line::15}"
    addr=$(echo "$addr" | xargs)
    log "Master $name $addr is home!"
  else
    log "Master $1 is not home."
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
[ "$#" -eq 1 ] || die "Usage: $BASE_IAM MAC-ADDRESS"
is_mac "$1"
while :; do
  find "$1"
  wait
done
exit 0
