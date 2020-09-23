#!/bin/sh -e
# vi:ts=2 sw=2 tw=79 et lbr wrap
# Copyright 2020-current David Rabkin
# tru stands for Transmission Remote Updater. The script removes a torrent with
# content and than adds it again. It is usefull to automatically increase a
# ratio.

IAM=$(basename -- "$0")
IAM="${IAM%.*}"
LOG="/tmp/$IAM-log"
LCK="/tmp/$IAM-lck"
CMD='transmission-remote'

# Prints timestamp before arguments.
tim() {
  date +"%Y%m%d-%H:%M:%S $*"
}

# Information logger.
log() {
  tim "I $*" | tee -a "$LOG"
}

# Error logger.
loge() {
  tim "E $*" | tee -a "$LOG" 1>&2
}

# Prints error and exits.
die() {
  loge "$@"
  exit 1
}

# Checks if the command exists.
validate() {
  command -v "$1" >/dev/null 2>&1 || die "Install $1."
}

# Looks for torrent ID by torrent file name.
tid() {
  "$CMD" "$SER" -l | grep "$FIL" | awk '{print $1}'
}

# Start point.
validate 'nc'
validate 'tr'
validate 'awk'
validate "$CMD"

# Checks amount of parameters.
if [ "$#" -ne 2 ]; then
  die "Usage: $CMD [host:port] [filename]"
fi

# Prepares host and port to be nc command parameters. Validates the first
# parameter host:port.
prm="$(printf '%s' "$1" | tr ':' ' ')"
# shellcheck disable=SC2086
nc -z $prm >/dev/null 2>&1 || die "$1 is not valid parameter for [host:port]."
SER="$1"

# Validates second parameter full path name.
if [ ! -r "$2" ]; then
  die "$2 is not valid parameter for a torrent file."
fi
TOR="$2"
FIL=$(basename -- "$TOR")
FIL="${FIL%.*}"

# Prevents multiple instances.
if [ -e "$LCK" ] && kill -0 "$(cat "$LCK")"; then
  die "$IAM is already running."
fi

# Makes sure the lockfile is removed when we exit and then claim it.
# shellcheck disable=SC2064
trap "rm -f $LCK" INT TERM EXIT
echo $$ > "$LCK"
log "$IAM says hi."
tid=$(tid)
if [ -n "$tid" ]; then
  "$CMD" "$SER" -t "$tid" --remove-and-delete 2>&1 | tee -a "$LOG"
  log "$FIL $tid is removed from $SER."
fi
"$CMD" "$SER" -a "$TOR" 2>&1 | tee -a "$LOG"
tid=$(tid)
if [ -z "$tid" ]; then
  die "Unable to find $FIL at $SER."
fi
log "$FIL $tid is added to $SER."
log "$IAM says bye."
exit 0
