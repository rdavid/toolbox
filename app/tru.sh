#!/bin/sh -eu
# vi:ts=2 sw=2 tw=79 et lbr wrap
# Copyright 2020 by David Rabkin
# tru stands for Transmission Remote Updater. The script removes a torrent with
# content and than adds it again. It is usefull to automatically increase a
# ratio.

# shellcheck source=../../shellbase/inc/base
. "$(dirname "$(realpath "$0")")/../shellbase/inc/base"
AUT=''
CMD='transmission-remote'

# Looks for torrent ID by torrent file name.
tid() {
  # SC2086: Double quote to prevent globbing and word splitting.
  # shellcheck disable=SC2086
  $CMD "$SER" $AUT -l | grep "$FIL" | awk '{print $1}'
}

validate 'nc'
validate 'tr'
validate 'awk'
validate $CMD
[ "$#" -eq 3 ] || die "Usage: $BASE_IAM HOST:PORT [USR]:[PWD] TORRENT-FILE"

# Prepares host and port to be nc command parameters. Validates the first
# parameter host:port.
prm="$(printf '%s' "$1" | tr ':' ' ')"
# shellcheck disable=SC2086
nc -z $prm >/dev/null 2>&1 || die "$1 is not valid parameter for HOST:PORT."
SER="$1"

# Single ':' means there is no authentication data.
if [ "$2" != ':' ]; then
  AUT="--auth $2"
fi

# Validates third parameter full torrent file name.
[ -r "$3" ] || die "$3 is not valid parameter for a TORRENT-FILE."
TOR="$3"
FIL=$(basename -- "$TOR")
FIL="${FIL%.*}"

# Looks for torrent ID by torrent name extracted from torrent file name.
tid=$(tid)
if [ -n "$tid" ]; then
  # SC2086: Double quote to prevent globbing and word splitting.
  # shellcheck disable=SC2086
  $CMD "$SER" $AUT -t "$tid" --remove-and-delete 2>&1 | tee -a "$BASE_LOG"
  log "$FIL $tid is removed from $SER."
fi

# Adds torrent file name to torrent server.
# SC2086: Double quote to prevent globbing and word splitting.
# shellcheck disable=SC2086
$CMD "$SER" $AUT -a "$TOR" 2>&1 | tee -a "$BASE_LOG"

# Verifies that a torrent was added.
tid=$(tid)
if [ -z "$tid" ]; then
  die "Unable to find $FIL at $SER."
fi
log "$FIL $tid is added to $SER."
exit 0
