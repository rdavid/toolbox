#!/bin/sh -eu
# vi:ts=2 sw=2 tw=79 et lbr wrap
# Copyright 2020-current David Rabkin
# tru stands for Transmission Remote Updater. The script removes a torrent with
# content and than adds it again. It is usefull to automatically increase a
# ratio.

# shellcheck source=./base
. "$(dirname "$(realpath "$0")")/base"
CMD='transmission-remote'

# Looks for torrent ID by torrent file name.
tid() {
  $CMD "$SER" -l | grep "$FIL" | awk '{print $1}'
}

validate 'nc'
validate 'tr'
validate 'awk'
validate $CMD
[ "$#" -eq 2 ] || die "Usage: $BASE_IAM [host:port] [filename]"

# Prepares host and port to be nc command parameters. Validates the first
# parameter host:port.
prm="$(printf '%s' "$1" | tr ':' ' ')"
# shellcheck disable=SC2086
nc -z $prm >/dev/null 2>&1 || die "$1 is not valid parameter for [host:port]."
SER="$1"

# Validates second parameter full path name.
[ -r "$2" ] || die "$2 is not valid parameter for a torrent file."
TOR="$2"
FIL=$(basename -- "$TOR")
FIL="${FIL%.*}"

# Looks for torrent ID by torrent name extracted from torrent file name.
tid=$(tid)
if [ -n "$tid" ]; then
  $CMD "$SER" -t "$tid" --remove-and-delete 2>&1 | tee -a "$BASE_LOG"
  log "$FIL $tid is removed from $SER."
fi

# Adds torrent file name to torrent server.
$CMD "$SER" -a "$TOR" 2>&1 | tee -a "$BASE_LOG"

# Verifies that a torrent was added.
tid=$(tid)
if [ -z "$tid" ]; then
  die "Unable to find $FIL at $SER."
fi
log "$FIL $tid is added to $SER."
exit 0
